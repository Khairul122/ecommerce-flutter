<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Product;
use App\Models\Store;
use App\Models\User;

class DashboardController extends Controller
{
    public function index()
    {
        $stats = [
            'users' => User::count(),
            'stores' => Store::count(),
            'products' => Product::count(),
            'orders' => Order::count(),
            'orders_pending' => Order::where('status', 'menunggu_pembayaran')->count(),
            'revenue_paid' => Order::where('payment_status', 'paid')->sum('total_price'),
        ];

        $recentOrders = Order::with(['user', 'store'])->latest('ordered_at')->limit(10)->get();

        return view('admin.dashboard', compact('stats', 'recentOrders'));
    }
}
