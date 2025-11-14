<?php
require "config.php";

header("Content-Type: application/json");

try {
    $query = "
        SELECT 
            id,
            no_pegawai AS nip,
            name,
            username,
            email,
            tempat_lhr,
            tgl_lhr,
            alamat,
            nikah,
            jkel,
            telp,
            jabatan_id,
            jabasn_id,
            seri_karpeg,
            status,
            divisi_id,
            subdivisi_id,
            golongan_id,
            foto,
            aktif,
            deskjob,
            TMT_Capeg,
            namanogelar,
            agama,
            created_at,
            updated_at
        FROM users
        WHERE deleted_at IS NULL
        ORDER BY id DESC
    ";

    $stmt = $conn->prepare($query);
    $stmt->execute();
    $result = $stmt->get_result();

    $data = [];
    while ($row = $result->fetch_assoc()) {
        $data[] = $row;
    }

    echo json_encode([
        "status" => "success",
        "count" => count($data),
        "data" => $data
    ], JSON_PRETTY_PRINT);

    $stmt->close();
    $conn->close();

} catch (Exception $e) {
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}
?>
