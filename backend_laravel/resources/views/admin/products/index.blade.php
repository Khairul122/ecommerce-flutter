@extends('admin.layouts.app')

@section('title', 'Produk')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-3">
        <form class="d-flex gap-2" method="GET">
            <input type="text" name="q" value="{{ request('q') }}" class="form-control" placeholder="Cari produk">
            <select name="store_id" class="form-select" onchange="this.form.submit()">
                <option value="">Semua Toko</option>
                @foreach ($stores as $store)
                    <option value="{{ $store->id }}" @selected(request('store_id') == $store->id)>{{ $store->store_name }}</option>
                @endforeach
            </select>
            <button class="btn btn-outline-secondary">Cari</button>
        </form>
        <a href="{{ route('admin.products.create') }}" class="btn btn-brand">Tambah Produk</a>
    </div>

    <div class="card">
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th style="width:70px">Gambar</th>
                        <th>Nama</th>
                        <th>Toko</th>
                        <th>Kategori</th>
                        <th>Harga</th>
                        <th>Stok</th>
                        <th>Status</th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($products as $product)
                        @php
                            $primaryImg = $product->primaryImage?->image_url ?? $product->images->first()?->image_url;
                            $imgSrc = $primaryImg
                                ? (str_starts_with($primaryImg, 'http') ? $primaryImg : asset($primaryImg))
                                : asset('assets/images/Produk_1.png');
                        @endphp
                        <tr>
                            <td>
                                <img src="{{ $imgSrc }}" alt="{{ $product->name }}" style="width:48px;height:48px;object-fit:cover;border-radius:6px;border:1px solid #e5e0d8">
                            </td>
                            <td class="fw-medium">{{ $product->name }}</td>
                            <td>{{ $product->store->store_name ?? '-' }}</td>
                            <td>{{ $product->category->name ?? '-' }}</td>
                            <td>Rp{{ number_format($product->price, 0, ',', '.') }}</td>
                            <td>{{ $product->stock }}</td>
                            <td>
                                <span class="badge {{ $product->status === 'active' ? 'text-bg-success' : 'text-bg-secondary' }}">
                                    {{ $product->status }}
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="{{ route('admin.products.edit', $product) }}" class="btn btn-sm btn-outline-secondary">Edit</a>
                                <form action="{{ route('admin.products.destroy', $product) }}" method="POST" class="d-inline" onsubmit="return confirm('Hapus produk ini?')">
                                    @csrf @method('DELETE')
                                    <button class="btn btn-sm btn-outline-danger">Hapus</button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="8" class="text-center text-muted py-3">Tidak ada data</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-3">{{ $products->links() }}</div>
@endsection
