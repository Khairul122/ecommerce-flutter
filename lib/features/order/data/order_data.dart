// order_data.dart
//
// Menggantikan endpoint PHP lama (/orders/get.php, /orders/create.php) dengan
// endpoint Laravel /api/orders/* (lihat backend_laravel/API_CONTRACT.md).
// Perbaikan audit penting:
// - Pesanan sekarang dibuat dari address_id/shipping_method_id/payment_method_id
//   yang benar-benar dipilih pelanggan, bukan data hardcode di checkout_screen.
// - Server memvalidasi stok sebelum membuat pesanan.
// - Status awal "menunggu_pembayaran"; berubah "menunggu_konfirmasi" hanya
//   setelah pelanggan menekan tombol konfirmasi bayar (confirmPayment),
//   BUKAN otomatis sukses seperti alur fake sebelumnya.
// - Tombol "Batalkan Pesanan" sekarang benar-benar memanggil endpoint cancel.
// - Semua tab status di my_orders_screen.dart mengambil data asli lewat
//   getOrders(status: ...), bukan cuma tab "Diproses" yang nyata.
import '../../../core/services/api_service.dart';

class OrderData {
  static final ApiService _api = ApiService();

  /// status: menunggu_pembayaran | diproses | dikirim | selesai | dibatalkan
  /// Kosongkan/biarkan null untuk mengambil semua status.
  static Future<List<Map<String, dynamic>>> getOrders({String? status}) async {
    final query = (status != null && status.isNotEmpty) ? '?status=$status' : '';
    final result = await _api.get('/orders$query');
    final List rawList = result['data'] ?? [];
    return List<Map<String, dynamic>>.from(rawList);
  }

  /// Dipertahankan untuk kompatibilitas pemanggil lama yang menghitung badge
  /// "pesanan aktif" (status diproses).
  static Future<List<Map<String, dynamic>>> getActiveOrders() => getOrders(status: 'diproses');

  static Future<Map<String, dynamic>> getOrderDetail(String orderId) async {
    final result = await _api.get('/orders/$orderId');
    return Map<String, dynamic>.from(result['data'] ?? {});
  }

  /// Membuat pesanan baru dari item keranjang yang sedang is_selected=true di
  /// server. Mengembalikan data pesanan (termasuk id & order_code) yang
  /// dibutuhkan untuk melanjutkan ke layar instruksi pembayaran.
  static Future<Map<String, dynamic>> createOrder({
    required String addressId,
    required int shippingMethodId,
    required int paymentMethodId,
  }) async {
    final result = await _api.post('/orders', {
      'address_id': int.tryParse(addressId) ?? addressId,
      'shipping_method_id': shippingMethodId,
      'payment_method_id': paymentMethodId,
    });
    return Map<String, dynamic>.from(result['data'] ?? {});
  }

  /// Pelanggan menandai "saya sudah bayar". Server mengubah payment_status
  /// menjadi "menunggu_konfirmasi" (bukan langsung lunas) karena verifikasi
  /// akhir masih dilakukan manual oleh pemilik toko.
  static Future<Map<String, dynamic>> confirmPayment(String orderId, {String? paymentProofUrl}) async {
    final result = await _api.post('/orders/$orderId/confirm-payment', {
      if (paymentProofUrl != null) 'payment_proof_url': paymentProofUrl,
    });
    return Map<String, dynamic>.from(result['data'] ?? {});
  }

  static Future<Map<String, dynamic>> cancelOrder(String orderId, {String? reason}) async {
    final result = await _api.post('/orders/$orderId/cancel', {
      if (reason != null) 'reason': reason,
    });
    return Map<String, dynamic>.from(result['data'] ?? {});
  }
}
