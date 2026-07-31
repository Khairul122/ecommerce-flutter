<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json(['message' => 'Ootday API. Lihat /api untuk endpoint.']);
});
