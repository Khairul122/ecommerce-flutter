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

## Pesanan — pelanggan (login diperlukan)
- `GET /orders?status=` — status: menunggu_pembayaran|diproses|dikirim|selesai|dibatalkan
- `GET /orders/{id}`
- `POST /orders` — `address_id, shipping_method_id, payment_method_id` (memakai item keranjang yang `is_selected=true`)
- `POST /orders/{id}/confirm-payment` — `payment_proof_url?`
- `POST /orders/{id}/cancel` — `reason?`

## Chat (login diperlukan, dipakai kedua aplikasi)
- `GET /conversations`
- `POST /conversations` — `store_id` (pelanggan mulai percakapan baru/lanjut yang sudah ada)
- `GET /conversations/{id}/messages`
- `POST /conversations/{id}/messages` — `message`

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
