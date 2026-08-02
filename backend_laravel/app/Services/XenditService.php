<?php

namespace App\Services;

use App\Models\Order;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;
use Exception;

class XenditService
{
    protected string $secretKey;
    protected string $baseUrl;

    public function __construct()
    {
        $this->secretKey = config('xendit.secret_key', env('XENDIT_SECRET_KEY', ''));
        $this->baseUrl = config('xendit.api_url', 'https://api.xendit.co');
    }

    /**
     * Membuat Invoice Xendit (Mencakup QRIS, VA, E-Wallet, Retail Outlets)
     * POST /v2/invoices
     */
    public function createInvoice(Order $order): array
    {
        $order->loadMissing(['user', 'items.product']);

        $externalId = 'ORD-' . $order->id . '-' . time();
        $amount = (int) round($order->total_price ?? $order->total_amount ?? 0);
        $customerEmail = $order->user->email ?? 'customer@ootday.com';
        $customerName = $order->user->name ?? 'Pelanggan Ootday';

        $itemsPayload = [];
        if (!empty($order->items)) {
            foreach ($order->items as $item) {
                $itemsPayload[] = [
                    'name' => $item->product_name ?? $item->product->name ?? 'Produk Ootday',
                    'quantity' => (int) $item->quantity,
                    'price' => (int) round($item->price),
                ];
            }
        }

        $payload = [
            'external_id' => $externalId,
            'amount' => $amount,
            'payer_email' => $customerEmail,
            'description' => 'Pembayaran Pesanan #' . $order->order_number . ' - Ootday Store',
            'currency' => 'IDR',
            'invoice_duration' => 86400, // 24 jam
            'customer' => [
                'given_names' => $customerName,
                'email' => $customerEmail,
            ],
            'items' => $itemsPayload,
            'success_redirect_url' => url('/api/xendit/redirect/success?order_id=' . $order->id),
            'failure_redirect_url' => url('/api/xendit/redirect/failure?order_id=' . $order->id),
        ];

        try {
            $response = Http::withBasicAuth($this->secretKey, '')
                ->withHeaders(['Content-Type' => 'application/json'])
                ->post($this->baseUrl . '/v2/invoices', $payload);

            if ($response->failed()) {
                Log::error('Xendit Create Invoice Failed', [
                    'order_id' => $order->id,
                    'status' => $response->status(),
                    'body' => $response->json(),
                ]);
                $errorMsg = $response->json()['message'] ?? 'Gagal membuat Invoice Xendit.';
                throw new Exception($errorMsg);
            }

            $data = $response->json();

            // Simpan invoice ID & payment URL ke order
            $order->update([
                'snap_token' => $data['id'] ?? null,
                'payment_url' => $data['invoice_url'] ?? null,
            ]);

            return [
                'status' => 'success',
                'invoice_id' => $data['id'] ?? null,
                'invoice_url' => $data['invoice_url'] ?? null,
                'expiry_date' => $data['expiry_date'] ?? null,
                'data' => $data,
            ];
        } catch (Exception $e) {
            Log::error('Xendit Exception in createInvoice', ['error' => $e->getMessage()]);
            throw $e;
        }
    }

