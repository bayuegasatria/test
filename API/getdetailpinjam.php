<?php
require "config.php";
header('Content-Type: application/json');

$idPinjam = $_GET['idPinjam'] ?? 0;

if (!$idPinjam) {
    echo json_encode(["success" => false, "message" => "ID pinjam tidak valid."]);
    exit;
}

$sql = "
  SELECT 
      p.id AS id_pinjam, 
      p.status, 
      vr.tanggal_berangkat, 
      vr.tanggal_kembali, 
      p.tanggal_pengembalian,
      CONCAT(c.merk, ' - ', c.police_number) AS kendaraan,
      vr.no_pengajuan, 
      vr.tujuan, 
      u.name AS nama,

      CASE 
          WHEN p.id_supir IS NULL THEN vr.pengemudi
          ELSE d.name
      END AS nama_supir,
      
      p.km_awal,
      p.km_akhir,
      p.awal_path,
      p.awal_name,
      p.akhir_path,
      p.akhir_name

  FROM pinjam p
  JOIN pengajuan vr ON p.id_pengajuan = vr.id
  JOIN users u ON vr.id_user = u.id
  JOIN car c ON p.id_kendaraan = c.id
  LEFT JOIN driver d ON p.id_supir = d.id
  WHERE p.id = ?
";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Query gagal disiapkan: " . $conn->error]);
    exit;
}

$stmt->bind_param("i", $idPinjam);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Data pinjam tidak ditemukan."]);
    exit;
}

$data = $res->fetch_assoc();


// ======================================================
// 🔹 BASE URL DINAMIS (sama seperti API kedua)
// ======================================================
$baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http")
         . "://" . $_SERVER['HTTP_HOST']
         . rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');


// 🔹 Buat URL foto jika ada
if (!empty($data['awal_path'])) {
    $data['foto_km_awal_url'] = $baseUrl . '/' . $data['awal_path'];
}
if (!empty($data['akhir_path'])) {
    $data['foto_km_akhir_url'] = $baseUrl . '/' . $data['akhir_path'];
}

echo json_encode([
    "success" => true,
    "data" => $data
], JSON_PRETTY_PRINT);
?>
