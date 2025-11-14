<?php
require 'config.php';
header('Content-Type: application/json');

try {
    $query = "
        SELECT 
            p.id,
            p.no,
            p.tanggal,
            p.pelapor_id,
            p.inventaris_id,
            p.old_lokasi,
            p.new_lokasi,
            p.keterangan,
            p.created_at,
            p.updated_at,
            
            u.name AS nama_pelapor,
            inv.nama_barang,
            inv.kode_barang,
            inv.kode_bmn,
            inv.merk,
            j.nama AS jenis_barang,
            l_old.nama AS nama_lokasi_lama,
            l_new.nama AS nama_lokasi_baru
        FROM perpindahan_dbr p
        LEFT JOIN users u ON p.pelapor_id = u.id
        LEFT JOIN inventaris inv ON p.inventaris_id = inv.id
        LEFT JOIN jenis_barang j ON inv.jenis_barang = j.id
        LEFT JOIN lokasi l_old ON p.old_lokasi = l_old.id
        LEFT JOIN lokasi l_new ON p.new_lokasi = l_new.id
        ORDER BY p.id DESC
    ";

    $stmt = $conn->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode([
        'status' => 'success',
        'message' => 'Data perpindahan DBR berhasil diambil',
        'data' => $data
    ], JSON_PRETTY_PRINT);

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
