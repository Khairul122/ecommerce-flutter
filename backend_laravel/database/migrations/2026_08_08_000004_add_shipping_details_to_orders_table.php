<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            if (!Schema::hasColumn('orders', 'shipping_courier')) {
                $table->string('shipping_courier', 50)->nullable()->after('shipping_cost');
            }
            if (!Schema::hasColumn('orders', 'shipping_service')) {
                $table->string('shipping_service', 50)->nullable();
            }
            if (!Schema::hasColumn('orders', 'shipping_weight')) {
                $table->integer('shipping_weight')->default(0)->comment('Berat total dalam gram');
            }
            if (!Schema::hasColumn('orders', 'shipping_etd')) {
                $table->string('shipping_etd', 50)->nullable();
            }
            if (!Schema::hasColumn('orders', 'tracking_number')) {
                $table->string('tracking_number', 100)->nullable()->comment('Nomor resi pengiriman');
            }
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $columnsToDrop = [];
            foreach (['shipping_courier', 'shipping_service', 'shipping_weight', 'shipping_etd', 'tracking_number'] as $col) {
                if (Schema::hasColumn('orders', $col)) {
                    $columnsToDrop[] = $col;
                }
            }
            if (!empty($columnsToDrop)) {
                $table->dropColumn($columnsToDrop);
            }
        });
    }
};
