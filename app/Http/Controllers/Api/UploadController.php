<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class UploadController extends Controller
{
    /**
     * Menggantikan firebase_storage (dihapus bersama Firebase). Menerima file
     * gambar (multipart/form-data, field "file") dan menyimpannya ke
     * storage/app/public/uploads, lalu mengembalikan URL publiknya.
     * Dipakai untuk foto profil toko dan gambar produk.
     * Jalankan `php artisan storage:link` supaya /storage/... bisa diakses publik.
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => ['required', 'file', 'image', 'max:5120'],
        ]);

        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $file = $request->file('file');
        $filename = Str::uuid().'.'.$file->getClientOriginalExtension();
        $path = $file->storeAs('uploads', $filename, 'public');

        return response()->json([
            'status' => 'success',
            'data' => ['url' => url('/storage/'.$path)],
        ], 201);
    }
}
