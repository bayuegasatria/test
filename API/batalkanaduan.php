<?php
require "config.php"; // koneksi ke database

header("Content-Type: application/json");

// Pastikan request POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
    exit;
}

// Ambil data JSON dari body
$input = json_decode(file_get_contents("php://input"), true);
$id = isset($input['id']) ? intval($input['id']) : 0;

if ($id <= 0) {
    echo json_encode(["success" => false, "message" => "ID tidak valid"]);
    exit;
}

// Update status jadi 'Dihapus'
$sql = "UPDATE aduan SET aduan_status = 'Dihapus', updated_at = NOW() WHERE id = ?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["success" => true, "message" => "Aduan berhasil dihapus (soft delete)"]);
} else {
    echo json_encode(["success" => false, "message" => "Gagal menghapus aduan"]);
}

$stmt->close();
$conn->close();
?>
