<?php
ini_set('display_errors', 1);
error_reporting(E_ALL);

header('Content-Type: application/json');
require "config.php";
require __DIR__ . '/vendor/autoload.php';

use Google\Auth\Credentials\ServiceAccountCredentials;

date_default_timezone_set('Asia/Jakarta');

$response = [];


function sendFCMNotification($token, $title, $body, $data = []) {
    $projectId = "bmn-bpom";
    $keyFilePath = __DIR__ . "/key/service-account.json"; 

    $scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    $credentials = new ServiceAccountCredentials($scopes, $keyFilePath);

    $accessTokenData = $credentials->fetchAuthToken();
    $accessToken = $accessTokenData['access_token'] ?? null;

    if (!$accessToken) {
        error_log("❌ Gagal mendapatkan access token FCM");
        return false;
    }

    $url = "https://fcm.googleapis.com/v1/projects/$projectId/messages:send";
    $payload = [
        "message" => [
            "token" => $token,
            "notification" => [
                "title" => $title,
                "body"  => $body
            ],
            "data" => $data
        ]
    ];

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => [
            "Authorization: Bearer $accessToken",
            "Content-Type: application/json"
        ],
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POSTFIELDS => json_encode($payload),
        CURLOPT_CONNECTTIMEOUT => 5,
        CURLOPT_TIMEOUT => 10
    ]);

    $result = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

    if (curl_errno($ch)) {
        error_log("⚠️ FCM Error: " . curl_error($ch));
    } else {
        error_log("📤 FCM Response ($httpCode): $result");
    }

    curl_close($ch);
    return $httpCode === 200;
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $id_user          = $_POST['id_user'] ?? '';
    $no_pengajuan     = $_POST['no_pengajuan'] ?? '';
    $tujuan           = $_POST['tujuan'] ?? '';
    $jenis_kendaraan  = $_POST['jenis_kendaraan'] ?? '';
    $perlu_supir      = $_POST['perlu_supir'] ?? '';
    $pengemudi        = $_POST['pengemudi'] ?? '';
    $tanggal_berangkat = $_POST['tanggal_berangkat'] ?? '';
    $tanggal_kembali   = $_POST['tanggal_kembali'] ?? '';
    $jumlah_pengguna   = $_POST['jumlah_pengguna'] ?? '';
    $keterangan        = $_POST['keterangan'] ?? '';
    $status            = $_POST['status'] ?? '';

    $file_path = null;
    $file_name = null;


    if (isset($_FILES['file']) && $_FILES['file']['error'] === UPLOAD_ERR_OK) {
        $uploadDir = __DIR__ . "/uploads/pengajuan/";
        if (!is_dir($uploadDir)) mkdir($uploadDir, 0777, true);

        $originalFileName = basename($_FILES['file']['name']);
        $uniqueFileName = time() . '_' . $originalFileName;
        $targetPath = $uploadDir . $uniqueFileName;

        if (move_uploaded_file($_FILES['file']['tmp_name'], $targetPath)) {
            $file_path = "uploads/pengajuan/" . $uniqueFileName;
            $file_name = $originalFileName;
            error_log("📁 File berhasil diupload: $file_path");
        } else {
            error_log("❌ Gagal memindahkan file upload.");
        }
    } else {
        error_log("ℹ️ Tidak ada file yang diupload atau terjadi error upload.");
    }

    $stmt = $conn->prepare("
        INSERT INTO pengajuan (
            id_user, no_pengajuan, tujuan, jenis_kendaraan, perlu_supir, pengemudi,
            tanggal_berangkat, tanggal_kembali, jumlah_pengguna, keterangan, status,
            file_path, file_name
        )
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    $stmt->bind_param(
        "issssssssssss",
        $id_user,
        $no_pengajuan,
        $tujuan,
        $jenis_kendaraan,
        $perlu_supir,
        $pengemudi,
        $tanggal_berangkat,
        $tanggal_kembali,
        $jumlah_pengguna,
        $keterangan,
        $status,
        $file_path,
        $file_name
    );

    if (!$stmt->execute()) {
        $response = [
            "success" => false,
            "message" => "❌ Gagal menyimpan pengajuan: " . $stmt->error
        ];
        echo json_encode($response, JSON_PRETTY_PRINT);
        exit;
    }

    $pengajuan_id = $conn->insert_id;
    error_log("✅ Pengajuan baru tersimpan dengan ID: $pengajuan_id");

    // =======================================================
    // 🔹 Kirim notifikasi ke semua petugas Pengelola Kendaraan
    // =======================================================
    $petugasQuery = $conn->prepare("SELECT user_id FROM petugas WHERE jenis = 'Pengelola Kendaraan Dinas'");
    $petugasQuery->execute();
    $petugasResult = $petugasQuery->get_result();

    if ($petugasResult && $petugasResult->num_rows > 0) {
        while ($row = $petugasResult->fetch_assoc()) {
            $user_id_petugas = $row['user_id'];
            $judul = "Pengajuan Baru";
            $pesan = "Pengajuan dengan nomor $no_pengajuan telah dibuat.";

            // Simpan notifikasi
            $notif = $conn->prepare("
                INSERT INTO notifikasi (user_id, pengajuan_id, judul, pesan, is_read)
                VALUES (?, ?, ?, ?, 'N')
            ");
            $notif->bind_param("iiss", $user_id_petugas, $pengajuan_id, $judul, $pesan);
            $notif->execute();

            // Ambil token FCM user petugas
            $tokenQuery = $conn->prepare("
                SELECT fcm_token
                FROM user_token
                WHERE user_id = ?
                ORDER BY updated_at DESC
                LIMIT 1
            ");
            $tokenQuery->bind_param("i", $user_id_petugas);
            $tokenQuery->execute();
            $tokenResult = $tokenQuery->get_result();

            if ($tokenResult && $tokenRow = $tokenResult->fetch_assoc()) {
                $fcmToken = trim($tokenRow['fcm_token']);
                if ($fcmToken !== "") {
                    error_log("📱 Mengirim FCM ke user_id=$user_id_petugas token=$fcmToken");
                    sendFCMNotification(
                        $fcmToken,
                        $judul,
                        $pesan,
                        [
                            "screen" => "notifikasi",
                            "pengajuan_id" => (string)$pengajuan_id
                        ]
                    );
                } else {
                    error_log("⚠️ Token FCM kosong untuk user_id=$user_id_petugas");
                }
            } else {
                error_log("⚠️ Tidak ditemukan token untuk user_id=$user_id_petugas");
            }
        }
    } else {
        error_log("⚠️ Tidak ada petugas dengan jenis 'Pengelola Kendaraan Dinas'");
    }

    $response = [
        "success" => true,
        "message" => "pengajuan berhasil disimpan",
        "file_uploaded" => $file_path ? true : false,
        "file_path" => $file_path,
        "file_name" => $file_name
    ];

    $stmt->close();
    $conn->close();

} else {
    $response = [
        "success" => false,
        "message" => "❌ Metode request tidak valid. Gunakan POST."
    ];
}

echo json_encode($response, JSON_PRETTY_PRINT);
?>
