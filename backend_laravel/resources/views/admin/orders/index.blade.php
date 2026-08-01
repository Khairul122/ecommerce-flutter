@extends('admin.layouts.app')

@section('title', 'Pesanan')

@section('content')
    <form class="d-flex gap-2 mb-3" method="GET">
        <input type="text" name="q" value="{{ request('q') }}" class="form-control" placeholder="Cari kode pesanan" style="max-width: 260px">
        <select name="status" class="form-select" onchange="this.form.submit()" style="max-width: 220px">
            <option value="">Semua Status</option>
            @foreach (['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai', 'dibatalkan'] as $status)
                <option value="{{ $status }}" @selected(request('status') === $status)>{{ $status }}</option>
            @endforeach
        </select>
        <button class="btn btn-outline-secondary">Cari</button>
    </form>

    <div class="card">
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th>Kode</th>
                        <th>Pelanggan</th>
                        <th>Toko</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Pembayaran</th>
                        <th>Tanggal</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($orders as $order)
                        <tr>
                            <td>{{ $order->order_code }}</td>
                            <td>{{ $order->user->name ?? '-' }}</td>
                            <td>{{ $order->store->store_name ?? '-' }}</td>
                            <td>Rp{{ number_format($order->total_price, 0, ',', '.') }}</td>
                            <td><span class="badge text-bg-secondary">{{ $order->status }}</span></td>
                            <td><span class="badge text-bg-light border">{{ $order->payment_status }}</span></td>
                            <td>{{ $order->ordered_at?->format('d M Y H:i') }}</td>
                            <td class="text-end"><a href="{{ route('admin.orders.show', $order) }}" class="btn btn-sm btn-outline-secondary">Detail</a></td>
                        </tr>
                    @empty
                        <tr><td colspan="8" class="text-center text-muted py-3">Tidak ada data</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>

    <div class="mt-3">{{ $orders->links() }}</div>
@endsection
