<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Category;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CategoryController extends Controller
{
    public function index(Request $request)
    {
        $query = Category::query();

        if ($request->filled('store_id')) {
            $query->where('store_id', $request->store_id);
        }

        return response()->json(['status' => 'success', 'data' => $query->get()]);
    }

    public function store(Request $request)
    {
        $store = $request->user()->store;

        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:100'],
            'icon_url' => ['nullable', 'string'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $category = $store->categories()->create($validator->validated());

        return response()->json(['status' => 'success', 'data' => $category], 201);
    }

    public function update(Request $request, Category $category)
    {
        if ($category->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $category->update($request->only('name', 'icon_url'));

        return response()->json(['status' => 'success', 'data' => $category]);
    }

    public function destroy(Request $request, Category $category)
    {
        if ($category->store_id !== $request->user()->store->id) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $category->delete();

        return response()->json(['status' => 'success', 'message' => 'Kategori dihapus']);
    }
}
