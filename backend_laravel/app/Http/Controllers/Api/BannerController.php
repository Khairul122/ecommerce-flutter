<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Banner;
use Illuminate\Http\Request;

class BannerController extends Controller
{
    /**
     * Mendapatkan daftar banner aktif untuk aplikasi pelanggan (Publik).
     */
    public function index()
    {
        $banners = Banner::where('is_active', true)
            ->orderBy('sort_order', 'asc')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $banners,
        ]);
    }

    /**
     * Khusus Owner/Admin: Mendapatkan semua banner.
     */
    public function ownerIndex()
    {
        $banners = Banner::orderBy('sort_order', 'asc')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $banners,
        ]);
    }

    /**
     * Khusus Owner/Admin: Menambah banner baru.
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'image_url' => 'required|string',
            'link_url' => 'nullable|string',
            'is_active' => 'boolean',
            'sort_order' => 'integer',
        ]);

        $banner = Banner::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'Banner promosi berhasil ditambahkan.',
            'data' => $banner,
        ], 201);
    }

    /**
     * Khusus Owner/Admin: Mengubah status / detail banner.
     */
    public function update(Request $request, $id)
    {
        $banner = Banner::findOrFail($id);

        $validated = $request->validate([
            'title' => 'sometimes|string|max:255',
            'image_url' => 'sometimes|string',
            'link_url' => 'nullable|string',
            'is_active' => 'sometimes|boolean',
            'sort_order' => 'sometimes|integer',
        ]);

        $banner->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Banner promosi berhasil diperbarui.',
            'data' => $banner,
        ]);
    }

    /**
     * Khusus Owner/Admin: Menghapus banner.
     */
    public function destroy($id)
    {
        $banner = Banner::findOrFail($id);
        $banner->delete();

        return response()->json([
            'success' => true,
            'message' => 'Banner promosi berhasil dihapus.',
        ]);
    }
}
