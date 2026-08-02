@extends('admin.layouts.app')

@section('title', 'Detail Pesanan')

@section('content')
    @if ($errors->any())
        <div class="alert alert-danger">
            <ul class="mb-0">
                @foreach ($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
        </div>
    @endif

    <div class="row g-3">
        <div class="col-md-8">
            <div class="card mb-3">
                <div class="card-header bg-white fw-semibold">{{ $order->order_code }}</div>
                <div class="table-responsive">
                    <table class="table mb-0 align-middle">
                        <thead>
                            <tr>
                                <th>Produk</th>
                                <th>Varian</th>
                                <th>Harga</th>
                                <th>Qty</th>
                            </tr>
                        </thead>
                        <tbody>
                            @foreach ($order->items as $item)
                                <tr>
                                    <td>{{ $item->product_name }}</td>
                                    <td>{{ $item->variant_label ?? '-' }}</td>
                                    <td>Rp{{ number_format($item->price, 0, ',', '.') }}</td>
                                    <td>{{ $item->quantity }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="card">
                <div class="card-header bg-white fw-semibold">Pengiriman</div>
                <div class="card-body">
                    <p class="mb-1"><strong>{{ $order->receiver_name }}</strong> ({{ $order->receiver_phone }})</p>
                    <p class="mb-0">{{ $order->shipping_address }}</p>
                </div>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card mb-3">
                <div class="card-header bg-white fw-semibold">Ringkasan</div>
                <div class="card-body">
                    <p class="mb-1">Pelanggan: {{ $order->user->name ?? '-' }}</p>
                    <p class="mb-1">Toko: {{ $order->store->store_name ?? '-' }}</p>
                    <p class="mb-1">Subtotal: Rp{{ number_format($order->subtotal, 0, ',', '.') }}</p>
                    <p class="mb-1">Ongkir: Rp{{ number_format($order->shipping_cost, 0, ',', '.') }}</p>
                    <p class="mb-1 fw-semibold">Total: Rp{{ number_format($order->total_price, 0, ',', '.') }}</p>
                    <p class="mb-1">Metode Pembayaran: {{ $order->paymentMethod->name ?? '-' }}</p>
                    <p class="mb-0">Metode Pengiriman: {{ $order->shippingMethod->name ?? '-' }}</p>
                </div>
            </div>

            @if ($order->payment_proof_url)
                <div class="card mb-3">
                    <div class="card-header bg-white fw-semibold">Bukti Pembayaran</div>
                    <div class="card-body">
                        <img src="{{ $order->payment_proof_url }}" class="img-fluid rounded">
                    </div>
                </div>
            @endif

            <div class="card">
                <div class="card-header bg-white fw-semibold">Ubah Status</div>
                <div class="card-body">
                    <form method="POST" action="{{ route('admin.orders.update-status', $order) }}" class="mb-3">
                        @csrf @method('PATCH')
                        <select name="status" id="order-status-select" class="form-select mb-2">
                            @foreach (['menunggu_pembayaran', 'diproses', 'dikirim', 'selesai', 'dibatalkan'] as $status)
                                <option value="{{ $status }}" @selected(old('status', $order->status) === $status)>{{ $status }}</option>
                            @endforeach
                        </select>
                        <input
                            type="text"
                            name="cancel_reason"
                            id="cancel-reason-input"
                            value="{{ old('cancel_reason', $order->cancel_reason) }}"
                            class="form-control mb-2"
                            placeholder="Alasan pembatalan (wajib diisi jika status dibatalkan)"
                            style="display:none"
                        >
                        <button class="btn btn-brand w-100">Simpan Status</button>
                    </form>
                    <script>
                        (function () {
                            const statusSelect = document.getElementById('order-status-select');
                            const reasonInput = document.getElementById('cancel-reason-input');

                            function syncReasonField() {
                                const isCancelled = statusSelect.value === 'dibatalkan';
                                reasonInput.style.display = isCancelled ? 'block' : 'none';
                                reasonInput.required = isCancelled;
                            }

                            statusSelect.addEventListener('change', syncReasonField);
                            syncReasonField();
                        })();
                    </script>

                    @if ($order->payment_status === 'menunggu_konfirmasi')
                        <form method="POST" action="{{ route('admin.orders.confirm-payment', $order) }}">
                            @csrf @method('PATCH')
                            <button class="btn btn-success w-100">Konfirmasi Pembayaran</button>
                        </form>
                    @endif
                </div>
            </div>
        </div>
    </div>
@endsection
