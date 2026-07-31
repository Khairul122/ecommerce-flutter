import 'order_item_entity.dart';

class OrderEntity {
  final int id;
  final String orderCode;

  /// menunggu_pembayaran | diproses | dikirim | selesai | dibatalkan
  final String status;
  final String paymentStatus;
  final num totalPrice;
  final String? cancelReason;

  final int? storeId;
  final String? storeName;

  final String? shippingMethodName;
  final String? paymentMethodName;

  final String? receiverName;
  final String? receiverPhone;
  final String? shippingAddress;

  final String? orderedAt;

  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    this.cancelReason,
    this.storeId,
    this.storeName,
    this.shippingMethodName,
    this.paymentMethodName,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
    this.orderedAt,
    this.items = const [],
  });
}
