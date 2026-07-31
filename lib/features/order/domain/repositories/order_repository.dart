import '../entities/order_entity.dart';

/// Kontrak layer domain untuk pesanan pelanggan. Pembuatan pesanan
/// (POST /orders) TIDAK termasuk di sini — itu bagian dari fitur checkout.
abstract class OrderRepository {
  /// status: menunggu_pembayaran | diproses | dikirim | selesai | dibatalkan
  /// Kosongkan/biarkan null untuk mengambil semua status.
  Future<List<OrderEntity>> getOrders({String? status});

  /// Dipertahankan untuk kompatibilitas pemanggil lama yang menghitung badge
  /// "pesanan aktif" (status diproses).
  Future<List<OrderEntity>> getActiveOrders();

  Future<OrderEntity> getOrder(String orderId);

  Future<OrderEntity> confirmPayment(String orderId, {String? paymentProofUrl});

  Future<OrderEntity> cancelOrder(String orderId, {String? reason});
}
