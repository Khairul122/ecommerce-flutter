import 'order_item_entity.dart';

class OrderEntity {
  final int id;
  final String orderCode;

  /// menunggu_pembayaran | diproses | dikirim | selesai | dibatalkan
  final String status;
  final String paymentStatus;
  final num totalPrice;
  final num subtotal;
  final num shippingCost;
  final String? cancelReason;

  final int? storeId;
  final String? storeName;

  final String? shippingMethodName;
  final String? paymentMethodName;

  final String? shippingCourier;
  final String? shippingService;
  final int? shippingWeight;
  final String? shippingEtd;
  final String? trackingNumber;

  final String? receiverName;
  final String? receiverPhone;
  final String? shippingAddress;

  final String? orderedAt;

  final String? snapToken;
  final String? snapRedirectUrl;
  final String? paymentType;

  final List<OrderItemEntity> items;

  const OrderEntity({
    required this.id,
    required this.orderCode,
    required this.status,
    required this.paymentStatus,
    required this.totalPrice,
    this.subtotal = 0,
    this.shippingCost = 0,
    this.cancelReason,
    this.storeId,
    this.storeName,
    this.shippingMethodName,
    this.paymentMethodName,
    this.shippingCourier,
    this.shippingService,
    this.shippingWeight,
    this.shippingEtd,
    this.trackingNumber,
    this.receiverName,
    this.receiverPhone,
    this.shippingAddress,
    this.orderedAt,
    this.snapToken,
    this.snapRedirectUrl,
    this.paymentType,
    this.items = const [],
  });

  String get courierDisplay {
    if (shippingCourier != null && shippingCourier!.isNotEmpty) {
      final service = shippingService != null ? ' $shippingService' : '';
      return '${shippingCourier!.toUpperCase()}$service';
    }
    return shippingMethodName ?? 'JNE REG';
  }
}
