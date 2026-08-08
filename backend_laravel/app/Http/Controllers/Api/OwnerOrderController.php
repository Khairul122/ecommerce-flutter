<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;

class OwnerOrderController extends Controller
{
    /**
     * Perbaikan audit: order_history_page.dart dan order_status_detail_page.dart
     * sebelumnya menampilkan jumlah dan status pesanan sebagai angka tetap
     * di kode. Endpoint ini menyediakan data pesanan sungguhan milik toko owner.
     */
    public function index(Request $request)
    {
        $store = $request->user()->store;
        $query = $store->orders()->with(['items', 'user', 'paymentMethod', 'shippingMethod']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return response()->json(['status' => 'success', 'data' => $query->orderByDesc('ordered_at')->get()]);
    }

    public function show(Request $request, Order $order)
    {
        if ($order->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        return response()->json(['status' => 'success', 'data' => $order->load(['items', 'user'])]);
    }

    /**
     * Owner menerima/menolak pesanan dan memperbarui status pengiriman.
     * Menggantikan home_page.dart / order_history_page.dart yang sebelumnya
     * tidak punya logika terima/tolak/update status sama sekali.
     */
    public function updateStatus(Request $request, Order $order)
    {
        if ($order->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $validator = Validator::make($request->all(), [
            'status' => ['required', Rule::in(['diproses', 'dikirim', 'selesai', 'dibatalkan'])],
            'cancel_reason' => ['required_if:status,dibatalkan', 'nullable', 'string'],
            'tracking_number' => ['nullable', 'string', 'max:100'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        if (! \Illuminate\Support\Facades\Schema::hasColumn('orders', 'tracking_number')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('tracking_number', 100)->nullable();
            });
        }
        if (! \Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_courier')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('shipping_courier', 50)->nullable();
            });
        }
        if (! \Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_service')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('shipping_service', 50)->nullable();
            });
        }
        if (! \Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_weight')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->integer('shipping_weight')->default(0);
            });
        }
        if (! \Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_etd')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('shipping_etd', 50)->nullable();
            });
        }

        if ($request->status === 'dibatalkan') {
            foreach ($order->items as $item) {
                if ($item->variant_id) {
                    \App\Models\ProductVariant::where('id', $item->variant_id)->increment('stock', $item->quantity);
                }
            }
        }

        $order->update([
            'status' => $request->status,
            'cancel_reason' => $request->status === 'dibatalkan' ? $request->cancel_reason : $order->cancel_reason,
            'tracking_number' => $request->filled('tracking_number') ? $request->tracking_number : $order->tracking_number,
        ]);

        \App\Services\NotificationService::notify(
            $order->user_id,
            'Status Pesanan Diperbarui',
            "Pesanan #{$order->id} sekarang {$request->status}.",
            'order',
            $order->id,
        );

        return response()->json(['status' => 'success', 'message' => 'Status pesanan diperbarui', 'data' => $order->fresh()]);
    }

    /**
     * Owner memverifikasi pembayaran pelanggan (payment_status: menunggu_konfirmasi -> paid).
     * Terintegrasi dengan Xendit Payment Gateway & konfirmasi manual owner.
     */
    public function confirmPayment(Request $request, Order $order)
    {
        if ($order->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        if ($order->payment_status !== 'menunggu_konfirmasi') {
            return response()->json(['status' => 'error', 'message' => 'Tidak ada pembayaran yang menunggu konfirmasi'], 422);
        }

        $order->update([
            'payment_status' => 'paid',
            'status' => $order->status === 'menunggu_pembayaran' ? 'diproses' : $order->status,
        ]);

        \App\Services\NotificationService::notify(
            $order->user_id,
            'Pesanan Diterima',
            "Pesanan #{$order->id} telah dikonfirmasi dan sedang diproses.",
            'order',
            $order->id,
        );

        return response()->json(['status' => 'success', 'message' => 'Pembayaran dikonfirmasi', 'data' => $order->fresh()]);
    }
}
