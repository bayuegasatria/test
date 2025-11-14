<?php
echo "Script mulai...\n";
require "config.php";
require __DIR__ . '/vendor/autoload.php'; // autoload composer
use Google\Auth\Credentials\ServiceAccountCredentials;

date_default_timezone_set('Asia/Jakarta');

/**
 * Kirim notifikasi FCM ke user
 */
function sendFCMNotification($token, $title, $body, $data = []) {
    $projectId = "bmn-bpom"; // 🔸 Ganti sesuai Firebase Project ID kamu
    $keyFilePath = __DIR__ . "/key/service-account.json"; // 🔸 path service account

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

// =======================================================
// 🔹 Ambil semua pengajuan yang harus diubah status otomatis
// =======================================================


$query = "
    SELECT id, id_user, no_pengajuan, tujuan
    FROM pengajuan
    WHERE status = 'P'
      AND tanggal_kembali <= NOW()
";

$stmt = $conn->prepare($query);
$stmt->execute();
$result = $stmt->get_result();

if ($result && $result->num_rows > 0) {
    $updatedCount = 0;

    while ($row = $result->fetch_assoc()) {
        $idPengajuan = $row['id'];
        $idUser = $row['id_user'];
        $noPengajuan = $row['no_pengajuan'];
        $tujuan = $row['tujuan'];

        // 🔸 Update status pengajuan jadi 'N'
        $update = $conn->prepare("
            UPDATE pengajuan
            SET status = 'N'
            WHERE id = ?
        ");
        $update->bind_param("i", $idPengajuan);
        $update->execute();

        if ($update->affected_rows > 0) {
            $updatedCount++;

            $judul = "Pengajuan Dibatalkan Otomatis";
            $pesan = "Pengajuan dengan nomor $noPengajuan \ntujuan $tujuan \ndibatalkan otomatis karena waktu persetujuan telah lewat.";

            $notif = $conn->prepare("
                INSERT INTO notifikasi (user_id, pengajuan_id, judul, pesan, is_read)
                VALUES (?, ?, ?, ?, 'N')
            ");
            $notif->bind_param("iiss", $idUser, $idPengajuan, $judul, $pesan);
            $notif->execute();

            $tokenQuery = $conn->prepare("
                SELECT fcm_token 
                FROM user_token 
                WHERE user_id = ? 
                ORDER BY updated_at DESC 
                LIMIT 1
            ");
            $tokenQuery->bind_param("i", $idUser);
            $tokenQuery->execute();
            $tokenResult = $tokenQuery->get_result();

            if ($tokenResult && $tokenRow = $tokenResult->fetch_assoc()) {
                $fcmToken = trim($tokenRow['fcm_token']);
                if ($fcmToken !== "") {
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
                    error_log("⚠️ fcm_token kosong untuk user_id $idUser");
                }
            } else {
                error_log("ℹ️ Tidak ada token aktif untuk user_id $idUser");
            }
        }
    }

    echo json_encode([
        "success" => true,
        "message" => "Scheduler pengajuan selesai dijalankan.",
        "rows_updated" => $updatedCount,
       
    ]);
} else {
    echo json_encode([
        "success" => true,
        "message" => "Tidak ada pengajuan yang perlu dibatalkan otomatis.",
      
    ]);
}

$conn->close();
?>
