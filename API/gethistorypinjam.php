<?php
require "config.php";

$userId = $_GET['userId'];


$sql = "
      SELECT pjm.id ,
             vr.no_pengajuan,
             pjm.id_pengajuan,
             pjm.id AS id_pinjam,
             u.name AS nama_user,
             pjm.tanggal_pengembalian,
             vr.tanggal_kembali,
             vr.tanggal_berangkat,
             vr.tujuan,
             c.merk AS nama_kendaraan,
             pjm.status
      FROM pinjam pjm
      JOIN pengajuan vr ON pjm.id_pengajuan = vr.id
      JOIN car c ON pjm.id_kendaraan = c.id
      JOIN users u ON vr.id_user = u.id
      WHERE (pjm.status = 'selesai' OR pjm.status = 'batal' )
        AND u.id = ?
      ORDER BY vr.no_pengajuan DESC
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
