<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\PaymentMethod;
use App\Models\ShippingMethod;
use Illuminate\Http\Request;

class PaymentShippingMethodController extends Controller
{
    public function paymentMethods()
    {
        return response()->json(['status' => 'success', 'data' => PaymentMethod::where('is_active', true)->get()]);
    }

    /**
     * Perbaikan audit: shipping_method_screen.dart sebelumnya menampilkan
     * ongkos kirim tetap tanpa memperhitungkan tujuan. Di sini base_cost
     * masih dari master data (belum terhubung ke API ongkos kirim pihak ketiga
     * seperti RajaOngkir), tapi setidaknya sumbernya nyata dari database, bukan
     * angka yang ditulis langsung di kode Flutter.
     */
    public function shippingMethods(Request $request)
    {
        return response()->json(['status' => 'success', 'data' => ShippingMethod::where('is_active', true)->get()]);
    }
}
