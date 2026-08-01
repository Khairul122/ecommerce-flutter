<?php

namespace App\Services;

use App\Models\Order;
use App\Models\ProductVariant;
use Illuminate\Support\Facades\Log;

class MidtransService
{
    public function __construct()
    {
        $this->ensureSDKLoaded();
        $this->configure();
    }

    protected function ensureSDKLoaded(): void
    {
        if (!class_exists(\Midtrans\Config::class)) {
            $sdkPath = app_path('Services/MidtransSDK/Midtrans.php');
            if (file_exists($sdkPath)) {
                require_once $sdkPath;
            }
        }
    }

    protected function configure(): void
    {
        $this->ensureSDKLoaded();
        $serverKey = config('midtrans.server_key');
        $isProduction = config('midtrans.is_production');

        if (str_starts_with($serverKey, 'SB-')) {
            $isProduction = false;
        } elseif (str_starts_with($serverKey, 'Mid-server-')) {
            $isProduction = true;
        }

        \Midtrans\Config::$serverKey = $serverKey;
        \Midtrans\Config::$clientKey = config('midtrans.client_key');
        \Midtrans\Config::$isProduction = (bool) $isProduction;
        \Midtrans\Config::$isSanitized = (bool) config('midtrans.is_sanitized');
        \Midtrans\Config::$is3ds = (bool) config('midtrans.is_3ds');
    }

    /**
     * Membuat Snap Token dan Redirect URL dari Midtrans untuk sebuah pesanan.
     */
    public function createSnapTransaction(Order $order): array
    {
        $this->configure();

        $order->loadMissing(['user', 'items']);

        $itemDetails = [];
        foreach ($order->items as $item) {
            $itemDetails[] = [
                'id' => 'ITEM-'.$item->product_id.'-'.$item->variant_id,
                'price' => (int) round($item->price),
                'quantity' => $item->quantity,
                'name' => mb_substr($item->product_name.' ('.$item->variant_label.')', 0, 50),
            ];
        }

        if ($order->shipping_cost > 0) {
            $itemDetails[] = [
                'id' => 'SHIPPING',
                'price' => (int) round($order->shipping_cost),
                'quantity' => 1,
                'name' => 'Ongkos Kirim',
            ];
        }

        $params = [
            'transaction_details' => [
                'order_id' => $order->order_code,
                'gross_amount' => (int) round($order->total_price),
            ],
            'enabled_payments' => ['gopay', 'shopeepay', 'other_qris'],
            'customer_details' => [
                'first_name' => $order->receiver_name,
                'email' => $order->user->email ?? 'buyer@ootday.com',
                'phone' => $order->receiver_phone,
            ],
            'item_details' => $itemDetails,
        ];

        try {
            $snapResponse = \Midtrans\Snap::createTransaction($params);

            $order->update([
                'snap_token' => $snapResponse->token ?? null,
                'snap_redirect_url' => $snapResponse->redirect_url ?? null,
            ]);

            return [
                'snap_token' => $snapResponse->token ?? null,
                'snap_redirect_url' => $snapResponse->redirect_url ?? null,
            ];
        } catch (\Exception $e) {
            Log::error('Midtrans Snap Transaction Error: '.$e->getMessage(), [
                'order_code' => $order->order_code,
            ]);

            return [
                'snap_token' => null,
                'snap_redirect_url' => null,
                'error' => $e->getMessage(),
            ];
        }
    }

    /**
     * Memproses Webhook/Notification HTTP Callback dari Midtrans.
     */
    public function handleNotification(array $payload): bool
    {
        $orderCode = $payload['order_id'] ?? null;
        $statusCode = $payload['status_code'] ?? null;
        $grossAmount = $payload['gross_amount'] ?? null;
        $signatureKey = $payload['signature_key'] ?? null;
        $transactionStatus = $payload['transaction_status'] ?? null;
        $fraudStatus = $payload['fraud_status'] ?? null;
        $paymentType = $payload['payment_type'] ?? null;

        if (!$orderCode || !$signatureKey) {
            Log::warning('Midtrans Webhook: Payload tidak valid', $payload);
            return false;
        }

        // Verifikasi Signature Hash SHA512
        $serverKey = config('midtrans.server_key');
        $expectedSignature = hash('sha512', $orderCode . $statusCode . $grossAmount . $serverKey);

        if ($signatureKey !== $expectedSignature) {
            Log::warning('Midtrans Webhook: Signature Key tidak cocok!', [
                'received' => $signatureKey,
                'expected' => $expectedSignature,
            ]);
            return false;
        }

        $order = Order::where('order_code', $orderCode)->first();
        if (!$order) {
            Log::error('Midtrans Webhook: Order tidak ditemukan', ['order_code' => $orderCode]);
            return false;
        }

        // Update tipe pembayaran (gopay, bank_transfer, qris, dll)
        if ($paymentType) {
            $order->payment_type = $paymentType;
        }

        if ($transactionStatus === 'capture') {
            if ($fraudStatus === 'accept') {
                $order->payment_status = 'paid';
                $order->status = 'diproses';
            }
        } elseif ($transactionStatus === 'settlement') {
            $order->payment_status = 'paid';
            $order->status = 'diproses';
        } elseif ($transactionStatus === 'pending') {
            $order->payment_status = 'unpaid';
        } elseif (in_array($transactionStatus, ['deny', 'expire', 'cancel'])) {
            if ($order->status !== 'dibatalkan') {
                $order->payment_status = 'dibatalkan';
                $order->status = 'dibatalkan';
                $order->cancel_reason = 'Pembayaran Midtrans '. $transactionStatus;

                // Kembalikan stok varian produk
                foreach ($order->items as $item) {
                    if ($item->variant_id) {
                        ProductVariant::where('id', $item->variant_id)->increment('stock', $item->quantity);
                    }
                }
            }
        }

        $order->save();

        Log::info('Midtrans Webhook Sukses Memproses Pesanan', [
            'order_code' => $orderCode,
            'payment_status' => $order->payment_status,
            'status' => $order->status,
        ]);

        return true;
    }
}
