<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            if (!Schema::hasColumn('addresses', 'district_id')) {
                $table->unsignedInteger('district_id')->nullable()->after('full_address');
            }
            if (!Schema::hasColumn('addresses', 'district_name')) {
                $table->string('district_name')->nullable();
            }
            if (!Schema::hasColumn('addresses', 'city_name')) {
                $table->string('city_name')->nullable();
            }
            if (!Schema::hasColumn('addresses', 'province_name')) {
                $table->string('province_name')->nullable();
            }
            if (!Schema::hasColumn('addresses', 'postal_code')) {
                $table->string('postal_code', 10)->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            $columnsToDrop = [];
            foreach (['district_id', 'district_name', 'city_name', 'province_name', 'postal_code'] as $col) {
                if (Schema::hasColumn('addresses', $col)) {
                    $columnsToDrop[] = $col;
                }
            }
            if (!empty($columnsToDrop)) {
                $table->dropColumn($columnsToDrop);
            }
        });
    }
};
