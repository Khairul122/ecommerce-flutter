<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\ShippingMethod;
use Illuminate\Http\Request;

class ShippingMethodController extends Controller
{
    public function index()
    {
        $shippingMethods = ShippingMethod::orderBy('name')->get();
        $couriers = self::COURIERS;

        return view('admin.shipping-methods.index', compact('shippingMethods', 'couriers'));
    }

    // Kode kurir yang didukung akun RajaOngkir Komerce user.
    public const COURIERS = ['jne' => 'JNE', 'pos' => 'POS Indonesia', 'tiki' => 'TIKI'];

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'courier_code' => ['required', 'string', 'in:'.implode(',', array_keys(self::COURIERS))],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $request->boolean('is_active');
        $data['base_cost'] = 0;

        ShippingMethod::create($data);

        return redirect()->route('admin.shipping-methods.index')->with('status', 'Metode pengiriman berhasil ditambahkan');
    }

    public function update(Request $request, ShippingMethod $shippingMethod)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'courier_code' => ['required', 'string', 'in:'.implode(',', array_keys(self::COURIERS))],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $request->boolean('is_active');

        $shippingMethod->update($data);

        return redirect()->route('admin.shipping-methods.index')->with('status', 'Metode pengiriman berhasil diperbarui');
    }

    public function destroy(ShippingMethod $shippingMethod)
    {
        $shippingMethod->delete();

        return redirect()->route('admin.shipping-methods.index')->with('status', 'Metode pengiriman berhasil dihapus');
    }
}
