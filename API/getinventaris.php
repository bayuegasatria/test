<?php
require "config.php";
if (!isset($_GET['jenis_barang'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Parameter 'jenis_barang' diperlukan"
    ]);
    exit;
}

$jenis_barang = $_GET['jenis_barang'];

try {
    // 🔹 Query dengan parameter binding
    $query = "SELECT 
    i.id,
    i.nama_barang,
    i.kode_barang,
    i.harga,
    i.kode_bmn,
    i.jenis_barang,
    i.jumlah_barang,
    i.satuan_id,
    i.tanggal_diterima,
    i.merk,
    i.no_seri,
    i.lokasi,
    l.nama AS nama_lokasi,
    i.penanggung_jawab,
    u.id AS user_id,
    u.name AS nama_penanggungjawab,
    u.alamat AS alamat_penanggungjawab,
    u.no_pegawai AS nip,
    i.file_user_manual,
    i.file_trouble,
    i.file_ika,
    i.file_foto,
    i.status_barang,
    i.spesifikasi,
    i.created_at,
    i.updated_at,
    i.kind,
    i.deleted_at,
    i.link_video,
    i.file_sert,
    i.sinonim,
    i.file_evakali
FROM inventaris i
LEFT JOIN lokasi l ON i.lokasi = l.id
LEFT JOIN users u ON i.penanggung_jawab = u.id
WHERE i.jenis_barang = ? AND kind = 'R'

";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $jenis_barang);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    if (empty($data)) {
        echo json_encode([
            "status" => "empty",
            "message" => "Data inventaris tidak ditemukan untuk jenis_barang ini"
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "count" => count($data),
            "data" => $data
        ]);
    }

    $stmt->close();
    $conn->close();

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Terjadi kesalahan: " . $e->getMessage()
    ]);
}
?>
