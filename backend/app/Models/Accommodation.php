<?php

namespace App\Models;

use Clickbar\Magellan\Data\Geometries\Point;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class Accommodation extends Model
{
    use HasUuids;

    protected $fillable = [
        'owner_id', 'type', 'name_ckb', 'geom', 'price_per_night', 'amenities', 'is_active',
    ];

    protected function casts(): array
    {
        return [
            'geom' => Point::class,
            'amenities' => 'array',
            'is_active' => 'boolean',
            'price_per_night' => 'decimal:2',
        ];
    }

    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function scopeNearby(Builder $query, float $lng, float $lat): Builder
    {
        $point = Point::make($lat, $lng, srid: 4326);

        return $query
            ->selectRaw('accommodations.*, ST_Distance(geom, ?) as distance_m', [$point->toWkt()])
            ->orderByRaw('geom <-> ?', [$point->toWkt()]);
    }
}
