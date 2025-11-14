<?php
require "config.php";

$userId  = isset($_POST['user_id']) ? intval($_POST['user_id']) : 0;
$notifId = isset($_POST['notif_id']) ? intval($_POST['notif_id']) : 0;

if ($userId <= 0) {
    echo json_encode(["success" => false, "message" => "User ID wajib ada"]);
    exit;
}

if ($notifId > 0) {
    // ✅ update 1 notifikasi tertentu
    $sql = "UPDATE notifikasi SET is_read='Y' WHERE id=? AND user_id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("ii", $notifId, $userId);
} else {
    // ✅ update semua notifikasi user
    $sql = "UPDATE notifikasi SET is_read='Y' WHERE user_id=?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $userId);
}

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false]);
}
?>
