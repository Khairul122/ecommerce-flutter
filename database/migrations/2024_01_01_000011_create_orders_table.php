<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up(): void
    {
        Schema::create('orders', function (Blueprint $table) {
            $table->id();
            $table->string('order_code', 50)->unique();
            $table->foreignId('user_id')->constrained('users')->cascadeOnDelete();
            $table->foreignId('store_id')->constrained('stores')->cascadeOnDelete();
            $table->foreignId('payment_method_id')->nullable()->constrained('payment_methods')->nullOnDelete();
            $table->foreignId('shipping_method_id')->nullable()->constrained('shipping_methods')->nullOnDelete();

            $table->string('receiver_name', 100);
            $table->string('receiver_phone', 20);
            $table->text('shipping_address');

            $table->decimal('subtotal', 15, 2);
            $table->decimal('shipping_cost', 15, 2);
            $table->decimal('total_price', 15, 2);

            // status = status pemenuhan pesanan oleh toko
            $table->enum('status', ['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai', 'dibatalkan'])
                ->default('menunggu_pembayaran');
            // payment_status = status pembayaran, terpisah dari status pemenuhan
            $table->enum('payment_status', ['unpaid', 'menunggu_konfirmasi', 'paid'])->default('unpaid');
            $table->string('payment_proof_url')->nullable();
            $table->string('cancel_reason')->nullable();

            $table->timestamp('ordered_at')->useCurrent();
            $table->timestamps();

            $table->index(['user_id', 'status']);
            $table->index(['store_id', 'status']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('orders');
    }
};
