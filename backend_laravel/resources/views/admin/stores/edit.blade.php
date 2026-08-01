@extends('admin.layouts.app')

@section('title', 'Edit Toko')

@section('content')
    <div class="card">
        <div class="card-body">
            <form method="POST" action="{{ route('admin.stores.update', $store) }}">
                @csrf @method('PUT')

                <div class="row g-3">
                    <div class="col-md-6">
                        <label class="form-label">Nama Toko</label>
                        <input type="text" name="store_name" value="{{ old('store_name', $store->store_name) }}" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Telepon</label>
                        <input type="text" name="phone" value="{{ old('phone', $store->phone) }}" class="form-control">
                    </div>
                    <div class="col-12">
                        <label class="form-label">Deskripsi</label>
                        <textarea name="description" class="form-control" rows="3">{{ old('description', $store->description) }}</textarea>
                    </div>
                    <div class="col-12">
                        <label class="form-label">Alamat</label>
                        <textarea name="address" class="form-control" rows="2">{{ old('address', $store->address) }}</textarea>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Status</label>
                        <select name="status" class="form-select">
                            <option value="active" @selected(old('status', $store->status) === 'active')>Active</option>
                            <option value="inactive" @selected(old('status', $store->status) === 'inactive')>Inactive</option>
                        </select>
                    </div>
                </div>

                <div class="mt-4">
                    <button class="btn btn-brand">Simpan</button>
                    <a href="{{ route('admin.stores.index') }}" class="btn btn-outline-secondary">Batal</a>
                </div>
            </form>
        </div>
    </div>
@endsection
