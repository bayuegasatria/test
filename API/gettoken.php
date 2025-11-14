<?php
require "config.php";

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    echo json_encode(['success' => false, 'message' => 'Invalid request method']);
    exit;
}

$user_id = $_GET['user_id'] ?? null;

if (!$user_id) {
    echo json_encode(['success' => false, 'message' => 'Missing user_id']);
    exit;
}

$stmt = $conn->prepare("SELECT fcm_token FROM user_token WHERE user_id = ?");
$stmt->bind_param("i", $user_id);
$stmt->execute();
$result = $stmt->get_result();

if ($row = $result->fetch_assoc()) {
    echo json_encode([
        'success' => true,
        'user_id' => $user_id,
        'fcm_token' => $row['fcm_token']
    ]);
} else {
    echo json_encode(['success' => false, 'message' => 'Token not found']);
}

$stmt->close();
$conn->close();
?>
