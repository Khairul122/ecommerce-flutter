<?php

use App\Http\Controllers\Admin;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json(['message' => 'Ootday API. Lihat /api untuk endpoint.']);
});

// TEMPORARY: hapus route ini setelah dipakai sekali untuk clear cache & update
Route::get('/clear-cache', function () {
    Artisan::call('view:clear');
    Artisan::call('cache:clear');
    Artisan::call('config:clear');
    return 'Cache cleared';
});

Route::get('/run-migration', function () {
    $log = [];
    try {
        \Illuminate\Support\Facades\Artisan::call('migrate', ['--force' => true]);
        $log[] = "Artisan Migrate: " . \Illuminate\Support\Facades\Artisan::output();
    } catch (\Throwable $e) {
        $log[] = "Artisan Migrate Error: " . $e->getMessage();
    }

    try {
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'snap_token')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('snap_token')->nullable()->after('payment_status');
            });
            $log[] = "Added column snap_token manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'snap_redirect_url')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->text('snap_redirect_url')->nullable()->after('snap_token');
            });
            $log[] = "Added column snap_redirect_url manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'payment_type')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('payment_type')->nullable()->after('snap_redirect_url');
            });
            $log[] = "Added column payment_type manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_courier')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('shipping_courier', 50)->nullable();
            });
            $log[] = "Added column shipping_courier manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_service')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('shipping_service', 50)->nullable();
            });
            $log[] = "Added column shipping_service manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_weight')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->integer('shipping_weight')->default(0);
            });
            $log[] = "Added column shipping_weight manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'shipping_etd')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('shipping_etd', 50)->nullable();
            });
            $log[] = "Added column shipping_etd manually.";
        }
        if (!\Illuminate\Support\Facades\Schema::hasColumn('orders', 'tracking_number')) {
            \Illuminate\Support\Facades\Schema::table('orders', function ($table) {
                $table->string('tracking_number', 100)->nullable();
            });
            $log[] = "Added column tracking_number manually.";
        }
        \App\Models\Order::where('status', 'menunggu_pembayaran')->update(['status' => 'diproses', 'payment_status' => 'paid']);
        $log[] = "Updated existing pending orders to diproses and paid.";

        // Auto-seed sample products for stores that currently have 0 products (e.g. Toko Sepatu)
        $storesWithoutProducts = \App\Models\Store::doesntHave('products')->get();
        foreach ($storesWithoutProducts as $st) {
            $isShoe = str_contains(strtolower($st->store_name), 'sepatu') || str_contains(strtolower($st->description ?? ''), 'sepatu');
            $sampleProducts = $isShoe ? [
                [
                    'name' => 'Sepatu Sneakers Casual Canvas White Classic',
                    'price' => 185000,
                    'stock' => 100,
                    'description' => 'Sepatu sneakers kasual dari bahan kanvas premium yang ringan, adem, dan fleksibel untuk dipakai sehari-hari.',
                    'image' => 'https://backend-ecommerce.synectra.xyz/storage/seed_images/produk_5.png',
                    'color' => 'Putih',
                    'sizes' => ['39', '40', '41', '42', '43'],
                ],
                [
                    'name' => 'Sepatu Running Sport Lightweight Performance',
                    'price' => 245000,
                    'stock' => 80,
                    'description' => 'Sepatu olahraga lari sporty dengan insole empuk dan outsole anti-slip untuk mendukung performa maksimal.',
                    'image' => 'https://backend-ecommerce.synectra.xyz/storage/seed_images/cowo1.jpeg',
                    'color' => 'Hitam',
                    'sizes' => ['39', '40', '41', '42', '43'],
                ],
                [
                    'name' => 'Sepatu Pantofel Executive Leather Black Formal',
                    'price' => 295000,
                    'stock' => 60,
                    'description' => 'Sepatu pantofel pria kulit sintetis premium dengan desain elegan untuk acara kantor dan formal.',
                    'image' => 'https://backend-ecommerce.synectra.xyz/storage/seed_images/produk_5.png',
                    'color' => 'Hitam',
                    'sizes' => ['39', '40', '41', '42', '43'],
                ],
            ] : [
                [
                    'name' => "Kemeja Exclusive Store {$st->store_name}",
                    'price' => 150000,
                    'stock' => 100,
                    'description' => "Produk eksklusif koleksi terbaru dari toko {$st->store_name}.",
                    'image' => 'https://backend-ecommerce.synectra.xyz/storage/seed_images/produk_2.png',
                    'color' => 'Putih',
                    'sizes' => ['M', 'L', 'XL'],
                ],
            ];

            foreach ($sampleProducts as $sp) {
                $p = \App\Models\Product::create([
                    'store_id' => $st->id,
                    'category_id' => 1,
                    'name' => $sp['name'],
                    'price' => $sp['price'],
                    'stock' => $sp['stock'],
                    'status' => 'active',
                    'description' => $sp['description'],
                    'sold_count' => rand(5, 20),
                ]);
                $p->images()->create([
                    'image_url' => $sp['image'],
                    'is_primary' => true,
                    'sort_order' => 0,
                ]);
                foreach ($sp['sizes'] as $sz) {
                    $p->variants()->create([
                        'size' => $sz,
                        'color' => $sp['color'],
                        'stock' => 20,
                        'price' => $sp['price'],
                    ]);
                }
            }
            $log[] = "Auto-seeded products for store: {$st->store_name}";
        }

        $log[] = "Schema check complete.";
    } catch (\Throwable $e) {
        $log[] = "Schema Alter Error: " . $e->getMessage();
    }

    return '<pre>' . htmlspecialchars(implode("\n\n", $log)) . '</pre>';
});

