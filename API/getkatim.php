<?php
header("Content-Type: application/json");
require_once "config.php"; // koneksi ke database

// Ambil parameter divisi_id dari GET
$divisi_id = isset($_GET['divisi_id']) ? intval($_GET['divisi_id']) : 0;

if ($divisi_id <= 0) {
    echo json_encode([
        "status" => "error",
        "message" => "Parameter divisi_id tidak valid"
    ]);
    exit;
}

try {
    // Query ambil data teamleader berdasarkan divisi_id
    $query = "
        SELECT 
            t.id,
            t.users_id,
            u.name AS nama_user,
            t.divisi_id,
            d.nama AS nama_divisi,
            t.detail,
            t.aktif,
            t.datefrom,
            t.dateto,
            t.created_at,
            t.updated_at
        FROM teamleader t
        LEFT JOIN users u ON t.users_id = u.id
        LEFT JOIN divisi d ON t.divisi_id = d.id
        WHERE t.divisi_id = ?
    ";

    $stmt = $conn->prepare($query);
    $stmt->bind_param("i", $divisi_id);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    if (empty($data)) {
        echo json_encode([
            "status" => "empty",
            "message" => "Tidak ada data teamleader untuk divisi ini"
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "data" => $data
        ]);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Terjadi kesalahan: " . $e->getMessage()
    ]);
}
?>
