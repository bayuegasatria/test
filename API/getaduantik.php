<?php
require "config.php";

$role     = $_GET['role'];
$userId   = $_GET['userId'];
$divisi = $_GET['divisi'];

if ($role != "AdminTIK") {
    // Jika bukan admin TIK → tampilkan hanya berdasarkan divisi
    $sql = "
        SELECT 
            a.*,
            u.name AS nama_user,
            u.no_pegawai AS nip,
            d.nama AS nama_divisi,
            pt.name AS nama_petugas,
            it.nama_barang,
            it.kode_barang,
            it.spesifikasi AS merk,
            it.lokasi,
            j.kelompok AS nama_kelompok
        FROM aduantik a
        JOIN users u ON a.users_id = u.id
        JOIN divisi d ON a.divisi_id = d.id
        LEFT JOIN petugas p ON a.petugas_id = p.id
        LEFT JOIN users pt ON p.user_id = pt.id
        LEFT JOIN itasset it ON a.itasset_id = it.id
        LEFT JOIN jenistik j ON it.jenistik_id = j.id
        WHERE a.divisi_id = ? AND a.status != 'Dihapus'
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
    // Jika AdminTIK → tampilkan semua
    $sql = "
        SELECT 
             a.*,
            u.name AS nama_user,
            u.no_pegawai AS nip,
            d.nama AS nama_divisi,
            pt.name AS nama_petugas,
            it.nama_barang,
            it.kode_barang,
            it.spesifikasi AS merk,
            it.lokasi,
            j.kelompok AS nama_kelompok
        FROM aduantik a
        JOIN users u ON a.users_id = u.id
        JOIN divisi d ON a.divisi_id = d.id
        LEFT JOIN petugas p ON a.petugas_id = p.id
        LEFT JOIN users pt ON p.user_id = pt.id
        LEFT JOIN itasset it ON a.itasset_id = it.id
        LEFT JOIN jenistik j ON it.jenistik_id = j.id
        WHERE a.status != 'Dihapus'
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
