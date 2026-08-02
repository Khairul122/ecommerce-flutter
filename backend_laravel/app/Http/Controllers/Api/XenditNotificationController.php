<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Exception;

class XenditNotificationController extends Controller
{
    /**
     * Menangani webhook callback dari Xendit (Invoice & QRIS)
     * POST /api/xendit/callback
     */
    public function handle(Request $request)
    {
        $payload = $request->all();

        Log::info('Xendit Callback Notification Received', [
            'headers' => $request->headers->all(),
            'payload' => $payload,
        ]);

        // Opsional: Verifikasi Callback Token dari Xendit jika diatur di .env
        $callbackToken = config('xendit.callback_token');
        if (!empty($callbackToken)) {
            $headerToken = $request->header('x-callback-token');
            if ($headerToken !== $callbackToken) {
                Log::warning('Xendit Invalid Callback Token Header', ['received' => $headerToken]);
                return response()->json(['status' => 'error', 'message' => 'Unauthorized callback token'], 401);
            }
        }

        try {
            $externalId = $payload['external_id'] ?? null;
            $status = strtoupper($payload['status'] ?? '');
            $invoiceId = $payload['id'] ?? null;

            if (empty($externalId)) {
                return response()->json(['status' => 'ignored', 'message' => 'No external_id provided'], 200);
            }

            // Extract Order ID dari external_id (format: ORD-{order_id}-{timestamp} atau QRIS-{order_id}-{timestamp})
            $orderId = null;
            if (preg_match('/^(ORD|QRIS)-(\d+)/i', $externalId, $matches)) {
                $orderId = (int) $matches[2];
            }

            $order = null;
            if ($orderId) {
                $order = Order::find($orderId);
            }

            if (!$order && $invoiceId) {
                $order = Order::where('snap_token', $invoiceId)->first();
            }

            if (!$order) {
                Log::warning('Xendit Callback Order Not Found', ['external_id' => $externalId, 'invoice_id' => $invoiceId]);
                return response()->json(['status' => 'not_found', 'message' => 'Order not found'], 404);
            }

            // Update status pesanan berdasarkan callback Xendit
            if (in_array($status, ['PAID', 'SETTLED', 'COMPLETED'])) {
                $order->update([
                    'status' => 'diproses',
                    'payment_status' => 'paid',
                    'paid_at' => now(),
                ]);

                \App\Services\NotificationService::notify(
                    $order->user_id,
                    'Pembayaran Berhasil',
                    "Pembayaran untuk pesanan #{$order->id} telah diterima.",
                    'payment',
                    $order->id,
                );

                Log::info('Order #' . $order->id . ' marked as PAID via Xendit webhook');
            } elseif (in_array($status, ['EXPIRED', 'FAILED', 'CANCELLED'])) {
                if ($order->status === 'menunggu_pembayaran') {
                    $order->update([
                        'status' => 'dibatalkan',
                        'payment_status' => 'dibatalkan',
                    ]);

                    \App\Services\NotificationService::notify(
                        $order->user_id,
                        'Pembayaran Gagal',
                        "Pesanan #{$order->id} dibatalkan karena pembayaran tidak berhasil.",
                        'payment',
                        $order->id,
                    );

                    Log::info('Order #' . $order->id . ' marked as CANCELLED via Xendit webhook');
                }
            }

            return response()->json([
                'status' => 'success',
                'message' => 'Webhook callback processed successfully',
                'order_id' => $order->id,
                'new_order_status' => $order->status,
            ], 200);
        } catch (Exception $e) {
            Log::error('Error processing Xendit Callback', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
            ]);

            return response()->json([
                'status' => 'error',
                'message' => 'Internal server error processing callback',
            ], 500);
        }
    }
}
