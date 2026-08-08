<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\RajaOngkirService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ShippingController extends Controller
{
    protected RajaOngkirService $rajaOngkir;

    public function __construct(RajaOngkirService $rajaOngkir)
    {
        $this->rajaOngkir = $rajaOngkir;
    }

    /**
     * Dapatkan daftar provinsi dari RajaOngkir
     */
    public function provinces()
    {
        $provinces = $this->rajaOngkir->getProvinces();

        return response()->json([
            'status' => 'success',
            'data' => $provinces,
        ]);
    }

    /**
     * Dapatkan daftar kota/kabupaten berdasarkan province_id
     */
    public function cities(Request $request)
    {
        $provinceId = $request->query('province_id');
        $cities = $this->rajaOngkir->getCities($provinceId ? (int) $provinceId : null);

        return response()->json([
            'status' => 'success',
            'data' => $cities,
        ]);
    }

    /**
     * Hitung biaya ongkos kirim berdasarkan destination, weight, courier
     */
    public function calculateCost(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'destination' => ['required', 'integer'],
            'weight' => ['required', 'integer', 'min:1'],
            'courier' => ['required', 'string'],
            'origin' => ['nullable', 'integer'],
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => $validator->errors()->first(),
            ], 422);
        }

        $origin = $request->input('origin', 153); // Default Kota Jakarta Selatan
        $destination = (int) $request->destination;
        $weight = (int) $request->weight;
        $courier = strtolower($request->courier);

        $results = $this->rajaOngkir->calculateCost($origin, $destination, $weight, $courier);

        return response()->json([
            'status' => 'success',
            'data' => $results,
        ]);
    }
}
