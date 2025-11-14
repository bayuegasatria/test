<?php
require "config.php";
require_once __DIR__ . '/vendor/autoload.php';

use Google\Auth\Credentials\ServiceAccountCredentials;

header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

// ==========================================================
// 🔹 Fungsi Ambil Access Token (dari referensi)
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
// 🔹 Fungsi Kirim Notifikasi FCM (dari referensi)
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
// 🔹 Ambil input
// ==========================================================
$idPengajuan = intval($_POST['id_pengajuan'] ?? 0);
$idMobil     = intval($_POST['idMobil'] ?? 0);
$idSupir     = $_POST['idSupir'] !== "" ? intval($_POST['idSupir']) : null;
$idUserLogin = intval($_POST['idUserLogin'] ?? 0);
$catatan     = $_POST['catatan'] ?? "";
$pengemudi   = trim($_POST['pengemudi'] ?? "");

if ($idPengajuan <= 0) {
    echo json_encode(["success" => false, "message" => "id_pengajuan kosong"]);
    exit;
}
if ($idMobil <= 0) {
    echo json_encode(["success" => false, "message" => "idMobil kosong"]);
    exit;
}

// ==========================================================
// 🔹 Update tabel pengajuan
// ==========================================================
if ($idSupir !== null && $idSupir > 0) {
    // ✅ Dengan supir → pengemudi dikosongkan
    $update = $conn->prepare("
        UPDATE pengajuan 
        SET status='Y', catatan=?, pengemudi=NULL 
        WHERE id=?
    ");
    $update->bind_param("si", $catatan, $idPengajuan);
} else {
    // ✅ Tanpa supir → isi kolom pengemudi
    $update = $conn->prepare("
        UPDATE pengajuan 
        SET status='Y', catatan=?, pengemudi=? 
        WHERE id=?
    ");
    $update->bind_param("ssi", $catatan, $pengemudi, $idPengajuan);
}

if (!$update->execute()) {
    echo json_encode(["success" => false, "message" => "Gagal update pengajuan: " . $update->error]);
    exit;
}

// ==========================================================
// 🔹 Update tabel pinjam (bukan insert) — sesuai permintaan awal
// ==========================================================
if ($idSupir !== null && $idSupir > 0) {
    // ✅ Dengan supir
    $updatePinjam = $conn->prepare("
        UPDATE pinjam 
        SET id_kendaraan=?, id_supir=? 
        WHERE id_pengajuan=?
    ");
    $updatePinjam->bind_param("iii", $idMobil, $idSupir, $idPengajuan);
} else {
    // ✅ Tanpa supir
    $updatePinjam = $conn->prepare("
        UPDATE pinjam 
        SET id_kendaraan=?, id_supir=NULL 
        WHERE id_pengajuan=?
    ");
    $updatePinjam->bind_param("ii", $idMobil, $idPengajuan);
}

if (!$updatePinjam->execute()) {
    echo json_encode(["success" => false, "message" => "Gagal update pinjam: " . $updatePinjam->error]);
    exit;
}

$getPengajuan = $conn->prepare("SELECT id_user FROM pengajuan WHERE id = ?");
$getPengajuan->bind_param("i", $idPengajuan);
$getPengajuan->execute();
$resPengajuan = $getPengajuan->get_result();
$rowPengajuan = $resPengajuan->fetch_assoc();

if (!$rowPengajuan) {
    // Meskipun update berhasil, jika data pengajuan hilang, tetap laporkan sukses update tapi beri catatan
    echo json_encode(["success" => true, "message" => "Pengajuan berhasil disetujui dan data pinjam diperbarui. Namun data pengajuan tidak ditemukan untuk notifikasi."]);
    $conn->close();
    exit;
}

$userId = intval($rowPengajuan['id_user']);

$judul = "Pengubahan Data Pengajuan";
$pesan = "Pengubahan Data Pengajuan Anda Sudah Selesai.";

$insertNotif = $conn->prepare("
    INSERT INTO notifikasi (user_id, pengajuan_id, judul, pesan, is_read)
    VALUES (?, ?, ?, ?, 'N')
");
$insertNotif->bind_param("iiss", $userId, $idPengajuan, $judul, $pesan);
if (!$insertNotif->execute()) {
    error_log("⚠️ Gagal insert notifikasi: " . $insertNotif->error);
}

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

    echo json_encode(["success" => true, "message" => "Pengajuan berhasil disetujui, data pinjam diperbarui, notifikasi disimpan dan FCM dikirim (jika token ada)."]);
} else {
    echo json_encode(["success" => true, "message" => "Pengajuan berhasil disetujui dan data pinjam diperbarui. Notifikasi disimpan (tanpa FCM karena pengelola/pengaju sama)."]);
}

$conn->close();
?>
