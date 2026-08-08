<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            $table->unsignedInteger('district_id')->nullable()->after('full_address');
            $table->string('district_name')->nullable()->after('district_id');
            $table->string('city_name')->nullable()->after('district_name');
            $table->string('province_name')->nullable()->after('city_name');
            $table->string('postal_code', 10)->nullable()->after('province_name');
        });
    }

    public function down(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            $table->dropColumn(['district_id', 'district_name', 'city_name', 'province_name', 'postal_code']);
        });
    }
};
