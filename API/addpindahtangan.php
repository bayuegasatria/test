<?php
require "config.php";
header('Content-Type: application/json');

// Ambil data dari POST
$nomor = $_POST['nomor'] ?? '';
$tanggal = $_POST['tanggal'] ?? '';
$kelompok = $_POST['kelompok'] ?? '';
$inventaris_id = $_POST['inventaris_id'] ?? null;
$asal_id = $_POST['asal_id'] ?? null;
$alamat_lama = $_POST['alamat_lama'] ?? '';
$baru_id = $_POST['baru_id'] ?? null;
$alamat_baru = $_POST['alamat_baru'] ?? '';
$ket = $_POST['ket'] ?? '';
$lokasi = $_POST['lokasi'] ?? null;

// Validasi sederhana
if (empty($nomor) || empty($tanggal) || empty($kelompok)) {
    echo json_encode(['status' => 'error', 'message' => 'Field wajib belum diisi']);
    exit;
}

try {
    // Simpan ke tabel pindahtangan
    $stmt = $conn->prepare("
        INSERT INTO pindahtangan 
        (nomor, tanggal, kelompok, inventaris_id, asal_id, alamat_lama, baru_id, alamat_baru, ket, lokasi_baru, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
    ");
    $stmt->bind_param(
        "sssiisisss",
        $nomor,
        $tanggal,
        $kelompok,
        $inventaris_id,
        $asal_id,
        $alamat_lama,
        $baru_id,
        $alamat_baru,
        $ket,
        $lokasi
    );

    if ($stmt->execute()) {
        // ✅ Update tabel inventaris
        $updateInv = $conn->prepare("
            UPDATE inventaris 
            SET penanggung_jawab = ?, lokasi = ?, updated_at = NOW()
            WHERE id = ?
        ");
        $updateInv->bind_param("isi", $baru_id, $lokasi, $inventaris_id);
        $updateInv->execute();
        $updateInv->close();

        echo json_encode([
            'status' => 'success',
            'message' => 'Data berhasil disimpan dan inventaris diperbarui'
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Gagal menyimpan data']);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

$conn->close();