Route::get('/update-code', function () {
    $out = function_exists('shell_exec') ? shell_exec('git pull origin main 2>&1') : 'shell_exec disabled';
    try { Artisan::call('view:clear'); } catch (\Throwable $e) {}
    try { Artisan::call('config:clear'); } catch (\Throwable $e) {}
    try { Artisan::call('cache:clear'); } catch (\Throwable $e) {}
    return '<pre>' . htmlspecialchars($out) . '</pre>';
});

Route::get('/git-pull', function () {
    $log = [];
    try {
        if (function_exists('shell_exec')) {
            $log[] = "GIT PULL:\n" . (shell_exec('git pull origin main 2>&1') ?? 'No output');
        } else {
            $log[] = "shell_exec is disabled on this server.";
        }
    } catch (\Throwable $e) {
        $log[] = "Git pull error: " . $e->getMessage();
    }

    try {
        Artisan::call('migrate', ['--force' => true]);
        $log[] = "Migrate: " . Artisan::output();
    } catch (\Throwable $e) {
        $log[] = "Migrate error: " . $e->getMessage();
    }

    try {
        Artisan::call('db:seed', ['--class' => 'PaymentShippingSeeder', '--force' => true]);
        $log[] = "Seeder: " . Artisan::output();
    } catch (\Throwable $e) {
        $log[] = "Seeder error: " . $e->getMessage();
    }

    try {
        Artisan::call('view:clear');
        Artisan::call('config:clear');
        Artisan::call('cache:clear');
        $log[] = "Cache cleared!";
    } catch (\Throwable $e) {
        $log[] = "Cache clear error: " . $e->getMessage();
    }

    return '<pre>' . htmlspecialchars(implode("\n\n", $log)) . '</pre>';
});

Route::get('/check-form', function () {
    $path = resource_path('views/admin/products/_form.blade.php');
    if (!file_exists($path)) return 'File not found';
    return '<pre>' . htmlspecialchars(file_get_contents($path)) . '</pre>';
});

