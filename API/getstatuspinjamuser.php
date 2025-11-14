<?php
require "config.php";

$userId = $_GET['userId'];
$now    = $_GET['now'];

$sql = "
  SELECT p.id, vr.tanggal_berangkat, vr.tanggal_kembali, p.status,
         m.merk AS nama_mobil, vr.tujuan, u.name AS nama_user
  FROM pinjam p
  JOIN pengajuan vr ON p.id_pengajuan = vr.id
  JOIN users u ON vr.id_user = u.id
  JOIN car m ON p.id_kendaraan = m.id
  WHERE u.id = ? AND p.status != 'selesai' AND p.status != 'batal'
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i",  $userId);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
