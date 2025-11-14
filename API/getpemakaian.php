<?php
require "config.php";

$carId = $_GET['carId'];
$bulan = $_GET['bulan'] ?? null;
$tahun = $_GET['tahun'] ?? null;

$sql = "
  SELECT 
      pjm.*,
      vr.no_pengajuan,
      vr.tanggal_berangkat,
      u.name AS nama_user,
      c.id,
      c.merk AS nama_kendaraan,
      vr.tujuan
  FROM pinjam pjm
  JOIN pengajuan vr ON pjm.id_pengajuan = vr.id
  JOIN users u ON vr.id_user = u.id
  JOIN car c ON pjm.id_kendaraan = c.id
  WHERE pjm.status = 'selesai' AND c.id = ?
";

// Filter berdasarkan bulan & tahun jika dikirim
if ($bulan && $tahun) {
    $sql .= " AND MONTH(pjm.tanggal_pengembalian) = ? AND YEAR(pjm.tanggal_pengembalian) = ?";
} elseif ($tahun) {
    $sql .= " AND YEAR(pjm.tanggal_pengembalian) = ?";
}

$sql .= " ORDER BY pjm.tanggal_pengembalian DESC";

$stmt = $conn->prepare($sql);

if ($bulan && $tahun) {
    $stmt->bind_param("iii", $carId, $bulan, $tahun);
} elseif ($tahun) {
    $stmt->bind_param("ii", $carId, $tahun);
} else {
    $stmt->bind_param("i", $carId);
}

$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
