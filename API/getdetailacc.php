<?php
require "config.php";
header('Content-Type: application/json');

$id = $_GET['id'] ?? 0;
if (!$id) {
    echo json_encode(["success" => false, "message" => "ID pengajuan tidak valid."]);
    exit;
}

$sql = "
    SELECT 
      vr.id,
      vr.no_pengajuan,
      vr.tujuan,
      vr.tanggal_berangkat,
      vr.tanggal_kembali,
      vr.catatan,
      vr.status,
      vr.perlu_supir,
      vr.pengemudi,
      vr.file_path,
      vr.file_name,
      vr.jenis_kendaraan,
      u.name AS nama,
      p.id_kendaraan,
      p.id_supir,
      CONCAT(c.merk, ' (', c.police_number, ')') AS nama_kendaraan,
      -- 🔹 Jika id_supir NULL ambil dari pengemudi (pengajuan)
      CASE 
          WHEN p.id_supir IS NULL THEN vr.pengemudi
          ELSE d.name
      END AS nama_supir
    FROM pengajuan vr
    JOIN pinjam p ON vr.id = p.id_pengajuan
    JOIN users u ON vr.id_user = u.id
    JOIN car c ON p.id_kendaraan = c.id
    LEFT JOIN driver d ON p.id_supir = d.id
    WHERE vr.id = ?
";

$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);
$stmt->execute();
$res = $stmt->get_result();

if ($res->num_rows === 0) {
    echo json_encode(["success" => false, "message" => "Data tidak ditemukan."]);
    exit;
}

$data = $res->fetch_assoc();

// 🔹 Cek file_path dan buat pesan sesuai kondisi
if (!empty($data['file_path'])) {
    $baseUrl = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? "https" : "http")
             . "://" . $_SERVER['HTTP_HOST']
             . rtrim(dirname($_SERVER['SCRIPT_NAME']), '/');
    $data['file_url'] = $baseUrl . '/' . $data['file_path'];
    $message = "File ditemukan: " . $data['file_url'];
} else {
    $data['file_url'] = null;
    $message = "File tidak ada.";
}

echo json_encode([
    "success" => true,
    "message" => $message,
    "data" => $data
], JSON_PRETTY_PRINT);
?>
