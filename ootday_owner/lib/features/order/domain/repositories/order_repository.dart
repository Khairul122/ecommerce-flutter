import '../entities/order_entity.dart';

/// Kontrak layer domain untuk manajemen pesanan owner. Implementasinya
/// (data layer) menentukan dari mana data ini datang (REST API).
abstract class OrderRepository {
  Future<List<OrderEntity>> getOrders({String? status});

  Future<OrderEntity> getOrder(int id);

  Future<void> updateStatus(
    int id, {
    required String status,
    String? cancelReason,
    String? trackingNumber,
  });

  Future<void> confirmPayment(int id);

  /// Ringkasan angka dashboard pesanan (GET /owner/stats). Dikembalikan
  /// sebagai Map mentah karena bentuknya berupa daftar hitungan per status
  /// yang hanya dibaca lewat key oleh UI (lihat OrderHistoryPage).
  Future<Map<String, dynamic>> getStats();
}
