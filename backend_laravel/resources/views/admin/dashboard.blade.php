@extends('admin.layouts.app')

@section('title', 'Dashboard')

@section('content')
    <div class="row g-3 mb-4">
        <div class="col-md-2 col-sm-6">
            <div class="stat-card">
                <div class="stat-value">{{ $stats['users'] }}</div>
                <div class="stat-label">Pengguna</div>
            </div>
        </div>
        <div class="col-md-2 col-sm-6">
            <div class="stat-card">
                <div class="stat-value">{{ $stats['stores'] }}</div>
                <div class="stat-label">Toko</div>
            </div>
        </div>
        <div class="col-md-2 col-sm-6">
            <div class="stat-card">
                <div class="stat-value">{{ $stats['products'] }}</div>
                <div class="stat-label">Produk</div>
            </div>
        </div>
        <div class="col-md-2 col-sm-6">
            <div class="stat-card">
                <div class="stat-value">{{ $stats['orders'] }}</div>
                <div class="stat-label">Pesanan</div>
            </div>
        </div>
        <div class="col-md-2 col-sm-6">
            <div class="stat-card">
                <div class="stat-value">{{ $stats['orders_pending'] }}</div>
                <div class="stat-label">Menunggu Bayar</div>
            </div>
        </div>
        <div class="col-md-2 col-sm-6">
            <div class="stat-card">
                <div class="stat-value">Rp{{ number_format($stats['revenue_paid'], 0, ',', '.') }}</div>
                <div class="stat-label">Pendapatan</div>
            </div>
        </div>
    </div>

    <div class="card">
        <div class="card-header bg-white fw-semibold">Pesanan Terbaru</div>
        <div class="table-responsive">
            <table class="table mb-0 align-middle">
                <thead>
                    <tr>
                        <th>Kode</th>
                        <th>Pelanggan</th>
                        <th>Toko</th>
                        <th>Total</th>
                        <th>Status</th>
                        <th>Tanggal</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($recentOrders as $order)
                        <tr>
                            <td><a href="{{ route('admin.orders.show', $order) }}">{{ $order->order_code }}</a></td>
                            <td>{{ $order->user->name ?? '-' }}</td>
                            <td>{{ $order->store->store_name ?? '-' }}</td>
                            <td>Rp{{ number_format($order->total_price, 0, ',', '.') }}</td>
                            <td><span class="badge text-bg-secondary">{{ $order->status }}</span></td>
                            <td>{{ $order->ordered_at?->format('d M Y H:i') }}</td>
                        </tr>
                    @empty
                        <tr><td colspan="6" class="text-center text-muted py-3">Belum ada pesanan</td></tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection
