<?php
require "config.php"; // koneksi mysqli: $conn
header('Content-Type: application/json');
$input = json_decode(file_get_contents("php://input"), true);
if (!$input) $input = $_POST; // fallback (kalau dikirim form-data)

$nomor          = $_POST['nomor'] ?? '';
$tanggal        = $_POST['tanggal'] ?? '';
$pelaporid      = $_POST['pelaporid'] ?? '';
$barangId       = $_POST['barangId'] ?? null;
$ruanganLamaId  = $_POST['ruanganLamaId'] ?? null;
$ruanganBaruId  = $_POST['ruanganBaruId'] ?? null;
$keterangan     = $_POST['keterangan'] ?? '';

// Validasi sederhana
if (empty($nomor) || empty($tanggal) || empty($pelaporid) || empty($barangId) || empty($ruanganLamaId) || empty($ruanganBaruId)) {
    echo json_encode(['status' => 'error', 'message' => 'Semua field wajib diisi']);
    echo($nomor);
    echo($tanggal);
    echo($pelaporid);
    echo($ruanganBaruId);
    echo($ruanganLamaId);
    echo($keterangan);
    exit;
}

// Cek apakah nomor sudah digunakan


try {
    // Simpan ke tabel perpindahan_dbr
    $stmt = $conn->prepare("
        INSERT INTO perpindahan_dbr 
        (no, pelapor_id, tanggal, inventaris_id, old_lokasi, new_lokasi, keterangan, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), NOW())
    ");
    $stmt->bind_param(
        "sisiiis",
        $nomor,
        $pelaporid,
        $tanggal,
        $barangId,
        $ruanganLamaId,
        $ruanganBaruId,
        $keterangan
    );

    if ($stmt->execute()) {
        // ✅ Update tabel inventaris
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
            'message' => 'Data perpindahan berhasil disimpan dan lokasi inventaris diperbarui'
        ]);
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Gagal menyimpan data perpindahan','error' => $stmt->error]);
    }

    $stmt->close();
} catch (Exception $e) {
    echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
}

$conn->close();
?>
