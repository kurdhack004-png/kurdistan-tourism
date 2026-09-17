<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\StoreLocationRequest;
use App\Models\Location;
use Clickbar\Magellan\Data\Geometries\Point;
use Illuminate\Http\Request;

class LocationController extends Controller
{
    /**
     * GET /api/locations
     * Supports: ?category=mountain&governorate_id=1&near_lat=36.19&near_lng=44.01&radius_m=5000
     */
    public function index(Request $request)
    {
        $query = Location::query()->where('is_verified', true);

        if ($category = $request->query('category')) {
            $query->where('category', $category);
        }
        if ($gov = $request->query('governorate_id')) {
            $query->where('governorate_id', $gov);
        }

        // Spatial "near me" search — this is the query the old generic
        // information_schema CRUD endpoint could never express efficiently.
        if ($request->has('near_lat') && $request->has('near_lng')) {
            $lat = (float) $request->query('near_lat');
            $lng = (float) $request->query('near_lng');

            if ($radius = $request->query('radius_m')) {
                $query->withinRadius($lng, $lat, (float) $radius);
            } else {
                $query->nearby($lng, $lat);
            }
        }

        $locations = $query->with('media')->paginate(
            min((int) $request->query('per_page', 20), 100) // hard cap — no unbounded pagination
        );

        return response()->json(['success' => true, 'data' => $locations]);
    }

    public function show(string $id)
    {
        $location = Location::with(['media', 'reviews', 'trails'])->findOrFail($id);

        return response()->json(['success' => true, 'data' => $location]);
    }

    public function store(StoreLocationRequest $request)
    {
        $data = $request->validated();

        $location = Location::create([
            ...$data,
            'geom' => Point::make($data['latitude'], $data['longitude'], srid: 4326),
            'created_by' => $request->user()->id,
            'is_verified' => false, // requires admin/guide approval before it becomes public
        ]);

        return response()->json(['success' => true, 'data' => $location], 201);
    }
}
