<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Conversation;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Str;

class ConversationController extends Controller
{
    /**
     * Perbaikan audit: chat.dart/room_chat.dart (owner) dan chat_list_screen.dart/
     * chat_detail_screen.dart (pelanggan) sebelumnya cuma array lokal di memori,
     * pesan hilang saat layar ditutup dan tidak pernah benar-benar terkirim.
     * Sekarang chat disimpan di database dan diambil lewat polling REST API
     * (belum realtime/websocket, itu perbaikan lanjutan di luar audit ini).
     */
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->isOwner()) {
            $conversations = Conversation::where('store_id', $user->store->id)
                ->with(['user', 'lastMessage'])
                ->orderByDesc('updated_at')->get();
        } else {
            $conversations = Conversation::where('user_id', $user->id)
                ->with(['store', 'lastMessage'])
                ->orderByDesc('updated_at')->get();
        }

        return response()->json(['status' => 'success', 'data' => $conversations]);
    }

    public function storeOrGet(Request $request)
    {
        $validator = Validator::make($request->all(), ['store_id' => ['required', 'exists:stores,id']]);
        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $conversation = Conversation::firstOrCreate([
            'user_id' => $request->user()->id,
            'store_id' => $request->store_id,
        ]);

        return response()->json(['status' => 'success', 'data' => $conversation->load('store')]);
    }

    private function authorizeConversation(Request $request, Conversation $conversation): bool
    {
        $user = $request->user();
        if ($user->isOwner()) {
            return $conversation->store_id === $user->store->id;
        }

        return $conversation->user_id === $user->id;
    }

    public function messages(Request $request, Conversation $conversation)
    {
        if (! $this->authorizeConversation($request, $conversation)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        return response()->json(['status' => 'success', 'data' => $conversation->messages]);
    }

    public function sendMessage(Request $request, Conversation $conversation)
    {
        if (! $this->authorizeConversation($request, $conversation)) {
            return response()->json(['status' => 'error', 'message' => 'Akses ditolak'], 403);
        }

        $validator = Validator::make($request->all(), ['message' => ['required', 'string']]);
        if ($validator->fails()) {
            return response()->json(['status' => 'error', 'message' => $validator->errors()->first()], 422);
        }

        $user = $request->user();
        $message = $conversation->messages()->create([
            'sender_type' => $user->isOwner() ? 'store' : 'user',
            'sender_user_id' => $user->id,
            'message' => $request->message,
        ]);
        $conversation->touch();

        $recipientId = $user->isOwner()
            ? $conversation->user_id
            : $conversation->loadMissing('store')->store->user_id;

        NotificationService::notify(
            $recipientId,
            'Pesan Baru',
            Str::limit($request->message, 80),
            'chat',
            $conversation->id,
        );

        return response()->json(['status' => 'success', 'data' => $message], 201);
    }
}
