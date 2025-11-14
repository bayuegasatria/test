<?php
require "config.php";
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

$bidang = $_POST['bidang'] ?? 'Semua Bidang';
$durasi = $_POST['durasi'] ?? '';
$bulan = $_POST['bulan'] ?? '';
$triwulan = $_POST['triwulan'] ?? '';
$tahun = intval($_POST['tahun'] ?? date('Y'));

$where = []; // simpan kondisi dalam array

// 🔹 Filter tahun
$where[] = "YEAR(pengajuan.tanggal_berangkat) = $tahun";

// 🔹 Mapping nama bulan (Indonesia)
$bulanMapping = [
    'Januari' => 1, 'Februari' => 2, 'Maret' => 3,
    'April' => 4, 'Mei' => 5, 'Juni' => 6,
    'Juli' => 7, 'Agustus' => 8, 'September' => 9,
    'Oktober' => 10, 'November' => 11, 'Desember' => 12
];

// 🔹 Filter berdasarkan durasi
if ($durasi == 'bulan' && isset($bulanMapping[$bulan])) {
    $monthNum = $bulanMapping[$bulan];
    $where[] = "MONTH(pengajuan.tanggal_berangkat) = $monthNum";
} elseif ($durasi == 'triwulan' && $triwulan != '') {
    switch ($triwulan) {
        case 'Jan - Mar': $where[] = "MONTH(pengajuan.tanggal_berangkat) BETWEEN 1 AND 3"; break;
        case 'Apr - Jun': $where[] = "MONTH(pengajuan.tanggal_berangkat) BETWEEN 4 AND 6"; break;
        case 'Jul - Sep': $where[] = "MONTH(pengajuan.tanggal_berangkat) BETWEEN 7 AND 9"; break;
        case 'Okt - Des': $where[] = "MONTH(pengajuan.tanggal_berangkat) BETWEEN 10 AND 12"; break;
    }
}

// 🔹 Filter bidang
if ($bidang != 'Semua Bidang') {
    $where[] = "divisi.nama = '$bidang'";
}

// 🔹 Gabungkan semua kondisi ke satu string
$whereClause = "";
if (!empty($where)) {
    $whereClause = " AND " . implode(" AND ", $where);
}

$sql = "SELECT 
            pinjam.id AS id_pinjam,
            pengajuan.no_pengajuan,
            users.name AS nama_pengaju,
            divisi.nama AS nama_bidang,
            car.merk AS nama_kendaraan,
            pengajuan.tanggal_berangkat AS tanggal_mulai,
            pengajuan.tanggal_kembali AS tanggal_kembali,
            pinjam.tanggal_pengembalian,
            pengajuan.tujuan,
            pinjam.status
        FROM pinjam
        JOIN pengajuan ON pinjam.id_pengajuan = pengajuan.id
        JOIN users ON pengajuan.id_user = users.id
        JOIN divisi ON users.divisi_id = divisi.id
        JOIN car ON pinjam.id_kendaraan = car.id
        WHERE pinjam.status = 'selesai'
        $whereClause
        ORDER BY pengajuan.tanggal_berangkat DESC";

$res = $conn->query($sql);
$data = [];

if ($res && $res->num_rows > 0) {
    while ($row = $res->fetch_assoc()) {
        $data[] = $row;
    }
}

echo json_encode( $data);
