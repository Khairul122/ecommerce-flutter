<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Review extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_item_id',
        'user_id',
        'order_id',
        'product_id',
        'rating',
        'comment',
        'photo_url',
        'images',
    ];

    protected $casts = [
        'images' => 'array',
        'rating' => 'integer',
    ];

    protected static function booted()
    {
        static::created(function ($review) {
            $review->updateProductRatingCache();
        });

        static::deleted(function ($review) {
            $review->updateProductRatingCache();
        });
    }

    public function updateProductRatingCache()
    {
        $product = Product::find($this->product_id);
        if ($product) {
            $avg = Review::where('product_id', $this->product_id)->avg('rating') ?: 0;
            $count = Review::where('product_id', $this->product_id)->count();

            $product->update([
                'average_rating' => round($avg, 2),
                'review_count' => $count,
            ]);
        }
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function product()
    {
        return $this->belongsTo(Product::class);
    }
}