Route::get('/fix-form', function () {
    $path = resource_path('views/admin/products/_form.blade.php');
    $content = <<<'BLADE'
@php $product = $product ?? null; @endphp

<div class="row g-3">
    <div class="col-md-6">
        <label class="form-label">Toko</label>
        <select name="store_id" class="form-select" required>
            <option value="">Pilih Toko</option>
            @foreach ($stores as $store)
                <option value="{{ $store->id }}" @selected(old('store_id', $product->store_id ?? '') == $store->id)>{{ $store->store_name }}</option>
            @endforeach
        </select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Kategori</label>
        <select name="category_id" class="form-select">
            <option value="">Tanpa Kategori</option>
            @foreach ($categories as $category)
                <option value="{{ $category->id }}" @selected(old('category_id', $product->category_id ?? '') == $category->id)>{{ $category->name }}</option>
            @endforeach
        </select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Nama Produk</label>
        <input type="text" name="name" value="{{ old('name', $product->name ?? '') }}" class="form-control" required>
    </div>
    <div class="col-md-3">
        <label class="form-label">Harga</label>
        <input type="number" step="0.01" name="price" value="{{ old('price', $product->price ?? '') }}" class="form-control" required>
    </div>
    <div class="col-md-3">
        <label class="form-label">Stok</label>
        <input type="number" name="stock" value="{{ old('stock', $product->stock ?? 0) }}" class="form-control">
    </div>
    <div class="col-12">
        <label class="form-label">Deskripsi</label>
        <textarea name="description" class="form-control" rows="3">{{ old('description', $product->description ?? '') }}</textarea>
    </div>
    <div class="col-md-4">
        <label class="form-label">Status</label>
        <select name="status" class="form-select">
            <option value="active" @selected(old('status', $product->status ?? 'active') === 'active')>Active</option>
            <option value="inactive" @selected(old('status', $product->status ?? '') === 'inactive')>Inactive</option>
        </select>
    </div>
</div>

@if ($product && $product->images->isNotEmpty())
    <div class="mt-4">
        <label class="form-label d-block">Gambar Saat Ini</label>
        <div class="d-flex flex-wrap gap-3">
            @foreach ($product->images as $image)
                <div class="text-center">
                    <img src="{{ $image->image_url }}" style="width:100px;height:100px;object-fit:cover;border-radius:.375rem" class="mb-1">
                    <form action="{{ route('admin.products.images.destroy', [$product, $image]) }}" method="POST" onsubmit="return confirm('Hapus gambar ini?')">
                        @csrf @method('DELETE')
                        <button class="btn btn-sm btn-outline-danger">Hapus</button>
                    </form>
                </div>
            @endforeach
        </div>
    </div>
@endif

<div class="mt-4">
    <label class="form-label">Tambah Gambar</label>
    <input type="file" name="images[]" class="form-control" multiple accept="image/*">
</div>

<div class="mt-4">
    <label class="form-label d-block">Varian (ukuran/warna)</label>
    <div id="variant-rows">
        @php $oldVariants = old('variants', $product?->variants?->toArray() ?? []); @endphp
        @foreach ($oldVariants as $i => $variant)
            <div class="row g-2 mb-2 variant-row">
                <div class="col-md-3">
                    <input type="text" name="variants[{{ $i }}][size]" value="{{ $variant['size'] ?? '' }}" class="form-control" placeholder="Ukuran">
                </div>
                <div class="col-md-3">
                    <input type="text" name="variants[{{ $i }}][color]" value="{{ $variant['color'] ?? '' }}" class="form-control" placeholder="Warna">
                </div>
                <div class="col-md-2">
                    <input type="number" name="variants[{{ $i }}][stock]" value="{{ $variant['stock'] ?? 0 }}" class="form-control" placeholder="Stok">
                </div>
                <div class="col-md-2">
                    <input type="number" step="0.01" name="variants[{{ $i }}][price]" value="{{ $variant['price'] ?? '' }}" class="form-control" placeholder="Harga">
                </div>
                <div class="col-md-2">
                    <button type="button" class="btn btn-outline-danger remove-variant">Hapus</button>
                </div>
            </div>
        @endforeach
    </div>
    <button type="button" id="add-variant" class="btn btn-sm btn-outline-secondary">+ Tambah Varian</button>
</div>

<div class="mt-4">
    <button class="btn btn-brand">Simpan</button>
    <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary">Batal</a>
</div>

<script>
(function () {
    const container = document.getElementById('variant-rows');
    let index = container.children.length;

    document.getElementById('add-variant').addEventListener('click', function () {
        const row = document.createElement('div');
        row.className = 'row g-2 mb-2 variant-row';
        row.innerHTML = `
            <div class="col-md-3"><input type="text" name="variants[${index}][size]" class="form-control" placeholder="Ukuran"></div>
            <div class="col-md-3"><input type="text" name="variants[${index}][color]" class="form-control" placeholder="Warna"></div>
            <div class="col-md-2"><input type="number" name="variants[${index}][stock]" class="form-control" placeholder="Stok"></div>
            <div class="col-md-2"><input type="number" step="0.01" name="variants[${index}][price]" class="form-control" placeholder="Harga"></div>
            <div class="col-md-2"><button type="button" class="btn btn-outline-danger remove-variant">Hapus</button></div>
        `;
        container.appendChild(row);
        index++;
    });

    container.addEventListener('click', function (e) {
        if (e.target.classList.contains('remove-variant')) {
            e.target.closest('.variant-row').remove();
        }
    });
})();
</script>
BLADE;
    file_put_contents($path, $content);
    Artisan::call('view:clear');
    return '<h2 style="color:green;">SUKSES! File _form.blade.php berhasil diperbaiki di server dan view cache telah dibersihkan.</h2><p><a href="/admin/products/create">Klik di sini untuk membuka Halaman Tambah Produk</a></p>';
});

Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login', [Admin\AuthController::class, 'showLogin'])->name('login')->middleware('guest:web');
    Route::post('login', [Admin\AuthController::class, 'login'])->middleware('guest:web');
    Route::match(['get', 'post'], 'logout', [Admin\AuthController::class, 'logout'])->name('logout');

    Route::middleware('admin')->group(function () {
        Route::get('dashboard', [Admin\DashboardController::class, 'index'])->name('dashboard');
        Route::get('/', fn () => redirect()->route('admin.dashboard'));

        Route::resource('users', Admin\UserController::class)->except(['show']);
        Route::resource('stores', Admin\StoreController::class)->except(['create', 'show']);
        Route::resource('categories', Admin\CategoryController::class)->except(['show']);

        Route::resource('products', Admin\ProductController::class)->except(['show']);
        Route::delete('products/{product}/images/{image}', [Admin\ProductController::class, 'destroyImage'])->name('products.images.destroy');

        Route::resource('orders', Admin\OrderController::class)->only(['index', 'show']);
        Route::patch('orders/{order}/status', [Admin\OrderController::class, 'updateStatus'])->name('orders.update-status');
        Route::patch('orders/{order}/confirm-payment', [Admin\OrderController::class, 'confirmPayment'])->name('orders.confirm-payment');

        Route::get('payment-methods', [Admin\PaymentMethodController::class, 'index'])->name('payment-methods.index');
        Route::post('payment-methods', [Admin\PaymentMethodController::class, 'store'])->name('payment-methods.store');
        Route::put('payment-methods/{paymentMethod}', [Admin\PaymentMethodController::class, 'update'])->name('payment-methods.update');
        Route::delete('payment-methods/{paymentMethod}', [Admin\PaymentMethodController::class, 'destroy'])->name('payment-methods.destroy');

        Route::get('shipping-methods', [Admin\ShippingMethodController::class, 'index'])->name('shipping-methods.index');
        Route::post('shipping-methods', [Admin\ShippingMethodController::class, 'store'])->name('shipping-methods.store');
        Route::put('shipping-methods/{shippingMethod}', [Admin\ShippingMethodController::class, 'update'])->name('shipping-methods.update');
        Route::delete('shipping-methods/{shippingMethod}', [Admin\ShippingMethodController::class, 'destroy'])->name('shipping-methods.destroy');
    });
});
