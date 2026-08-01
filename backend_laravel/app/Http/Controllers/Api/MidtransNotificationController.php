<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

class MidtransNotificationController extends Controller
{
    protected MidtransService $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    /**
     * Endpoint Webhook / HTTP Notification dari Midtrans MAP.
     */
    public function handle(Request $request)
    {
        $payload = $request->all();

        Log::info('Midtrans Notification Request Received', $payload);

        $success = $this->midtransService->handleNotification($payload);

        if ($success) {
            return response()->json([
                'status' => 'success',
                'message' => 'Notification processed successfully',
            ], 200);
        }

        return response()->json([
            'status' => 'error',
            'message' => 'Invalid notification payload or signature',
        ], 400);
    }
}
