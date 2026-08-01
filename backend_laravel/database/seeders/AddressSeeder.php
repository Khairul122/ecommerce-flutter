<?php

namespace Database\Seeders;

use App\Models\Address;
use App\Models\User;
use Illuminate\Database\Seeder;

class AddressSeeder extends Seeder
{
    public function run(): void
    {
        $budi = User::where('email', 'budi@ootday.com')->first();
        if ($budi) {
            Address::firstOrCreate(
                ['user_id' => (string) $budi->id, 'is_main' => true],
                [
                    'receiver_name' => 'Budi Santoso',
                    'phone' => '081298765432',
                    'full_address' => 'Jl. Sudirman No. 45, RT 02 / RW 05, Kebayoran Baru, Jakarta Selatan, DKI Jakarta 12190',
                ]
            );
        }

        $siti = User::where('email', 'siti@ootday.com')->first();
        if ($siti) {
            Address::firstOrCreate(
                ['user_id' => (string) $siti->id, 'is_main' => true],
                [
                    'receiver_name' => 'Siti Rahma',
                    'phone' => '081311223344',
                    'full_address' => 'Jl. Diponegoro No. 12, Dago, Coblong, Kota Bandung, Jawa Barat 40135',
                ]
            );
        }
    }
}
