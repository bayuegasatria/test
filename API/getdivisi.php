<?php
require "config.php"; // koneksi ke DB

header('Content-Type: application/json; charset=utf-8');
date_default_timezone_set('Asia/Jakarta');

try {
    $query = "SELECT id, nama, lokasi, kode_sppd FROM divisi ORDER BY nama ASC";
    $result = $conn->query($query);

    $divisi = [];
    while ($row = $result->fetch_assoc()) {
        $divisi[] = [
            'id' => (int)$row['id'],
            'nama' => $row['nama'],
            'lokasi' => $row['lokasi'],
            'kode_sppd' => $row['kode_sppd'],
        ];
    }

    echo json_encode([
        'status' => 'success',
        'message' => 'Data divisi ditemukan',
        'data' => $divisi
    ]);
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Gagal mengambil data: ' . $e->getMessage()
    ]);
}
