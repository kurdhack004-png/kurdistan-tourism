<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'booking_id', 'method', 'status', 'amount', 'provider_ref', 'idempotency_key',
    ];

    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
}
