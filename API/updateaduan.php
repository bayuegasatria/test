<?php
require "config.php"; // koneksi ke database

header("Content-Type: application/json");

// pastikan metode POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
    exit;
}

// ambil data JSON dari body
$input = json_decode(file_get_contents("php://input"), true);

if (!$input) {
    echo json_encode(["success" => false, "message" => "Invalid JSON input"]);
    exit;
}

// ambil parameter
$id             = $input['id'] ?? null;
$role           = $input['role'] ?? null;
$problem        = $input['problem'] ?? null;
$aduan_status   = $input['aduan_status'] ?? 0;
$analisa        = $input['analisa'] ?? null;
$follow_up      = $input['follow_up'] ?? null;
$result         = $input['result'] ?? null;
$analyze_date   = $input['analyze_date'] ?? null;
$user_petugas_id= $input['petugas_id'] ?? null; // ini dari JSON (users.id)
$inventaris_id  = $input['inventaris_id'] ?? null;
$updated_at     = date('Y-m-d H:i:s');

// validasi wajib
if (!$id) {
    echo json_encode(["success" => false, "message" => "Missing aduan ID"]);
    exit;
}

// ====================================================
// Jika role bukan AdminTIK → update terbatas
// ====================================================
if ($role !== "AdminTIK") {
    $sql = "UPDATE aduan 
            SET problem = ?, inventaris_id = ?, updated_at = ?
            WHERE id = ?";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
        exit;
    }

    $stmt->bind_param("sisi", $problem, $inventaris_id, $updated_at, $id);
    $ok = $stmt->execute();
    $stmt->close();

    echo json_encode([
        "success" => $ok,
        "message" => $ok ? "Aduan berhasil diperbarui (pegawai)." : "Gagal memperbarui aduan."
    ]);
    exit;
}

// ====================================================
// ROLE ADMIN TIK
// Ambil petugas.id berdasarkan users.id dari JSON
// ====================================================
$petugas_id = null;
if ($user_petugas_id) {
    $q = $conn->prepare("SELECT id FROM petugas WHERE user_id = ?");
    $q->bind_param("i", $user_petugas_id);
    $q->execute();
    $q->bind_result($petugas_id);
    $q->fetch();
    $q->close();

    // Jika tidak ditemukan
    if (!$petugas_id) {
        echo json_encode(["success" => false, "message" => "Petugas dengan user_id tersebut tidak ditemukan"]);
        exit;
    }
}

// ====================================================
// Update aduan
// ====================================================
$sql = "UPDATE aduan 
        SET 
            aduan_status = ?, 
            problem = ?, 
            analisa = ?, 
            follow_up = ?, 
            result = ?, 
            analyze_date = ?, 
            petugas_id = ?, 
            inventaris_id = ?, 
            updated_at = ?
        WHERE id = ?";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    exit;
}

$stmt->bind_param(
    "ssssssiisi",
    $aduan_status,
    $problem,
    $analisa,
    $follow_up,
    $result,
    $analyze_date,
    $petugas_id,
    $inventaris_id,
    $updated_at,
    $id
);

$ok = $stmt->execute();
$stmt->close();

echo json_encode([
    "success" => $ok,
    "message" => $ok ? "Aduan berhasil diperbarui (AdminTIK)." : "Gagal memperbarui aduan."
]);
?>
