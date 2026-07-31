import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

/// Implementasi [OrderRepository]: murni delegasi ke remote data source
/// (REST API). Tidak ada cache lokal — data pesanan selalu diambil fresh
/// dari server tiap kali diminta.
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remote;

  OrderRepositoryImpl({required this.remote});

  @override
  Future<List<OrderEntity>> getOrders({String? status}) =>
      remote.getOrders(status: status);

  @override
  Future<List<OrderEntity>> getActiveOrders() => remote.getOrders(status: 'diproses');

  @override
  Future<OrderEntity> getOrder(String orderId) => remote.getOrder(orderId);

  @override
  Future<OrderEntity> confirmPayment(String orderId, {String? paymentProofUrl}) {
    return remote.confirmPayment(orderId, paymentProofUrl: paymentProofUrl);
  }

  @override
  Future<OrderEntity> cancelOrder(String orderId, {String? reason}) {
    return remote.cancelOrder(orderId, reason: reason);
  }
}
