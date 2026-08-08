@extends('admin.layouts.app')

@section('title', 'Metode Pengiriman')

@section('content')
    <div class="d-flex justify-content-end mb-3">
        <button class="btn btn-brand" data-bs-toggle="modal" data-bs-target="#createModal">Tambah Metode</button>
    </div>

    <div class="card">
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Kurir</th>
                        <th>Status</th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($shippingMethods as $method)
                        <tr>
                            <td>{{ $method->name }}</td>
                            <td>{{ $couriers[$method->courier_code] ?? $method->courier_code ?? '-' }}</td>
                            <td>
                                <span class="badge {{ $method->is_active ? 'text-bg-success' : 'text-bg-secondary' }}">
                                    {{ $method->is_active ? 'Aktif' : 'Nonaktif' }}
                                </span>
                            </td>
                            <td class="text-end">
                                <button class="btn btn-sm btn-outline-secondary" data-bs-toggle="modal" data-bs-target="#editModal{{ $method->id }}">Edit</button>
                                <form action="{{ route('admin.shipping-methods.destroy', $method) }}" method="POST" class="d-inline" onsubmit="return confirm('Hapus metode ini?')">
                                    @csrf @method('DELETE')
                                    <button class="btn btn-sm btn-outline-danger">Hapus</button>
                                </form>
                            </td>
                        </tr>

                        <div class="modal fade" id="editModal{{ $method->id }}">
                            <div class="modal-dialog">
                                <div class="modal-content">
                                    <form method="POST" action="{{ route('admin.shipping-methods.update', $method) }}">
                                        @csrf @method('PUT')
                                        <div class="modal-header">
                                            <h5 class="modal-title">Edit Metode Pengiriman</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <div class="modal-body">
                                            <div class="mb-2">
                                                <label class="form-label">Nama</label>
                                                <input type="text" name="name" value="{{ $method->name }}" class="form-control" required>
                                            </div>
                                            <div class="mb-2">
                                                <label class="form-label">Kurir (RajaOngkir)</label>
                                                <select name="courier_code" class="form-select" required>
                                                    @foreach ($couriers as $code => $label)
                                                        <option value="{{ $code }}" @selected($method->courier_code === $code)>{{ $label }}</option>
                                                    @endforeach
                                                </select>
                                            </div>
                                            <div class="form-check">
                                                <input type="checkbox" name="is_active" value="1" class="form-check-input" id="active{{ $method->id }}" @checked($method->is_active)>
                                                <label class="form-check-label" for="active{{ $method->id }}">Aktif</label>
                                            </div>
                                        </div>
                                        <div class="modal-footer">
                                            <button class="btn btn-brand">Simpan</button>
                                        </div>
                                    </form>
                                </div>
                            </div>
                        </div>
                    @empty
                        <tr><td colspan="4" class="text-center text-muted py-3">Tidak ada data</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="modal fade" id="createModal">
        <div class="modal-dialog">
            <div class="modal-content">
                <form method="POST" action="{{ route('admin.shipping-methods.store') }}">
                    @csrf
                    <div class="modal-header">
                        <h5 class="modal-title">Tambah Metode Pengiriman</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                    </div>
                    <div class="modal-body">
                        <div class="mb-2">
                            <label class="form-label">Nama</label>
                            <input type="text" name="name" class="form-control" required>
                        </div>
                        <div class="mb-2">
                            <label class="form-label">Kurir (RajaOngkir)</label>
                            <select name="courier_code" class="form-select" required>
                                @foreach ($couriers as $code => $label)
                                    <option value="{{ $code }}">{{ $label }}</option>
                                @endforeach
                            </select>
                        </div>
                        <div class="form-check">
                            <input type="checkbox" name="is_active" value="1" class="form-check-input" id="activeNew" checked>
                            <label class="form-check-label" for="activeNew">Aktif</label>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button class="btn btn-brand">Simpan</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
@endsection
