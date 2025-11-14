<?php
require "config.php";
require_once __DIR__ . '/vendor/autoload.php';

use Google\Auth\Credentials\ServiceAccountCredentials;

header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

// ==========================================================
// 🔹 Fungsi Ambil Access Token
// ==========================================================
function getAccessToken() {
    $SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];
    $KEY_PATH = __DIR__ . '/key/service-account.json';

    try {
        $credentials = new ServiceAccountCredentials($SCOPES, $KEY_PATH);
        $tokenData = $credentials->fetchAuthToken();
        return $tokenData['access_token'] ?? null;
    } catch (Exception $e) {
        error_log("❌ Gagal ambil access token: " . $e->getMessage());
        return null;
    }
}

// ==========================================================
// 🔹 Fungsi Kirim Notifikasi FCM
// ==========================================================
function sendFCMNotification($token, $title, $body, $data = []) {
    $projectId = "bmn-bpom";
    $accessToken = getAccessToken();

    if (!$accessToken) {
        error_log("❌ Gagal ambil Access Token dari Google Auth");
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

// ==========================================================
// 🔹 Ambil data dari POST
// ==========================================================
$idPengajuan  = intval($_POST['id_pengajuan'] ?? 0);
$idMobil      = intval($_POST['idMobil'] ?? 0);
$idSupir      = intval($_POST['idSupir'] ?? 0);
$catatan      = $_POST['catatan'] ?? "";
$idUserLogin  = intval($_POST['id_user_login'] ?? 0);

if ($idPengajuan <= 0) {
    echo json_encode(["success" => false, "message" => "id_pengajuan kosong"]);
    exit;
}

// ==========================================================
// 🔹 Cek apakah user login pengelola kendaraan dinas
// ==========================================================
$isPengelola = false;

if ($idUserLogin > 0) {
    $cekPetugas = $conn->prepare("SELECT jenis FROM petugas WHERE user_id = ?");
    $cekPetugas->bind_param("i", $idUserLogin);
    $cekPetugas->execute();
    $resultPetugas = $cekPetugas->get_result();

    if ($resultPetugas && $rowPetugas = $resultPetugas->fetch_assoc()) {
        if (strtolower($rowPetugas['jenis']) === 'pengelola kendaraan dinas') {
            $isPengelola = true;
        }
    }
}

// ==========================================================
// 🔹 Update status pengajuan
// ==========================================================
$update = $conn->prepare("UPDATE pengajuan SET status='Y', catatan=? WHERE id=?");
$update->bind_param("si", $catatan, $idPengajuan);
if (!$update->execute()) {
    echo json_encode(["success" => false, "message" => "Gagal update pengajuan: " . $update->error]);
    exit;
}

// ==========================================================
// 🔹 Ambil data pengajuan untuk referensi user
// ==========================================================
$getPengajuan = $conn->prepare("SELECT tanggal_berangkat, tanggal_kembali, id_user FROM pengajuan WHERE id = ?");
$getPengajuan->bind_param("i", $idPengajuan);
$getPengajuan->execute();
$res = $getPengajuan->get_result();
$row = $res->fetch_assoc();

if (!$row) {
    echo json_encode(["success" => false, "message" => "Data pengajuan tidak ditemukan"]);
    exit;
}

$userId = intval($row['id_user']);

// ==========================================================
// 🔹 Insert ke tabel pinjam (handle tanpa supir)
// ==========================================================
if ($idSupir > 0) {
    // ✅ Dengan supir
    $insertPinjam = $conn->prepare("
        INSERT INTO pinjam (id_pengajuan, tanggal_pengembalian, id_kendaraan, id_supir, status)
        VALUES (?, NULL, ?, ?, 'menunggu')
    ");
    $insertPinjam->bind_param("iii", $idPengajuan, $idMobil, $idSupir);
} else {
    // ✅ Tanpa supir
    $insertPinjam = $conn->prepare("
        INSERT INTO pinjam (id_pengajuan, tanggal_pengembalian, id_kendaraan, status)
        VALUES (?, NULL, ?, 'menunggu')
    ");
    $insertPinjam->bind_param("ii", $idPengajuan, $idMobil);
}

if (!$insertPinjam->execute()) {
    echo json_encode(["success" => false, "message" => "Gagal insert ke pinjam: " . $insertPinjam->error]);
    exit;
}

// ==========================================================
// 🔹 Simpan notifikasi ke DB
// ==========================================================
$judul = "Persetujuan Pengajuan";
$pesan = "Pengajuan anda telah disetujui.";

$insertNotif = $conn->prepare("
    INSERT INTO notifikasi (user_id, pengajuan_id, judul, pesan, is_read)
    VALUES (?, ?, ?, ?, 'N')
");
$insertNotif->bind_param("iiss", $userId, $idPengajuan, $judul, $pesan);
$insertNotif->execute();

// ==========================================================
// 🔹 Kirim FCM (jika bukan pengelola kendaraan dinas)
// ==========================================================
if ($idUserLogin != $userId) {
    $tokenStmt = $conn->prepare("
        SELECT fcm_token 
        FROM user_token 
        WHERE user_id = ? 
        ORDER BY updated_at DESC 
        LIMIT 1
    ");
    $tokenStmt->bind_param("i", $userId);
    $tokenStmt->execute();
    $tokenResult = $tokenStmt->get_result();

    if ($tokenResult && $tokenRow = $tokenResult->fetch_assoc()) {
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
    } else {
        error_log("⚠️ Tidak ditemukan token FCM untuk user_id $userId");
    }

    echo json_encode(["success" => true, "message" => "Pengajuan disetujui dan notifikasi dikirim"]);
} else {
    echo json_encode(["success" => true, "message" => "Pengajuan disetujui (tanpa FCM, pengelola kendaraan dinas)"]);
}

// ==========================================================
// 🔹 Tutup koneksi
// ==========================================================
$conn->close();
?>
