<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ProductVariant;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class CartController extends Controller
{
    public function index(Request $request)
    {
        $items = $request->user()->cartItems()
            ->with(['variant.product.images'])
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['status' => 'success', 'data' => $items]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'variant_id' => ['required', 'exists:product_variants,id'],
            'quantity' => ['nullable', 'integer', 'min:1'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $user = $request->user();
        $variant = ProductVariant::findOrFail($request->variant_id);
        $quantity = $request->integer('quantity', 1);

        $item = $user->cartItems()->where('variant_id', $variant->id)->first();

        if ($item) {
            $item->increment('quantity', $quantity);
            $item->update(['is_selected' => true]);
        } else {
            $item = $user->cartItems()->create([
                'variant_id' => $variant->id,
                'quantity' => $quantity,
                'is_selected' => true,
            ]);
        }

        return response()->json(['status' => 'success', 'data' => $item->fresh('variant.product.images')], 201);
    }

    public function update(Request $request, $id)
    {
        $item = $request->user()->cartItems()->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'quantity' => ['nullable', 'integer', 'min:1'],
            'is_selected' => ['nullable', 'boolean'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $item->update($validator->validated());

        return response()->json(['status' => 'success', 'data' => $item->fresh()]);
    }

    public function destroy(Request $request, $id)
    {
        $item = $request->user()->cartItems()->findOrFail($id);
        $item->delete();

        return response()->json(['status' => 'success', 'message' => 'Item dihapus dari keranjang']);
    }

    public function selectAll(Request $request)
    {
        $validator = Validator::make($request->all(), ['is_selected' => ['required', 'boolean']]);
        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $request->user()->cartItems()->update(['is_selected' => $request->boolean('is_selected')]);

        return response()->json(['status' => 'success', 'message' => 'Keranjang diperbarui']);
    }
}
