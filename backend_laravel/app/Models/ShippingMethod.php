<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ShippingMethod extends Model
{
    protected $fillable = ['name', 'courier_code', 'base_cost', 'is_active'];

    protected function casts(): array
    {
        return [
            'base_cost' => 'decimal:2',
            'is_active' => 'boolean',
        ];
    }
}
