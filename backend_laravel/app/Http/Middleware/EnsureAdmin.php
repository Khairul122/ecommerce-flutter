<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class EnsureAdmin
{
    /**
     * Membatasi akses halaman admin panel (session/web) hanya untuk role admin.
     * Berbeda dari EnsureRole yang JSON-based dan dipakai untuk API mobile.
     */
    public function handle(Request $request, Closure $next)
    {
        $user = $request->user('web');

        if (! $user || $user->role !== 'admin') {
            return redirect()->route('admin.login')->withErrors([
                'email' => 'Akses ditolak. Halaman ini khusus admin.',
            ]);
        }

        return $next($request);
    }
}
