# Kontrak API Ootday (Laravel)

Base URL contoh (sesuaikan di `api_service.dart` kedua aplikasi): `http://<ip-server>:8000/api`

Semua endpoint berlogin memerlukan header:
```
Authorization: Bearer <token>
Accept: application/json
```
Semua response berbentuk `{ "status": "success"|"error", "message"?: string, "data"?: ..., "errors"?: {...} }`.

## Auth (publik)
- `POST /register` — body: `name, email, password, phone?, role(pelanggan|owner), store_name(wajib jika role=owner)` → `{token, user}`
- `POST /login` — body: `email, password` → `{token, user}`
- `POST /forgot-password` — body: `email`
- `POST /reset-password` — body: `email, token, password, password_confirmation`

## Auth (login diperlukan)
- `POST /logout`
- `GET /me` → data user + store (jika owner)
- `PUT /me/password` — body: `current_password, new_password`
- `DELETE /me` — hapus akun (owner: ikut hapus toko/produk/gambar/varian lewat cascade)

## Produk & kategori (publik, GET saja)
- `GET /products?store_id=&category_id=&q=&per_page=` — paginated
- `GET /products/{id}`
- `GET /categories?store_id=`
- `GET /payment-methods`
- `GET /shipping-methods`

## Upload gambar (login diperlukan)
- `POST /upload` — multipart/form-data, field `file` (image, maks 5MB) → `{url}`. Menggantikan Firebase Storage untuk foto profil toko dan gambar produk.

## Alamat (login diperlukan)
- `GET /addresses`
- `POST /addresses` — `receiver_name, phone, full_address, is_main?`
- `PUT /addresses/{id}`
- `DELETE /addresses/{id}`
- `POST /addresses/{id}/set-main`

## Keranjang (login diperlukan)
- `GET /cart`
- `POST /cart` — `variant_id, quantity?`
- `PUT /cart/{id}` — `quantity?, is_selected?`
- `DELETE /cart/{id}`
- `POST /cart/select-all` — `is_selected`

## Pembayaran Otomatis (Xendit) & Pesanan — pelanggan (login diperlukan)
- `GET /orders?status=` — status: menunggu_pembayaran|diproses|dikirim|selesai|dibatalkan
- `GET /orders/{id}`
- `POST /orders` — `address_id, shipping_method_id, payment_method_id` (memakai item keranjang yang `is_selected=true`)
- `POST /orders/{id}/snap-token` → `{ snap_token, snap_redirect_url, payment_url }` (Invoice Xendit)
- `POST /orders/{id}/qris` → `{ qr_string, account_number, ... }` (QRIS / Virtual Account Xendit)
- `POST /orders/{id}/confirm-payment` — `payment_proof_url?` (Bukti transfer manual fallback)
- `POST /orders/{id}/cancel` — `reason?`

## Xendit Webhook Callback (Publik)
- `POST /xendit/callback` — Webhook otomatis dari Xendit untuk memperbarui status pesanan menjadi `paid`.
- `GET /xendit/redirect/success` — Halaman konfirmasi sukses setelah pembayaran invoice Xendit.
- `GET /xendit/redirect/failure` — Halaman konfirmasi gagal setelah pembayaran invoice Xendit.

## Chat (login diperlukan, dipakai kedua aplikasi)
- `GET /conversations`
- `POST /conversations` — `store_id` (pelanggan mulai percakapan baru/lanjut yang sudah ada)
- `GET /conversations/{id}/messages`
- `POST /conversations/{id}/messages` — `message`

## Notifikasi (login diperlukan, dipakai kedua aplikasi)
- `GET /notifications` — daftar notifikasi milik user login, terbaru dulu
- `GET /notifications/unread-count` — `{ count }`
- `POST /notifications/{id}/read` — tandai satu notifikasi sebagai terbaca

## Wishlist (login diperlukan)
- `GET /wishlist` — list produk favorit user login
- `GET /wishlist/ids` — list ID produk yang ada di wishlist
- `POST /wishlist/toggle/{productId}` — tambah/hapus dari wishlist (returns `is_wishlist: true|false`)

## Review Produk (publik & berlogin)
- `GET /products/{productId}/reviews` — list ulasan produk (paginated, returns `avg_rating`, `total_reviews`, `data`)
- `POST /reviews` — body: `order_id, product_id, rating(1-5), comment?` (tambah ulasan dari pesanan selesai)

## Khusus owner (login + role owner), prefix `/owner`
- `GET /owner/store` / `PUT /owner/store` — `store_name?, description?, address?, phone?, logo_url?`
- `PUT /owner/profile` — `name?, phone?`
- `GET /owner/stats` — angka dashboard asli
- `GET /owner/products` — semua produk toko sendiri (termasuk nonaktif)
- `POST /owner/products` — `name, category_id?, price, stock?, description?, status?, images?[], variants?[{size,color,stock?,price?}]`
- `PUT /owner/products/{id}`
- `DELETE /owner/products/{id}`
- `POST /owner/categories`, `PUT /owner/categories/{id}`, `DELETE /owner/categories/{id}`
- `GET /owner/orders?status=`
- `GET /owner/orders/{id}`
- `PUT /owner/orders/{id}/status` — `status(diproses|dikirim|selesai|dibatalkan), cancel_reason?`
- `POST /owner/orders/{id}/confirm-payment`

## Kode status error umum
- `401` — token tidak ada/tidak valid → arahkan ke login
- `403` — role salah atau bukan pemilik resource
- `404` — resource tidak ditemukan
- `422` — validasi gagal, lihat `message`/`errors`
