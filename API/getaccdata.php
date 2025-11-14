<?php
require "config.php";

$role   = $_GET['role'];
$userId = $_GET['userId'];

if ($role != "Admin") {
    $sql = "
      SELECT vr.*, u.name AS nama 
      FROM pengajuan vr
      JOIN users u ON vr.id_user = u.id
      WHERE vr.id_user = ? AND vr.status != 'C'
      ORDER BY vr.id DESC
    ";
    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        die('Prepare failed: ' . $conn->error);
    }
    $stmt->bind_param("i", $userId);
    $stmt->execute();
    $res = $stmt->get_result();
}
 else  {
    $sql = "
      SELECT vr.*, u.name AS nama 
      FROM pengajuan vr
      JOIN users u ON vr.id_user = u.id
      WHERE vr.status != 'C'
      ORDER BY vr.id DESC
    ";
    $res = $conn->query($sql);
}

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
