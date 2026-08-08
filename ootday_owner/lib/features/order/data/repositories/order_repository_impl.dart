import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

/// Implementasi [OrderRepository]: mengoordinasikan remote data source
/// (REST API) untuk manajemen pesanan owner.
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;

  OrderRepositoryImpl({required this.remote});

  @override
  Future<List<OrderEntity>> getOrders({String? status}) {
    return remote.getOrders(status: status);
  }

  @override
  Future<OrderEntity> getOrder(int id) {
    return remote.getOrder(id);
  }

  @override
  Future<void> updateStatus(
    int id, {
    required String status,
    String? cancelReason,
    String? trackingNumber,
  }) {
    return remote.updateStatus(id, status: status, cancelReason: cancelReason, trackingNumber: trackingNumber);
  }

  @override
  Future<void> confirmPayment(int id) {
    return remote.confirmPayment(id);
  }

  @override
  Future<Map<String, dynamic>> getStats() {
    return remote.getStats();
  }
}
