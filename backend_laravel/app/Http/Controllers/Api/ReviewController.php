<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Review;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    /**
     * Mendapatkan ulasan ulasan untuk suatu produk (Publik).
     */
    public function index($productId)
    {
        $reviews = Review::with('user:id,name,avatar')
            ->where('product_id', $productId)
            ->latest()
            ->paginate(15);

        $avgRating = Review::where('product_id', $productId)->avg('rating') ?: 5.0;
        $totalReviews = Review::where('product_id', $productId)->count();

        return response()->json([
            'success' => true,
            'avg_rating' => round($avgRating, 1),
            'total_reviews' => $totalReviews,
            'data' => $reviews->items(),
            'current_page' => $reviews->currentPage(),
            'last_page' => $reviews->lastPage(),
        ]);
    }

    /**
     * Menambahkan ulasan dari pengguna setelah pesanan selesai.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'product_id' => 'required|exists:products,id',
            'rating' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
            'images' => 'nullable|array',
            'images.*' => 'string',
        ]);

        $order = Order::where('id', $validated['order_id'])
            ->where('user_id', $request->user()->id)
            ->firstOrFail();

        // Cek apakah ulasan sudah pernah diberikan untuk produk ini di pesanan ini
        $existing = Review::where('order_id', $order->id)
            ->where('product_id', $validated['product_id'])
            ->where('user_id', $request->user()->id)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Anda sudah memberikan ulasan untuk produk ini pada pesanan tersebut.',
            ], 422);
        }

        $review = Review::create([
            'user_id' => $request->user()->id,
            'order_id' => $order->id,
            'product_id' => $validated['product_id'],
            'rating' => $validated['rating'],
            'comment' => $validated['comment'] ?? null,
            'images' => $validated['images'] ?? [],
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Ulasan Anda berhasil dikirim! Terima kasih atas masukkannya.',
            'data' => $review->load('user:id,name,avatar'),
        ], 201);
    }
}
