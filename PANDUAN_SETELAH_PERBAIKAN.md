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

Di kedua aplikasi, cari baris `baseUrl` di `lib/services/api_service.dart` dan ganti dengan alamat IP LAN komputer Anda (bukan `127.0.0.1`/`localhost`, karena itu tidak bisa diakses dari HP fisik atau emulator):

- `ootday_owner/lib/services/api_service.dart` — sekarang berisi `http://192.168.1.77:8000/api` (nilai lama, placeholder), ganti sesuai IP Anda.
- `ootday_pelanggan/lib/services/api_service.dart` — sama, cari komentar "GANTI dengan alamat IP LAN".

Cek IP LAN Anda dengan `ipconfig` (Windows) atau `ifconfig`/`ip addr` (Mac/Linux).

Lalu di masing-masing folder aplikasi:

```
flutter pub get
flutter run
```

## Yang belum sepenuhnya selesai, perlu keputusan Anda selanjutnya

- **Pembayaran masih verifikasi manual**, belum payment gateway sungguhan. Pelanggan checkout, transfer manual, tekan "saya sudah bayar", lalu owner memeriksa mutasi dan menekan konfirmasi di aplikasinya. Ini jujur dan tercatat di database (beda dari alur lama yang langsung mengklaim sukses tanpa verifikasi apa pun), tapi belum otomatis. Kalau nanti mau pakai Midtrans/Xendit, cukup ganti dua endpoint `confirm-payment` di `backend_laravel/app/Http/Controllers/Api/`.
- **Push notification belum ada penggantinya** (Firebase Cloud Messaging dihapus sesuai permintaan, belum diganti apa pun). Chat dan status pesanan sekarang jalan lewat REST API biasa (pull/polling saat layar dibuka), bukan realtime. Kalau nanti perlu push notification tanpa Firebase, opsinya OneSignal.
- **Kode ini belum pernah dikompilasi/dites** karena sandbox tempat perbaikan ini ditulis tidak punya Flutter SDK maupun PHP. Sebelum dipakai, jalankan `flutter analyze` dan `flutter run` di kedua aplikasi, serta `php artisan serve` + coba semua endpoint lewat Postman/aplikasi, untuk menangkap kesalahan sintaks atau ketidakcocokan kecil yang mungkin lolos dari peninjauan manual.
- Beberapa layar lama yang datanya sudah tidak relevan dengan skema baru (misalnya rating/pengikut toko, statistik pengunjung) dijadikan placeholder statis karena backend belum punya data itu. Tidak menyebabkan error, tapi belum menampilkan angka nyata.

## Berkas referensi

- `Laporan_Audit_Ootday.docx` — audit awal lengkap dengan semua temuan.
- `backend_laravel/README.md` — detail setup backend dan perbedaan skema database.
- `backend_laravel/API_CONTRACT.md` — daftar lengkap endpoint REST API.
