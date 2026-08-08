<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class RajaOngkirService
{
    protected string $apiKey;
    protected string $baseUrl;
    protected string $accountType;

    public function __construct()
    {
        $this->apiKey = config('services.rajaongkir.api_key', env('RAJAONGKIR_API_KEY', ''));
        $this->accountType = config('services.rajaongkir.account_type', env('RAJAONGKIR_ACCOUNT_TYPE', 'starter'));

        if ($this->accountType === 'pro') {
            $this->baseUrl = 'https://pro.rajaongkir.com/api';
        } elseif ($this->accountType === 'basic') {
            $this->baseUrl = 'https://api.rajaongkir.com/basic';
        } else {
            $this->baseUrl = 'https://api.rajaongkir.com/starter';
        }
    }

    /**
     * Ambil daftar provinsi dari RajaOngkir
     */
    public function getProvinces(): array
    {
        try {
            $response = Http::withHeaders([
                'key' => $this->apiKey,
            ])->get("{$this->baseUrl}/province");

            if ($response->successful() && isset($response->json()['rajaongkir']['results'])) {
                return $response->json()['rajaongkir']['results'];
            }
        } catch (\Exception $e) {
            Log::error('RajaOngkir getProvinces Error: '.$e->getMessage());
        }

        // Fallback data jika API offline/key bermasalah
        return $this->fallbackProvinces();
    }

    /**
     * Ambil daftar kota/kabupaten dari RajaOngkir
     */
    public function getCities(?int $provinceId = null): array
    {
        try {
            $params = [];
            if ($provinceId) {
                $params['province'] = $provinceId;
            }

            $response = Http::withHeaders([
                'key' => $this->apiKey,
            ])->get("{$this->baseUrl}/city", $params);

            if ($response->successful() && isset($response->json()['rajaongkir']['results'])) {
                return $response->json()['rajaongkir']['results'];
            }
        } catch (\Exception $e) {
            Log::error('RajaOngkir getCities Error: '.$e->getMessage());
        }

        return $this->fallbackCities($provinceId);
    }

    /**
     * Hitung ongkos kirim via RajaOngkir
     */
    public function calculateCost(int $origin, int $destination, int $weight, string $courier): array
    {
        try {
            $response = Http::withHeaders([
                'key' => $this->apiKey,
            ])->post("{$this->baseUrl}/cost", [
                'origin' => $origin,
                'destination' => $destination,
                'weight' => max(1, $weight),
                'courier' => strtolower($courier),
            ]);

            if ($response->successful() && isset($response->json()['rajaongkir']['results'])) {
                return $response->json()['rajaongkir']['results'];
            }
        } catch (\Exception $e) {
            Log::error('RajaOngkir calculateCost Error: '.$e->getMessage());
        }

        return $this->fallbackCost($courier, $weight);
    }

    // --- FALLBACK MOCK DATA APABILA API OFF / KEY MITRA EXPIRED ---
    private function fallbackProvinces(): array
    {
        return [
            ['province_id' => '1', 'province' => 'Bali'],
            ['province_id' => '3', 'province' => 'Banten'],
            ['province_id' => '5', 'province' => 'DI Yogyakarta'],
            ['province_id' => '6', 'province' => 'DKI Jakarta'],
            ['province_id' => '9', 'province' => 'Jawa Barat'],
            ['province_id' => '10', 'province' => 'Jawa Tengah'],
            ['province_id' => '11', 'province' => 'Jawa Timur'],
        ];
    }

    private function fallbackCities(?int $provinceId): array
    {
        $all = [
            ['city_id' => '151', 'province_id' => '6', 'province' => 'DKI Jakarta', 'type' => 'Kota', 'city_name' => 'Jakarta Barat', 'postal_code' => '11710'],
            ['city_id' => '152', 'province_id' => '6', 'province' => 'DKI Jakarta', 'type' => 'Kota', 'city_name' => 'Jakarta Pusat', 'postal_code' => '10110'],
            ['city_id' => '153', 'province_id' => '6', 'province' => 'DKI Jakarta', 'type' => 'Kota', 'city_name' => 'Jakarta Selatan', 'postal_code' => '12110'],
            ['city_id' => '154', 'province_id' => '6', 'province' => 'DKI Jakarta', 'type' => 'Kota', 'city_name' => 'Jakarta Timur', 'postal_code' => '13110'],
            ['city_id' => '155', 'province_id' => '6', 'province' => 'DKI Jakarta', 'type' => 'Kota', 'city_name' => 'Jakarta Utara', 'postal_code' => '14110'],
            ['city_id' => '22', 'province_id' => '9', 'province' => 'Jawa Barat', 'type' => 'Kota', 'city_name' => 'Bandung', 'postal_code' => '40111'],
            ['city_id' => '78', 'province_id' => '9', 'province' => 'Jawa Barat', 'type' => 'Kota', 'city_name' => 'Bogor', 'postal_code' => '16111'],
            ['city_id' => '501', 'province_id' => '10', 'province' => 'Jawa Tengah', 'type' => 'Kota', 'city_name' => 'Yogyakarta', 'postal_code' => '55111'],
            ['city_id' => '444', 'province_id' => '11', 'province' => 'Jawa Timur', 'type' => 'Kota', 'city_name' => 'Surabaya', 'postal_code' => '60111'],
        ];

        if (! $provinceId) {
            return $all;
        }

        return array_values(array_filter($all, fn ($item) => (int) $item['province_id'] === $provinceId));
    }

    private function fallbackCost(string $courier, int $weight): array
    {
        $weightKg = ceil($weight / 1000);
        $courierName = strtoupper($courier);

        return [
            [
                'code' => strtolower($courier),
                'name' => $courierName === 'JNE' ? 'Jalur Nugraha Ekakurir (JNE)' : ($courierName === 'POS' ? 'POS Indonesia' : 'Citra Van Titipan Kilat (TIKI)'),
                'costs' => [
                    [
                        'service' => 'REG',
                        'description' => 'Layanan Reguler',
                        'cost' => [
                            ['value' => 15000 * $weightKg, 'etd' => '2-3', 'note' => ''],
                        ],
                    ],
                    [
                        'service' => 'YES',
                        'description' => 'Yakin Besok Sampai',
                        'cost' => [
                            ['value' => 25000 * $weightKg, 'etd' => '1-1', 'note' => ''],
                        ],
                    ],
                ],
            ],
        ];
    }
}
