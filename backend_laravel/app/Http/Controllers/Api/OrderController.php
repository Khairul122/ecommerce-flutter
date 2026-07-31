<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\CartItem;
use App\Models\Order;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class OrderController extends Controller
{
    /**
     * Daftar pesanan pelanggan, difilter per status. Perbaikan audit:
     * my_orders_screen.dart sebelumnya hanya tab "Diproses" yang nyata,
     * tab lain statis/selalu kosong. Sekarang semua tab query status asli.
     */
    public function index(Request $request)
    {
        $query = $request->user()->orders()->with(['items', 'store', 'paymentMethod', 'shippingMethod']);

        if ($request->filled('status')) {
            $query->where('status', $request->status);
        }

        return response()->json(['status' => 'success', 'data' => $query->orderByDesc('ordered_at')->get()]);
    }

    /**
     * Perbaikan audit: order_details_screen.dart sebelumnya adalah widget
     * tanpa parameter sama sekali, semua pesanan menampilkan data identik.
     * Sekarang mengambil data pesanan spesifik berdasarkan id.
     */
    public function show(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $order->load(['items', 'store', 'paymentMethod', 'shippingMethod']);

        return response()->json(['status' => 'success', 'data' => $order]);
    }

    /**
     * Membuat pesanan dari item keranjang yang dipilih (is_selected = true).
     * Perbaikan audit penting:
     * - Validasi ulang stok varian sebelum pesanan dibuat (sebelumnya tidak ada).
     * - Alamat diambil dari address_id yang benar-benar dipilih pelanggan
     *   (sebelumnya diabaikan, checkout_screen.dart memakai alamat hardcode).
     * - Status awal "menunggu_pembayaran", bukan langsung dianggap selesai.
     *   Keranjang baru dikosongkan setelah pesanan berhasil dibuat, dan status
     *   pembayaran baru berubah lewat endpoint confirmPayment terpisah,
     *   bukan otomatis sukses seperti alur payment_instruction_screen.dart lama.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'address_id' => ['required', 'exists:addresses,id'],
            'shipping_method_id' => ['required', 'exists:shipping_methods,id'],
            'payment_method_id' => ['required', 'exists:payment_methods,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $user = $request->user();

        $address = Address::where('user_id', $user->id)->find($request->address_id);
        if (! $address) {
            return response()->json(['status' => 'error', 'message' => 'Alamat tidak ditemukan'], 404);
        }

        $cartItems = $user->cartItems()->where('is_selected', true)->with('variant.product')->get();

        if ($cartItems->isEmpty()) {
            return response()->json(['status' => 'error', 'message' => 'Tidak ada item terpilih di keranjang'], 422);
        }

        // Semua item harus dari toko yang sama (satu pesanan = satu toko)
        $storeIds = $cartItems->pluck('variant.product.store_id')->unique();
        if ($storeIds->count() > 1) {
            return response()->json([
                'status' => 'error',
                'message' => 'Item di keranjang berasal dari toko berbeda. Checkout terpisah per toko.',
            ], 422);
        }

        foreach ($cartItems as $item) {
            if ($item->variant->stock < $item->quantity) {
                return response()->json([
                    'status' => 'error',
                    'message' => 'Stok tidak cukup untuk '.$item->variant->product->name.' ('.$item->variant->size.'/'.$item->variant->color.')',
                ], 422);
            }
        }

        $shippingMethod = \App\Models\ShippingMethod::findOrFail($request->shipping_method_id);
        $subtotal = $cartItems->sum(fn ($i) => (float) ($i->variant->price ?? $i->variant->product->price) * $i->quantity);

        $order = DB::transaction(function () use ($cartItems, $address, $shippingMethod, $request, $user, $subtotal, $storeIds) {
            $order = \App\Models\Order::create([
                'order_code' => 'OD'.now()->format('ymd').Str::upper(Str::random(6)),
                'user_id' => $user->id,
                'store_id' => $storeIds->first(),
                'payment_method_id' => $request->payment_method_id,
                'shipping_method_id' => $shippingMethod->id,
                'receiver_name' => $address->receiver_name,
                'receiver_phone' => $address->phone,
                'shipping_address' => $address->full_address,
                'subtotal' => $subtotal,
                'shipping_cost' => $shippingMethod->base_cost,
                'total_price' => $subtotal + $shippingMethod->base_cost,
                'status' => 'menunggu_pembayaran',
                'payment_status' => 'unpaid',
            ]);

            foreach ($cartItems as $item) {
                $order->items()->create([
                    'product_id' => $item->variant->product_id,
                    'variant_id' => $item->variant_id,
                    'product_name' => $item->variant->product->name,
                    'variant_label' => $item->variant->size.' / '.$item->variant->color,
                    'image_url' => optional($item->variant->product->images()->where('is_primary', true)->first())->image_url,
                    'price' => $item->variant->price ?? $item->variant->product->price,
                    'quantity' => $item->quantity,
                ]);

                $item->variant->decrement('stock', $item->quantity);
                $item->variant->product()->increment('sold_count', $item->quantity);
                $item->delete();
            }

            return $order;
        });

        return response()->json([
            'status' => 'success',
            'message' => 'Pesanan berhasil dibuat, menunggu pembayaran',
            'data' => $order->load('items'),
        ], 201);
    }

    /**
     * Pelanggan menandai sudah membayar. Status pembayaran menjadi
     * "menunggu_konfirmasi", BUKAN langsung "paid" -- verifikasi akhir tetap
     * di tangan owner lewat OwnerOrderController::confirmPayment. Ini
     * menggantikan payment_instruction_screen.dart lama yang langsung
     * menganggap pembayaran sukses tanpa verifikasi apa pun.
     */
    public function confirmPayment(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        if ($order->payment_status !== 'unpaid') {
            return response()->json(['status' => 'error', 'message' => 'Status pembayaran tidak bisa diubah lagi'], 422);
        }

        $order->update([
            'payment_status' => 'menunggu_konfirmasi',
            'payment_proof_url' => $request->input('payment_proof_url'),
        ]);

        return response()->json(['status' => 'success', 'message' => 'Konfirmasi pembayaran terkirim, menunggu verifikasi toko', 'data' => $order->fresh()]);
    }

    /**
     * Perbaikan audit: tombol "Batalkan Pesanan" di order_details_screen.dart
     * sebelumnya onPressed kosong. Sekarang benar-benar membatalkan pesanan
     * dan mengembalikan stok varian.
     */
    public function cancel(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        if (! in_array($order->status, ['menunggu_pembayaran', 'diproses'])) {
            return response()->json(['status' => 'error', 'message' => 'Pesanan tidak bisa dibatalkan pada status ini'], 422);
        }

        DB::transaction(function () use ($order, $request) {
            foreach ($order->items as $item) {
                if ($item->variant_id) {
                    \App\Models\ProductVariant::where('id', $item->variant_id)->increment('stock', $item->quantity);
                }
            }

            $order->update([
                'status' => 'dibatalkan',
                'cancel_reason' => $request->input('reason', 'Dibatalkan oleh pelanggan'),
            ]);
        });

        return response()->json(['status' => 'success', 'message' => 'Pesanan dibatalkan', 'data' => $order->fresh()]);
    }
}
