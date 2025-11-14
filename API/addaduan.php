<?php
require "config.php";

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    // Ambil data dari body POST
    $no_aduan = $_POST['no_aduan'] ?? null;
    $tanggal = $_POST['tanggal'] ?? null;
    $aduan_status = "Belum Diproses";
    $pegawai_id = $_POST['pegawai_id'] ?? null;
    $divisi_id = $_POST['divisi_id'] ?? null;
    $inventaris_id = $_POST['inventaris_id'] ?? null;
    $problem = $_POST['problem'] ?? null;
    $katim = $_POST['katim'] ?? null;

    // Validasi sederhana
    if (empty($no_aduan) || empty($tanggal) || empty($pegawai_id) || empty($divisi_id)) {
        $response = [
            'success' => false,
            'message' => 'Field wajib tidak boleh kosong (no_aduan, tanggal, pegawai_id, divisi_id).'
        ];
    } else {
        $stmt = $conn->prepare("
            INSERT INTO aduan (
                no_aduan, tanggal, aduan_status, pegawai_id, divisi_id, created_at, inventaris_id, problem,teamleader_id
            ) VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, ?, ? ,?)
        ");
        $stmt->bind_param(
            "sssiissi",
            $no_aduan,
            $tanggal,
            $aduan_status,
            $pegawai_id,
            $divisi_id,
            $inventaris_id,
            $problem,
            $katim
        );

        if ($stmt->execute()) {
            $response = [
                'success' => true,
                'message' => 'Data aduan berhasil ditambahkan.',
                'insert_id' => $stmt->insert_id
            ];
        } else {
            $response = [
                'success' => false,
                'message' => 'Gagal menambahkan data: ' . $stmt->error
            ];
        }

        $stmt->close();
    }
} else {
    $response = [
        'success' => false,
        'message' => 'Metode request tidak diizinkan. Gunakan POST.'
    ];
}

echo json_encode($response);
$conn->close();
?>
