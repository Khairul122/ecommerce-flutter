<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // 0. Akun Admin Panel
        User::firstOrCreate(
            ['email' => 'admin@ootday.com'],
            [
                'name' => 'Ootday Admin',
                'password' => Hash::make('admin123'),
                'phone' => '081200000000',
                'role' => 'admin',
            ]
        );

        // 1. Akun Owner Toko
        User::firstOrCreate(
            ['email' => 'owner@ootday.com'],
            [
                'name' => 'Ootday Owner',
                'password' => Hash::make('owner123'),
                'phone' => '081234567890',
                'role' => 'owner',
            ]
        );

        // 2. Akun Guest / Default Pelanggan
        User::firstOrCreate(
            ['email' => 'guest@ootday.com'],
            [
                'name' => 'Guest User',
                'password' => Hash::make('guest123'),
                'phone' => '08000000000',
                'role' => 'pelanggan',
            ]
        );

        // 3. Pelanggan Sample 1: Budi Santoso
        User::firstOrCreate(
            ['email' => 'budi@ootday.com'],
            [
                'name' => 'Budi Santoso',
                'password' => Hash::make('pelanggan123'),
                'phone' => '081298765432',
                'role' => 'pelanggan',
            ]
        );

        // 4. Pelanggan Sample 2: Siti Rahma
        User::firstOrCreate(
            ['email' => 'siti@ootday.com'],
            [
                'name' => 'Siti Rahma',
                'password' => Hash::make('pelanggan123'),
                'phone' => '081311223344',
                'role' => 'pelanggan',
            ]
        );
    }
}
