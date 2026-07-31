# Folder ini sudah tidak dipakai

File-file di folder `database/` ini (`schema.sql`, `migration_owner_uid.sql`, dua seeder) digantikan oleh migration dan seeder Laravel di `backend_laravel/database/migrations/` dan `backend_laravel/database/seeders/DatabaseSeeder.php`.

Skema baru sedikit berbeda (lihat `backend_laravel/README.md` bagian "Perbedaan skema"), terutama karena autentikasi sekarang sepenuhnya lewat Laravel + Sanctum, bukan Firebase. Jangan jalankan `schema.sql` ini lagi pada database yang dipakai backend Laravel, karena struktur tabelnya tidak kompatibel.
