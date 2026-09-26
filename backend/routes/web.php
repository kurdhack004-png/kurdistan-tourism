<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'success' => true,
        'service' => 'Kurdistan Tourism API',
        'status' => 'online',
    ]);
});
