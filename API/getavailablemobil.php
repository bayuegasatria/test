<?php
require "config.php";

$berangkat = $_GET['berangkat'];
$kembali   = $_GET['kembali'];
$type = $_GET['type'];  

// Query untuk menampilkan semua mobil + status
$sql = "
  SELECT 
    c.*, 
    CASE 
      WHEN EXISTS (
        SELECT 1
        FROM pinjam p
        JOIN pengajuan vr ON p.id_pengajuan = vr.id
        WHERE p.id_kendaraan = c.id
          AND ( p.status != 'selesai' AND p.status != 'batal'
          AND (
            vr.tanggal_berangkat <= ?
            AND vr.tanggal_kembali >=?
          ))
      )
      THEN 'dipinjam'
      ELSE 'ready'
    END AS status_pinjam
  FROM car c
  WHERE c.type = ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("sss", $kembali, $berangkat, $type);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
