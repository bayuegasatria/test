<?php
require "config.php";

$sql = "
  SELECT *
  FROM jenistik
  ORDER BY id DESC
";

$res = $conn->query($sql);

$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
?>
