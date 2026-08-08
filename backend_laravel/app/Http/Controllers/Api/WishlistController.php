<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Wishlist;
use Illuminate\Http\Request;

class WishlistController extends Controller
{
    /**
     * Mendapatkan daftar produk favorit/wishlist milik pengguna aktif.
     */
    public function index(Request $request)
    {
        $wishlists = Wishlist::with(['product.category', 'product.images', 'product.variants'])
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $wishlists->pluck('product')->filter()->values(),
        ]);
    }

    /**
     * Menambah atau menghapus produk dari wishlist (toggle).
     */
    public function toggle(Request $request, $productId)
    {
        $userId = $request->user()->id;

        $existing = Wishlist::where('user_id', $userId)
            ->where('product_id', $productId)
            ->first();

        if ($existing) {
            $existing->delete();
            return response()->json([
                'success' => true,
                'is_wishlist' => false,
                'message' => 'Produk dihapus dari wishlist',
            ]);
        }

        Wishlist::create([
            'user_id' => $userId,
            'product_id' => $productId,
        ]);

        return response()->json([
            'success' => true,
            'is_wishlist' => true,
            'message' => 'Produk ditambahkan ke wishlist',
        ]);
    }

    /**
     * Memeriksa daftar ID produk yang ada di wishlist pengguna (untuk sync UI).
     */
    public function ids(Request $request)
    {
        $ids = Wishlist::where('user_id', $request->user()->id)
            ->pluck('product_id')
            ->toArray();

        return response()->json([
            'success' => true,
            'data' => $ids,
        ]);
    }
}
