<?php

require __DIR__.'/vendor/autoload.php';

use GuzzleHttp\Client;

$client = new Client([
    'base_uri' => 'https://backend-ecommerce.synectra.xyz/api/',
    'timeout' => 10,
    'http_errors' => false,
]);

echo "Testing login with owner@ootday.com..." . PHP_EOL;
$res = $client->post('login', [
    'json' => [
        'email' => 'owner@ootday.com',
        'password' => 'owner123'
    ]
]);

echo "Status Code: " . $res->getStatusCode() . PHP_EOL;
echo "Response: " . $res->getBody() . PHP_EOL;
