<?php
require "config.php";
header('Content-Type: application/json');
date_default_timezone_set('Asia/Jakarta');

// Ambil parameter POST
$kelompok = $_POST['kelompok'] ?? 'divisi'; // divisi / kendaraan
$divisi = $_POST['divisi'] ?? '';           // jika kelompok = divisi
$durasi = $_POST['durasi'] ?? '';           // bulan / tahun
$bulan = $_POST['bulan'] ?? '';
$tahun = intval($_POST['tahun'] ?? date('Y'));

// 🔹 Mapping nama bulan (Indonesia)
$bulanMapping = [
    'Januari' => 1, 'Februari' => 2, 'Maret' => 3,
    'April' => 4, 'Mei' => 5, 'Juni' => 6,
    'Juli' => 7, 'Agustus' => 8, 'September' => 9,
    'Oktober' => 10, 'November' => 11, 'Desember' => 12
];

// 🔹 Buat filter waktu
$where = ["YEAR(pengajuan.tanggal_berangkat) = $tahun"];

if ($durasi == 'bulan' && isset($bulanMapping[$bulan])) {
    $monthNum = $bulanMapping[$bulan];
    $where[] = "MONTH(pengajuan.tanggal_berangkat) = $monthNum";
}

$whereClause = implode(" AND ", $where);

// ==========================================================
// MODE 1 : LAPORAN PER DIVISI
// ==========================================================
if ($kelompok == 'bidang') {
    $extraDivisi = "";
    if (!empty($divisi)) {
        $extraDivisi = "AND divisi.nama = '$divisi'";
    }

   $sql = "
    SELECT 
        divisi.nama AS nama_bidang,
        users.name AS nama_pengaju,
        COUNT(pinjam.id) AS frekuensi_pemakaian,
        SUM(COUNT(pinjam.id)) OVER(PARTITION BY divisi.nama) AS total_per_divisi
    FROM pinjam
    JOIN pengajuan ON pinjam.id_pengajuan = pengajuan.id
    JOIN users ON pengajuan.id_user = users.id
    JOIN divisi ON users.divisi_id = divisi.id
    WHERE pinjam.status = 'selesai'
    AND $whereClause
    $extraDivisi
    GROUP BY divisi.nama, users.name
    ORDER BY divisi.nama ASC, frekuensi_pemakaian DESC
";


    $res = $conn->query($sql);
    $data = [];

    if ($res && $res->num_rows > 0) {
        while ($row = $res->fetch_assoc()) {
            $data[] = $row;
        }
    }

    echo json_encode($data);
    exit;
}

// ==========================================================
// MODE 2 : LAPORAN PER KENDARAAN
// ==========================================================
if ($kelompok == 'kendaraan') {
    // Ambil semua nama divisi untuk header tabel
    $divisiRes = $conn->query("SELECT DISTINCT nama FROM divisi ORDER BY nama ASC");
    $divisiList = [];
    while ($row = $divisiRes->fetch_assoc()) {
        $divisiList[] = $row['nama'];
    }

    // Ambil data frekuensi
    $sql = "
        SELECT 
            car.merk AS nama_kendaraan,
            divisi.nama AS nama_divisi,
            COUNT(pinjam.id) AS frekuensi
        FROM pinjam
        JOIN pengajuan ON pinjam.id_pengajuan = pengajuan.id
        JOIN users ON pengajuan.id_user = users.id
        JOIN divisi ON users.divisi_id = divisi.id
        JOIN car ON pinjam.id_kendaraan = car.id
        WHERE pinjam.status = 'selesai' 
        AND $whereClause
        GROUP BY car.merk, divisi.nama
        ORDER BY car.merk ASC, divisi.nama ASC
    ";

    $res = $conn->query($sql);

    $kendaraanData = [];
    while ($row = $res->fetch_assoc()) {
        $kendaraan = $row['nama_kendaraan'];
        $divisi = $row['nama_divisi'];
        $freq = intval($row['frekuensi']);

        if (!isset($kendaraanData[$kendaraan])) {
            $kendaraanData[$kendaraan] = array_fill_keys($divisiList, 0);
        }
        $kendaraanData[$kendaraan][$divisi] = $freq;
    }

    // Bentuk hasil akhir
    $result = [
        "divisi_headers" => $divisiList,
        "data" => []
    ];

    $no = 1;
    foreach ($kendaraanData as $namaKendaraan => $freqList) {
        $result["data"][] = [
            "nama_kendaraan" => $namaKendaraan,
            "frekuensi_divisi" => array_values($freqList)
        ];
    }

    echo json_encode($result);
    exit;
}

// Jika tidak ada mode cocok
echo json_encode(["error" => "Kelompok tidak dikenali"]);
?>
