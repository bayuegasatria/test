<?php
require "config.php";

$sql = "
  SELECT 
      c.id,
      c.code AS nomor_inventaris,
      c.merk,
      c.type AS tipe,
      c.police_number AS da,
      CASE 
          WHEN 
              MAX(
                CASE 
                  WHEN p.id IS NOT NULL AND (p.status != 'selesai' AND p.status != 'batal') AND (
                      NOW() BETWEEN vr.tanggal_berangkat AND vr.tanggal_kembali
                      OR NOW() > vr.tanggal_kembali
                  )
                  THEN 1 ELSE 0
                END
              ) = 1
              THEN 'Dipakai'
          ELSE 'Ready'
      END AS status,
      MAX(vr.tanggal_berangkat) AS tanggal_berangkat,
      MAX(vr.tanggal_kembali) AS tanggal_kembali
  FROM car c
  LEFT JOIN pinjam p ON c.id = p.id_kendaraan
  LEFT JOIN pengajuan vr ON vr.id = p.id_pengajuan
  GROUP BY c.id, c.code, c.merk, c.type, c.police_number
";

$stmt = $conn->prepare($sql);
$stmt->execute();
$res = $stmt->get_result();

$data = [];
while ($row = $res->fetch_assoc()) {
   
    $row['id'] = (int)$row['id'];
    $data[] = $row;
}

echo json_encode($data);
?>
