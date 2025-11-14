<?php
require "config.php";

$id = $_GET['id'];

$sql = "
  SELECT vr.*, u.name AS nama 
  FROM pengajuan vr
  JOIN users u ON vr.id_user = u.id
  WHERE vr.id = ?
";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);
$stmt->execute();
$res = $stmt->get_result();

$data = $res->fetch_assoc();

if (!empty($data['file_path'])) {
    $baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http")
             . "://" . $_SERVER['HTTP_HOST']
             . rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
    $data['file_url'] = $baseUrl . '/' . $data['file_path'];
} else {
    $data['file_url'] = null;
}

echo json_encode($data);
?>
