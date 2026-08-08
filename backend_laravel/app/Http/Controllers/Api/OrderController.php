<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\CartItem;
use App\Models\Order;
use App\Services\NotificationService;
use App\Services\XenditService;
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
    public function store(Request $request, XenditService $xenditService)
    {
        $validator = Validator::make($request->all(), [
            'address_id' => ['required', 'exists:addresses,id'],
            'shipping_method_id' => ['nullable'],
            'payment_method_id' => ['required', 'exists:payment_methods,id'],
            'shipping_courier' => ['nullable', 'string'],
            'shipping_service' => ['nullable', 'string'],
            'shipping_cost' => ['nullable', 'numeric'],
            'shipping_etd' => ['nullable', 'string'],
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

        $shippingMethod = $request->shipping_method_id ? \App\Models\ShippingMethod::find($request->shipping_method_id) : null;
        $subtotal = $cartItems->sum(fn ($i) => (float) ($i->variant->price ?? $i->variant->product->price) * $i->quantity);
        $totalWeight = $cartItems->sum(fn ($i) => (int) ($i->variant->product->weight ?? 500) * $i->quantity);
        $shippingCost = $request->filled('shipping_cost') ? (float) $request->shipping_cost : ($shippingMethod->base_cost ?? 15000);
        $courier = $request->shipping_courier ?? ($shippingMethod->name ?? 'JNE');
        $service = $request->shipping_service ?? 'REG';
        $etd = $request->shipping_etd ?? '2-3 hari';

        $order = DB::transaction(function () use ($cartItems, $address, $shippingMethod, $request, $user, $subtotal, $totalWeight, $shippingCost, $courier, $service, $etd, $storeIds) {
            $order = \App\Models\Order::create([
                'order_code' => 'OD'.now()->format('ymd').Str::upper(Str::random(6)),
                'user_id' => $user->id,
                'store_id' => $storeIds->first(),
                'payment_method_id' => $request->payment_method_id,
                'shipping_method_id' => $shippingMethod?->id,
                'receiver_name' => $address->receiver_name,
                'receiver_phone' => $address->phone,
                'shipping_address' => $address->full_address.($address->city_name ? ", {$address->city_name}, {$address->province_name}" : ''),
                'subtotal' => $subtotal,
                'shipping_cost' => $shippingCost,
                'shipping_courier' => $courier,
                'shipping_service' => $service,
                'shipping_weight' => $totalWeight,
                'shipping_etd' => $etd,
                'total_price' => $subtotal + $shippingCost,
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

        // 4. Generate Xendit Invoice Url secara langsung
        try {
            $xenditResult = $xenditService->createInvoice($order);
            $order->refresh();
        } catch (\Exception $e) {
            // Jika Xendit fail, pesanan tetap tersimpan dengan status pending
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Pesanan berhasil dibuat',
            'data' => $order->load(['items', 'paymentMethod', 'shippingMethod', 'store']),
        ], 201);
    }

    /**
     * Menghasilkan URL Invoice Xendit untuk pembayaran pesanan.
     */
    public function getSnapToken(Request $request, Order $order, XenditService $xenditService)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        if (in_array($order->payment_status, ['paid', 'sudah_dibayar'])) {
            return response()->json(['status' => 'error', 'message' => 'Pesanan ini sudah lunas'], 422);
        }

        if ($order->payment_url) {
            return response()->json([
                'status' => 'success',
                'data' => [
                    'snap_token' => $order->snap_token,
                    'snap_redirect_url' => $order->payment_url,
                    'payment_url' => $order->payment_url,
                ],
            ]);
        }

        $result = $xenditService->createInvoice($order);

        return response()->json([
            'status' => 'success',
            'data' => [
                'snap_token' => $result['invoice_id'] ?? null,
                'snap_redirect_url' => $result['invoice_url'] ?? null,
                'payment_url' => $result['invoice_url'] ?? null,
            ],
        ]);
    }

    /**
     * Menghasilkan QR Code QRIS Xendit secara langsung.
     */
    public function getQrisCode(Request $request, Order $order, XenditService $xenditService)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        if (in_array($order->payment_status, ['paid', 'sudah_dibayar'])) {
            return response()->json(['status' => 'error', 'message' => 'Pesanan ini sudah lunas'], 422);
        }

        $order->loadMissing('paymentMethod');
        $pm = $order->paymentMethod;
        $pmType = strtolower($pm->type ?? '');
        $pmCode = strtoupper($pm->code ?? '');

        if ($pmType === 'bank_transfer' || in_array($pmCode, ['BCA', 'MANDIRI', 'BNI', 'BRI', 'PERMATA'])) {
            $bankCode = in_array($pmCode, ['BCA', 'MANDIRI', 'BNI', 'BRI', 'PERMATA']) ? $pmCode : 'BCA';
            $result = $xenditService->createVirtualAccount($order, $bankCode);
        } elseif ($pmType === 'qris' || $pmCode === 'QRIS') {
            $result = $xenditService->createQrisCode($order);
        } else {
            $result = $xenditService->createInvoice($order);
        }

        return response()->json([
            'status' => 'success',
            'data' => $result,
        ]);
    }
    public function confirmPayment(Request $request, Order $order)
    {
        if ($order->user_id !== $request->user()->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        if ($order->payment_status === 'menunggu_konfirmasi') {
            return response()->json([
                'status' => 'success',
                'message' => 'Konfirmasi pembayaran sudah terkirim, menunggu verifikasi toko',
                'data' => $order->fresh(),
            ]);
        }

        if ($order->payment_status !== 'unpaid') {
            return response()->json(['status' => 'error', 'message' => 'Status pembayaran tidak bisa diubah lagi'], 422);
        }

        $order->update([
            'payment_status' => 'menunggu_konfirmasi',
            'payment_proof_url' => $request->input('payment_proof_url'),
        ]);

        NotificationService::notify(
            $order->store->user_id,
            'Konfirmasi Pembayaran',
            "Pesanan #{$order->id} menunggu verifikasi pembayaran.",
            'order',
            $order->id,
        );

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

        NotificationService::notify(
            $order->store->user_id,
            'Pesanan Dibatalkan',
            "Pesanan #{$order->id} dibatalkan oleh pembeli.",
            'order',
            $order->id,
        );

        return response()->json(['status' => 'success', 'message' => 'Pesanan dibatalkan', 'data' => $order->fresh()]);
    }
}
