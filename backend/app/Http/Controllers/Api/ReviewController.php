<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Review;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index(Request $request)
    {
        $data = $request->validate([
            'reviewable_type' => ['required', 'in:location,accommodation,trail'],
            'reviewable_id' => ['required', 'uuid'],
        ]);

        $reviews = Review::with('user:id,full_name')
            ->where('reviewable_type', $data['reviewable_type'])
            ->where('reviewable_id', $data['reviewable_id'])
            ->orderByDesc('created_at')
            ->paginate(20);

        return response()->json(['success' => true, 'data' => $reviews]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'reviewable_type' => ['required', 'in:location,accommodation,trail'],
            'reviewable_id' => ['required', 'uuid'],
            'rating' => ['required', 'integer', 'between:1,5'],
            'comment' => ['nullable', 'string', 'max:1000'],
        ]);

        if ($data['reviewable_type'] === 'accommodation') {
            $visited = Booking::where('user_id', $request->user()->id)
                ->where('accommodation_id', $data['reviewable_id'])
                ->where('status', 'completed')
                ->exists();

            abort_unless($visited, 403, 'You can review an accommodation after a completed stay.');
        }

        $alreadyReviewed = Review::where('user_id', $request->user()->id)
            ->where('reviewable_type', $data['reviewable_type'])
            ->where('reviewable_id', $data['reviewable_id'])
            ->exists();

        abort_if($alreadyReviewed, 409, 'You have already reviewed this item.');

        $review = Review::create([...$data, 'user_id' => $request->user()->id]);

        return response()->json(['success' => true, 'data' => $review], 201);
    }
}
