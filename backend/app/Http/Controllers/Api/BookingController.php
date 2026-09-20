<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBookingRequest;
use App\Models\Accommodation;
use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        $bookings = Booking::with(['accommodation', 'payment'])
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $bookings]);
    }

    public function store(StoreBookingRequest $request)
    {
        $data = $request->validated();

        $booking = DB::transaction(function () use ($data, $request) {
            $accommodation = Accommodation::whereKey($data['accommodation_id'])
                ->where('is_active', true)
                ->lockForUpdate()
                ->firstOrFail();

            if (!in_array($accommodation->type, ['hotel', 'house', 'cabin', 'chalet'], true)) {
                abort(422, 'This accommodation type is not bookable.');
            }

            $overlap = Booking::where('accommodation_id', $accommodation->id)
                ->whereIn('status', ['pending', 'confirmed'])
                ->where('check_in', '<', $data['check_out'])
                ->where('check_out', '>', $data['check_in'])
                ->exists();

            if ($overlap) {
                abort(409, 'The accommodation is not available for these dates.');
            }

            $nights = \Carbon\Carbon::parse($data['check_in'])->diffInDays($data['check_out']);
            $bookingFee = 10000;
            $total = $nights * (float) $accommodation->price_per_night + $bookingFee;

            return Booking::create([
                ...$data,
                'user_id' => $request->user()->id,
                'status' => 'pending',
                'total_price' => $total,
            ]);
        });

        return response()->json([
            'success' => true,
            'data' => $booking->load('accommodation'),
        ], 201);
    }

    public function pay(Request $request, string $id)
    {
        $data = $request->validate([
            'method' => ['required', 'in:fib,visa,cash,bank_transfer'],
            'idempotency_key' => ['required', 'string', 'max:64'],
        ]);

        $booking = Booking::findOrFail($id);
        abort_unless($booking->user_id === $request->user()->id, 403);
        abort_if(in_array($booking->status, ['cancelled', 'completed'], true), 422, 'This booking cannot be paid.');

        $existing = Payment::where('idempotency_key', $data['idempotency_key'])->first();
        if ($existing) {
            abort_unless($existing->booking_id === $booking->id, 409, 'This payment key belongs to another booking.');
            return response()->json(['success' => true, 'data' => $existing, 'booking' => $booking->fresh()]);
        }

        $payment = Payment::create([
            'booking_id' => $booking->id,
            'method' => $data['method'],
            'amount' => $booking->total_price,
            'status' => 'pending',
            'idempotency_key' => $data['idempotency_key'],
        ]);

        return response()->json([
            'success' => true,
            'data' => $payment,
            'booking' => $booking->fresh(),
        ]);
    }

    public function cancel(Request $request, string $id)
    {
        $booking = Booking::where('user_id', $request->user()->id)->findOrFail($id);

        abort_if(in_array($booking->status, ['cancelled', 'completed'], true), 422, 'This booking cannot be cancelled.');
        abort_if($booking->check_in->isPast(), 422, 'A booking that has already started cannot be cancelled.');

        $booking->update(['status' => 'cancelled']);

        return response()->json(['success' => true, 'data' => $booking->fresh()]);
    }
}
