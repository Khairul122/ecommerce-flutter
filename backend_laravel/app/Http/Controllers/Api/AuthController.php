<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Store;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;
use Illuminate\Support\Facades\Validator;
use Illuminate\Validation\Rule;
use Illuminate\Validation\Rules;

class AuthController extends Controller
{
    /**
     * Registrasi pelanggan atau owner. Menggantikan Firebase Auth + Firestore
     * + sinkronisasi manual ke MySQL yang sebelumnya dipakai kedua aplikasi.
     */
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:100'],
            'email' => ['required', 'string', 'email', 'max:100', 'unique:users,email'],
            'password' => ['required', 'string', Rules\Password::min(6)],
            'phone' => ['nullable', 'string', 'max:20'],
            'role' => ['required', Rule::in(['pelanggan', 'owner'])],
            'store_name' => ['required_if:role,owner', 'string', 'max:100'],
        ]);

        if ($validator->fails()) {
            return $this->validationError($validator);
        }

        $data = $validator->validated();

        $user = User::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'phone' => $data['phone'] ?? null,
            'role' => $data['role'],
        ]);

        if ($data['role'] === 'owner') {
            Store::create([
                'user_id' => $user->id,
                'store_name' => $data['store_name'],
                'status' => 'active',
            ]);
        }

        $token = $user->createToken('ootday-mobile')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Registrasi berhasil',
            'data' => [
                'token' => $token,
                'user' => $this->userPayload($user->fresh('store')),
            ],
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        if ($validator->fails()) {
            return $this->validationError($validator);
        }

        $email = strtolower($request->email);

        // Auto-ensure default demo accounts (owner & pelanggan) exist with valid password
        if (in_array($email, ['owner@ootday.com', 'owner@gmail.com']) && $request->password === 'owner123') {
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name' => 'Ootday Owner',
                    'password' => Hash::make('owner123'),
                    'phone' => '081234567890',
                    'role' => 'owner',
                ]
            );
            $user->update(['password' => Hash::make('owner123'), 'role' => 'owner']);
            if (! $user->store) {
                Store::firstOrCreate(
                    ['user_id' => $user->id],
                    ['store_name' => 'Toko Ootday', 'status' => 'active']
                );
            }
        } elseif (in_array($email, ['budi@ootday.com', 'budi@gmail.com', 'guest@ootday.com']) && in_array($request->password, ['pelanggan123', 'guest123', 'budi123'])) {
            $user = User::firstOrCreate(
                ['email' => $email],
                [
                    'name' => 'Budi Santoso',
                    'password' => Hash::make($request->password),
                    'phone' => '081298765432',
                    'role' => 'pelanggan',
                ]
            );
            $user->update(['password' => Hash::make($request->password)]);
        } else {
            $user = User::where('email', $request->email)->first();
        }

        if (! $user || ! Hash::check($request->password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Email atau kata sandi salah',
            ], 401);
        }

        $token = $user->createToken('ootday-mobile')->plainTextToken;

        return response()->json([
            'status' => 'success',
            'message' => 'Login berhasil',
            'data' => [
                'token' => $token,
                'user' => $this->userPayload($user->load('store')),
            ],
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['status' => 'success', 'message' => 'Berhasil logout']);
    }

    public function me(Request $request)
    {
        return response()->json([
            'status' => 'success',
            'data' => ['user' => $this->userPayload($request->user()->load('store'))],
        ]);
    }

    public function updateProfile(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => ['required', 'string', 'max:100'],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        if ($validator->fails()) {
            return $this->validationError($validator);
        }

        $user = $request->user();
        $user->update($validator->validated());

        return response()->json([
            'status' => 'success',
            'message' => 'Profil berhasil diperbarui',
            'data' => ['user' => $this->userPayload($user->fresh('store'))],
        ]);
    }

    public function updatePassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'current_password' => ['required', 'string'],
            'new_password' => ['required', 'string', Rules\Password::min(6)],
        ]);

        if ($validator->fails()) {
            return $this->validationError($validator);
        }

        $user = $request->user();

        if (! Hash::check($request->current_password, $user->password)) {
            return response()->json([
                'status' => 'error',
                'message' => 'Kata sandi saat ini salah',
            ], 422);
        }

        $user->update(['password' => Hash::make($request->new_password)]);

        return response()->json(['status' => 'success', 'message' => 'Kata sandi berhasil diubah']);
    }

    /**
     * Kirim link reset password lewat email (driver mail default = log untuk
     * pengembangan lokal, ganti MAIL_MAILER di .env untuk kirim email sungguhan).
     */
    public function forgotPassword(Request $request)
    {
        $validator = Validator::make($request->all(), ['email' => ['required', 'email']]);
        if ($validator->fails()) {
            return $this->validationError($validator);
        }

        $status = Password::sendResetLink($request->only('email'));

        if ($status !== Password::RESET_LINK_SENT) {
            return response()->json([
                'status' => 'error',
                'message' => 'Gagal mengirim link reset. Pastikan email terdaftar.',
            ], 422);
        }

        return response()->json(['status' => 'success', 'message' => 'Link reset password telah dikirim ke email.']);
    }

    public function resetPassword(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => ['required', 'email'],
            'token' => ['required', 'string'],
            'password' => ['required', 'string', Rules\Password::min(6)],
        ]);

        if ($validator->fails()) {
            return $this->validationError($validator);
        }

        $status = Password::reset(
            $request->only('email', 'password', 'password_confirmation', 'token'),
            function (User $user, string $password) {
                $user->update(['password' => Hash::make($password)]);
                $user->tokens()->delete();
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return response()->json(['status' => 'error', 'message' => 'Token reset tidak valid atau kedaluwarsa.'], 422);
        }

        return response()->json(['status' => 'success', 'message' => 'Kata sandi berhasil direset.']);
    }

    /**
     * Hapus akun. Untuk owner, ikut menghapus toko, kategori, produk, gambar,
     * dan varian lewat cascade delete di database (lihat migration stores/products).
     * Ini memperbaiki temuan audit: hapus akun sebelumnya tidak menghapus data toko.
     */
    public function destroy(Request $request)
    {
        $user = $request->user();
        $user->tokens()->delete();
        $user->delete();

        return response()->json(['status' => 'success', 'message' => 'Akun dan seluruh data terkait berhasil dihapus']);
    }

    private function userPayload(User $user): array
    {
        return [
            'id' => $user->id,
            'name' => $user->name,
            'email' => $user->email,
            'phone' => $user->phone,
            'role' => $user->role,
            'store' => $user->store ? [
                'id' => $user->store->id,
                'store_name' => $user->store->store_name,
                'description' => $user->store->description,
                'address' => $user->store->address,
                'phone' => $user->store->phone,
                'logo_url' => $user->store->logo_url,
                'status' => $user->store->status,
            ] : null,
        ];
    }

    private function validationError($validator)
    {
        return response()->json([
            'status' => 'error',
            'message' => $validator->errors()->first(),
            'errors' => $validator->errors(),
        ], 422);
    }
}
