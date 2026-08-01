@extends('admin.layouts.app')

@section('title', 'Kategori')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-3">
        <form class="d-flex gap-2" method="GET">
            <select name="store_id" class="form-select" onchange="this.form.submit()">
                <option value="">Semua Toko</option>
                @foreach ($stores as $store)
                    <option value="{{ $store->id }}" @selected(request('store_id') == $store->id)>{{ $store->store_name }}</option>
                @endforeach
            </select>
        </form>
        <a href="{{ route('admin.categories.create') }}" class="btn btn-brand">Tambah Kategori</a>
    </div>

    <div class="card">
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th style="width:60px">Icon</th>
                        <th>Nama</th>
                        <th>Toko</th>
                        <th>Produk</th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($categories as $category)
                        @php
                            $iconSrc = $category->icon_url
                                ? (str_starts_with($category->icon_url, 'http') ? $category->icon_url : asset($category->icon_url))
                                : asset('assets/images/pria icons.png');
                        @endphp
                        <tr>
                            <td>
                                <img src="{{ $iconSrc }}" alt="{{ $category->name }}" style="width:36px;height:36px;object-fit:contain">
                            </td>
                            <td class="fw-medium">{{ $category->name }}</td>
                            <td>{{ $category->store->store_name ?? '-' }}</td>
                            <td>{{ $category->products_count }}</td>
                            <td class="text-end">
                                <a href="{{ route('admin.categories.edit', $category) }}" class="btn btn-sm btn-outline-secondary">Edit</a>
                                <form action="{{ route('admin.categories.destroy', $category) }}" method="POST" class="d-inline" onsubmit="return confirm('Hapus kategori ini?')">
                                    @csrf @method('DELETE')
                                    <button class="btn btn-sm btn-outline-danger">Hapus</button>
                                </form>
                            </td>
                        </tr>
                    @empty
                        <tr><td colspan="5" class="text-center text-muted py-3">Tidak ada data</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-3">{{ $categories->links() }}</div>
@endsection
