<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\File;

class DatabaseSeeder extends Seeder
{
    /**
     * Master Seeder Ootday.
     * Mengisi seluruh data aplikasi Ootday dan menyalin file gambar ke storage public.
     */
    public function run(): void
    {
        $this->command->info('Memulai seeding database Ootday...');

        // 1. Menyalin Aset Gambar ke Storage Publik
        $this->copyImageAssetsToStorage();

        // 2. Menjalankan Seeder Modular
        $this->call([
            UserSeeder::class,
            StoreSeeder::class,
            CategorySeeder::class,
            ProductSeeder::class,
            AddressSeeder::class,
            PaymentShippingSeeder::class,
            OrderSeeder::class,
            ConversationSeeder::class,
        ]);

        $this->command->info('Seeding database Ootday selesai!');
        $this->command->info('Akun Owner: owner@ootday.com / owner123');
        $this->command->info('Akun Pelanggan: budi@ootday.com / pelanggan123');
        $this->command->info('Akun Guest: guest@ootday.com / guest123');
    }

    /**
     * Salin semua file gambar dari folder assets Flutter ke storage/app/public/seed_images
     */
    private function copyImageAssetsToStorage(): void
    {
        $possibleSources = [
            base_path('../ootday_pelanggan/assets/images'),
            base_path('public/assets/images'),
            public_path('assets/images'),
        ];

        $sourceDir = null;
        foreach ($possibleSources as $dir) {
            if (File::exists($dir)) {
                $sourceDir = $dir;
                break;
            }
        }

        $destDir = storage_path('app/public/seed_images');

        if (!$sourceDir) {
            $this->command->warn("Info: Direktori sumber gambar lokal tidak ditemukan, menggunakan jalur aset Flutter default.");
            return;
        }

        if (!File::exists($destDir)) {
            File::makeDirectory($destDir, 0755, true);
        }

        File::copyDirectory($sourceDir, $destDir);
        $this->command->info("Berhasil menyalin seluruh gambar produk ke: {$destDir}");
    }
}
