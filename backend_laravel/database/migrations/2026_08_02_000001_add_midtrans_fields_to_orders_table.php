<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->string('snap_token')->nullable()->after('payment_proof_url');
            $table->string('snap_redirect_url')->nullable()->after('snap_token');
            $table->string('payment_type', 50)->nullable()->after('snap_redirect_url');
        });
    }

    public function down(): void
    {
        Schema::table('orders', function (Blueprint $table) {
            $table->dropColumn(['snap_token', 'snap_redirect_url', 'payment_type']);
        });
    }
};
