# SAAS READINESS AUDIT & REKOMENDASI PENGEMBANGAN OOTDAY
**Transformasi Sistem E-Commerce Single-Tenant ke Platform SaaS Multi-Tenant**

---

## 1. Executive Summary

Dokumen ini menyajikan hasil audit mendalam dan rekomendasi arsitektur untuk menyeberangkan proyek **Ootday** dari sistem e-commerce *single-tenant* (satu backend untuk satu toko) menjadi platform **SaaS Multi-Tenant** yang siap dijual secara komersial (Subscription Model).

---

## 2. Analisis Arsitektur Multi-Tenancy

### 2.1 Kondisi Database & Backend Saat Ini
- **Status Database**: Skema database saat ini (`database/schema.sql` dan Laravel migrations) sudah memiliki tabel `stores`, serta tabel `products` dan `categories` yang memegang `store_id`.
- **Keterbatasan saat ini**:
  - `orders` terhubung ke `store_id`, namun `users` (pelanggan) saat ini bersifat global tanpa asosiasi tenant.
  - `cart_items` dan `conversations` terhubung ke `store_id` / `user_id`, tetapi belum ada batasan isolasi data tenant pada level Eloquent Query Scope di Laravel.
  - `addresses` dan `notifications` bersifat per-user tanpa pembatasan ruang lingkup toko/tenant.

### 2.2 Rekomendasi Pendekatan Multi-Tenant
Disarankan menggunakan **Shared Database, Shared Schema dengan `tenant_id` / `store_id` Scoping** untuk tahap awal hingga menengah (0 - 5.000 tenant aktif).

#### Trade-off Analysis:
| Kriteria | Shared Database (`tenant_id` Scoping) [Rekomendasi] | Separate Database per Tenant |
| :--- | :--- | :--- |
| **Biaya Hosting** | **Sangat Murah** (satu instance MySQL/PostgreSQL) | Mahal (ratusan/ribuan instance DB) |
| **Kemudahan Maintenance** | **Tinggi** (1x migrasi untuk semua tenant) | Rumit (perlu runner migrasi massal) |
| **Isolasi Data** | Diatur pada level aplikasi (Global Scopes/Middleware) | Terisolasi total pada level DB |
| **Skalabilitas Awal** | Sangat Cepat (Instant Tenant Provisioning) | Lambat (perlu provisioning DB baru) |

### 2.3 Perubahan Backend Laravel yang Diperlukan
1. **Trait & Global Scope `BelongsToTenant`**:
   Semua Model yang relevan (`Product`, `Category`, `Order`, `Conversation`) wajib menggunakan Tenant Global Scope:
   ```php
   protected static function booted()
   {
       static::addGlobalScope('tenant', function (Builder $builder) {
           if (auth()->check() && auth()->user()->isOwner()) {
               $builder->where('store_id', auth()->user()->store_id);
           }
       });
   }
   ```
2. **Middleware Scoping (`IdentifyTenant`)**:
   Memeriksa `X-Tenant-ID` header atau sub-domain (`tenant.ootday.com`) pada setiap request API.

---

## 3. Onboarding & Provisioning Otomatis (Self-Service)

### 3.1 Alur Pendaftaran Toko Baru (Self-Service Signup)
1. **Pendaftaran Admin Toko**: Toko baru mendaftar via web/app owner (`POST /api/saas/register-tenant`).
2. **Automated Provisioning Workflow**:
   - Sistem membuat entitas `User` (Role Owner) & `Store`.
   - Seeder otomatis membuat sampel kategori standar (misal: *Pakaian Pria*, *Pakaian Wanita*, *Aksesori*).
   - Pengaturan default toko (Metode Pembayaran, Tarif Kurir Default) langsung diisi secara otomatis.
   - Masa percobaan (*Free Trial*) 14 hari langsung aktif tanpa memerlukan kartu kredit.

---

## 4. Billing & Subscription Management

### 4.1 Integrasi Payment Gateway Langganan (Penggunaan Ulang `XenditService`)
- **Evaluasi Kemampuan saat ini**: Kode backend `app/Services/XenditService.php` yang saat ini digunakan untuk pembayaran pesanan (`/snap-token` & `/qris`) **dapat diperluas secara langsung** untuk menangani **Xendit Recurring Subscriptions API**.
- **Mekanisme Billing**:
  - Penagihan otomatis bulanan/tahunan (Auto-debit / VA / E-wallet QRIS).
  - Webhook Listener (`POST /api/saas/webhook/subscription`) untuk memperbarui status langganan tenant (`active`, `past_due`, `canceled`).

