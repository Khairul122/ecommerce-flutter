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
            <div class="row g-2 mb-2 variant-row align-items-center">
                <div class="col-md-2">
                    <input type="text" name="variants[{{ $i }}][size]" value="{{ $variant['size'] ?? '' }}" class="form-control" placeholder="Ukuran">
                </div>
                <div class="col-md-2">
                    <input type="text" name="variants[{{ $i }}][color]" value="{{ $variant['color'] ?? '' }}" class="form-control" placeholder="Warna">
                </div>
                <div class="col-md-2">
                    <input type="number" name="variants[{{ $i }}][stock]" value="{{ $variant['stock'] ?? 0 }}" class="form-control" placeholder="Stok">
                </div>
                <div class="col-md-2">
                    <input type="number" step="0.01" name="variants[{{ $i }}][price]" value="{{ $variant['price'] ?? '' }}" class="form-control" placeholder="Harga">
                </div>
                <div class="col-md-2">
                    <input type="file" name="variant_images[{{ $i }}]" class="form-control form-control-sm" accept="image/*">
                    @if (! empty($variant['image_url']))
                        <input type="hidden" name="variants[{{ $i }}][existing_image_url]" value="{{ $variant['image_url'] }}">
                        <img src="{{ $variant['image_url'] }}" style="width:32px;height:32px;object-fit:cover;border-radius:4px" class="mt-1">
                    @endif
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
        row.className = 'row g-2 mb-2 variant-row align-items-center';
        row.innerHTML = `
            <div class="col-md-2"><input type="text" name="variants[${index}][size]" class="form-control" placeholder="Ukuran"></div>
            <div class="col-md-2"><input type="text" name="variants[${index}][color]" class="form-control" placeholder="Warna"></div>
            <div class="col-md-2"><input type="number" name="variants[${index}][stock]" class="form-control" placeholder="Stok"></div>
            <div class="col-md-2"><input type="number" step="0.01" name="variants[${index}][price]" class="form-control" placeholder="Harga"></div>
            <div class="col-md-2"><input type="file" name="variant_images[${index}]" class="form-control form-control-sm" accept="image/*"></div>
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
