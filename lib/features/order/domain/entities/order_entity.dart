import 'order_item_entity.dart';

class OrderEntity {
  final int id;
  final String orderCode;
  final String status;
  final String? paymentStatus;
  final dynamic totalPrice;
  final String? cancelReason;
  final List<OrderItemEntity> items;

  /// JSON mentah dari server, dipertahankan supaya layar yang belum
  /// sepenuhnya dirapikan masih bisa membaca field yang belum dimodelkan
  /// di sini (mis. alamat pengiriman, data pembeli).
  final Map<String, dynamic> raw;

  const OrderEntity({
    required this.id,
    required this.orderCode,
    required this.status,
    this.paymentStatus,
    this.totalPrice,
    this.cancelReason,
    required this.items,
    required this.raw,
  });
}