### 4.2 Push Notification Tanpa Firebase (Evaluasi OneSignal)
- **Kondisi Saat Ini**: Setelah pembersihan total Firebase (FCM), notifikasi dan chat berjalan menggunakan **REST API Polling** (`GET /conversations`, `GET /notifications`).
- **Evaluasi Skala SaaS**: Polling cukup efisien untuk 1-5 toko. Namun untuk skala SaaS dengan ribuan tenant, polling akan meningkatkan beban server HTTP secara eksponensial.
- **Rekomendasi Integrasi OneSignal**:
  - Mengintegrasikan SDK **OneSignal Flutter** di `ootday_owner` dan `ootday_pelanggan`.
  - Mengirim push notification langsung dari Laravel via REST API OneSignal (`OneSignalService`) saat ada chat baru atau perubahan status pesanan.

### 4.3 Struktur Paket Langganan & Quota Enforcer
| Fitur / Quota | Basic Plan (Rp 99k/bln) | Pro Plan (Rp 299k/bln) | Enterprise (Custom) |
| :--- | :--- | :--- | :--- |
| **Maksimal Produk** | 50 Produk | 1.000 Produk | Unlimited |
| **Jumlah Akun Admin** | 1 Admin | 5 Admin | Unlimited |
| **Biaya Transaksi (Fee)** | 1.5% per order | 0.5% per order | 0% |
| **Laporan & Analytics** | Laporan Dasar | Laporan Tingkat Lanjut + Ekspor Excel | Custom Dashboard |
| **Domain Sendiri (Custom Domain)**| ❌ Tidak | ✅ Ya (`toko.com`) | ✅ Ya |

---

## 5. Branding & White-Label Strategy (App Mobile)

### 5.1 Opsi Arsitektur Aplikasi Mobile

#### Opsi A: Single Mobile App + Multi-Store Selector (Rekomendasi MVP SaaS)
- **Konsep**: Satu aplikasi `Ootday` di Play Store/App Store. Pelanggan memilih toko via Scan QR Code Toko, Link Deep-link (`ootday.app/toko/fashion-hub`), atau memilih toko di halaman depan.
- **Kelebihan**: Biaya rilis gratis/hemat, biaya pemeliharaan build APK minimal, onboarding pelanggan sangat cepat.

#### Opsi B: Automated White-Label Build per Tenant (Paket Enterprise)
- **Konsep**: Memanfaatkan workflow GitHub Actions yang telah dibuat pada **MISI 3** untuk meng-generate APK tersendiri dengan nama, logo, dan warna sesuai branding tenant.
- **Kelebihan**: Pengalaman eksklusif untuk brand besar.

---

## 6. Keamanan & Isolasi Data Multi-Tenant

1. **Pencegahan Kebocoran Data (Cross-Tenant Data Leakage)**:
   - File upload (`storage/app/public`) wajib dipisah berdasarkan folder tenant: `storage/tenants/{tenant_id}/products/`.
   - Mengubah endpoint publik `GET /products/{id}` agar memverifikasi bahwa produk memang milik toko yang sedang diakses.
2. **Strict Rate Limiting per Tenant**:
   - Mencegah satu tenant yang mengalami lonjakan traffic membebani tenant lainnya (DDoS isolation).

---

## 7. Observability & Operasional SaaS

1. **Centralized Error Tracking**: Integrasi **Sentry** pada backend Laravel dan kedua aplikasi Flutter untuk mendeteksi crash secara real-time.
2. **Health Check & Uptime Monitoring**: Endpoint `/health` untuk memantau status database, queue worker, dan koneksi payment gateway.
3. **Audit Log System**: Mencatat setiap perubahan penting (perubahan harga, pengubahan pesanan, penghapusan produk) lengkap dengan `tenant_id`, `user_id`, dan `ip_address`.

---

## 8. Roadmap Prioritas Pengembangan SaaS

| Fase | Target Utama | Fitur Utama | Estimasi Effort |
| :--- | :--- | :--- | :--- |
| **Fase 1 (MVP SaaS)** | Kesiapan Multi-Tenant Dasar | Tenant Global Scopes, Identification Middleware, Storage Partitioning, Basic Self-Service Signup | **M (Medium)** |
| **Fase 2 (Monetization)** | Billing & Subscriptions | Xendit/Midtrans Recurring API, Quota Enforcement Middleware, Trial Expiry Logic | **M (Medium)** |
| **Fase 3 (Growth)** | White-Label & Domain | Custom Sub-Domain Router, White-label App Builder CLI via GitHub Actions | **L (Large)** |
| **Fase 4 (Scale)** | Enterprise & Analytics | Multi-Region DB Read Replicas, Tenant Usage Analytics Dashboard | **L (Large)** |

---

> *Dokumen ini disusun sebagai panduan teknis operasional dan dasar diskusi sprint pengembangan SaaS Ootday.*
