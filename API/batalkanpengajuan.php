<?php
require "config.php";
header('Content-Type: application/json');

// =======================================================
// 🔹 Ambil data dari request
// =======================================================
$idPengajuan = intval($_POST['id_pengajuan'] ?? 0);
$catatan = $_POST['catatan'] ?? "";
$idUserLogin = intval($_POST['id_user_login'] ?? 0);

if ($idPengajuan <= 0) {
    echo json_encode(["success" => false, "message" => "id_pengajuan kosong"]);
    exit;
}

// =======================================================
// 🔹 Update status pengajuan jadi DIBATALKAN
// =======================================================
$sql = "UPDATE pengajuan SET status='C', catatan=? WHERE id=?";
$stmt = $conn->prepare($sql);
$stmt->bind_param("si", $catatan, $idPengajuan);

if ($stmt->execute()) {
    if ($stmt->affected_rows > 0) {
        echo json_encode([
            "success" => true,
            "message" => "Pengajuan berhasil dibatalkan.",
            "id_pengajuan" => $idPengajuan
        ]);
    } else {
        echo json_encode([
            "success" => false,
            "message" => "Tidak ada pengajuan yang diperbarui. Periksa ID pengajuan."
        ]);
    }
} else {
    echo json_encode([
        "success" => false,
        "message" => "Gagal membatalkan pengajuan: " . $stmt->error
    ]);
}

$conn->close();
?>
