<?php

namespace App\Models;

use Clickbar\Magellan\Data\Geometries\LineString;
use Illuminate\Database\Eloquent\Model;

class Trail extends Model
{
    protected $fillable = [
        'location_id', 'name_ckb', 'difficulty', 'distance_km',
        'elevation_gain_m', 'route', 'waypoints', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'route' => LineString::class, // the GPX/GeoJSON track as a native geometry
            'waypoints' => 'array',
        ];
    }

    public function location()
    {
        return $this->belongsTo(Location::class);
    }
}
