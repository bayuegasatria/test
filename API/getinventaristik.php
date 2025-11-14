<?php
require "config.php";

if (!isset($_GET['jenistik_id'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Parameter 'jenistik_id' diperlukan"
    ]);
    exit;
}

$jenistik_id = $_GET['jenistik_id'];

try {
    // 🔹 Query data itasset dengan relasi ke tabel users dan jenistik (jika ada)
    $query = "SELECT 
        i.id,
        i.kode_barang,
        i.nama_barang,
        i.jenistik_id,
        j.kelompok AS nama_jenis,
        i.lokasi,
        i.users_id,
        u.name AS nama_pengguna,
        i.spesifikasi AS merk,
        i.file_foto,
        i.created_at,
        i.updated_at,
        i.deleted_at
    FROM itasset i
    LEFT JOIN users u ON i.users_id = u.id
    LEFT JOIN jenistik j ON i.jenistik_id = j.id
    WHERE i.jenistik_id = ?
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $jenistik_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    if (empty($data)) {
        echo json_encode([
            "status" => "empty",
            "message" => "Data IT Asset tidak ditemukan untuk jenistik ini"
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "count" => count($data),
            "data" => $data
        ]);
    }

    $stmt->close();
    $conn->close();

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Terjadi kesalahan: " . $e->getMessage()
    ]);
}
?>
