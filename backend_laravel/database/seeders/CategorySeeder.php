<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Store;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $store = Store::first();
        if (!$store) return;

        $categories = [
            [
                'id' => 1,
                'name' => 'Pria',
                'icon' => 'assets/images/pria icons.png',
            ],
            [
                'id' => 2,
                'name' => 'Wanita',
                'icon' => 'assets/images/wanita_icons.png',
            ],
            [
                'id' => 3,
                'name' => 'Rok',
                'icon' => 'assets/images/rok_icons.png',
            ],
            [
                'id' => 4,
                'name' => 'Celana',
                'icon' => 'assets/images/celana_icons.png',
            ],
        ];

        foreach ($categories as $cat) {
            Category::updateOrCreate(
                ['id' => $cat['id']],
                [
                    'store_id' => $store->id,
                    'name' => $cat['name'],
                    'icon_url' => $cat['icon'],
                ]
            );
        }
    }
}
