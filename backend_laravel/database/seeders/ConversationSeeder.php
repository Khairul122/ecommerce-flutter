<?php

namespace Database\Seeders;

use App\Models\Conversation;
use App\Models\Message;
use App\Models\Store;
use App\Models\User;
use Illuminate\Database\Seeder;

class ConversationSeeder extends Seeder
{
    public function run(): void
    {
        $budi = User::where('email', 'budi@ootday.com')->first();
        $owner = User::where('role', 'owner')->first();
        $store = Store::first();

        if (!$budi || !$owner || !$store) return;

        $conv = Conversation::firstOrCreate(
            ['user_id' => (string) $budi->id, 'store_id' => $store->id],
            ['last_message_at' => now()]
        );

        $messages = [
            [
                'sender_id' => (string) $budi->id,
                'sender_role' => 'pelanggan',
                'message' => 'Halo kak, apakah produk Pink Ribbon Bow Shirt ready size M?',
            ],
            [
                'sender_id' => (string) $owner->id,
                'sender_role' => 'owner',
                'message' => 'Halo kak Budi, ready stok ya untuk size M. Silakan langsung diorder!',
            ],
            [
                'sender_id' => (string) $budi->id,
                'sender_role' => 'pelanggan',
                'message' => 'Baik kak, pengiriman dari mana ya?',
            ],
            [
                'sender_id' => (string) $owner->id,
                'sender_role' => 'owner',
                'message' => 'Pengiriman dari Jakarta Pusat kak. Pemesanan sebelum jam 15.00 dikirim hari ini.',
            ],
        ];

        foreach ($messages as $msg) {
            Message::firstOrCreate(
                [
                    'conversation_id' => $conv->id,
                    'sender_id' => $msg['sender_id'],
                    'message' => $msg['message'],
                ],
                [
                    'sender_role' => $msg['sender_role'],
                    'is_read' => true,
                ]
            );
        }
    }
}
