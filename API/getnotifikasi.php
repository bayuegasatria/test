<?php
require "config.php";

// ambil user_id dari parameter
$userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

if ($userId <= 0) {
    echo json_encode(["success" => false, "message" => "User ID wajib ada"]);
    exit;
}

// Ambil notifikasi belum terbaca
$sql = "SELECT n.id, n.user_id,n.pengajuan_id, n.judul, n.pesan, n.is_read, n.created_at ,pg.status AS status_pengajuan
        FROM notifikasi n
        JOIN pengajuan pg ON n.pengajuan_id = pg.id
        WHERE user_id = ? AND is_read = 'N'
        ORDER BY created_at DESC";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$res = $stmt->get_result();

$notifs = [];
while ($row = $res->fetch_assoc()) {
    $notifs[] = $row;
}

echo json_encode([
    "success" => true,
    "data" => $notifs
]);
?>
