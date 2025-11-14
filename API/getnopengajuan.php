<?php
require "config.php";
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

try {
    // Ambil bulan & tahun sekarang
    $bulan = date('m');
    $tahun = date('Y');

    // 🔹 Ambil nomor terakhir di bulan & tahun yang sama
    $sql = "SELECT no_pengajuan 
            FROM pengajuan 
            WHERE no_pengajuan LIKE ? 
            ORDER BY id DESC 
            LIMIT 1";

    $likePattern = "%/PKB/BBPOM/$bulan/$tahun";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("s", $likePattern);
    $stmt->execute();
    $result = $stmt->get_result();

    $lastNumber = 0;

    if ($row = $result->fetch_assoc()) {
        // Ambil 3 digit pertama sebelum tanda '/'
        $parts = explode('/', $row['no_pengajuan']);
        if (!empty($parts[0]) && is_numeric($parts[0])) {
            $lastNumber = intval($parts[0]);
        }
    }

    // 🔹 Nomor baru
    $newNumber = str_pad($lastNumber + 1, 3, '0', STR_PAD_LEFT);

    // 🔹 Bentuk format lengkap
    $no_pengajuan = "$newNumber/PKB/BBPOM/$bulan/$tahun";

    // 🔹 Kirim hasil JSON
    echo json_encode([
        'status' => 'success',
        'no_pengajuan' => $no_pengajuan
    ]);
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
