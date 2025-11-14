<?php
require "config.php";

$response = array();

if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // 🔹 Ambil data dari body POST
    $no_aduan = $_POST['no_aduan'] ?? null;
    $tanggal = $_POST['tanggal'] ?? null;
    $users_id = $_POST['users_id'] ?? null;
    $divisi_id = $_POST['divisi_id'] ?? null;
    $itasset_id = $_POST['itasset_id'] ?? null;
    $trouble = $_POST['trouble'] ?? null;

    // Nilai default
    $status = "Belum Diproses";// 0 = belum diperiksa
    $follow_up = "";
    $result = "";
    $analyze_date = date('Y-m-d');

    // 🔹 Validasi field wajib
    if (empty($no_aduan) || empty($tanggal) || empty($users_id) || empty($divisi_id) || empty($itasset_id)) {
        $response = [
            'success' => false,
            'message' => 'Field wajib tidak boleh kosong (no_aduan, tanggal, users_id, divisi_id, itasset_id).'
        ];
    } else {
        // 🔹 Query insert data
        $stmt = $conn->prepare("
            INSERT INTO aduantik (
                no_aduan, tanggal, users_id, divisi_id, itasset_id,
                trouble, follow_up, result, analyze_date, status, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)
        ");

        $stmt->bind_param(
            "ssiiisssss",
            $no_aduan,
            $tanggal,
            $users_id,
            $divisi_id,
            $itasset_id,
            $trouble,
            $follow_up,
            $result,
            $analyze_date,
            $status
        );

        if ($stmt->execute()) {
            $response = [
                'success' => true,
                'message' => 'Data aduan TIK berhasil ditambahkan.',
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

// 🔹 Output JSON
echo json_encode($response);
$conn->close();
?>
