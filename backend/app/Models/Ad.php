<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Ad extends Model
{
    use HasUuids;

    protected $fillable = [
        'created_by','title_ckb','title_ar','title_en',
        'description_ckb','description_ar','description_en',
        'image_storage_key','target_url','price_iqd','starts_at','ends_at','is_active',
    ];

    protected function casts(): array
    {
        return [
            'price_iqd' => 'decimal:2',
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
            'is_active' => 'boolean',
        ];
    }

    public function creator() { return $this->belongsTo(User::class, 'created_by'); }
}
