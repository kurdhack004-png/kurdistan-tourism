<?php

use App\Http\Controllers\Api\AccommodationController;
use App\Http\Controllers\Api\AdminController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\DashboardController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\HealthController;
use App\Http\Controllers\Api\LocationController;
use App\Http\Controllers\Api\PaymentWebhookController;
use App\Http\Controllers\Api\ReviewController;
use Illuminate\Support\Facades\Route;

Route::get('/health', HealthController::class);

Route::post('/payments/webhook', [PaymentWebhookController::class, 'handle'])
    ->middleware('throttle:120,1');

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

    Route::middleware('role:admin,super-admin')->prefix('admin')->group(function () {
        Route::get('/dashboard', DashboardController::class);
        Route::get('/locations', [AdminController::class, 'locations']);
        Route::post('/locations', [AdminController::class, 'storeLocation']);
        Route::patch('/locations/{id}', [AdminController::class, 'updateLocation']);
        Route::delete('/locations/{id}', [AdminController::class, 'deleteLocation']);
        Route::post('/media', [AdminController::class, 'uploadMedia']);
        Route::delete('/media/{id}', [AdminController::class, 'deleteMedia']);

        Route::get('/accommodations', [AdminController::class, 'accommodations']);
        Route::post('/accommodations', [AdminController::class, 'storeAccommodation']);
        Route::patch('/accommodations/{id}', [AdminController::class, 'updateAccommodation']);
        Route::delete('/accommodations/{id}', [AdminController::class, 'deleteAccommodation']);

        Route::get('/bookings', [AdminController::class, 'bookings']);
        Route::patch('/bookings/{id}', [AdminController::class, 'updateBooking']);
        Route::get('/users', [AdminController::class, 'users']);
        Route::patch('/users/{id}', [AdminController::class, 'updateUser']);
        Route::get('/reviews', [AdminController::class, 'reviews']);
        Route::delete('/reviews/{id}', [AdminController::class, 'deleteReview']);
        Route::get('/ads', [AdminController::class, 'ads']);
        Route::post('/ads', [AdminController::class, 'storeAd']);
        Route::patch('/ads/{id}', [AdminController::class, 'updateAd']);
        Route::post('/ads/{id}/image', [AdminController::class, 'uploadAdImage']);
        Route::delete('/ads/{id}', [AdminController::class, 'deleteAd']);
    });

    Route::middleware('role:guide,admin,super-admin')->group(function () {
        Route::patch('/locations/{id}/verify', function (string $id) {
            $location = \App\Models\Location::findOrFail($id);
            $location->update(['is_verified' => true]);
            return response()->json(['success' => true, 'data' => $location]);
        });
    });
});
