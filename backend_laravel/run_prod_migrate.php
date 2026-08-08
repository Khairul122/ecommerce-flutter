<?php

require __DIR__.'/vendor/autoload.php';

// 1. Load .env.production
$envFile = __DIR__.'/.env.production';
if (!file_exists($envFile)) {
    echo "ERROR: .env.production file not found!" . PHP_EOL;
    exit(1);
}

$lines = file($envFile, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
foreach ($lines as $line) {
    if (strpos(trim($line), '#') === 0) continue;
    $parts = explode('=', $line, 2);
    if (count($parts) === 2) {
        putenv(trim($parts[0]).'='.trim($parts[1]));
        $_ENV[trim($parts[0])] = trim($parts[1]);
        $_SERVER[trim($parts[0])] = trim($parts[1]);
    }
}

echo "Configured DB Connection: " . getenv('DB_CONNECTION') . PHP_EOL;
echo "Configured DB Host: " . getenv('DB_HOST') . PHP_EOL;
echo "Configured DB Database: " . getenv('DB_DATABASE') . PHP_EOL;
echo "Configured DB Username: " . getenv('DB_USERNAME') . PHP_EOL;

$host = getenv('DB_HOST') ?: '127.0.0.1';
$port = getenv('DB_PORT') ?: '3306';
$db = getenv('DB_DATABASE');
$user = getenv('DB_USERNAME');
$pass = getenv('DB_PASSWORD');

// Test direct PDO MySQL connection
try {
    echo PHP_EOL . "Connecting to MySQL server ({$host}:{$port}, DB: {$db})..." . PHP_EOL;
    $pdo = new PDO("mysql:host={$host};port={$port};dbname={$db}", $user, $pass, [
        PDO::ATTR_TIMEOUT => 5,
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);
    echo "PDO CONNECTION SUCCESSFUL!" . PHP_EOL;
} catch (\Throwable $e) {
    echo "PDO CONNECTION FAILED: " . $e->getMessage() . PHP_EOL;
    
    // Try connecting to domain hostname synectra.xyz
    $remoteHost = 'backend-ecommerce.synectra.xyz';
    echo PHP_EOL . "Trying domain host {$remoteHost}:{$port}..." . PHP_EOL;
    try {
        $pdo = new PDO("mysql:host={$remoteHost};port={$port};dbname={$db}", $user, $pass, [
            PDO::ATTR_TIMEOUT => 5,
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
        ]);
        echo "PDO REMOTE HOST CONNECTION SUCCESSFUL!" . PHP_EOL;
        $host = $remoteHost;
    } catch (\Throwable $e2) {
        echo "PDO REMOTE HOST CONNECTION FAILED: " . $e2->getMessage() . PHP_EOL;
    }
}

