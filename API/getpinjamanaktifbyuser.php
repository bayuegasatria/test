<?php
require "config.php";

$userId = $_GET['userId'];

$sql = "
  SELECT 
    vr.id,
    vr.id_user,
    vr.status AS status_pengajuan,
    p.status AS status_pinjam
  FROM pengajuan vr
  LEFT JOIN pinjam p ON vr.id = p.id_pengajuan
  WHERE vr.id_user = ?
    AND (
      vr.status = 'P'
      OR (p.status IS NOT NULL AND p.status != 'selesai' OR p.status != 'batal')
    )
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $userId);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);
?>
