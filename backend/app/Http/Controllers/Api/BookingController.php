<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreBookingRequest;
use App\Models\Accommodation;
use App\Models\Booking;
use App\Models\Payment;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    /** GET /api/bookings — the authenticated user's own booking history. */
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
        $accommodation = Accommodation::findOrFail($data['accommodation_id']);

        $nights = max(1, \Carbon\Carbon::parse($data['check_in'])->diffInDays($data['check_out']));
        $total = $nights * (float) $accommodation->price_per_night;

        $booking = Booking::create([
            ...$data,
            'user_id' => $request->user()->id,
            'status' => 'pending',
            'total_price' => $total,
        ]);

        return response()->json(['success' => true, 'data' => $booking->load('accommodation')], 201);
    }

    /**
     * POST /api/bookings/{id}/pay
     * Creates the payment record. The idempotency_key means a client that
     * retries a dropped request (e.g. on a bad mountain-road connection)
     * never double-charges the guest.
     */
    public function pay(Request $request, string $id)
    {
        $data = $request->validate([
            'method' => ['required', 'in:fib,visa,cash,bank_transfer'],
            'idempotency_key' => ['required', 'string', 'max:64'],
        ]);

        $booking = Booking::findOrFail($id);
        abort_unless($booking->user_id === $request->user()->id, 403);

        $payment = Payment::firstOrCreate(
            ['idempotency_key' => $data['idempotency_key']],
            [
                'booking_id' => $booking->id,
                'method' => $data['method'],
                'amount' => $booking->total_price,
                // Cash/bank transfer are confirmed on-site/manually; card
                // methods would normally go 'pending' until a webhook from
                // FIB/Visa confirms the charge — wire that webhook before
                // treating this as real payment confirmation in production.
                'status' => in_array($data['method'], ['cash', 'bank_transfer']) ? 'pending' : 'paid',
            ],
        );

        $booking->update(['status' => 'confirmed']);

        return response()->json(['success' => true, 'data' => $payment]);
    }
}
