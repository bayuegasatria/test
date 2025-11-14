<?php
echo "Script mulai...\n";
require "config.php";
require __DIR__ . '/vendor/autoload.php';
use Google\Auth\Credentials\ServiceAccountCredentials;

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


$query = "
    SELECT p.id, p.id_pengajuan, g.id_user, g.no_pengajuan, g.tujuan, g.tanggal_berangkat
    FROM pinjam p
    INNER JOIN pengajuan g ON p.id_pengajuan = g.id
    WHERE p.status = 'menunggu'
      AND g.tanggal_berangkat <= NOW()
";

$result = $conn->query($query);

if ($result && $result->num_rows > 0) {
    $updatedCount = 0;

    while ($row = $result->fetch_assoc()) {
        $idPinjam = $row['id'];
        $idUser = $row['id_user'];
        $idPengajuan = $row['id_pengajuan'];
        $noPengajuan = $row['no_pengajuan'];
        $tujuan = $row['tujuan'];

        // Ubah status menjadi "berjalan"
        $update = $conn->prepare("
            UPDATE pinjam 
            SET status = 'berjalan'
            WHERE id = ?
        ");
        $update->bind_param("i", $idPinjam);
        $update->execute();

        if ($update->affected_rows > 0) {
            $updatedCount++;

            $judul = "Pinjaman Dimulai";
            $pesan = "Pinjaman dengan nomor $noPengajuan \nuntuk tujuan $tujuan \ntelah dimulai.";

            // Simpan ke tabel notifikasi
            $notif = $conn->prepare("
                INSERT INTO notifikasi (user_id, pengajuan_id, judul, pesan, is_read)
                VALUES (?, ?, ?, ?, 'N')
            ");
            $notif->bind_param("iiss", $idUser, $idPengajuan, $judul, $pesan);
            $notif->execute();

            // Ambil token FCM user
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
        "message" => "Scheduler auto mulai selesai dijalankan.",
        "rows_updated" => $updatedCount
    ]);
} else {
    echo json_encode([
        "success" => true,
        "message" => "Tidak ada pinjaman yang perlu dimulai otomatis."
    ]);
}

$conn->close();
?>
