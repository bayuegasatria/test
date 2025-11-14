<?php
require "config.php";

$idPinjam  = $_POST['idPinjam'];
$newStatus = $_POST['newStatus'];
$kmAwal    = $_POST['kmAwal'] ?? null;
$kmAkhir   = $_POST['kmAkhir'] ?? null;

// Folder upload
$uploadDir = "uploads/pinjam/";
if (!file_exists($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

$awalPath = $awalName = $akhirPath = $akhirName = null;

// Upload foto KM awal
if (isset($_FILES['fotoKmAwal']) && $_FILES['fotoKmAwal']['error'] == 0) {
    $awalName = time() . "_awal_" . basename($_FILES['fotoKmAwal']['name']);
    $awalPath = $uploadDir . $awalName;
    move_uploaded_file($_FILES['fotoKmAwal']['tmp_name'], $awalPath);
}

// Upload foto KM akhir
if (isset($_FILES['fotoKmAkhir']) && $_FILES['fotoKmAkhir']['error'] == 0) {
    $akhirName = time() . "_akhir_" . basename($_FILES['fotoKmAkhir']['name']);
    $akhirPath = $uploadDir . $akhirName;
    move_uploaded_file($_FILES['fotoKmAkhir']['tmp_name'], $akhirPath);
}

if ($newStatus === "batal") {
    $sql = "UPDATE pinjam SET status = ? WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("si", $newStatus, $idPinjam);
} else {
    $sql = "UPDATE pinjam 
            SET status = ?, 
                tanggal_pengembalian = NOW(),
                km_awal = IFNULL(?, km_awal),
                km_akhir = IFNULL(?, km_akhir),
                awal_path = IFNULL(?, awal_path),
                awal_name = IFNULL(?, awal_name),
                akhir_path = IFNULL(?, akhir_path),
                akhir_name = IFNULL(?, akhir_name)
            WHERE id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param(
        "sssssssi",
        $newStatus,
        $kmAwal,
        $kmAkhir,
        $awalPath,
        $awalName,
        $akhirPath,
        $akhirName,
        $idPinjam
    );
}

if ($stmt->execute()) {
    echo json_encode(["success" => true]);
} else {
    echo json_encode(["success" => false, "error" => $stmt->error]);
}

$stmt->close();
$conn->close();
?>
