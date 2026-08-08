<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            if (!Schema::hasColumn('addresses', 'province_id')) {
                $table->unsignedBigInteger('province_id')->nullable()->after('phone');
            }
            if (!Schema::hasColumn('addresses', 'province_name')) {
                $table->string('province_name', 100)->nullable();
            }
            if (!Schema::hasColumn('addresses', 'city_id')) {
                $table->unsignedBigInteger('city_id')->nullable();
            }
            if (!Schema::hasColumn('addresses', 'city_name')) {
                $table->string('city_name', 100)->nullable();
            }
        });
    }

    public function down(): void
    {
        Schema::table('addresses', function (Blueprint $table) {
            $columnsToDrop = [];
            foreach (['province_id', 'province_name', 'city_id', 'city_name'] as $col) {
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
