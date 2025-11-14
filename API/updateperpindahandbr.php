<?php
require "config.php"; // koneksi mysqli: $conn
header('Content-Type: application/json');

$input = json_decode(file_get_contents("php://input"), true);
if (!$input) $input = $_POST; // fallback (kalau dikirim form-data)

// Ambil data dari request
$id             = $_POST['id'] ?? null; // ID perpindahan yang akan diupdate
$nomor          = $_POST['nomor'] ?? '';
$tanggal        = $_POST['tanggal'] ?? '';
$pelaporid      = $_POST['pelaporid'] ?? '';
$barangId       = $_POST['barangId'] ?? null;
$ruanganLamaId  = $_POST['ruanganLamaId'] ?? null;
$ruanganBaruId  = $_POST['ruanganBaruId'] ?? null;
$keterangan     = $_POST['keterangan'] ?? '';

// Validasi input
if (empty($id) || empty($nomor) || empty($tanggal) || empty($pelaporid) || empty($barangId) || empty($ruanganLamaId) || empty($ruanganBaruId)) {
    echo json_encode([
        'status' => 'error',
        'message' => 'Semua field wajib diisi'
    ]);
    exit;
}

try {
    // ✅ Update tabel perpindahan_dbr
    $stmt = $conn->prepare("
        UPDATE perpindahan_dbr
        SET 
            no = ?, 
            pelapor_id = ?, 
            tanggal = ?, 
            inventaris_id = ?, 
            old_lokasi = ?, 
            new_lokasi = ?, 
            keterangan = ?, 
            updated_at = NOW()
        WHERE id = ?
    ");
    $stmt->bind_param(
        "sisiiisi",
        $nomor,
        $pelaporid,
        $tanggal,
        $barangId,
        $ruanganLamaId,
        $ruanganBaruId,
        $keterangan,
        $id
    );

    if ($stmt->execute()) {
        // ✅ Update lokasi inventaris juga
        $update = $conn->prepare("
            UPDATE inventaris 
            SET lokasi = ?, updated_at = NOW() 
            WHERE id = ?
        ");
        $update->bind_param("ii", $ruanganBaruId, $barangId);
        $update->execute();
        $update->close();

        echo json_encode([
            'status' => 'success',
            'message' => 'Data perpindahan berhasil diperbarui dan lokasi inventaris disesuaikan'
        ]);
    } else {
        echo json_encode([
            'status' => 'error', 
            'message' => 'Gagal memperbarui data perpindahan',
            'error' => $stmt->error
        ]);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

$conn->close();
?>
