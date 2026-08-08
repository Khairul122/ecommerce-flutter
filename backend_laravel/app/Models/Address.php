<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Address extends Model
{
    protected $fillable = [
        'user_id', 'receiver_name', 'phone', 'full_address', 'is_main',
        'district_id', 'district_name', 'city_name', 'province_name', 'postal_code',
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
