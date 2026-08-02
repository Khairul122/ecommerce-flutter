<?php

namespace Database\Seeders;

use App\Models\PaymentMethod;
use App\Models\ShippingMethod;
use Illuminate\Database\Seeder;

class PaymentShippingSeeder extends Seeder
{
    public function run(): void
    {
        // Payment Methods (Shopee Checkout Style - Xendit Integrated)
        $payments = [
            ['name' => 'QRIS (GoPay, ShopeePay, DANA, OVO, m-Banking)', 'type' => 'qris', 'code' => 'QRIS'],
            ['name' => 'BCA Virtual Account', 'type' => 'bank_transfer', 'code' => 'BCA'],
            ['name' => 'Mandiri Virtual Account', 'type' => 'bank_transfer', 'code' => 'MANDIRI'],
            ['name' => 'BNI Virtual Account', 'type' => 'bank_transfer', 'code' => 'BNI'],
            ['name' => 'BRI Virtual Account', 'type' => 'bank_transfer', 'code' => 'BRI'],
            ['name' => 'Permata Virtual Account', 'type' => 'bank_transfer', 'code' => 'PERMATA'],
            ['name' => 'ShopeePay / E-Wallet', 'type' => 'ewallet', 'code' => 'SHOPEEPAY'],
            ['name' => 'GoPay', 'type' => 'ewallet', 'code' => 'GOPAY'],
            ['name' => 'COD (Bayar di Tempat)', 'type' => 'cod', 'code' => 'COD'],
        ];

        foreach ($payments as $p) {
            PaymentMethod::updateOrCreate(
                ['name' => $p['name']],
                ['type' => $p['type'], 'code' => $p['code'] ?? null, 'is_active' => true]
            );
        }

        // Shipping Methods
        $shippings = [
            ['name' => 'Hemat Kargo - SPX Hemat', 'base_cost' => 10000],
            ['name' => 'Reguler - SPX Reguler', 'base_cost' => 15000],
            ['name' => 'Express - J&T Express', 'base_cost' => 25000],
        ];

        foreach ($shippings as $s) {
            ShippingMethod::firstOrCreate(
                ['name' => $s['name']],
                ['base_cost' => $s['base_cost'], 'is_active' => true]
            );
        }
    }
}
