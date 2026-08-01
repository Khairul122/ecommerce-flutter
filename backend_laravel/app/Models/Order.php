<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    protected $fillable = [
        'order_code', 'user_id', 'store_id', 'payment_method_id', 'shipping_method_id',
        'receiver_name', 'receiver_phone', 'shipping_address',
        'subtotal', 'shipping_cost', 'total_price',
        'status', 'payment_status', 'payment_proof_url', 'cancel_reason', 'ordered_at',
        'snap_token', 'snap_redirect_url', 'payment_type',
    ];

    protected function casts(): array
    {
        return [
            'subtotal' => 'decimal:2',
            'shipping_cost' => 'decimal:2',
            'total_price' => 'decimal:2',
            'ordered_at' => 'datetime',
        ];
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function store()
    {
        return $this->belongsTo(Store::class);
    }

    public function paymentMethod()
    {
        return $this->belongsTo(PaymentMethod::class);
    }

    public function shippingMethod()
    {
        return $this->belongsTo(ShippingMethod::class);
    }

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }
}
