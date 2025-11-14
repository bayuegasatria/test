<?php
require "config.php";

// Ambil bulan dan tahun sekarang
$bulan = date("m");
$tahun = date("Y");

try {
    // Ambil nomor urut terakhir dari no_aduan
    $sql = "SELECT no_aduan FROM aduan ORDER BY id DESC LIMIT 1";
    $result = $conn->query($sql);

    $nextNumber = 1; // default jika tabel kosong

    if ($result && $result->num_rows > 0) {
        $row = $result->fetch_assoc();

        // Pisahkan format "001/SPI/BBPOM/11/2025"
        $parts = explode("/", $row['no_aduan']);
        if (count($parts) > 0 && is_numeric($parts[0])) {
            $nextNumber = intval($parts[0]) + 1;
        }
    }

    // Format nomor aduan baru
    $formattedNumber = str_pad($nextNumber, 3, '0', STR_PAD_LEFT);
    $noAduan = "{$formattedNumber}/SPI/BBPOM/{$bulan}/{$tahun}";

    echo json_encode([
        "success" => true,
        "no_aduan" => $noAduan,
        "message" => "Nomor aduan berhasil digenerate"
    ]);
} catch (Exception $e) {
    echo json_encode([
        "success" => false,
        "message" => "Terjadi kesalahan: " . $e->getMessage()
    ]);
}

$conn->close();
?>
