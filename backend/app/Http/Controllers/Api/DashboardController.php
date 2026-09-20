<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Accommodation;
use App\Models\Ad;
use App\Models\Booking;
use App\Models\Location;
use App\Models\Review;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function __invoke()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'counts' => [
                    'users' => User::count(),
                    'locations' => Location::count(),
                    'accommodations' => Accommodation::count(),
                    'bookings' => Booking::count(),
                    'reviews' => Review::count(),
                    'ads' => Ad::count(),
                ],
                'bookings_by_status' => Booking::query()
                    ->select('status', DB::raw('count(*) as total'))
                    ->groupBy('status')
                    ->orderBy('status')
                    ->get(),
                'recent_bookings' => Booking::with(['user:id,full_name,email', 'accommodation:id,name_en,name_ckb'])
                    ->latest()
                    ->limit(10)
                    ->get(),
            ],
        ]);
    }
}
