<?php

use App\Http\Controllers\Api\AddressController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CartController;
use App\Http\Controllers\Api\CategoryController;
use App\Http\Controllers\Api\ConversationController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\OwnerOrderController;
use App\Http\Controllers\Api\PaymentShippingMethodController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\StoreController;
use App\Http\Controllers\Api\UploadController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Ootday
|--------------------------------------------------------------------------
| Menggantikan Firebase Auth/Firestore/Messaging/Crashlytics dan koneksi
| MySQL langsung dari aplikasi mobile (mysql_service.dart). Semua akses
| data sekarang wajib lewat endpoint di sini, diautentikasi dengan token
| Sanctum yang dikirim lewat header Authorization: Bearer <token>.
*/

// ---- Publik (tanpa login) ----
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

Route::get('/products', [ProductController::class, 'index']);
Route::get('/products/{product}', [ProductController::class, 'show']);
Route::get('/categories', [CategoryController::class, 'index']);
Route::get('/payment-methods', [PaymentShippingMethodController::class, 'paymentMethods']);
Route::get('/shipping-methods', [PaymentShippingMethodController::class, 'shippingMethods']);

// ---- Wajib login (pelanggan maupun owner) ----
Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/me/password', [AuthController::class, 'updatePassword']);
    Route::delete('/me', [AuthController::class, 'destroy']);
    Route::post('/upload', [UploadController::class, 'store']);

    Route::get('/addresses', [AddressController::class, 'index']);
    Route::post('/addresses', [AddressController::class, 'store']);
    Route::put('/addresses/{id}', [AddressController::class, 'update']);
    Route::delete('/addresses/{id}', [AddressController::class, 'destroy']);
    Route::post('/addresses/{id}/set-main', [AddressController::class, 'setMain']);

    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{id}', [CartController::class, 'update']);
    Route::delete('/cart/{id}', [CartController::class, 'destroy']);
    Route::post('/cart/select-all', [CartController::class, 'selectAll']);

    Route::get('/orders', [OrderController::class, 'index']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::post('/orders/{order}/confirm-payment', [OrderController::class, 'confirmPayment']);
    Route::post('/orders/{order}/cancel', [OrderController::class, 'cancel']);

    Route::get('/conversations', [ConversationController::class, 'index']);
    Route::post('/conversations', [ConversationController::class, 'storeOrGet']);
    Route::get('/conversations/{conversation}/messages', [ConversationController::class, 'messages']);
    Route::post('/conversations/{conversation}/messages', [ConversationController::class, 'sendMessage']);

    // ---- Khusus role owner ----
    Route::middleware('role:owner')->prefix('owner')->group(function () {
        Route::get('/store', [StoreController::class, 'show']);
        Route::put('/store', [StoreController::class, 'update']);
        Route::put('/profile', [StoreController::class, 'updateProfile']);
        Route::get('/stats', [StoreController::class, 'stats']);

        Route::get('/products', [ProductController::class, 'myProducts']);
        Route::post('/products', [ProductController::class, 'store']);
        Route::put('/products/{product}', [ProductController::class, 'update']);
        Route::delete('/products/{product}', [ProductController::class, 'destroy']);

        Route::post('/categories', [CategoryController::class, 'store']);
        Route::put('/categories/{category}', [CategoryController::class, 'update']);
        Route::delete('/categories/{category}', [CategoryController::class, 'destroy']);

        Route::get('/orders', [OwnerOrderController::class, 'index']);
        Route::get('/orders/{order}', [OwnerOrderController::class, 'show']);
        Route::put('/orders/{order}/status', [OwnerOrderController::class, 'updateStatus']);
        Route::post('/orders/{order}/confirm-payment', [OwnerOrderController::class, 'confirmPayment']);
    });
});
