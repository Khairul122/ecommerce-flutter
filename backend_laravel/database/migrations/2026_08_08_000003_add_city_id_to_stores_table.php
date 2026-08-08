<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            if (!Schema::hasColumn('stores', 'city_id')) {
                $table->unsignedBigInteger('city_id')->default(153)->after('address')->comment('Default: 153 (Jakarta Selatan) untuk origin RajaOngkir');
            }
            if (!Schema::hasColumn('stores', 'city_name')) {
                $table->string('city_name', 100)->default('Jakarta Selatan');
            }
        });
    }

    public function down(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $columnsToDrop = [];
            foreach (['city_id', 'city_name'] as $col) {
                if (Schema::hasColumn('stores', $col)) {
                    $columnsToDrop[] = $col;
                }
            }
            if (!empty($columnsToDrop)) {
                $table->dropColumn($columnsToDrop);
            }
        });
    }
};
