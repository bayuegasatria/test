<?php
require "config.php";

$role     = $_GET['role'];
$userId   = $_GET['userId'];
$divisi = $_GET['divisi'];

if ($role != "AdminTIK") {
    $sql = "
        SELECT 
            a.*, 
            u.name AS nama_user, 
            u.no_pegawai AS nip,
            d.nama AS nama_divisi,
            tl.name AS nama_leader,
            pt.name AS nama_petugas,
            i.nama_barang,
            i.kode_barang,
            i.kode_bmn AS nup,
            i.merk,
            l.nama AS nama_lokasi,
            j.nama AS nama_kelompok,
            i.lokasi
        FROM aduan a
        JOIN users u ON a.pegawai_id = u.id
        JOIN divisi d ON a.divisi_id = d.id
        LEFT JOIN users tl ON a.teamleader_id = tl.id
        LEFT JOIN inventaris i ON a.inventaris_id = i.id
        LEFT JOIN lokasi l ON i.lokasi = l.id
        LEFT JOIN petugas p ON a.petugas_id = p.id
        LEFT JOIN users pt ON p.user_id = pt.id
        LEFT JOIN jenis_barang j ON i.jenis_barang = j.id
        WHERE a.divisi_id = ? AND a.aduan_status != 'Dihapus'
        ORDER BY a.id DESC
    ";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        die(json_encode(["error" => "Prepare failed: " . $conn->error]));
    }
    $stmt->bind_param("i", $divisi);
    $stmt->execute();
    $res = $stmt->get_result();

} else {
    $sql = "
        SELECT 
            a.*, 
            u.name AS nama_user, 
            u.no_pegawai AS nip,
            d.nama AS nama_divisi,
            tl.name AS nama_leader,
            pt.name AS nama_petugas,
            i.nama_barang,
            i.kode_barang,
            i.kode_bmn AS nup,
            i.merk,
            l.nama AS nama_lokasi,
            j.nama AS nama_kelompok,
            i.lokasi
        FROM aduan a
        JOIN users u ON a.pegawai_id = u.id
        JOIN divisi d ON a.divisi_id = d.id
        LEFT JOIN users tl ON a.teamleader_id = tl.id
        LEFT JOIN inventaris i ON a.inventaris_id = i.id
        LEFT JOIN lokasi l ON i.lokasi = l.id
        LEFT JOIN petugas p ON a.petugas_id = p.id
        LEFT JOIN users pt ON p.user_id = pt.id
        LEFT JOIN jenis_barang j ON i.jenis_barang = j.id
        WHERE a.aduan_status != 'Dihapus'
        ORDER BY a.id DESC
    ";

    $res = $conn->query($sql);
}

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
