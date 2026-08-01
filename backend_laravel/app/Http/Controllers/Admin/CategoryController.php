<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Store;
use Illuminate\Http\Request;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $query = Category::with('store')->withCount('products');

        if ($request->filled('store_id')) {
            $query->where('store_id', $request->store_id);
        }

        $categories = $query->orderBy('name')->paginate(20)->withQueryString();
        $stores = Store::orderBy('store_name')->get();

        return view('admin.categories.index', compact('categories', 'stores'));
    }

    public function create()
    {
        $stores = Store::orderBy('store_name')->get();

        return view('admin.categories.create', compact('stores'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'store_id' => ['required', 'exists:stores,id'],
            'name' => ['required', 'string', 'max:100'],
            'icon_url' => ['nullable', 'string'],
        ]);

        Category::create($data);

        return redirect()->route('admin.categories.index')->with('status', 'Kategori berhasil ditambahkan');
    }

    public function edit(Category $category)
    {
        $stores = Store::orderBy('store_name')->get();

        return view('admin.categories.edit', compact('category', 'stores'));
    }

    public function update(Request $request, Category $category)
    {
        $data = $request->validate([
            'store_id' => ['required', 'exists:stores,id'],
            'name' => ['required', 'string', 'max:100'],
            'icon_url' => ['nullable', 'string'],
        ]);

        $category->update($data);

        return redirect()->route('admin.categories.index')->with('status', 'Kategori berhasil diperbarui');
    }

    public function destroy(Category $category)
    {
        $category->delete();

        return redirect()->route('admin.categories.index')->with('status', 'Kategori berhasil dihapus');
    }
}
