<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\PaymentMethod;
use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ProductVariant;
use App\Models\ShippingMethod;
use App\Models\Store;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Data contoh untuk pengembangan lokal. Dulunya ada di database/schema.sql
     * dan disisipkan otomatis oleh aplikasi Flutter lewat koneksi MySQL langsung
     * (mysql_service.dart). Sekarang seeding hanya lewat sini, dijalankan manual
     * lewat `php artisan db:seed`, tidak lagi berjalan otomatis dari aplikasi mobile.
     */
    public function run(): void
    {
        $owner = User::firstOrCreate(
            ['email' => 'owner@ootday.com'],
            [
                'name' => 'Ootday Owner',
                'password' => Hash::make('owner123'),
                'phone' => '081234567890',
                'role' => 'owner',
            ]
        );

        $store = Store::firstOrCreate(
            ['user_id' => $owner->id],
            [
                'store_name' => 'Ootday Fashion Store',
                'description' => 'Pusat Fashion Pria & Wanita Terlengkap',
                'address' => 'Jakarta, Indonesia',
                'phone' => '081234567890',
                'status' => 'active',
            ]
        );

        User::firstOrCreate(
            ['email' => 'guest@ootday.com'],
            [
                'name' => 'Guest User',
                'password' => Hash::make('guest123'),
                'phone' => '08000000000',
                'role' => 'pelanggan',
            ]
        );

        $categories = [
            'Pria' => 'assets/images/pria_icons.png',
            'Wanita' => 'assets/images/wanita_icons.png',
            'Rok' => 'assets/images/rok_icons.png',
            'Celana' => 'assets/images/celana_icons.png',
        ];
        $categoryIds = [];
        foreach ($categories as $name => $icon) {
            $cat = Category::firstOrCreate(
                ['store_id' => $store->id, 'name' => $name],
                ['icon_url' => $icon]
            );
            $categoryIds[$name] = $cat->id;
        }

        PaymentMethod::firstOrCreate(['name' => 'DANA'], ['type' => 'ewallet', 'is_active' => true]);
        PaymentMethod::firstOrCreate(['name' => 'GoPay'], ['type' => 'ewallet', 'is_active' => true]);
        PaymentMethod::firstOrCreate(['name' => 'OVO'], ['type' => 'ewallet', 'is_active' => true]);
        PaymentMethod::firstOrCreate(['name' => 'BCA Transfer'], ['type' => 'bank_transfer', 'is_active' => true]);
        PaymentMethod::firstOrCreate(['name' => 'Mandiri Transfer'], ['type' => 'bank_transfer', 'is_active' => true]);
        PaymentMethod::firstOrCreate(['name' => 'COD (Bayar di Tempat)'], ['type' => 'cod', 'is_active' => true]);

        ShippingMethod::firstOrCreate(['name' => 'Hemat Kargo - SPX Hemat'], ['base_cost' => 10000, 'is_active' => true]);
        ShippingMethod::firstOrCreate(['name' => 'Reguler - SPX Reguler'], ['base_cost' => 15000, 'is_active' => true]);
        ShippingMethod::firstOrCreate(['name' => 'Express - J&T Express'], ['base_cost' => 25000, 'is_active' => true]);

        $sampleProducts = [
            ['Trendy Red Dress', 'Wanita', 150000, 'assets/images/Produk_1.png'],
            ['Casual White Shirt', 'Pria', 95000, 'assets/images/produk_2.png'],
            ['Stylish Denim Jacket', 'Pria', 250000, 'assets/images/produk_3.png'],
            ['Floral Summer Skirt', 'Rok', 120000, 'assets/images/produk_4.png'],
            ['Black Leather Shoes', 'Pria', 300000, 'assets/images/produk_5.png'],
            ['Classic Blue Jeans', 'Celana', 180000, 'assets/images/produk_6.png'],
        ];

        foreach ($sampleProducts as [$name, $catName, $price, $img]) {
            $product = Product::firstOrCreate(
                ['store_id' => $store->id, 'name' => $name],
                [
                    'category_id' => $categoryIds[$catName],
                    'price' => $price,
                    'stock' => 100,
                    'status' => 'active',
                    'description' => 'Koleksi fashion berkualitas tinggi dan nyaman dipakai sehari-hari.',
                    'sold_count' => rand(5, 30),
                ]
            );

            ProductImage::firstOrCreate(
                ['product_id' => $product->id, 'image_url' => $img],
                ['is_primary' => true, 'sort_order' => 0]
            );

            foreach (['S', 'M', 'L', 'XL'] as $size) {
                ProductVariant::firstOrCreate(
                    ['product_id' => $product->id, 'size' => $size, 'color' => 'Default'],
                    ['stock' => 25, 'price' => $price, 'price_adjustment' => 0]
                );
            }
        }

        $this->command->info('Seeding selesai. Login owner: owner@ootday.com / owner123');
    }
}
