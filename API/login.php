<?php
require "config.php";
require_once __DIR__ . '/vendor/autoload.php';

use Google\Auth\Credentials\ServiceAccountCredentials;

header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

// ==========================================================
// 🔹 Fungsi Ambil Access Token (Firebase Authentication)
// ==========================================================
function getAccessToken() {
    $SCOPES = ['https://www.googleapis.com/auth/firebase.messaging'];
    $KEY_PATH = __DIR__ . '/key/service-account.json'; // Pastikan path benar

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
// 🔹 Fungsi Kirim FCM Logout
// ==========================================================
function sendForceLogoutFCM($token, $userId) {
    $projectId = "bmn-bpom"; // Ganti sesuai project Firebase kamu
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
                "title" => "Anda Telah Logout",
                "body"  => "Akun Anda logout karena login di perangkat lain.",
            ],
            "data" => [
                "type" => "force_logout",
                "message" => "Akun Anda logout karena login di perangkat lain.",
                "user_id" => (string)$userId
            ]
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
    error_log("📤 FCM Logout Response ($httpCode): $result");
    return $httpCode === 200;
}

// ==========================================================
// 🔹 Ambil input login
// ==========================================================
$username   = $_POST['username'] ?? '';
$password   = $_POST['password'] ?? '';
$app_id     = $_POST['app_id'] ?? '';
$fcm_token  = $_POST['fcm_token'] ?? '';

if (empty($username) || empty($password) || empty($app_id)) {
    echo json_encode([
        "status" => "error",
        "message" => "Username, password, dan app_id wajib diisi."
    ]);
    exit;
}

// ==========================================================
// 🔹 Validasi user
// ==========================================================
$sql = "SELECT u.id, u.name AS nama, u.no_pegawai AS nip, u.deskjob, 
               u.password, d.nama AS nama_divisi, d.id AS divisi_id
        FROM users u
        JOIN divisi d ON u.divisi_id = d.id
        WHERE LOWER(TRIM(u.email)) = LOWER(TRIM(?))
        LIMIT 1";

$stmt = $conn->prepare($sql);
$stmt->bind_param("s", $username);
$stmt->execute();
$res = $stmt->get_result();

if (!$row = $res->fetch_assoc()) {
    echo json_encode(["status" => "error", "message" => "Username atau password salah"]);
    exit;
}

if (!password_verify($password, $row['password'])) {
    echo json_encode(["status" => "error", "message" => "Username atau password salah"]);
    exit;
}

$userId = $row['id'];

// ==========================================================
// 🔹 Cek session lain & kirim notifikasi logout (opsional)
// ==========================================================
$sqlCheck = "SELECT id, app_id, fcm_token FROM user_token WHERE user_id = ? AND login = 'Y'";
$stmtCheck = $conn->prepare($sqlCheck);
$stmtCheck->bind_param("i", $userId);
$stmtCheck->execute();
$existingSessions = $stmtCheck->get_result();

while ($old = $existingSessions->fetch_assoc()) {
    $oldToken = trim($old['fcm_token']);
    if ($oldToken !== "") {
        sendForceLogoutFCM($oldToken, $userId);
    }
}

// ==========================================================
// 🔹 Hapus semua session lama user sebelum membuat baru
// ==========================================================
$sqlDeleteOld = "DELETE FROM user_token WHERE user_id = ?";
$stmtDeleteOld = $conn->prepare($sqlDeleteOld);
$stmtDeleteOld->bind_param("i", $userId);
$stmtDeleteOld->execute();

// ==========================================================
// 🔹 Simpan session baru (bersih)
// ==========================================================
$sqlInsert = "
INSERT INTO user_token (user_id, app_id, fcm_token, login, updated_at)
VALUES (?, ?, ?, 'Y',NOW())";
$stmtInsert = $conn->prepare($sqlInsert);
$stmtInsert->bind_param("iss", $userId, $app_id, $fcm_token);
$stmtInsert->execute();

// ==========================================================
// 🔹 Ambil role user
// ==========================================================
$sqlRole = "SELECT jenis FROM petugas WHERE user_id = ? LIMIT 1";
$stmtRole = $conn->prepare($sqlRole);
$stmtRole->bind_param("i", $userId);
$stmtRole->execute();
$roleRes = $stmtRole->get_result();

$role = "Pegawai";
$namaRole = "Pegawai";

if ($roleRes->num_rows > 0) {
    $roleData = $roleRes->fetch_assoc();
    $namaRole = $roleData['jenis'];

    if ($namaRole === "Pengelola Kendaraan Dinas") {
        $role = "Admin";
    } elseif ($namaRole === "Petugas TIK") {
        $role = "AdminTIK";
    }
}

// ==========================================================
// 🔹 Response sukses
// ==========================================================
echo json_encode([
    "status" => "success",
    "message" => "Login berhasil",
    "user" => [
        "id" => $row['id'],
        "nama" => $row['nama'],
        "nip" => $row['nip'],
        "deskjob" => $row['deskjob'],
        "nama_divisi" => $row['nama_divisi'],
        "divisi_id" => $row['divisi_id'],
        "role" => $role,
        "nama_role" => $namaRole
    ]
]);

$conn->close();
?>
