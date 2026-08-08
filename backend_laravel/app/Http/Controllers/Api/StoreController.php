<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class StoreController extends Controller
{
    public function show(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['status' => 'error', 'message' => 'Toko tidak ditemukan'], 404);
        }

        return response()->json(['status' => 'success', 'data' => $store]);
    }

    /**
     * Perbaikan audit: sebelumnya tombol simpan di informasi_toko.dart dan
     * pengaturan_akun.dart cuma menampilkan SnackBar sukses tanpa menyimpan apa pun.
     * Endpoint ini benar-benar menyimpan perubahan ke database.
     */
    public function update(Request $request)
    {
        $store = $request->user()->store;

        if (! $store) {
            return response()->json(['status' => 'error', 'message' => 'Toko tidak ditemukan'], 404);
        }

        $validator = Validator::make($request->all(), [
            'store_name' => ['sometimes', 'required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'address' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'logo_url' => ['nullable', 'string'],
            'district_id' => ['nullable', 'integer'],
            'district_name' => ['nullable', 'string', 'max:150'],
            'city_name' => ['nullable', 'string', 'max:150'],
            'province_name' => ['nullable', 'string', 'max:150'],
            'postal_code' => ['nullable', 'string', 'max:10'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $store->update($validator->validated());

        return response()->json(['status' => 'success', 'message' => 'Informasi toko berhasil disimpan', 'data' => $store->fresh()]);
    }

    public function updateProfile(Request $request)
    {
        $user = $request->user();

        $validator = Validator::make($request->all(), [
            'name' => ['sometimes', 'required', 'string', 'max:100'],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $user->update($validator->validated());

        return response()->json(['status' => 'success', 'message' => 'Profil berhasil disimpan', 'data' => $user->fresh()]);
    }

    /**
     * Statistik dashboard owner dihitung dari data pesanan/produk sungguhan,
     * menggantikan angka tetap di home_page.dart dan stat_detail_page.dart.
     */
    public function stats(Request $request)
    {
        $store = $request->user()->store;
        if (! $store) {
            return response()->json(['status' => 'error', 'message' => 'Toko tidak ditemukan'], 404);
        }

        $orders = $store->orders();

        return response()->json(['status' => 'success', 'data' => [
            'total_produk' => $store->products()->count(),
            'total_pesanan' => (clone $orders)->count(),
            'pesanan_menunggu_konfirmasi' => (clone $orders)->where('status', 'menunggu_pembayaran')->count(),
            'pesanan_diproses' => (clone $orders)->where('status', 'diproses')->count(),
            'pesanan_dikirim' => (clone $orders)->where('status', 'dikirim')->count(),
            'pesanan_selesai' => (clone $orders)->where('status', 'selesai')->count(),
            'pesanan_dibatalkan' => (clone $orders)->where('status', 'dibatalkan')->count(),
            'total_pendapatan' => (clone $orders)->where('payment_status', 'paid')->sum('total_price'),
        ]]);
    }
}
