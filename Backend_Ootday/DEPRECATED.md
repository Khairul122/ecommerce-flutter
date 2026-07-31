# Folder ini sudah tidak dipakai

`Backend_Ootday/` (PHP polos) digantikan sepenuhnya oleh `backend_laravel/` di root proyek ini, sebagai bagian dari perbaikan menyeluruh hasil audit (Juli 2026): menghapus Firebase dan koneksi MySQL langsung dari aplikasi mobile, diganti REST API Laravel + Sanctum.

`auth/register_owner.php` di folder ini punya beberapa masalah yang sudah diperbaiki di backend baru: tidak ada verifikasi token, pesan error PDOException bocor ke client, dan ALTER TABLE dijalankan di setiap request. Lihat `Laporan_Audit_Ootday.docx` di root proyek untuk detail lengkap.

Folder ini dibiarkan ada (tidak dihapus otomatis) supaya Anda bisa memeriksa isinya sendiri sebelum menghapusnya secara manual jika sudah yakin tidak dibutuhkan lagi.