    /**
     * Membuat Dynamic QR Code Xendit (/qr_codes)
     */
    public function createQrisCode(Order $order): array
    {
        $order->loadMissing(['user']);

        $externalId = 'QRIS-' . $order->id . '-' . time();
        $amount = (int) round($order->total_price ?? $order->total_amount ?? 0);

        $payload = [
            'external_id' => $externalId,
            'type' => 'DYNAMIC',
            'callback_url' => url('/api/xendit/callback'),
            'amount' => $amount,
            'currency' => 'IDR',
        ];

        try {
            $response = Http::withBasicAuth($this->secretKey, '')
                ->withHeaders([
                    'Content-Type' => 'application/json',
                    'api-version' => '2022-07-31',
                ])
                ->post($this->baseUrl . '/qr_codes', $payload);

            if ($response->successful()) {
                $data = $response->json();
                $qrString = $data['qr_string'] ?? null;
                $qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" . urlencode($qrString ?? '');

                return [
                    'status' => 'success',
                    'qr_string' => $qrString,
                    'qr_url' => $qrUrl,
                    'external_id' => $data['external_id'] ?? $externalId,
                ];
            } else {
                Log::warning('Xendit QR Code API Failed', [
                    'status' => $response->status(),
                    'body' => $response->json() ?? $response->body(),
                ]);
            }
        } catch (Exception $e) {
            Log::warning('Xendit QR Code API Exception, falling back to invoice', ['error' => $e->getMessage()]);
        }

        // Fallback: Buat Invoice Xendit yang mencakup QRIS + seluruh metode pembayaran
        $invoice = $this->createInvoice($order);
        return [
            'status' => 'fallback',
            'invoice_url' => $invoice['invoice_url'] ?? null,
            'payment_url' => $invoice['invoice_url'] ?? null,
            'qr_string' => null,
            'qr_url' => null,
            'message' => 'Silakan buka halaman pembayaran resmi untuk memilih QRIS, E-Wallet, atau Transfer Bank.',
        ];
    }

    /**
     * Membuat Virtual Account Bank Xendit (POST /callback_virtual_accounts)
     */
    public function createVirtualAccount(Order $order, string $bankCode): array
    {
        $order->loadMissing(['user']);

        $externalId = 'VA-' . $order->id . '-' . time();
        $amount = (int) round($order->total_price ?? $order->total_amount ?? 0);
        $customerName = substr($order->user->name ?? 'Pelanggan Ootday', 0, 30);

        $payload = [
            'external_id' => $externalId,
            'bank_code' => strtoupper($bankCode),
            'name' => $customerName,
            'expected_amount' => $amount,
            'is_closed' => true,
            'is_single_use' => true,
        ];

        try {
            $response = Http::withBasicAuth($this->secretKey, '')
                ->withHeaders(['Content-Type' => 'application/json'])
                ->post($this->baseUrl . '/callback_virtual_accounts', $payload);

            if ($response->successful()) {
                $data = $response->json();
                return [
                    'status' => 'success',
                    'type' => 'va',
                    'bank_code' => $data['bank_code'] ?? $bankCode,
                    'account_number' => $data['account_number'] ?? null,
                    'expected_amount' => $data['expected_amount'] ?? $amount,
                    'expiration_date' => $data['expiration_date'] ?? null,
                    'external_id' => $data['external_id'] ?? $externalId,
                ];
            } else {
                Log::warning('Xendit Virtual Account API Failed', [
                    'status' => $response->status(),
                    'body' => $response->json() ?? $response->body(),
                ]);
            }
        } catch (Exception $e) {
            Log::warning('Xendit Virtual Account API Exception, falling back to invoice', ['error' => $e->getMessage()]);
        }

        // Fallback ke Xendit Invoice
        $invoice = $this->createInvoice($order);
        return [
            'status' => 'fallback',
            'type' => 'invoice',
            'invoice_url' => $invoice['invoice_url'] ?? null,
            'payment_url' => $invoice['invoice_url'] ?? null,
            'bank_code' => $bankCode,
            'message' => 'Silakan buka halaman pembayaran resmi untuk melengkapi transfer ' . strtoupper($bankCode),
        ];
    }

    /**
     * Cek status Invoice dari Xendit GET /v2/invoices/{id}
     */
    public function getInvoiceStatus(string $invoiceId): array
    {
        $response = Http::withBasicAuth($this->secretKey, '')
            ->get($this->baseUrl . '/v2/invoices/' . $invoiceId);

        if ($response->failed()) {
            throw new Exception('Gagal mengambil status invoice dari Xendit');
        }

        return $response->json();
    }
}
