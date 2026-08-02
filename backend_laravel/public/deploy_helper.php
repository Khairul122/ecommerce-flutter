<?php

/**
 * Deployment Helper Script for Rumahweb Shared Hosting (cPanel)
 * Safely unzips vendor.zip and runs Laravel optimization & migration tasks without SSH terminal access.
 *
 * Usage: http://your-domain.com/deploy_helper.php?token=ootday_deploy_secret_2026
 */

header('Content-Type: application/json');

$secretToken = 'ootday_deploy_secret_2026';
$providedToken = $_GET['token'] ?? '';

if ($providedToken !== $secretToken) {
    http_response_code(403);
    echo json_encode([
        'status' => 'error',
        'message' => 'Unauthorized access. Invalid deployment token.'
    ]);
    exit;
}

$baseDir = realpath(__DIR__ . '/..');
$vendorZip = $baseDir . '/vendor.zip';
$vendorDir = $baseDir . '/vendor';
$log = [];

$log[] = 'Base directory: ' . $baseDir;

// 0. Ensure required storage and bootstrap cache directories exist
$requiredDirs = [
    $baseDir . '/bootstrap/cache',
    $baseDir . '/storage/app/public',
    $baseDir . '/storage/framework/cache/data',
    $baseDir . '/storage/framework/sessions',
    $baseDir . '/storage/framework/views',
    $baseDir . '/storage/logs',
];

foreach ($requiredDirs as $dir) {
    if (!file_exists($dir)) {
        if (@mkdir($dir, 0755, true)) {
            $log[] = "Created directory: $dir";
        } else {
            $log[] = "Failed to create directory: $dir";
        }
    }
}

// 1. Unzip vendor.zip if present
if (file_exists($vendorZip)) {
    $log[] = 'Found vendor.zip. Unzipping into vendor/...';
    $zip = new ZipArchive();
    if ($zip->open($vendorZip) === true) {
        $zip->extractTo($baseDir);
        $zip->close();
        $log[] = 'vendor.zip extracted successfully!';
        @unlink($vendorZip);
        $log[] = 'vendor.zip removed after extraction.';
    } else {
        $log[] = 'Failed to open vendor.zip.';
    }
} else {
    $log[] = 'vendor.zip not found on server. Skipping extraction (assuming vendor/ directory exists).';
}

// 2. Setup storage symlink if needed
$publicStorage = __DIR__ . '/storage';
$targetStorage = $baseDir . '/storage/app/public';

if (!file_exists($publicStorage) && file_exists($targetStorage)) {
    if (@symlink($targetStorage, $publicStorage)) {
        $log[] = 'Storage symlink created successfully.';
    } else {
        $log[] = 'Could not create symlink automatically.';
    }
} else {
    $log[] = 'Storage symlink already exists or target missing.';
}

// 3. Run artisan commands
chdir($baseDir);

function runArtisan($command, &$log) {
    $output = [];
    $returnCode = 0;
    exec('php artisan ' . $command . ' 2>&1', $output, $returnCode);
    $log[] = "Artisan command [php artisan $command] (Exit: $returnCode): " . implode(' | ', $output);
}

runArtisan('config:cache', $log);
runArtisan('route:cache', $log);
runArtisan('view:cache', $log);

// Execute migration & seeding if requested
if (isset($_GET['migrate']) && $_GET['migrate'] === 'true') {
    runArtisan('migrate --force', $log);
}
if (isset($_GET['seed']) && $_GET['seed'] === 'true') {
    runArtisan('db:seed --force', $log);
}

echo json_encode([
    'status' => 'success',
    'timestamp' => date('Y-m-d H:i:s'),
    'logs' => $log
], JSON_PRETTY_PRINT);
