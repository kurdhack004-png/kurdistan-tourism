<?php

use IlluminateSupportFacadesRoute;

Route::get('/', function () {
    return response()->json([
        'success' => true,
        'service' => 'Kurdistan Tourism API',
        'status' => 'online',
    ]);
});
