<?php

namespace Database\Seeders;

use App\Models\Store;
use App\Models\User;
use Illuminate\Database\Seeder;

class StoreSeeder extends Seeder
{
    public function run(): void
    {
        $owner = User::where('role', 'owner')->first();

        if ($owner) {
            Store::firstOrCreate(
                ['user_id' => $owner->id],
                [
                    'store_name' => 'Ootday Fashion Store',
                    'description' => 'Pusat Fashion Pria & Wanita Terlengkap, berkualitas tinggi dan nyaman dipakai sehari-hari.',
                    'address' => 'Jl. Sudirman No. 100, Jakarta Pusat, DKI Jakarta',
                    'phone' => '081234567890',
                    'status' => 'active',
                ]
            );
        }
    }
}
