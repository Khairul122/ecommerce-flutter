<!doctype html>
<html lang="id">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>@yield('title', 'Dashboard') - Ootday Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="{{ asset('css/admin_custom.css') }}" rel="stylesheet">
</head>
<body>
    <div class="d-flex">
        <aside class="ootday-sidebar d-flex flex-column flex-shrink-0">
            <div class="brand">Ootday Admin</div>
            <nav class="nav flex-column py-2">
                <a class="nav-link {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}" href="{{ route('admin.dashboard') }}">
                    <i class="bi bi-speedometer2 me-2"></i> Dashboard
                </a>
                <a class="nav-link {{ request()->routeIs('admin.users.*') ? 'active' : '' }}" href="{{ route('admin.users.index') }}">
                    <i class="bi bi-people me-2"></i> Pengguna
                </a>
                <a class="nav-link {{ request()->routeIs('admin.stores.*') ? 'active' : '' }}" href="{{ route('admin.stores.index') }}">
                    <i class="bi bi-shop me-2"></i> Toko
                </a>
                <a class="nav-link {{ request()->routeIs('admin.categories.*') ? 'active' : '' }}" href="{{ route('admin.categories.index') }}">
                    <i class="bi bi-tags me-2"></i> Kategori
                </a>
                <a class="nav-link {{ request()->routeIs('admin.products.*') ? 'active' : '' }}" href="{{ route('admin.products.index') }}">
                    <i class="bi bi-box-seam me-2"></i> Produk
                </a>
                <a class="nav-link {{ request()->routeIs('admin.orders.*') ? 'active' : '' }}" href="{{ route('admin.orders.index') }}">
                    <i class="bi bi-receipt me-2"></i> Pesanan
                </a>
                <a class="nav-link {{ request()->routeIs('admin.payment-methods.*') ? 'active' : '' }}" href="{{ route('admin.payment-methods.index') }}">
                    <i class="bi bi-credit-card me-2"></i> Metode Pembayaran
                </a>
                <a class="nav-link {{ request()->routeIs('admin.shipping-methods.*') ? 'active' : '' }}" href="{{ route('admin.shipping-methods.index') }}">
                    <i class="bi bi-truck me-2"></i> Metode Pengiriman
                </a>
            </nav>
        </aside>

        <div class="flex-grow-1">
            <header class="ootday-topbar d-flex justify-content-between align-items-center px-4 py-2">
                <h1 class="h5 mb-0">@yield('title', 'Dashboard')</h1>
                <div class="d-flex align-items-center gap-3">
                    <span class="text-muted small">{{ auth('web')->user()->name ?? '' }}</span>
                    <form method="POST" action="{{ route('admin.logout') }}">
                        @csrf
                        <button type="submit" class="btn btn-sm btn-outline-secondary">Keluar</button>
                    </form>
                </div>
            </header>

            <main class="ootday-content">
                @if (session('status'))
                    <div class="alert alert-success">{{ session('status') }}</div>
                @endif

                @if ($errors->any())
                    <div class="alert alert-danger">
                        <ul class="mb-0">
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif

                @yield('content')
            </main>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    @yield('scripts')
</body>
</html>
