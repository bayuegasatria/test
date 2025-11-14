<?php
require "config.php";
header("Content-Type: application/json");

try {
    $sql = "SELECT * FROM lokasi ORDER BY id DESC";
    $res = $conn->query($sql);

    $data = [];
    while ($row = $res->fetch_assoc()) {
        $data[] = $row;
    }

    if (empty($data)) {
        echo json_encode([
            "status" => "empty",
            "message" => "Tidak ada data lokasi ditemukan"
        ]);
    } else {
        echo json_encode([
            "status" => "success",
            "count" => count($data),
            "data" => $data
        ], JSON_PRETTY_PRINT);
    }
} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Terjadi kesalahan: " . $e->getMessage()
    ]);
}
?>
