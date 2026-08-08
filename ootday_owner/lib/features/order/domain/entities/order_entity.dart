import 'order_item_entity.dart';

class OrderEntity {
  final int id;
  final String orderCode;
  final String status;
  final String? paymentStatus;
  final dynamic totalPrice;
  final String? cancelReason;
  final List<OrderItemEntity> items;

  final String? shippingCourier;
  final String? shippingService;
  final dynamic shippingCost;
  final int? shippingWeight;
  final String? shippingEtd;
  final String? trackingNumber;

  final Map<String, dynamic> raw;

  const OrderEntity({
    required this.id,
    required this.orderCode,
    required this.status,
    this.paymentStatus,
    this.totalPrice,
    this.cancelReason,
    required this.items,
    this.shippingCourier,
    this.shippingService,
    this.shippingCost,
    this.shippingWeight,
    this.shippingEtd,
    this.trackingNumber,
    required this.raw,
  });

  String get courierDisplay {
    if (shippingCourier != null && shippingCourier!.isNotEmpty) {
      final service = shippingService != null ? ' $shippingService' : '';
      return '${shippingCourier!.toUpperCase()}$service';
    }
    return raw['shipping_method']?['name']?.toString() ?? 'JNE REG';
  }
}
