<?php

use App\Http\Controllers\Api\AccommodationController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\ReviewController;
use Illuminate\Support\Facades\Route;

Route::get('/health', fn () => response()->json(['success' => true, 'status' => 'online', 'version' => '10.0']));

Route::middleware('throttle:10,1')->group(function () {
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/login', [AuthController::class, 'login']);
});

Route::get('/locations', [LocationController::class, 'index']);
Route::get('/locations/{id}', [LocationController::class, 'show']);
Route::get('/reviews', [ReviewController::class, 'index']);
Route::get('/accommodations', [AccommodationController::class, 'index']);
Route::get('/accommodations/{id}', [AccommodationController::class, 'show']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/auth/me', [AuthController::class, 'me']);
    Route::post('/auth/logout', [AuthController::class, 'logout']);

    Route::post('/locations', [LocationController::class, 'store']);
    Route::post('/reviews', [ReviewController::class, 'store']);

    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::post('/bookings/{id}/pay', [BookingController::class, 'pay']);
    Route::post('/bookings/{id}/cancel', [BookingController::class, 'cancel']);

    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::post('/favorites', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{type}/{id}', [FavoriteController::class, 'destroy']);

    Route::middleware('role:guide,admin')->group(function () {
        Route::patch('/locations/{id}/verify', function (string $id) {
            $location = \App\Models\Location::findOrFail($id);
            $location->update(['is_verified' => true]);
            return response()->json(['success' => true, 'data' => $location]);
        });
    });
});
