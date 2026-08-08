<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Address;
use App\Models\ShippingMethod;
use App\Services\RajaOngkirService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ShippingController extends Controller
{
    // Belum ada kolom berat produk, pakai berat rata-rata per item (gram).
    private const DEFAULT_ITEM_WEIGHT_GRAM = 1000;

    /**
     * Autocomplete kecamatan/kota untuk form alamat & profil toko.
     */
    public function destinations(Request $request, RajaOngkirService $rajaOngkir)
    {
        $keyword = trim((string) $request->query('search', ''));
        if (strlen($keyword) < 3) {
            return response()->json(['status' => 'success', 'data' => []]);
        }

        try {
            $data = $rajaOngkir->searchDestination($keyword);
            return response()->json(['status' => 'success', 'data' => $data]);
        } catch (\Exception $e) {
            return response()->json(['status' => 'error', 'message' => $e->getMessage()], 502);
        }
    }

    /**
     * Hitung ongkir dari toko asal (berdasarkan isi keranjang terpilih) ke
     * alamat pelanggan, untuk tiap kurir aktif yang admin sudah setel.
     */
    public function cost(Request $request, RajaOngkirService $rajaOngkir)
    {
        $validator = Validator::make($request->all(), [
            'address_id' => ['required', 'exists:addresses,id'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $user = $request->user();

        $address = Address::where('user_id', $user->id)->find($request->address_id);
        if (! $address || ! $address->district_id) {
            return response()->json(['status' => 'error', 'message' => 'Alamat belum punya lokasi kecamatan, lengkapi dulu alamatnya'], 422);
        }

        $cartItems = $user->cartItems()->where('is_selected', true)->with('variant.product.store')->get();
        if ($cartItems->isEmpty()) {
            return response()->json(['status' => 'error', 'message' => 'Tidak ada item terpilih di keranjang'], 422);
        }

        $storeIds = $cartItems->pluck('variant.product.store_id')->unique();
        if ($storeIds->count() > 1) {
            return response()->json(['status' => 'error', 'message' => 'Item di keranjang berasal dari toko berbeda. Checkout terpisah per toko.'], 422);
        }

        $store = $cartItems->first()->variant->product->store;
        if (! $store || ! $store->district_id) {
            return response()->json(['status' => 'error', 'message' => 'Alamat toko belum punya lokasi kecamatan'], 422);
        }

        $weight = (int) $cartItems->sum('quantity') * self::DEFAULT_ITEM_WEIGHT_GRAM;

        $couriers = ShippingMethod::where('is_active', true)->whereNotNull('courier_code')->get();
        $options = [];

        foreach ($couriers as $shippingMethod) {
            try {
                $services = $rajaOngkir->calculateCost(
                    (int) $store->district_id,
                    (int) $address->district_id,
                    $weight,
                    $shippingMethod->courier_code,
                );
            } catch (\Exception $e) {
                continue; // kurir ini gagal, lewati, jangan gagalkan seluruh permintaan
            }

            foreach ($services as $service) {
                $options[] = [
                    'shipping_method_id' => $shippingMethod->id,
                    'courier' => $shippingMethod->courier_code,
                    'courier_name' => $shippingMethod->name,
                    'service' => $service['service'] ?? null,
                    'description' => $service['description'] ?? null,
                    'cost' => $service['cost'] ?? null,
                    'etd' => $service['etd'] ?? null,
                ];
            }
        }

        return response()->json(['status' => 'success', 'data' => $options]);
    }
}
