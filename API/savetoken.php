<?php
require "config.php";

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
    exit;
}

$user_id = $_POST['user_id'] ?? null;
$token   = $_POST['token'] ?? null;
$app_id  = $_POST['app_id'] ?? null;

if (!$user_id || !$token || !$app_id) {
    echo json_encode(['success' => false, 'message' => 'Missing user_id, token, or app_id']);
    exit;
}

// 🔹 Cek apakah user + app_id sudah ada
$check = $conn->prepare("SELECT id FROM user_token WHERE user_id = ? AND app_id = ?");
$check->bind_param("is", $user_id, $app_id);
$check->execute();
$res = $check->get_result();
$update = $conn->prepare("
        UPDATE user_token 
        SET fcm_token = ?, updated_at = NOW()
        WHERE user_id = ? AND app_id = ?
    ");
    $update->bind_param("sis", $token, $user_id, $app_id);
    $update->execute();
    echo json_encode(['success' => true, 'message' => 'Token updated']);
    $update->close();


$check->close();
$conn->close();
?>
