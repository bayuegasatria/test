<?php
require "config.php";

$berangkat = $_GET['berangkat'];
$kembali   = $_GET['kembali'];

// Tampilkan semua driver aktif, beri kolom status
$sql = "
  SELECT 
    d.*, 
    CASE 
      WHEN EXISTS (
        SELECT 1
        FROM pinjam p
        JOIN pengajuan vr ON p.id_pengajuan = vr.id
        WHERE p.id_supir = d.id
          AND p.id_supir IS NOT NULL
           AND ( p.status != 'selesai' AND p.status != 'batal'
          AND (
            vr.tanggal_berangkat <= ?
            AND vr.tanggal_kembali >=?
          ))
      )
      THEN 'dipinjam'
      ELSE 'ready'
    END AS status_pinjam
  FROM driver d
  WHERE d.aktif = 'Y'
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("ss", $kembali, $berangkat);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
