<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class RajaOngkirService
{
    protected string $apiKey;
    protected string $baseUrl;

    public function __construct()
    {
        $this->apiKey = config('rajaongkir.api_key', '');
        $this->baseUrl = config('rajaongkir.api_url', 'https://rajaongkir.komerce.id/api/v1');
    }

    /**
     * Cari kecamatan/kota tujuan untuk autocomplete alamat.
     * GET /destination/domestic-destination?search=
     */
    public function searchDestination(string $keyword): array
    {
        $response = Http::withHeaders(['key' => $this->apiKey])
            ->get($this->baseUrl . '/destination/domestic-destination', [
                'search' => $keyword,
                'limit' => 20,
            ]);

        if ($response->failed()) {
            Log::error('RajaOngkir Search Destination Failed', [
                'keyword' => $keyword,
                'status' => $response->status(),
                'body' => $response->json(),
            ]);
            throw new Exception('Gagal mencari data lokasi dari RajaOngkir.');
        }

        return $response->json('data', []);
    }

    /**
     * Hitung ongkir antar kecamatan untuk satu kurir.
     * POST /calculate/district/domestic-cost
     */
    public function calculateCost(int $originDistrictId, int $destDistrictId, int $weight, string $courier): array
    {
        $response = Http::asForm()
            ->withHeaders(['key' => $this->apiKey])
            ->post($this->baseUrl . '/calculate/district/domestic-cost', [
                'origin' => $originDistrictId,
                'destination' => $destDistrictId,
                'weight' => $weight,
                'courier' => $courier,
                'price' => 'lowest',
            ]);

        if ($response->failed()) {
            Log::error('RajaOngkir Calculate Cost Failed', [
                'origin' => $originDistrictId,
                'destination' => $destDistrictId,
                'courier' => $courier,
                'status' => $response->status(),
                'body' => $response->json(),
            ]);
            throw new Exception('Gagal menghitung ongkos kirim dari RajaOngkir.');
        }

        return $response->json('data', []);
    }
}
