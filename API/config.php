<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "bmn"; 

$conn = new mysqli($host, $user, $pass, $db);

if ($conn->connect_error) {
    die(json_encode(["error" => "Connection failed: " . $conn->connect_error]));
}
$conn->set_charset("utf8");
?>
