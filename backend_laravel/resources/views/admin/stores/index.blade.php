@extends('admin.layouts.app')

@section('title', 'Toko')

@section('content')
    <form class="d-flex gap-2 mb-3" method="GET">
        <input type="text" name="q" value="{{ request('q') }}" class="form-control" placeholder="Cari nama toko" style="max-width: 320px">
        <button class="btn btn-outline-secondary">Cari</button>
    </form>

    <div class="card">
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th>Nama Toko</th>
                        <th>Pemilik</th>
                        <th>Produk</th>
                        <th>Status</th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($stores as $store)
                        <tr>
                            <td>{{ $store->store_name }}</td>
                            <td>{{ $store->owner->name ?? '-' }}</td>
                            <td>{{ $store->products_count }}</td>
                            <td>
                                <span class="badge {{ $store->status === 'active' ? 'text-bg-success' : 'text-bg-secondary' }}">
                                    {{ $store->status }}
                                </span>
                            </td>
                            <td class="text-end">
                                <a href="{{ route('admin.stores.edit', $store) }}" class="btn btn-sm btn-outline-secondary">Edit</a>
                                <form action="{{ route('admin.stores.destroy', $store) }}" method="POST" class="d-inline" onsubmit="return confirm('Hapus toko ini?')">
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

    <div class="mt-3">{{ $stores->links() }}</div>
@endsection
