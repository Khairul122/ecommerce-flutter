<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsureRole
{
    /**
     * Membatasi akses endpoint berdasarkan role user (owner / pelanggan).
     * Dipakai lewat middleware alias 'role', contoh: ->middleware('role:owner')
     */
    public function handle(Request $request, Closure $next, string $role)
    {
        $user = $request->user();

        if (! $user || $user->role !== $role) {
            return response()->json([
                'status' => 'error',
                'message' => 'Akses ditolak. Endpoint ini khusus untuk role '.$role.'.',
            ], 403);
        }

        return $next($request);
    }
}
