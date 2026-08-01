<?php

namespace Database\Seeders;

use App\Models\PaymentMethod;
use App\Models\ShippingMethod;
use Illuminate\Database\Seeder;

class PaymentShippingSeeder extends Seeder
{
    public function run(): void
    {
        // Payment Methods
        $payments = [
            ['name' => 'QRIS (GoPay / ShopeePay / All Bank)', 'type' => 'qris'],
            ['name' => 'GoPay', 'type' => 'ewallet'],
            ['name' => 'ShopeePay', 'type' => 'ewallet'],
            ['name' => 'BCA Transfer', 'type' => 'bank_transfer'],
            ['name' => 'COD (Bayar di Tempat)', 'type' => 'cod'],
        ];

        foreach ($payments as $p) {
            PaymentMethod::firstOrCreate(
                ['name' => $p['name']],
                ['type' => $p['type'], 'is_active' => true]
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
