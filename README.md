# Ootday Pelanggan App (Customer Mobile Application)

Flutter-based mobile application for customers of the Ootday fashion store platform.

---

## 🛍️ Features

- **Product Discovery & Search**: Browse featured products, categories, search with filters.
- **Cart & Checkout**: Multi-item cart management, address selection, shipping cost calculation, and order submission.
- **Order Tracking**: Real-time order status tracking (Pending Payment, Processed, Shipped, Completed, Cancelled).
- **Manual Payment Verification**: Upload transfer receipt proof directly to backend.
- **In-App Customer Support**: Chat directly with store owners.
- **Profile & Address Management**: Multi-address support with primary address tagging.

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
