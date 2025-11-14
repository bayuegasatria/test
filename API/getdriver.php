<?php
require "config.php";

$result = $conn->query("SELECT * FROM driver WHERE aktif='Y'");
$data = [];
while ($row = $result->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);
?>
