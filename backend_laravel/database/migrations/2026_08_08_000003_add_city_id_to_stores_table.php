<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->unsignedBigInteger('city_id')->default(153)->after('address')->comment('Default: 153 (Jakarta Selatan) untuk origin RajaOngkir');
            $table->string('city_name', 100)->default('Jakarta Selatan')->after('city_id');
        });
    }

    public function down(): void
    {
        Schema::table('stores', function (Blueprint $table) {
            $table->dropColumn(['city_id', 'city_name']);
        });
    }
};
