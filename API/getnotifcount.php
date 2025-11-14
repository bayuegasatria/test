<?php
require "config.php";

// ambil user_id dari parameter
$userId = $_GET['user_id'];

// hitung notifikasi yang belum terbaca (is_read = 'N')
$sql = "SELECT COUNT(*) as total FROM notifikasi WHERE user_id = ? AND is_read = 'N'";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$res = $stmt->get_result();
$row = $res->fetch_assoc();

echo json_encode($row);
?>
