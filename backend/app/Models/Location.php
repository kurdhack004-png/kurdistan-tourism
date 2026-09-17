<?php

namespace App\Models;

use Clickbar\Magellan\Data\Geometries\Point;
use Clickbar\Magellan\Database\PostgisFunctions\MagellanExpression;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;

class Location extends Model
{
    use HasUuids;

    protected $fillable = [
        'category', 'governorate_id', 'district_id', 'name_ckb', 'name_ar', 'name_en',
        'description_ckb', 'description_en', 'geom', 'elevation_meters',
        'is_verified', 'created_by',
    ];

    protected function casts(): array
    {
        return [
            'geom' => Point::class, // laravel-magellan casts geography(Point,4326) to/from PHP
            'is_verified' => 'boolean',
        ];
    }

    public function media()
    {
        return $this->hasMany(Media::class, 'mediable_id')->where('mediable_type', 'location');
    }

    public function reviews()
    {
        return $this->hasMany(Review::class, 'reviewable_id')->where('reviewable_type', 'location');
    }

    public function trails()
    {
        return $this->hasMany(Trail::class);
    }

    /**
     * Scope: order by distance from a given point, nearest first.
     * Usage: Location::nearby($lng, $lat)->limit(20)->get()
     */
    public function scopeNearby(Builder $query, float $lng, float $lat): Builder
    {
        $point = Point::make($lat, $lng, srid: 4326);

        return $query
            ->selectRaw('locations.*, ST_Distance(geom, ?) as distance_m', [$point->toWkt()])
            ->orderByRaw('geom <-> ?', [$point->toWkt()]);
    }

    public function scopeWithinRadius(Builder $query, float $lng, float $lat, float $radiusMeters): Builder
    {
        $point = Point::make($lat, $lng, srid: 4326);

        return $query->whereRaw('ST_DWithin(geom, ?, ?)', [$point->toWkt(), $radiusMeters]);
    }
}
