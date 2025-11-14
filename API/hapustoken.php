<?php
require "config.php";
header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    echo json_encode([
        'success' => false,
        'message' => 'Invalid request method'
    ]);
    exit;
}

$user_id = $_POST['user_id'] ?? null;

if (!$user_id) {
    echo json_encode([
        'success' => false,
        'message' => 'Missing user_id'
    ]);
    exit;
}

// Cek apakah user_id ada di tabel user_token
$check = $conn->prepare("SELECT id FROM user_token WHERE user_id = ? LIMIT 1");
$check->bind_param("i", $user_id);
$check->execute();
$res = $check->get_result();

if ($res->num_rows > 0) {
    // Update login status dan hapus token
    $update = $conn->prepare("
        UPDATE user_token 
        SET login = 'N', fcm_token = '' 
        WHERE user_id = ?
    ");
    $update->bind_param("i", $user_id);
    $update->execute();

    echo json_encode([
        'success' => true,
        'message' => 'Logout berhasil dan token berhasil dihapus'
    ]);

    $update->close();
} else {
    echo json_encode([
        'success' => false,
        'message' => 'User not found di tabel user_token'
    ]);
}

$check->close();
$conn->close();
?>
