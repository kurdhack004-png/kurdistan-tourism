<?php

namespace App\Models;

use Clickbar\Magellan\Data\Geometries\Point;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class Accommodation extends Model
{
    protected $fillable = [
        'owner_id','type','name_ckb','name_ar','name_en',
        'description_ckb','description_ar','description_en',
        'city_ckb','city_ar','city_en','geom',
        'price_per_night','rating','review_count','amenities','is_active',
    ];

    protected function casts(): array
    {
        return [
            'geom' => Point::class,
            'amenities' => 'array',
            'is_active' => 'boolean',
            'price_per_night' => 'decimal:2',
            'rating' => 'decimal:2',
            'review_count' => 'integer',
        ];
    }

    public function owner() { return $this->belongsTo(User::class, 'owner_id'); }
    public function bookings() { return $this->hasMany(Booking::class); }

    public function scopeNearby(Builder $query, float $lng, float $lat): Builder
    {
        $point = Point::make($lat, $lng, srid: 4326);
        return $query
            ->selectRaw('accommodations.*, ST_Distance(geom, ?) as distance_m', [$point->toWkt()])
            ->orderByRaw('geom <-> ?', [$point->toWkt()]);
    }
}
