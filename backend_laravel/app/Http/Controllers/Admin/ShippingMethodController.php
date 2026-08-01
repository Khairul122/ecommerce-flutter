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

        return view('admin.shipping-methods.index', compact('shippingMethods'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'base_cost' => ['required', 'numeric', 'min:0'],
            'is_active' => ['nullable', 'boolean'],
        ]);

        $data['is_active'] = $request->boolean('is_active');

        ShippingMethod::create($data);

        return redirect()->route('admin.shipping-methods.index')->with('status', 'Metode pengiriman berhasil ditambahkan');
    }

    public function update(Request $request, ShippingMethod $shippingMethod)
    {
        $data = $request->validate([
            'name' => ['required', 'string', 'max:100'],
            'base_cost' => ['required', 'numeric', 'min:0'],
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
