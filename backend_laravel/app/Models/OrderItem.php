<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class OrderItem extends Model
{
    protected $fillable = [
        'order_id', 'product_id', 'variant_id', 'product_name', 'variant_label', 'image_url', 'price', 'quantity',
    ];

    protected function casts(): array
    {
        return ['price' => 'decimal:2'];
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }
}
