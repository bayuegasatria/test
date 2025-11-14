<?php
require "config.php"; // koneksi mysqli: $conn
header('Content-Type: application/json');

date_default_timezone_set('Asia/Jakarta'); // pastikan zona waktu benar

try {
    // Ambil bulan & tahun saat ini
    $bulan = date('m');
    $tahun = date('Y');

    // Ambil nomor urut terakhir di tabel perpindahan_dbr untuk bulan & tahun yang sama
    $query = $conn->prepare("
        SELECT no 
        FROM perpindahan_dbr 
        WHERE no LIKE CONCAT('%/', ?, '/', ?) 
        ORDER BY id DESC 
        LIMIT 1
    ");
    $query->bind_param("ss", $bulan, $tahun);
    $query->execute();
    $result = $query->get_result();
    $lastNo = null;

    if ($row = $result->fetch_assoc()) {
        // Ambil 3 digit pertama sebelum tanda '/'
        $parts = explode('/', $row['no']);
        $lastNo = intval($parts[0]);
    }

    // Tentukan nomor berikutnya
    $nextNo = ($lastNo) ? $lastNo + 1 : 1;

    // Format ke tiga digit (misal: 001, 002, 010, 123)
    $noFormatted = str_pad($nextNo, 3, '0', STR_PAD_LEFT);

    // Susun format lengkap
    $noBaru = "$noFormatted/DBR/BBPOM/$bulan/$tahun";

    echo json_encode([
        'status' => 'success',
        'nomor' => $noBaru
    ]);

    $query->close();
    $conn->close();

} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage()
    ]);
}
?>
