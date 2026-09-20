<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Accommodation;
use Illuminate\Http\Request;

class AccommodationController extends Controller
{
    public function index(Request $request)
    {
        $data = $request->validate([
            'type' => ['nullable','in:hotel,house,cabin,chalet,guesthouse,campsite,eco_lodge'],
            'language' => ['nullable','in:ckb,ar,en'],
            'city' => ['nullable','string','max:120'],
            'min_price' => ['nullable','numeric','min:0'],
            'max_price' => ['nullable','numeric','gte:min_price'],
            'near_lat' => ['nullable','numeric','between:-90,90'],
            'near_lng' => ['nullable','numeric','between:-180,180'],
            'per_page' => ['nullable','integer','min:1','max:100'],
        ]);

        $query = Accommodation::query()->where('is_active', true);

        if (!empty($data['type'])) $query->where('type', $data['type']);
        if (isset($data['min_price'])) $query->where('price_per_night', '>=', $data['min_price']);
        if (isset($data['max_price'])) $query->where('price_per_night', '<=', $data['max_price']);

        if (!empty($data['city'])) {
            $language = $data['language'] ?? 'ckb';
            $column = match ($language) {
                'ar' => 'city_ar',
                'en' => 'city_en',
                default => 'city_ckb',
            };
            $query->where($column, 'ILIKE', '%'.$data['city'].'%');
        }

        if (isset($data['near_lat'], $data['near_lng'])) {
            $query->nearby((float)$data['near_lng'], (float)$data['near_lat']);
        } else {
            $query->orderByDesc('rating')->orderByDesc('review_count');
        }

        return response()->json([
            'success' => true,
            'data' => $query->paginate($data['per_page'] ?? 20),
        ]);
    }

    public function show(string $id)
    {
        return response()->json(['success' => true, 'data' => Accommodation::findOrFail($id)]);
    }
}
