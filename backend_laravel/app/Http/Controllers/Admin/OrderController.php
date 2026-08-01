<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $query = Order::with(['user', 'store']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        if ($request->filled('q')) {
            $query->where('order_code', 'like', '%'.$request->q.'%');
        }

        $orders = $query->orderByDesc('ordered_at')->paginate(20)->withQueryString();

        return view('admin.orders.index', compact('orders'));
    }

    public function show(Order $order)
    {
        $order->load(['items', 'user', 'store', 'paymentMethod', 'shippingMethod']);

        return view('admin.orders.show', compact('order'));
    }

    public function updateStatus(Request $request, Order $order)
    {
        $data = $request->validate([
            'status' => ['required', Rule::in(['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai', 'dibatalkan'])],
            'cancel_reason' => ['required_if:status,dibatalkan', 'nullable', 'string'],
        ]);

        if ($data['status'] === 'dibatalkan' && $order->status !== 'dibatalkan') {
            foreach ($order->items as $item) {
                if ($item->variant_id) {
                    ProductVariant::where('id', $item->variant_id)->increment('stock', $item->quantity);
                }
            }
        }

        $order->update([
            'status' => $data['status'],
            'cancel_reason' => $data['status'] === 'dibatalkan' ? ($data['cancel_reason'] ?? null) : $order->cancel_reason,
        ]);

        return back()->with('status', 'Status pesanan diperbarui');
    }

    public function confirmPayment(Order $order)
    {
        if ($order->payment_status !== 'menunggu_konfirmasi') {
            return back()->withErrors(['payment' => 'Tidak ada pembayaran yang menunggu konfirmasi']);
        }

        $order->update([
            'payment_status' => 'paid',
            'status' => $order->status === 'menunggu_pembayaran' ? 'diproses' : $order->status,
        ]);

        return back()->with('status', 'Pembayaran dikonfirmasi');
    }
}
