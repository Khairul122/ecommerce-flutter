<?php

use App\Http\Controllers\Admin;
use Illuminate\Support\Facades\Artisan;
use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json(['message' => 'Ootday API. Lihat /api untuk endpoint.']);
});

// TEMPORARY: hapus route ini setelah dipakai sekali untuk clear cache compiled view
Route::get('/clear-cache', function () {
    Artisan::call('view:clear');
    Artisan::call('cache:clear');
    Artisan::call('config:clear');
    return 'Cache cleared';
});

Route::prefix('admin')->name('admin.')->group(function () {
    Route::get('login', [Admin\AuthController::class, 'showLogin'])->name('login')->middleware('guest:web');
    Route::post('login', [Admin\AuthController::class, 'login'])->middleware('guest:web');
    Route::post('logout', [Admin\AuthController::class, 'logout'])->name('logout');

    Route::middleware('admin')->group(function () {
        Route::get('/', [Admin\DashboardController::class, 'index'])->name('dashboard');

        Route::resource('users', Admin\UserController::class)->except(['show']);
        Route::resource('stores', Admin\StoreController::class)->except(['create', 'show']);
        Route::resource('categories', Admin\CategoryController::class)->except(['show']);

        Route::resource('products', Admin\ProductController::class)->except(['show']);
        Route::delete('products/{product}/images/{image}', [Admin\ProductController::class, 'destroyImage'])->name('products.images.destroy');

        Route::resource('orders', Admin\OrderController::class)->only(['index', 'show']);
        Route::patch('orders/{order}/status', [Admin\OrderController::class, 'updateStatus'])->name('orders.update-status');
        Route::patch('orders/{order}/confirm-payment', [Admin\OrderController::class, 'confirmPayment'])->name('orders.confirm-payment');

        Route::get('payment-methods', [Admin\PaymentMethodController::class, 'index'])->name('payment-methods.index');
        Route::post('payment-methods', [Admin\PaymentMethodController::class, 'store'])->name('payment-methods.store');
        Route::put('payment-methods/{paymentMethod}', [Admin\PaymentMethodController::class, 'update'])->name('payment-methods.update');
        Route::delete('payment-methods/{paymentMethod}', [Admin\PaymentMethodController::class, 'destroy'])->name('payment-methods.destroy');

        Route::get('shipping-methods', [Admin\ShippingMethodController::class, 'index'])->name('shipping-methods.index');
        Route::post('shipping-methods', [Admin\ShippingMethodController::class, 'store'])->name('shipping-methods.store');
        Route::put('shipping-methods/{shippingMethod}', [Admin\ShippingMethodController::class, 'update'])->name('shipping-methods.update');
        Route::delete('shipping-methods/{shippingMethod}', [Admin\ShippingMethodController::class, 'destroy'])->name('shipping-methods.destroy');
    });
});
