<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = [
        'full_name',
        'name',
        'email',
        'phone_number',
        'password',
        'role',
        'preferred_lang',
        'is_active',
    ];

    protected $hidden = ['password', 'remember_token'];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'is_active' => 'boolean',
            'email_verified_at' => 'datetime',
        ];
    }

    public function getNameAttribute($value): ?string
    {
        return $this->full_name ?? $value;
    }

    public function isAdmin(): bool
    {
        return in_array($this->role, ['admin', 'super-admin'], true);
    }

    public function isSuperAdmin(): bool
    {
        return $this->role === 'super-admin';
    }
}
