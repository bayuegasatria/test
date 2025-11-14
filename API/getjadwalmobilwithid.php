<?php
require "config.php";

$now = $_GET['now']; 
$id = $_GET['id'];

$sql = "
    SELECT 
      p.id AS id_pinjam,
      vr.tanggal_berangkat,
      p.tanggal_pengembalian,
      vr.tanggal_kembali,
      p.status,
      CONCAT(m.merk, ' - ', m.police_number) AS nama_mobil,
      u.name AS nama_user,
      vr.no_pengajuan,
      vr.tujuan
    FROM pinjam p
    JOIN pengajuan vr ON p.id_pengajuan = vr.id
    JOIN car m ON p.id_kendaraan = m.id
    JOIN users u ON vr.id_user = u.id
    WHERE DATE(vr.tanggal_kembali) >= DATE(?) 
      AND (p.status = 'menunggu' OR  p.status = 'berjalan') AND m.id = ?
    ORDER BY vr.tanggal_berangkat ASC
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $now,$id);
$stmt->execute();
$result = $stmt->get_result();

$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
