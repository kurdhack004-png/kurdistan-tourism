<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class FavoriteController extends Controller
{
    public function index(Request $request)
    {
        $favorites = DB::table('favorites')
            ->where('user_id', $request->user()->id)
            ->orderByDesc('created_at')
            ->get();

        return response()->json(['success' => true, 'data' => $favorites]);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'favoritable_type' => ['required', 'in:location,accommodation,trail'],
            'favoritable_id' => ['required', 'uuid'],
        ]);

        DB::table('favorites')->updateOrInsert(
            [
                'user_id' => $request->user()->id,
                'favoritable_type' => $data['favoritable_type'],
                'favoritable_id' => $data['favoritable_id'],
            ],
            ['created_at' => now()],
        );

        return response()->json(['success' => true, 'data' => $data], 201);
    }

    public function destroy(Request $request, string $type, string $id)
    {
        abort_unless(in_array($type, ['location', 'accommodation', 'trail'], true), 422, 'Unsupported favorite type.');

        $deleted = DB::table('favorites')
            ->where('user_id', $request->user()->id)
            ->where('favoritable_type', $type)
            ->where('favoritable_id', $id)
            ->delete();

        return response()->json(['success' => true, 'deleted' => $deleted > 0]);
    }
}
