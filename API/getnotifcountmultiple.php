<?php
require "config.php";

$statuses = isset($_GET['statuses']) ? explode(",", $_GET['statuses']) : [];
$userId   = isset($_GET['userId']) ? intval($_GET['userId']) : 0;

if (empty($statuses)) {
    echo json_encode(["count" => 0]);
    exit;
}

// Buat placeholder "?, ?, ?" sesuai jumlah status
$placeholders = implode(",", array_fill(0, count($statuses), "?"));

// Buat string tipe: semua status = "s", userId = "i"
$types = str_repeat("s", count($statuses)) . "i";

$sql = "
  SELECT COUNT(*) as count 
  FROM pengajuan 
  WHERE status IN ($placeholders) 
    AND id_user = ? 
    AND dibaca = 'N'
";

$stmt = $conn->prepare($sql);

// Gabungkan array statuses + userId
$params = array_merge($statuses, [$userId]);

// Karena bind_param tidak terima array langsung, harus pakai call_user_func_array
$stmt->bind_param($types, ...$params);

$stmt->execute();
$res = $stmt->get_result();
$row = $res->fetch_assoc();

echo json_encode($row);
?>
