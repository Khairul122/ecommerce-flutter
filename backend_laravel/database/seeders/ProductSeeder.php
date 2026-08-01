<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\ProductImage;
use App\Models\ProductVariant;
use App\Models\Store;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $store = Store::first();
        if (!$store) return;

        // Data Produk
        $products = [
            // --- Homepage Featured Products ---
            [
                'id' => 101,
                'category_id' => 2,
                'name' => 'Trendy Red Dress',
                'price' => 150000,
                'stock' => 100,
                'sold_count' => 15,
                'description' => 'Dress merah elegan dengan potongan modern, cocok untuk acara formal maupun santai.',
                'primary_image' => 'assets/images/Produk_1.png',
                'extra_images' => ['assets/images/produk_1.1.png', 'assets/images/produk_1.2.png'],
                'color' => 'Merah',
            ],
            [
                'id' => 102,
                'category_id' => 1,
                'name' => 'Casual White Shirt',
                'price' => 95000,
                'stock' => 100,
                'sold_count' => 25,
                'description' => 'Kemeja kasual warna putih dari bahan katun premium yang adem dan nyaman digunakan seharian.',
                'primary_image' => 'assets/images/produk_2.png',
                'extra_images' => [],
                'color' => 'Putih',
            ],
            [
                'id' => 103,
                'category_id' => 1,
                'name' => 'Stylish Denim Jacket',
                'price' => 250000,
                'stock' => 100,
                'sold_count' => 8,
                'description' => 'Jaket denim bergaya streetwear dengan detail jahitan rapi dan warna durable.',
                'primary_image' => 'assets/images/produk_3.png',
                'extra_images' => [],
                'color' => 'Biru Denim',
            ],
            [
                'id' => 104,
                'category_id' => 3,
                'name' => 'Floral Summer Skirt',
                'price' => 120000,
                'stock' => 100,
                'sold_count' => 12,
                'description' => 'Rok musim panas bermotif bunga yang anggun, memberikan tampilan segar dan feminin.',
                'primary_image' => 'assets/images/produk_4.png',
                'extra_images' => [],
                'color' => 'Multicolor',
            ],
            [
                'id' => 105,
                'category_id' => 1,
                'name' => 'Black Leather Shoes',
                'price' => 300000,
                'stock' => 100,
                'sold_count' => 5,
                'description' => 'Sepatu kulit hitam formal berkualitas tinggi untuk penampilan maskulin dan profesional.',
                'primary_image' => 'assets/images/produk_5.png',
                'extra_images' => [],
                'color' => 'Hitam',
            ],
            [
                'id' => 106,
                'category_id' => 4,
                'name' => 'Classic Blue Jeans',
                'price' => 180000,
                'stock' => 100,
                'sold_count' => 30,
                'description' => 'Celana jeans klasik potongan regular fit, kuat dan cocok dipadukan dengan berbagai atasan.',
                'primary_image' => 'assets/images/produk_6.png',
                'extra_images' => [],
                'color' => 'Navy',
            ],
        ];

        // --- Kemeja Wanita (ID 1 - 20) ---
        $wNames = [
            1 => 'Pink Ribbon Bow Shirt – Kemeja Pita Cantik',
            2 => 'Cream Bow Ruffle Blouse',
            3 => 'Wide Collar Drawstring Sleeve Blouse',
            4 => 'Kemeja Wanita Elegan Style 4',
            5 => 'Kemeja Wanita Elegan Style 5',
            6 => 'Kemeja Wanita Elegan Style 6',
            7 => 'Kemeja Wanita Elegan Style 7',
            8 => 'Kemeja Wanita Elegan Style 8',
            9 => 'Kemeja Wanita Elegan Style 9',
            10 => 'Kemeja Wanita Elegan Style 10',
            11 => 'Kemeja Wanita Elegan Style 11',
            12 => 'Kemeja Wanita Elegan Style 12',
            13 => 'Kemeja Wanita Elegan Style 13',
            14 => 'Kemeja Wanita Elegan Style 14',
            15 => 'Kemeja Wanita Elegan Style 15',
            16 => 'Kemeja Wanita Elegan Style 16',
            17 => 'Kemeja Wanita Elegan Style 17',
            18 => 'Kemeja Wanita Elegan Style 18',
            19 => 'Kemeja Wanita Elegan Style 19',
            20 => 'Kemeja Wanita Elegan Style 20',
        ];

        $wPrices = [
            1 => 95000, 2 => 90000, 3 => 95000, 4 => 115000, 5 => 120000,
            6 => 125000, 7 => 130000, 8 => 135000, 9 => 140000, 10 => 145000,
            11 => 150000, 12 => 155000, 13 => 160000, 14 => 165000, 15 => 170000,
            16 => 175000, 17 => 180000, 18 => 185000, 19 => 190000, 20 => 195000,
        ];

        for ($i = 1; $i <= 20; $i++) {
            $products[] = [
                'id' => $i,
                'category_id' => 2, // Wanita
                'name' => $wNames[$i],
                'price' => $wPrices[$i],
                'stock' => 100,
                'sold_count' => rand(5, 40),
                'description' => 'Kemeja & Blouse wanita elegan dengan desain kekinian, bahan adem dan jahitan super presisi.',
                'primary_image' => "assets/images/kemeja_wanita/{$i}.jpeg",
                'extra_images' => [],
                'color' => 'Putih',
            ];
        }

        // --- Kemeja Pria (ID 21 - 25) ---
        for ($i = 21; $i <= 25; $i++) {
            $num = $i - 20;
            $products[] = [
                'id' => $i,
                'category_id' => 1, // Pria
                'name' => "Kemeja Pria Exclusive {$num}",
                'price' => 150000 + ($num * 10000),
                'stock' => 100,
                'sold_count' => rand(10, 50),
                'description' => 'Kemeja pria eksklusif dari bahan pilihan, sangat nyaman dipakai untuk kerja maupun acara santai.',
                'primary_image' => "assets/images/kemeja_pria/{$num}.jpeg",
                'extra_images' => [],
                'color' => 'Hitam',
            ];
        }

        // --- Rok (ID 26 - 31) ---
        $rNames = [
            26 => 'Asymmetrical Layered Floral Skirt',
            27 => 'Floral Pleated Long Skirt',
            28 => 'Rok Cantik Koleksi 3',
            29 => 'Rok Cantik Koleksi 4',
            30 => 'Rok Cantik Koleksi 5',
            31 => 'Rok Cantik Koleksi 6',
        ];
        for ($i = 26; $i <= 31; $i++) {
            $num = $i - 25;
            $products[] = [
                'id' => $i,
                'category_id' => 3, // Rok
                'name' => $rNames[$i],
                'price' => 100000 + ($num * 15000),
                'stock' => 100,
                'sold_count' => rand(8, 35),
                'description' => 'Koleksi rok wanita terbaru yang stylish, fleksibel, dan memberikan kesan elegan.',
                'primary_image' => "assets/images/Rok/{$num}.jpeg",
                'extra_images' => [],
                'color' => 'Navy',
            ];
        }

        // --- Celana (ID 32 - 36) ---
        $cImages = ['cowo1.jpeg', 'cowo2.jpeg', 'cowo3.jpeg', 'cewe1.jpeg', 'cewe2.jpeg'];
        $cNames = [
            32 => 'High Waist Slim Fit Denim Pants',
            33 => 'Celana Trend Terbaru 2',
            34 => 'Celana Trend Terbaru 3',
            35 => 'Celana Trend Terbaru 4',
            36 => 'Celana Trend Terbaru 5',
        ];
        for ($i = 32; $i <= 36; $i++) {
            $idx = $i - 32;
            $products[] = [
                'id' => $i,
                'category_id' => 4, // Celana
                'name' => $cNames[$i],
                'price' => 130000 + ($idx * 10000),
                'stock' => 100,
                'sold_count' => rand(15, 60),
                'description' => 'Celana modern berbahan lentur dan tahan lama, cocok dipadukan dengan gaya kasual sehari-hari.',
                'primary_image' => "assets/images/celana/{$cImages[$idx]}",
                'extra_images' => [],
                'color' => 'Hitam',
            ];
        }

        // Memasukkan ke Database
        foreach ($products as $p) {
            $product = Product::updateOrCreate(
                ['id' => $p['id']],
                [
                    'store_id' => $store->id,
                    'category_id' => $p['category_id'],
                    'name' => $p['name'],
                    'price' => $p['price'],
                    'stock' => $p['stock'],
                    'status' => 'active',
                    'description' => $p['description'],
                    'sold_count' => $p['sold_count'],
                ]
            );

            // Seed Gambar Utama
            ProductImage::updateOrCreate(
                ['product_id' => $product->id, 'sort_order' => 0],
                ['image_url' => $p['primary_image'], 'is_primary' => true]
            );

            // Seed Gambar Sekunder
            foreach ($p['extra_images'] as $order => $extraImg) {
                ProductImage::updateOrCreate(
                    ['product_id' => $product->id, 'sort_order' => $order + 1],
                    ['image_url' => $extraImg, 'is_primary' => false]
                );
            }

            // Seed Varian Ukuran (S, M, L, XL)
            foreach (['S', 'M', 'L', 'XL'] as $size) {
                ProductVariant::updateOrCreate(
                    ['product_id' => $product->id, 'size' => $size, 'color' => $p['color']],
                    ['stock' => 25, 'price' => $p['price'], 'price_adjustment' => 0]
                );
            }
        }
    }
}
