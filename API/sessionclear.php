<?php
require "config.php";
date_default_timezone_set('Asia/Jakarta');

$now = date('Y-m-d H:i:s');

$logoutStmt = $conn->prepare("
    UPDATE user_token 
    SET login = 'N'
    WHERE login = 'Y'
      AND TIMESTAMPDIFF(DAY, updated_at, ?) > 30
");
$logoutStmt->bind_param("s", $now);
$logoutStmt->execute();

$affectedLogout = $logoutStmt->affected_rows;
$logoutStmt->close();

$deleteStmt = $conn->prepare("
    DELETE FROM user_token
    WHERE login = 'N'
      AND TIMESTAMPDIFF(DAY, updated_at, ?) > 7
");
$deleteStmt->bind_param("s", $now);
$deleteStmt->execute();

$affectedDelete = $deleteStmt->affected_rows;
$deleteStmt->close();

$logMsg = sprintf(
    "[%s] Auto Logout: %d | Session Deleted: %d\n",
    $now,
    $affectedLogout,
    $affectedDelete
);

file_put_contents(__DIR__ . '/cron_cleanup.log', $logMsg, FILE_APPEND);

echo json_encode([
    'success' => true,
    'auto_logout' => $affectedLogout,
    'deleted_sessions' => $affectedDelete,
    'timestamp' => $now
]);

$conn->close();
