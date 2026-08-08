<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = [
        'user_id', 'receiver_name', 'phone', 'province_id', 'province_name', 'city_id', 'city_name', 'full_address', 'is_main',
    ];

    protected function casts(): array
    {
        return ['is_main' => 'boolean'];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}
