<?php

namespace App\Services;

use App\Models\Notification;

class NotificationService
{
    public static function notify(int $userId, string $title, string $body, ?string $type = null, ?int $relatedId = null): void
    {
        Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'body' => $body,
            'type' => $type,
            'related_id' => $relatedId,
        ]);
    }
}
