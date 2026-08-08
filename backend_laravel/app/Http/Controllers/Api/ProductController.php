<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;

class ProductController extends Controller
{
    /**
     * Daftar produk publik dipakai untuk beranda dan pencarian pelanggan.
     * Menggantikan _allProducts hardcode di search_page.dart (owner) dan
     * memastikan search_screen.dart / search_result_screen.dart (pelanggan)
     * benar-benar query ke database, bukan daftar statis.
     */
    public function index(Request $request)
    {
        $query = Product::with(['images', 'variants'])
            ->withAvg('reviews', 'rating')
            ->withCount('reviews')
            ->where('status', 'active');

        if ($request->filled('store_id')) {
            $query->where('store_id', $request->store_id);
        }

        if ($request->filled('category_id')) {
            $query->where('category_id', $request->category_id);
        }

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->q.'%');
        }

        $products = $query->orderByDesc('created_at')->paginate($request->integer('per_page', 20));

        return response()->json(['status' => 'success', 'data' => $products]);
    }

    public function show(Product $product)
    {
        $product->load(['images', 'variants', 'category', 'store'])
            ->loadAvg('reviews', 'rating')
            ->loadCount('reviews');

        return response()->json(['status' => 'success', 'data' => $product]);
    }

    /**
     * Owner: daftar produk milik toko sendiri (termasuk yang nonaktif), dipakai
     * di profil_produk_tab.dart / tambah_produk_page.dart.
     */
    public function myProducts(Request $request)
    {
        $store = $request->user()->store;

        $products = $store->products()->with(['images', 'variants', 'category'])
            ->orderByDesc('created_at')->get();

        return response()->json(['status' => 'success', 'data' => $products]);
    }

    public function store(Request $request)
    {
        $store = $request->user()->store;

        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:255'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'price' => ['required', 'numeric', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'in:active,inactive'],
            'images' => ['nullable', 'array'],
            'images.*' => ['string'],
            'variants' => ['nullable', 'array'],
            'variants.*.size' => ['required_with:variants', 'string'],
            'variants.*.color' => ['required_with:variants', 'string'],
            'variants.*.stock' => ['nullable', 'integer', 'min:0'],
            'variants.*.price' => ['nullable', 'numeric', 'min:0'],
            'variants.*.image_url' => ['nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $data = $validator->validated();

        $product = DB::transaction(function () use ($store, $data) {
            $product = $store->products()->create([
                'category_id' => $data['category_id'] ?? null,
                'name' => $data['name'],
                'price' => $data['price'],
                'stock' => $data['stock'] ?? 0,
                'status' => $data['status'] ?? 'active',
                'description' => $data['description'] ?? null,
            ]);

            foreach (($data['images'] ?? []) as $i => $url) {
                $product->images()->create(['image_url' => $url, 'is_primary' => $i === 0, 'sort_order' => $i]);
            }

            foreach (($data['variants'] ?? []) as $variant) {
                $product->variants()->create([
                    'size' => $variant['size'],
                    'color' => $variant['color'],
                    'stock' => $variant['stock'] ?? 0,
                    'price' => $variant['price'] ?? $data['price'],
                    'image_url' => $variant['image_url'] ?? null,
                ]);
            }

            return $product;
        });

        return response()->json(['status' => 'success', 'data' => $product->load('images', 'variants')], 201);
    }

    /**
     * Perbaikan audit: edit dan hapus produk sebelumnya tidak ada implementasinya
     * sama sekali di aplikasi owner.
     */
    public function update(Request $request, Product $product)
    {
        if ($product->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $validator = Validator::make($request->all(), [
            'name' => ['sometimes', 'required', 'string', 'max:255'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['nullable', 'in:active,inactive'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $product->update($validator->validated());

        return response()->json(['status' => 'success', 'message' => 'Produk berhasil diperbarui', 'data' => $product->fresh(['images', 'variants'])]);
    }

    public function destroy(Request $request, Product $product)
    {
        if ($product->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $product->delete();

        return response()->json(['status' => 'success', 'message' => 'Produk berhasil dihapus']);
    }
}
