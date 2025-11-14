<?php
require "config.php"; // koneksi ke database

header("Content-Type: application/json");

// Pastikan metode request adalah POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(["success" => false, "message" => "Invalid request method"]);
    exit;
}

// Ambil input JSON dari body
$input = json_decode(file_get_contents("php://input"), true);

if (!$input) {
    echo json_encode(["success" => false, "message" => "Invalid JSON input"]);
    exit;
}

// Ambil parameter dari JSON
$id             = $input['id'] ?? null;
$role           = $input['role'] ?? null;
$trouble        = $input['trouble'] ?? null;
$status         = $input['status'] ?? "Belum Diproses";
$analisa        = $input['analisa'] ?? null;
$follow_up      = $input['follow_up'] ?? null;
$result         = $input['result'] ?? null;
$analyze_date   = $input['analyze_date'] ?? null;
$user_petugas_id= $input['petugas_id'] ?? null; // ini dikirim dari JSON (users.id)
$itasset_id     = $input['itasset_id'] ?? null;
$followup_date  = $input['followup_date'] ?? null;
$result_date    = $input['result_date'] ?? null;
$updated_at     = date('Y-m-d H:i:s');

// Validasi wajib
if (!$id) {
    echo json_encode(["success" => false, "message" => "Missing aduan ID"]);
    exit;
}

// ==========================
// ROLE PEGAWAI / NON-ADMIN
// ==========================
if ($role !== "AdminTIK") {
    $sql = "UPDATE aduantik 
            SET trouble = ?, itasset_id = ?, updated_at = ?
            WHERE id = ?";

    $stmt = $conn->prepare($sql);
    if (!$stmt) {
        echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
        exit;
    }

    $stmt->bind_param("sisi", $trouble, $itasset_id, $updated_at, $id);
    $ok = $stmt->execute();
    $stmt->close();

    echo json_encode([
        "success" => $ok,
        "message" => $ok ? "Aduan TIK berhasil diperbarui (pegawai)." : "Gagal memperbarui aduan TIK."
    ]);
    exit;
}

// ==========================
// ROLE ADMIN TIK
// Ambil petugas.id dari tabel petugas berdasarkan users.id
// ==========================
$petugas_id = null;

if ($user_petugas_id) {
    $q = $conn->prepare("SELECT id FROM petugas WHERE user_id = ?");
    $q->bind_param("i", $user_petugas_id);
    $q->execute();
    $q->bind_result($petugas_id);
    $q->fetch();
    $q->close();

    if (!$petugas_id) {
        echo json_encode([
            "success" => false,
            "message" => "Petugas dengan user_id tersebut tidak ditemukan di tabel petugas."
        ]);
        exit;
    }
}

// ==========================
// UPDATE ADUANTIK
// ==========================
$sql = "UPDATE aduantik 
        SET 
            status = ?, 
            trouble = ?, 
            analisa = ?, 
            follow_up = ?, 
            result = ?, 
            analyze_date = ?, 
            followup_date = ?, 
            result_date = ?, 
            petugas_id = ?, 
            itasset_id = ?, 
            updated_at = ?
        WHERE id = ?";

$stmt = $conn->prepare($sql);
if (!$stmt) {
    echo json_encode(["success" => false, "message" => "Prepare failed: " . $conn->error]);
    exit;
}

// urutan bind_param harus sesuai urutan di query
$stmt->bind_param(
    "ssssssssiisi",
    $status,
    $trouble,
    $analisa,
    $follow_up,
    $result,
    $analyze_date,
    $followup_date,
    $result_date,
    $petugas_id,
    $itasset_id,
    $updated_at,
    $id
);

$ok = $stmt->execute();

if (!$ok) {
    echo json_encode([
        "success" => false,
        "message" => "Gagal memperbarui aduan TIK: " . $stmt->error
    ]);
} else {
    echo json_encode([
        "success" => true,
        "message" => "Aduan TIK berhasil diperbarui (AdminTIK)."
    ]);
}

$stmt->close();
$conn->close();
?>
