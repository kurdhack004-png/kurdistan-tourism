<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Accommodation;
use Illuminate\Http\Request;

class AccommodationController extends Controller
{
    /** GET /api/accommodations?near_lat=&near_lng=&type=hotel */
    public function index(Request $request)
    {
        $query = Accommodation::query()->where('is_active', true);

        if ($type = $request->query('type')) {
            $query->where('type', $type);
        }

        if ($request->has('near_lat') && $request->has('near_lng')) {
            $query->nearby((float) $request->query('near_lng'), (float) $request->query('near_lat'));
        }

        $accommodations = $query->paginate(min((int) $request->query('per_page', 20), 100));

        return response()->json(['success' => true, 'data' => $accommodations]);
    }

    public function show(string $id)
    {
        $accommodation = Accommodation::findOrFail($id);

        return response()->json(['success' => true, 'data' => $accommodation]);
    }
}
