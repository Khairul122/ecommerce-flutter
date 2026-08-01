<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class StoreController extends Controller
{
    public function index(Request $request)
    {
        $query = Store::with('owner')->withCount('products');

        if ($request->filled('q')) {
            $query->where('store_name', 'like', '%'.$request->q.'%');
        }

        $stores = $query->orderByDesc('created_at')->paginate(20)->withQueryString();

        return view('admin.stores.index', compact('stores'));
    }

    public function edit(Store $store)
    {
        return view('admin.stores.edit', compact('store'));
    }

    public function update(Request $request, Store $store)
    {
        $data = $request->validate([
            'store_name' => ['required', 'string', 'max:100'],
            'description' => ['nullable', 'string'],
            'address' => ['nullable', 'string'],
            'phone' => ['nullable', 'string', 'max:20'],
            'status' => ['required', Rule::in(['active', 'inactive'])],
        ]);

        $store->update($data);

        return redirect()->route('admin.stores.index')->with('status', 'Toko berhasil diperbarui');
    }

    public function destroy(Store $store)
    {
        $store->delete();

        return redirect()->route('admin.stores.index')->with('status', 'Toko berhasil dihapus');
    }
}
