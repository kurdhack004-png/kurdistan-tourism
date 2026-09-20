<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\DB;
use Throwable;

class HealthController extends Controller
{
    public function __invoke()
    {
        $database = 'unavailable';

        try {
            DB::connection()->getPdo();
            DB::select('select 1');
            $database = 'connected';
        } catch (Throwable $exception) {
            report($exception);
        }

        $healthy = $database === 'connected';

        return response()->json([
            'success' => $healthy,
            'status' => $healthy ? 'online' : 'degraded',
            'service' => config('app.name'),
            'environment' => app()->environment(),
            'database' => $database,
            'timestamp' => now()->toIso8601String(),
        ], $healthy ? 200 : 503);
    }
}
