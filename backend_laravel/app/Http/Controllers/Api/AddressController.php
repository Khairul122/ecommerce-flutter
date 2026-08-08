<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class AddressController extends Controller
{
    public function index(Request $request)
    {
        $addresses = $request->user()->addresses()->orderByDesc('is_main')->orderByDesc('created_at')->get();

        return response()->json(['status' => 'success', 'data' => $addresses]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'receiver_name' => ['required', 'string', 'max:100'],
            'phone' => ['required', 'string', 'max:20'],
            'full_address' => ['required', 'string'],
            'province_id' => ['nullable', 'integer'],
            'province_name' => ['nullable', 'string', 'max:100'],
            'city_id' => ['nullable', 'integer'],
            'city_name' => ['nullable', 'string', 'max:100'],
            'is_main' => ['nullable', 'boolean'],
            'district_id' => ['nullable', 'integer'],
            'district_name' => ['nullable', 'string', 'max:150'],
            'city_name' => ['nullable', 'string', 'max:150'],
            'province_name' => ['nullable', 'string', 'max:150'],
            'postal_code' => ['nullable', 'string', 'max:10'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $data = $validator->validated();
        $user = $request->user();

        if (($data['is_main'] ?? false) || $user->addresses()->count() === 0) {
            $user->addresses()->update(['is_main' => false]);
            $data['is_main'] = true;
        }

        $address = $user->addresses()->create($data);

        return response()->json(['status' => 'success', 'data' => $address], 201);
    }

    public function update(Request $request, $id)
    {
        $address = $request->user()->addresses()->findOrFail($id);

        $validator = Validator::make($request->all(), [
            'receiver_name' => ['sometimes', 'required', 'string', 'max:100'],
            'phone' => ['sometimes', 'required', 'string', 'max:20'],
            'full_address' => ['sometimes', 'required', 'string'],
            'province_id' => ['nullable', 'integer'],
            'province_name' => ['nullable', 'string', 'max:100'],
            'city_id' => ['nullable', 'integer'],
            'city_name' => ['nullable', 'string', 'max:100'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $address->update($validator->validated());

        return response()->json(['status' => 'success', 'data' => $address]);
    }

    public function destroy(Request $request, $id)
    {
        $address = $request->user()->addresses()->findOrFail($id);
        $address->delete();

        return response()->json(['status' => 'success', 'message' => 'Alamat dihapus']);
    }

    public function setMain(Request $request, $id)
    {
        $user = $request->user();
        $address = $user->addresses()->findOrFail($id);

        $user->addresses()->update(['is_main' => false]);
        $address->update(['is_main' => true]);

        return response()->json(['status' => 'success', 'data' => $address]);
    }
}
