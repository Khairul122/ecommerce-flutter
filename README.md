# Ootday Owner App (Seller / Store Admin Application)

Flutter-based mobile application for store owners and sellers to manage products, stores, orders, and customer conversations on the Ootday platform.

---

## 🏪 Features

- **Dashboard & Analytics**: Store sales statistics, order counters, and performance stats.
- **Product & Category Management**: Full CRUD for products, image uploading via API, category organization.
- **Order Processing**: Review incoming orders, confirm payment proofs, update fulfillment status (Processing, Shipped, Completed, Cancelled).
- **Customer Chat**: Communicate directly with buyers.
- **Store & Profile Settings**: Edit store details, logo, description, and contact profile.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `^3.6.1`
- Android Studio / Xcode

### Installation Steps

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Configure Backend Endpoint:
   Open `lib/core/services/api_service.dart` (or `lib/services/api_service.dart`) and update `baseUrl`:
   ```dart
   static const String baseUrl = 'http://<YOUR_LOCAL_IP>:8000/api';
   ```

3. Run Application:
   ```bash
   flutter run
   ```

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
