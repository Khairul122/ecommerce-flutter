@php $category = $category ?? null; @endphp

<div class="row g-3">
    <div class="col-md-6">
        <label class="form-label">Toko</label>
        <select name="store_id" class="form-select" required>
            <option value="">Pilih Toko</option>
            @foreach ($stores as $store)
                <option value="{{ $store->id }}" @selected(old('store_id', $category->store_id ?? '') == $store->id)>{{ $store->store_name }}</option>
            @endforeach
        </select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Nama Kategori</label>
        <input type="text" name="name" value="{{ old('name', $category->name ?? '') }}" class="form-control" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">URL Ikon (opsional)</label>
        <input type="text" name="icon_url" value="{{ old('icon_url', $category->icon_url ?? '') }}" class="form-control">
    </div>
</div>

<div class="mt-4">
    <button class="btn btn-brand">Simpan</button>
    <a href="{{ route('admin.categories.index') }}" class="btn btn-outline-secondary">Batal</a>
</div>
