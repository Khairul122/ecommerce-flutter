# Ootday E-Commerce Application System

A complete full-stack e-commerce system built for fashion & lifestyle retail, featuring dual Flutter mobile applications (Customer & Store Owner) backed by a modern Laravel 11 REST API.

---

## 📌 Repository Branch Structure

This repository is organized into four dedicated branches:

| Branch | Description | Tech Stack |
| :--- | :--- | :--- |
| **`main`** | Complete monorepo overview, architectural documentation, and full codebase. | Documentation & Full Stack |
| **`pelanggan`** | Mobile application for Customers / Buyers. | Flutter (Android/iOS) |
| **`owner`** | Mobile application for Store Owners / Sellers. | Flutter (Android/iOS) |
| **`backend`** | REST API backend service with Sanctum token authentication. | Laravel 11 & MySQL |

---

## 🏗️ System Architecture

```
                      +-----------------------------+
                      |   Laravel 11 REST API       |
                      |   (backend_laravel)         |
                      |   Sanctum Auth + MySQL      |
                      +--------------+--------------+
                                     ^
                                     | Bearer Token (Sanctum)
                    +----------------+----------------+
                    |                                 |
       +------------+------------+       +------------+------------+
       |   Ootday Pelanggan App  |       |     Ootday Owner App    |
       |   (Customer Mobile)     |       |    (Seller/Store Admin)  |
       +-------------------------+       +-------------------------+
```

---

## 🚀 Quick Start Guide

### 1. Backend Service (`backend_laravel`)

```bash
cd backend_laravel
composer install
cp .env.example .env
php artisan key:generate
```
Configure your database settings in `.env`, then run:
```bash
php artisan migrate --seed
php artisan storage:link
php artisan serve --host=0.0.0.0 --port=8000
```
Default accounts seeded:
- **Owner**: `owner@ootday.com` / `owner123`
- **Customer**: `guest@ootday.com` / `guest123`

### 2. Mobile Applications (`ootday_pelanggan` & `ootday_owner`)

Update the backend API base URL in `lib/core/services/api_service.dart` (or `lib/services/api_service.dart`) with your local LAN IP (e.g. `http://192.168.1.X:8000/api`).

Then run in each Flutter project:
```bash
flutter pub get
flutter run
```

---

## 📄 License

This project is open-sourced software licensed under the [MIT License](LICENSE).
