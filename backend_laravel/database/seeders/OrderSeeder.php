<?php

namespace Database\Seeders;

use App\Models\Order;
use App\Models\OrderItem;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\ShippingMethod;
use App\Models\Store;
use App\Models\User;
use Illuminate\Database\Seeder;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        $budi = User::where('email', 'budi@ootday.com')->first();
        $siti = User::where('email', 'siti@ootday.com')->first();
        $store = Store::first();
        $payDana = PaymentMethod::where('name', 'DANA')->first();
        $payBCA = PaymentMethod::where('name', 'BCA Transfer')->first();
        $shipReg = ShippingMethod::where('name', 'Reguler - SPX Reguler')->first();
        $shipExp = ShippingMethod::where('name', 'Express - J&T Express')->first();

        if (!$store || !$budi || !$siti) return;

        // Order 1: Budi Santoso - Status: Selesai
        $p1 = Product::find(1); // Pink Ribbon Bow Shirt
        $p2 = Product::find(102); // Casual White Shirt
        if ($p1 && $p2) {
            $subtotal = $p1->price + $p2->price;
            $shipCost = $shipReg ? $shipReg->base_cost : 15000;
            $order1 = Order::firstOrCreate(
                ['order_code' => 'ORD-20260801-001'],
                [
                    'user_id' => (string) $budi->id,
                    'store_id' => $store->id,
                    'payment_method_id' => $payDana ? $payDana->id : null,
                    'shipping_method_id' => $shipReg ? $shipReg->id : null,
                    'subtotal' => $subtotal,
                    'shipping_cost' => $shipCost,
                    'total_price' => $subtotal + $shipCost,
                    'status' => 'selesai',
                ]
            );

            OrderItem::firstOrCreate(
                ['order_id' => $order1->id, 'product_name' => $p1->name],
                [
                    'variant_label' => 'Size M, Putih',
                    'image_url' => 'assets/images/kemeja_wanita/1.jpeg',
                    'price' => $p1->price,
                    'quantity' => 1,
                ]
            );

            OrderItem::firstOrCreate(
                ['order_id' => $order1->id, 'product_name' => $p2->name],
                [
                    'variant_label' => 'Size L, Putih',
                    'image_url' => 'assets/images/produk_2.png',
                    'price' => $p2->price,
                    'quantity' => 1,
                ]
            );
        }

        // Order 2: Siti Rahma - Status: Diproses
        $p3 = Product::find(101); // Trendy Red Dress
        $p4 = Product::find(104); // Floral Summer Skirt
        if ($p3 && $p4) {
            $subtotal = $p3->price + $p4->price;
            $shipCost = $shipExp ? $shipExp->base_cost : 25000;
            $order2 = Order::firstOrCreate(
                ['order_code' => 'ORD-20260801-002'],
                [
                    'user_id' => (string) $siti->id,
                    'store_id' => $store->id,
                    'payment_method_id' => $payBCA ? $payBCA->id : null,
                    'shipping_method_id' => $shipExp ? $shipExp->id : null,
                    'subtotal' => $subtotal,
                    'shipping_cost' => $shipCost,
                    'total_price' => $subtotal + $shipCost,
                    'status' => 'diproses',
                ]
            );

            OrderItem::firstOrCreate(
                ['order_id' => $order2->id, 'product_name' => $p3->name],
                [
                    'variant_label' => 'Size S, Merah',
                    'image_url' => 'assets/images/Produk_1.png',
                    'price' => $p3->price,
                    'quantity' => 1,
                ]
            );

            OrderItem::firstOrCreate(
                ['order_id' => $order2->id, 'product_name' => $p4->name],
                [
                    'variant_label' => 'Size M, Multicolor',
                    'image_url' => 'assets/images/produk_4.png',
                    'price' => $p4->price,
                    'quantity' => 1,
                ]
            );
        }
    }
}
