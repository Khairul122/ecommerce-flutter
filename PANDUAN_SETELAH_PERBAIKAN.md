# Panduan Setelah Perbaikan Menyeluruh (Juli 2026)

Ringkasan perubahan besar yang baru dilakukan pada proyek Ootday, dan langkah yang perlu Anda jalankan sendiri di komputer lokal (sandbox tempat perbaikan ini ditulis tidak punya PHP, Composer, MySQL, atau Flutter SDK terpasang, jadi belum ada yang benar-benar dijalankan/diuji secara otomatis).

## Apa yang berubah

1. **Firebase dihapus total** dari `ootday_owner` dan `ootday_pelanggan`: Auth, Firestore, Cloud Messaging, Crashlytics, dan (di aplikasi owner) Storage. Tidak ada satu pun kode Dart yang masih memanggil Firebase.
2. **Koneksi MySQL langsung dari aplikasi mobile dihapus** (`ootday_owner/lib/services/mysql_service.dart`, celah keamanan paling kritis di hasil audit sebelumnya).
3. **Backend baru: Laravel + Sanctum**, di folder `backend_laravel/`. Menggantikan `Backend_Ootday/` (PHP polos, hanya 1 endpoint) dan koneksi MySQL langsung sekaligus.
4. Sebagian besar bug fungsional dari hasil audit (`Laporan_Audit_Ootday.docx`) ikut diperbaiki: simpan profil/toko yang sebelumnya palsu, manajemen pesanan owner, chat (sekarang lewat REST API, bukan data lokal), tombol batalkan pesanan, alamat/ongkos kirim yang sebelumnya diabaikan saat checkout, validasi stok, dan beberapa kebocoran memori (`dispose()` yang hilang).
5. Folder lama `Backend_Ootday/` dan `database/` (schema.sql lama) dibiarkan ada tapi sudah ditandai tidak dipakai lagi (lihat `DEPRECATED.md` di masing-masing folder).

## Struktur folder feature-first

Kedua aplikasi Flutter (`ootday_owner` dan `ootday_pelanggan`) sudah direstrukturisasi dari folder datar (`lib/screens`, `lib/services`, `lib/utils`) menjadi feature-first:

```
lib/
  main.dart
  core/
    services/     -> api_service.dart, auth_service.dart, dst (dipakai lintas fitur)
    widgets/       -> widget bersama (khusus ootday_owner: owner_bottom_nav.dart)
  features/
    <nama_fitur>/
      presentation/   -> halaman/layar fitur tersebut
      data/            -> service atau data-helper khusus fitur itu saja
```

Contoh: fitur `order` di `ootday_owner` berisi `order_history_page.dart`, `order_status_detail_page.dart`, `stat_detail_page.dart` di `presentation/`. Fitur `cart` di `ootday_pelanggan` berisi `cart_screen.dart` di `presentation/` dan `cart_data.dart` di `data/`.

Tidak ada layer domain/repository terpisah karena kode aslinya memang belum memakainya (widget memanggil service langsung) — restrukturisasi ini murni memindahkan file dan merapikan import, bukan mengubah arsitektur data. Semua import sudah diverifikasi otomatis (dicek satu per satu bahwa file yang diimpor benar-benar ada di lokasi barunya), tapi tetap jalankan `flutter analyze` setelah `flutter pub get` untuk memastikan tidak ada yang terlewat.

## Langkah menjalankan backend

```
cd backend_laravel
composer install
cp .env.example .env        (Windows: copy .env.example .env)
php artisan key:generate
```

Edit `.env`, sesuaikan `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD` ke MySQL Anda (boleh database baru, skema tabelnya beda dari `database/schema.sql` lama).

```
php artisan migrate
php artisan db:seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```

`--host=0.0.0.0` penting supaya HP/emulator di jaringan yang sama bisa mengakses server, bukan cuma `localhost` komputer Anda sendiri.

Akun contoh setelah seeding:
- Owner: `owner@ootday.com` / `owner123`
- Pelanggan: `guest@ootday.com` / `guest123`

Detail lengkap endpoint ada di `backend_laravel/API_CONTRACT.md`.

## Langkah menjalankan kedua aplikasi Flutter

Di kedua aplikasi, `baseUrl` utama di `lib/core/services/api_service.dart` secara bawaan sudah menunjuk ke server backend produksi:
- `https://backend-ecommerce.synectra.xyz/api`

Jika ingin menjalankan backend lokal sendiri, ganti `baseUrl` di `lib/core/services/api_service.dart` dengan alamat IP LAN komputer Anda (misal `http://192.168.1.X:8000/api`).

Lalu di masing-masing folder aplikasi:

```
flutter pub get
flutter run
```

## Status Fitur & Keputusan Pengembangan Selanjutnya

- **Pembayaran Hybrid (Otomatis via Xendit & Manual Transfer Fallback)**: Sistem backend (`backend_laravel`) sudah terintegrasi dengan Xendit API (`XenditService`, `XenditNotificationController`). Pelanggan dapat melakukan pembayaran otomatis via QRIS (`/orders/{id}/qris`) dan Invoice Xendit (`/orders/{id}/snap-token`) yang statusnya ter-update otomatis lewat webhook callback (`/xendit/callback`). Sebagai fallback, konfirmasi manual (`confirm-payment`) tetap tersedia.
- **Push notification menggunakan REST API Polling**: Firebase Cloud Messaging telah dihapus total. Fitur chat dan status pesanan berjalan secara aman menggunakan polling REST API (`/conversations`, `/notifications`). Jika nanti diperlukan push notification berbasis cloud untuk skala lanjut, disarankan mengintegrasikan **OneSignal**.
- **Kode & Layout**: Seluruh kode Dart pada aplikasi Flutter dan REST API Laravel telah diaudit secara statis dan struktural untuk memastikan kompatibilitas dan eliminasi RenderFlex overflow pixel.
- Beberapa layar lama yang datanya sudah tidak relevan dengan skema baru (misalnya rating/pengikut toko, statistik pengunjung) dijadikan placeholder statis karena backend belum punya data itu. Tidak menyebabkan error, tapi belum menampilkan angka nyata.

## Berkas referensi

- `Laporan_Audit_Ootday.docx` — audit awal lengkap dengan semua temuan.
- `backend_laravel/README.md` — detail setup backend dan perbedaan skema database.
- `backend_laravel/API_CONTRACT.md` — daftar lengkap endpoint REST API.
