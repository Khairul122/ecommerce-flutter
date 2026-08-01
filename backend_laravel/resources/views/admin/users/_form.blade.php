@php $user = $user ?? null; @endphp

<div class="row g-3">
    <div class="col-md-6">
        <label class="form-label">Nama</label>
        <input type="text" name="name" value="{{ old('name', $user->name ?? '') }}" class="form-control" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">Email</label>
        <input type="email" name="email" value="{{ old('email', $user->email ?? '') }}" class="form-control" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">Kata Sandi {{ $user ? '(kosongkan jika tidak diubah)' : '' }}</label>
        <input type="password" name="password" class="form-control" {{ $user ? '' : 'required' }}>
    </div>
    <div class="col-md-6">
        <label class="form-label">Telepon</label>
        <input type="text" name="phone" value="{{ old('phone', $user->phone ?? '') }}" class="form-control">
    </div>
    <div class="col-md-6">
        <label class="form-label">Role</label>
        <select name="role" class="form-select" required>
            @foreach (['pelanggan', 'owner', 'admin'] as $role)
                <option value="{{ $role }}" @selected(old('role', $user->role ?? '') === $role)>{{ ucfirst($role) }}</option>
            @endforeach
        </select>
    </div>
</div>

<div class="mt-4">
    <button class="btn btn-brand">Simpan</button>
    <a href="{{ route('admin.users.index') }}" class="btn btn-outline-secondary">Batal</a>
</div>
