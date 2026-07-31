# Ootday Backend (Laravel)

Backend REST API baru untuk proyek Ootday. Menggantikan dua hal sekaligus:

1. Firebase (Auth, Firestore, Cloud Messaging, Crashlytics) yang sebelumnya dipakai kedua aplikasi Flutter.
2. `Backend_Ootday/` (PHP polos, hanya 1 endpoint) dan `ootday_owner/lib/services/mysql_service.dart` (koneksi MySQL langsung dari aplikasi mobile, celah keamanan kritis pada hasil audit sebelumnya).

Semua autentikasi sekarang pakai token Laravel Sanctum (bukan Firebase, bukan koneksi database langsung). Lihat `API_CONTRACT.md` untuk daftar lengkap endpoint.

## Cara menjalankan (di komputer Anda, bukan di sandbox Claude)

Sandbox tempat proyek ini ditulis tidak memiliki PHP/Composer/MySQL terpasang, jadi kode ini belum pernah dijalankan otomatis. Jalankan langkah berikut di XAMPP/Laragon/komputer lokal Anda:

```
cd backend_laravel
composer install
copy .env.example .env        (Windows)  atau  cp .env.example .env   (Mac/Linux)
php artisan key:generate
```

Edit `.env`, sesuaikan `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` dengan MySQL Anda (boleh pakai database baru, tidak perlu database `ootday_db` versi lama — skema tabel di proyek ini sedikit berbeda, lihat bagian "Perbedaan skema" di bawah).

```
php artisan migrate
php artisan db:seed
php artisan storage:link
php artisan serve
```

Server berjalan di `http://127.0.0.1:8000`. Ganti `baseUrl` di kedua aplikasi Flutter (`lib/services/api_service.dart`) supaya menunjuk ke alamat ini (untuk device fisik/emulator, pakai IP LAN komputer Anda, bukan `127.0.0.1`, misalnya `http://192.168.1.x:8000/api`).

Akun owner contoh setelah seeding: `owner@ootday.com` / `owner123`.
Akun pelanggan contoh: `guest@ootday.com` / `guest123`.

## Perbedaan skema dari database/schema.sql lama

- Tabel `users` sekarang punya kolom `password` (di-hash bcrypt), karena autentikasi sepenuhnya dipegang Laravel, bukan Firebase lagi. Primary key `id` auto-increment, bukan `uid` string dari Firebase.
- Tabel `stores` tidak lagi punya kolom `email`/`password` sendiri (dulu dobel dengan `users`); sekarang cukup `user_id` yang mengarah ke akun owner di tabel `users`.
- Kolom `status` pada `orders` dipisah jadi dua: `status` (status pemenuhan pesanan: menunggu_pembayaran/diproses/dikirim/selesai/dibatalkan) dan `payment_status` (unpaid/menunggu_konfirmasi/paid). Ini memperbaiki temuan audit bahwa status pembayaran dan status pengiriman sebelumnya tercampur jadi satu kolom.
- Tabel baru: `conversations` dan `messages` untuk fitur chat (sebelumnya tidak ada tabel sama sekali, chat hanya data lokal di aplikasi).
- `database/schema.sql`, `migration_owner_uid.sql`, dan seeder lama di folder `database/` di root proyek tidak lagi dipakai. Sumber kebenaran skema sekarang ada di `backend_laravel/database/migrations/`.

## Catatan tentang pembayaran

Proyek ini belum terhubung ke payment gateway sungguhan (Midtrans/Xendit/dll) karena belum ditentukan penyedia mana yang dipakai. Sebagai gantinya, alur pembayaran sekarang berbasis konfirmasi manual yang tercatat di database (bukan lagi hanya dialog sukses palsu di aplikasi seperti sebelumnya):

1. Pelanggan checkout, status pesanan `menunggu_pembayaran`.
2. Pelanggan transfer manual, lalu tekan "saya sudah bayar" di aplikasi -> `payment_status` jadi `menunggu_konfirmasi`.
3. Owner memeriksa mutasi rekening/e-wallet secara manual, lalu tekan konfirmasi di aplikasi owner -> `payment_status` jadi `paid` dan status pesanan otomatis lanjut ke `diproses`.

Jika nanti ingin memakai payment gateway sungguhan, endpoint yang perlu diganti hanya `OrderController::confirmPayment` dan `OwnerOrderController::confirmPayment` di `app/Http/Controllers/Api/`, ditambah webhook baru dari penyedia pembayaran.

## Push notification dan crash reporting

Firebase Cloud Messaging dan Crashlytics dihapus total dari kedua aplikasi sesuai permintaan, belum ada penggantinya. Fitur notifikasi antar pengguna sekarang murni lewat polling REST API (`/api/conversations`, dsb). Jika nanti perlu push notification tanpa Firebase, alternatifnya adalah OneSignal.
