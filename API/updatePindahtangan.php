<?php
require "config.php";
header('Content-Type: application/json');

// Ambil data dari POST
$id = $_POST['id'] ?? null;
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

// Validasi data wajib
if (empty($id) || empty($nomor) || empty($tanggal) || empty($kelompok)) {
    echo json_encode(['status' => 'error', 'message' => 'Field wajib belum diisi']);
    exit;
}

try {
    // 🔹 Gunakan transaksi untuk menjaga konsistensi data
    $conn->begin_transaction();

    // 1️⃣ Update tabel pindahtangan
    $stmt = $conn->prepare("
        UPDATE pindahtangan
        SET nomor = ?, 
            tanggal = ?, 
            kelompok = ?, 
            inventaris_id = ?, 
            asal_id = ?, 
            alamat_lama = ?, 
            baru_id = ?, 
            alamat_baru = ?, 
            ket = ?, 
            lokasi_baru = ?, 
            updated_at = NOW()
        WHERE id = ?
    ");

    $stmt->bind_param(
        "sssiisisssi",
        $nomor,
        $tanggal,
        $kelompok,
        $inventaris_id,
        $asal_id,
        $alamat_lama,
        $baru_id,
        $alamat_baru,
        $ket,
        $lokasi,
        $id
    );

    if (!$stmt->execute()) {
        throw new Exception("Gagal memperbarui data pindahtangan");
    }
    $stmt->close();

    // 2️⃣ Update tabel inventaris sesuai data baru
    $updateInv = $conn->prepare("
        UPDATE inventaris 
        SET penanggung_jawab = ?, lokasi = ?, updated_at = NOW()
        WHERE id = ?
    ");
    $updateInv->bind_param("isi", $baru_id, $lokasi, $inventaris_id);

    if (!$updateInv->execute()) {
        throw new Exception("Gagal memperbarui data inventaris");
    }
    $updateInv->close();

    // ✅ Commit transaksi
    $conn->commit();

    echo json_encode([
        'status' => 'success',
        'message' => 'Data berhasil diperbarui dan inventaris telah di-update'
    ]);
} catch (Exception $e) {
    $conn->rollback();
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

$conn->close();
?>
