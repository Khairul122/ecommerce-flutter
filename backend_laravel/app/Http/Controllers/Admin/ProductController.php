<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Category;
use App\Models\Product;
use App\Models\Store;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Illuminate\Validation\Rule;

class ProductController extends Controller
{
    public function index(Request $request)
    {
        $query = Product::with(['store', 'category']);

        if ($request->filled('store_id')) {
            $query->where('store_id', $request->store_id);
        }

        if ($request->filled('q')) {
            $query->where('name', 'like', '%'.$request->q.'%');
        }

        $products = $query->orderByDesc('created_at')->paginate(20)->withQueryString();
        $stores = Store::orderBy('store_name')->get();

        return view('admin.products.index', compact('products', 'stores'));
    }

    public function create()
    {
        $stores = Store::orderBy('store_name')->get();
        $categories = Category::orderBy('name')->get();

        return view('admin.products.create', compact('stores', 'categories'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'store_id' => ['required', 'exists:stores,id'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['required', Rule::in(['active', 'inactive'])],
            'images' => ['nullable', 'array'],
            'images.*' => ['file', 'image', 'max:5120'],
            'variants' => ['nullable', 'array'],
            'variants.*.size' => ['required_with:variants', 'string'],
            'variants.*.color' => ['required_with:variants', 'string'],
            'variants.*.stock' => ['nullable', 'integer', 'min:0'],
            'variants.*.price' => ['nullable', 'numeric', 'min:0'],
            'variants.*.existing_image_url' => ['nullable', 'string'],
            'variant_images' => ['nullable', 'array'],
            'variant_images.*' => ['nullable', 'file', 'image', 'max:5120'],
        ]);

        DB::transaction(function () use ($data, $request) {
            $product = Product::create([
                'store_id' => $data['store_id'],
                'category_id' => $data['category_id'] ?? null,
                'name' => $data['name'],
                'price' => $data['price'],
                'stock' => $data['stock'] ?? 0,
                'status' => $data['status'],
                'description' => $data['description'] ?? null,
            ]);

            $this->syncImages($product, $request);
            $this->syncVariants($product, $data['variants'] ?? [], $request);
        });

        return redirect()->route('admin.products.index')->with('status', 'Produk berhasil ditambahkan');
    }

    public function edit(Product $product)
    {
        $product->load(['images', 'variants']);
        $stores = Store::orderBy('store_name')->get();
        $categories = Category::orderBy('name')->get();

        return view('admin.products.edit', compact('product', 'stores', 'categories'));
    }

    public function update(Request $request, Product $product)
    {
        $data = $request->validate([
            'store_id' => ['required', 'exists:stores,id'],
            'category_id' => ['nullable', 'exists:categories,id'],
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'stock' => ['nullable', 'integer', 'min:0'],
            'description' => ['nullable', 'string'],
            'status' => ['required', Rule::in(['active', 'inactive'])],
            'images' => ['nullable', 'array'],
            'images.*' => ['file', 'image', 'max:5120'],
            'variants' => ['nullable', 'array'],
            'variants.*.size' => ['required_with:variants', 'string'],
            'variants.*.color' => ['required_with:variants', 'string'],
            'variants.*.stock' => ['nullable', 'integer', 'min:0'],
            'variants.*.price' => ['nullable', 'numeric', 'min:0'],
            'variants.*.existing_image_url' => ['nullable', 'string'],
            'variant_images' => ['nullable', 'array'],
            'variant_images.*' => ['nullable', 'file', 'image', 'max:5120'],
        ]);

        DB::transaction(function () use ($product, $data, $request) {
            $product->update([
                'store_id' => $data['store_id'],
                'category_id' => $data['category_id'] ?? null,
                'name' => $data['name'],
                'price' => $data['price'],
                'stock' => $data['stock'] ?? 0,
                'status' => $data['status'],
                'description' => $data['description'] ?? null,
            ]);

            $this->syncImages($product, $request);

            $product->variants()->delete();
            $this->syncVariants($product, $data['variants'] ?? [], $request);
        });

        return redirect()->route('admin.products.index')->with('status', 'Produk berhasil diperbarui');
    }

    public function destroy(Product $product)
    {
        $product->delete();

        return redirect()->route('admin.products.index')->with('status', 'Produk berhasil dihapus');
    }

    public function destroyImage(Product $product, \App\Models\ProductImage $image)
    {
        abort_unless($image->product_id === $product->id, 404);

        $image->delete();

        return back()->with('status', 'Gambar berhasil dihapus');
    }

    private function syncImages(Product $product, Request $request): void
    {
        if (! $request->hasFile('images')) {
            return;
        }

        $nextOrder = $product->images()->max('sort_order');
        $nextOrder = $nextOrder === null ? 0 : $nextOrder + 1;
        $hasPrimary = $product->images()->where('is_primary', true)->exists();

        foreach ($request->file('images') as $file) {
            $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
            $path = $file->storeAs('uploads', $filename, 'public');

            $product->images()->create([
                'image_url' => url('/storage/'.$path),
                'is_primary' => ! $hasPrimary,
                'sort_order' => $nextOrder,
            ]);

            $hasPrimary = true;
            $nextOrder++;
        }
    }

    private function syncVariants(Product $product, array $variants, Request $request): void
    {
        foreach ($variants as $i => $variant) {
            if (empty($variant['size']) || empty($variant['color'])) {
                continue;
            }

            $imageUrl = $variant['existing_image_url'] ?? null;
            if ($request->hasFile("variant_images.$i")) {
                $file = $request->file("variant_images.$i");
                $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
                $path = $file->storeAs('uploads', $filename, 'public');
                $imageUrl = url('/storage/'.$path);
            }

            $product->variants()->create([
                'size' => $variant['size'],
                'color' => $variant['color'],
                'stock' => $variant['stock'] ?? 0,
                'price' => $variant['price'] ?? $product->price,
                'image_url' => $imageUrl,
            ]);
        }
    }
}
