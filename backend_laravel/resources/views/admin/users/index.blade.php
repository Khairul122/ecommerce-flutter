@extends('admin.layouts.app')

@section('title', 'Pengguna')

@section('content')
    <div class="d-flex justify-content-between align-items-center mb-3">
        <form class="d-flex gap-2" method="GET">
            <input type="text" name="q" value="{{ request('q') }}" class="form-control" placeholder="Cari nama/email">
            <select name="role" class="form-select">
                <option value="">Semua Role</option>
                <option value="pelanggan" @selected(request('role') === 'pelanggan')>Pelanggan</option>
                <option value="owner" @selected(request('role') === 'owner')>Owner</option>
                <option value="admin" @selected(request('role') === 'admin')>Admin</option>
            </select>
            <button class="btn btn-outline-secondary">Cari</button>
        </form>
        <a href="{{ route('admin.users.create') }}" class="btn btn-brand">Tambah Pengguna</a>
    </div>

    <div class="card">
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th>Nama</th>
                        <th>Email</th>
                        <th>Telepon</th>
                        <th>Role</th>
                        <th class="text-end">Aksi</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($users as $user)
                        <tr>
                            <td>{{ $user->name }}</td>
                            <td>{{ $user->email }}</td>
                            <td>{{ $user->phone ?? '-' }}</td>
                            <td><span class="badge text-bg-secondary">{{ $user->role }}</span></td>
                            <td class="text-end">
                                <a href="{{ route('admin.users.edit', $user) }}" class="btn btn-sm btn-outline-secondary">Edit</a>
                                <form action="{{ route('admin.users.destroy', $user) }}" method="POST" class="d-inline" onsubmit="return confirm('Hapus pengguna ini?')">
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

    <div class="mt-3">{{ $users->links() }}</div>
@endsection
