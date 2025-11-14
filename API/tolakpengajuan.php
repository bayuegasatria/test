<?php
require "config.php";
header('Content-Type: application/json');

require_once __DIR__ . '/vendor/autoload.php';
use Google\Auth\Credentials\ServiceAccountCredentials;

// =======================================================
// 🔹 Fungsi ambil Access Token dari Service Account
// =======================================================
function getAccessToken() {
    $keyPath = __DIR__ . '/key/service-account.json';

    if (!file_exists($keyPath)) {
        error_log("❌ File service-account.json tidak ditemukan di: $keyPath");
        return null;
    }

    try {
        $scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
        $credentials = new ServiceAccountCredentials($scopes, $keyPath);
        $token = $credentials->fetchAuthToken();

        if (isset($token['access_token'])) {
            return $token['access_token'];
        } else {
            error_log("❌ Gagal ambil access_token: " . json_encode($token));
            return null;
        }
    } catch (Exception $e) {
        error_log("❌ Exception saat ambil token: " . $e->getMessage());
        return null;
    }
}

// =======================================================
// 🔹 Fungsi Kirim Notifikasi ke Firebase Cloud Messaging
// =======================================================
function sendFCMNotification($token, $title, $body, $data = []) {
    $projectId = "bmn-bpom"; 
    $accessToken = getAccessToken();

    if (!$accessToken) {
        error_log("❌ Gagal mendapatkan access token.");
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
        error_log("⚠️ FCM CURL Error: " . curl_error($ch));
        curl_close($ch);
        return false;
    }

    curl_close($ch);
    error_log("📤 FCM Response ($httpCode): $result");

    return $httpCode === 200;
}

// =======================================================
// 🔹 Ambil data dari request
// =======================================================
$idPengajuan = intval($_POST['id_pengajuan'] ?? 0);
$catatan = $_POST['catatan'] ?? "";
$idUserLogin = intval($_POST['id_user_login'] ?? 0); // ✅ kirim dari frontend

if ($idPengajuan <= 0) {
    echo json_encode(["success" => false, "message" => "id_pengajuan kosong"]);
    exit;
}

// =======================================================
// 🔹 Cek apakah user login adalah pengelola kendaraan dinas
// =======================================================
$isPengelola = false;

if ($idUserLogin > 0) {
    $cekPetugas = $conn->prepare("SELECT jenis FROM petugas WHERE user_id = ?");
    $cekPetugas->bind_param("i", $idUserLogin);
    $cekPetugas->execute();
    $resultPetugas = $cekPetugas->get_result();

    if ($resultPetugas->num_rows > 0) {
        $rowPetugas = $resultPetugas->fetch_assoc();
        if (strtolower($rowPetugas['jenis']) === 'pengelola kendaraan dinas') {
            $isPengelola = true;
        }
    }
}

// =======================================================
// 🔹 Update status pengajuan jadi DITOLAK
// =======================================================
$sql = "UPDATE pengajuan SET status='N', catatan=? WHERE id=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $catatan, $idPengajuan);

if ($stmt->execute()) {

    // Ambil data user dari pengajuan
    $sqlPengajuan = "SELECT id_user FROM pengajuan WHERE id = ?";
    $stmtPengajuan = $conn->prepare($sqlPengajuan);
    $stmtPengajuan->bind_param("i", $idPengajuan);
    $stmtPengajuan->execute();
    $res = $stmtPengajuan->get_result();
    $row = $res->fetch_assoc();

    if (!$row) {
        echo json_encode(["success" => false, "message" => "Data pengajuan tidak ditemukan"]);
        exit;
    }

    $userId = $row['id_user'];

    // =======================================================
    // 🔹 Simpan notifikasi ke tabel notifikasi
    // =======================================================
    $judul = "Penolakan Pengajuan";
    $pesan = "Pengajuan anda ditolak. \nCatatan: $catatan";

    $sqlNotif = "INSERT INTO notifikasi(user_id, pengajuan_id, judul, pesan, is_read)
                 VALUES (?, ?, ?, ?, 'N')";
    $stmtNotif = $conn->prepare($sqlNotif);
    $stmtNotif->bind_param("iiss", $userId, $idPengajuan, $judul, $pesan);

    if ($stmtNotif->execute()) {

        // =======================================================
        // 🔹 Jika BUKAN pengelola kendaraan dinas → kirim FCM
        // =======================================================
        if (!$isPengelola) {
            $tokenQuery = "SELECT fcm_token FROM user_token WHERE user_id = ? ORDER BY updated_at DESC LIMIT 1";
            $stmtToken = $conn->prepare($tokenQuery);
            $stmtToken->bind_param("i", $userId);
            $stmtToken->execute();
            $tokenResult = $stmtToken->get_result();

            if ($tokenResult->num_rows === 0) {
                error_log("⚠️ Tidak ditemukan token FCM untuk user_id $userId");
            } else if ($tokenRow = $tokenResult->fetch_assoc()) {
                $fcmToken = trim($tokenRow['fcm_token']);
                if ($fcmToken !== "") {
                    if (function_exists('fastcgi_finish_request')) {
                        ignore_user_abort(true);
                        fastcgi_finish_request();
                    } else {
                        ignore_user_abort(true);
                        @ob_end_flush();
                        @flush();
                    }

                    sendFCMNotification(
                        $fcmToken,
                        $judul,
                        $pesan,
                        [
                            "screen" => "notifikasi",
                            "pengajuan_id" => (string)$idPengajuan
                        ]
                    );
                } else {
                    error_log("⚠️ fcm_token kosong untuk user_id $userId");
                }
            }

            echo json_encode(["success" => true, "message" => "Pengajuan ditolak dan notifikasi dikirim"]);
        } else {
            // ✅ Jika pengelola kendaraan dinas, tidak kirim FCM
            echo json_encode(["success" => true, "message" => "Pengajuan ditolak (tanpa FCM, pengelola kendaraan dinas)"]);
        }

    } else {
        echo json_encode(["success" => false, "message" => "Gagal simpan notifikasi: " . $stmtNotif->error]);
    }

} else {
    echo json_encode(["success" => false, "message" => "Gagal update pengajuan: " . $stmt->error]);
}
?>
