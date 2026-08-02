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
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
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
        ]);

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

        return response()->json(['status' => 'success', 'message' => 'Pembayaran dikonfirmasi', 'data' => $order->fresh()]);
    }
}
