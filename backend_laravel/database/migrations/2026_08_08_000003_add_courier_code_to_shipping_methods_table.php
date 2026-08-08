<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('shipping_methods', function (Blueprint $table) {
            // courier_code = kode kurir RajaOngkir (jne/pos/tiki/dst). base_cost tidak
            // dipakai lagi untuk hitung ongkir (ongkir sekarang live dari RajaOngkir),
            // dibiarkan ada untuk kompatibilitas data lama.
            $table->string('courier_code', 20)->nullable()->after('name');
        });
    }

    public function down(): void
    {
        Schema::table('shipping_methods', function (Blueprint $table) {
            $table->dropColumn('courier_code');
        });
    }
};
