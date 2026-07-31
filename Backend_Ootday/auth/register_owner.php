<?php
// auth/register_owner.php
// Salinan untuk repo — deploy ke C:\xampp\htdocs\Backend_Ootday\auth\
header('Content-Type: application/json');
require_once '../config/database.php';
require_once '../utils/response.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse('error', 'Method not allowed', null, 405);
}

$data = json_decode(file_get_contents('php://input'), true);

$uid   = trim($data['uid'] ?? '');
$name  = trim($data['name'] ?? '');
$email = trim($data['email'] ?? '');
$phone = trim($data['phone'] ?? '');

if (empty($uid) || empty($name) || empty($email)) {
    jsonResponse('error', 'UID, Nama, dan Email wajib diisi', null, 400);
}

try {
    try {
        $pdo->exec("ALTER TABLE stores ADD COLUMN owner_uid VARCHAR(128) NULL AFTER id");
    } catch (PDOException $e) {
        // Kolom sudah ada
    }

    $sql = "INSERT INTO users (uid, name, email, phone, role)
            VALUES (?, ?, ?, ?, 'owner')
            ON DUPLICATE KEY UPDATE
            name = VALUES(name),
            phone = VALUES(phone),
            email = VALUES(email),
            role = 'owner'";

    $stmt = $pdo->prepare($sql);
    $stmt->execute([$uid, $name, $email, $phone]);

    $check = $pdo->prepare(
        "SELECT id FROM stores WHERE owner_uid = ? OR email = ? LIMIT 1"
    );
    $check->execute([$uid, $email]);
    $store = $check->fetch();

    if ($store) {
        $upd = $pdo->prepare(
            "UPDATE stores SET owner_uid = ?, owner_name = ?, phone = ? WHERE id = ?"
        );
        $upd->execute([$uid, $name, $phone, $store['id']]);
        $storeId = (int) $store['id'];
    } else {
        $ins = $pdo->prepare(
            "INSERT INTO stores
                (owner_uid, owner_name, email, password, phone, store_name, description, address, status)
             VALUES (?, ?, ?, '', ?, ?, 'Toko baru', '', 'active')"
        );
        $storeName = 'Toko ' . $name;
        $ins->execute([$uid, $name, $email, $phone, $storeName]);
        $storeId = (int) $pdo->lastInsertId();
    }

    jsonResponse('success', 'Owner berhasil disinkronisasi ke MySQL', [
        'uid' => $uid,
        'name' => $name,
        'email' => $email,
        'role' => 'owner',
        'store_id' => $storeId,
    ]);

} catch (PDOException $e) {
    jsonResponse('error', 'Gagal menyimpan ke database: ' . $e->getMessage(), null, 500);
}
?>
