# Ootday Backend REST API

Laravel 11 REST API backend service for the Ootday E-Commerce ecosystem. Provides authentication (Sanctum), store management, catalog services, cart & order processing, and communication APIs.

---

## 🛠️ Technology Stack

- **PHP**: `^8.2`
- **Framework**: Laravel 11.9
- **Authentication**: Laravel Sanctum 4.0
- **Database**: MySQL

---

## 🚀 Setup & Installation

1. Install Composer dependencies:
   ```bash
   composer install
   ```

2. Environment Setup:
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

3. Database Configuration & Seed:
   Update your `.env` file with your MySQL database credentials, then execute:
   ```bash
   php artisan migrate --seed
   php artisan storage:link
   ```

4. Run Local Server:
   ```bash
   php artisan serve --host=0.0.0.0 --port=8000
   ```

---

## 🔑 Default Accounts (Seeded)

- **Store Owner**: `owner@ootday.com` / `owner123`
- **Customer**: `guest@ootday.com` / `guest123`

---

## 📖 API Documentation

Detailed API endpoint specs are available in [API_CONTRACT.md](API_CONTRACT.md).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
