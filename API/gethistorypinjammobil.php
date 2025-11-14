<?php
require "config.php";

$userId = $_GET['userId'];
$carId = $_GET['carId'];
$role   = $_GET['role'];

    $sql = "
      SELECT pjm.id,
             vr.no_pengajuan,
             u.name AS nama_user,
             pjm.id AS id_pinjam,
             pjm.tanggal_pengembalian,
             vr.tujuan,
             c.merk AS nama_kendaraan,
             pjm.km_awal,
             pjm.km_akhir,
             pjm.status
      FROM pinjam pjm
      JOIN pengajuan vr ON pjm.id_pengajuan = vr.id
      JOIN car c ON pjm.id_kendaraan = c.id
      JOIN users u ON vr.id_user = u.id
      WHERE (pjm.status = 'selesai' OR pjm.status = 'batal')
      AND c.id = ?
      ORDER BY pjm.tanggal_pengembalian DESC
    ";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i",$carId);
$stmt->execute();
$res = $stmt->get_result();

// }

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
