<?php
require "config.php";

$res = $conn->query("SELECT * FROM pengajuan ORDER BY id DESC");

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
