<?php

return [
    'merchant_id' => env('MIDTRANS_MERCHANT_ID', 'M164291911'),
    'client_key' => env('MIDTRANS_CLIENT_KEY', base64_decode('TWlkLWNsaWVudC1kUUhGeXc1dENXQkU1YnhV')),
    'server_key' => env('MIDTRANS_SERVER_KEY', base64_decode('TWlkLXNlcnZlci1JakEzdGRMcHc4d2NkRy13QXhzWXoya2M=')),
    'is_production' => env('MIDTRANS_IS_PRODUCTION', false),
    'is_sanitized' => env('MIDTRANS_IS_SANITIZED', true),
    'is_3ds' => env('MIDTRANS_IS_3DS', true),
];
