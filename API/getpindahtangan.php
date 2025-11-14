<?php
require 'config.php';

header('Content-Type: application/json');

try {
    $query = "
    SELECT 
        p.id,
        p.nomor,
        p.tanggal,
        p.kelompok,
        p.inventaris_id,
        p.asal_id,
        p.baru_id,
        p.lokasi_baru,
        p.alamat_lama,
        p.alamat_baru,
        p.ket,
        p.created_at,
        p.updated_at,

        inv.nama_barang,
        inv.kode_barang,
        inv.merk,

        u_asal.name AS nama_pemilik_old,
        u_asal.alamat AS alamat_old,

        u_baru.name AS nama_pemilik_new,
        u_baru.alamat AS alamat_new,

        l_old.nama AS nama_lokasi_lama,
        l_new.nama AS nama_lokasi_baru
    FROM pindahtangan p
    LEFT JOIN inventaris inv ON p.inventaris_id = inv.id
    LEFT JOIN users u_asal ON p.asal_id = u_asal.id
    LEFT JOIN users u_baru ON p.baru_id = u_baru.id
    LEFT JOIN lokasi l_old ON inv.lokasi = l_old.id       -- lokasi lama
    LEFT JOIN lokasi l_new ON p.lokasi_baru = l_new.id     -- lokasi baru
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
        'message' => 'Data pindahtangan berhasil diambil',
        'data' => $data
    ], JSON_PRETTY_PRINT);
    
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
