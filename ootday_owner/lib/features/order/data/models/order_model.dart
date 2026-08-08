import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.productName,
    required super.quantity,
    super.price,
    required super.raw,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      productName: json['product_name']?.toString() ?? 'Produk',
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity'].toString()) ?? 0,
      price: json['price'],
      raw: json,
    );
  }
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderCode,
    required super.status,
    super.paymentStatus,
    super.totalPrice,
    super.cancelReason,
    required super.items,
    super.shippingCourier,
    super.shippingService,
    super.shippingCost,
    super.shippingWeight,
    super.shippingEtd,
    super.trackingNumber,
    required super.raw,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      orderCode: json['order_code']?.toString() ?? '#-',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString(),
      totalPrice: json['total_price'],
      cancelReason: json['cancel_reason']?.toString(),
      shippingCourier: json['shipping_courier']?.toString(),
      shippingService: json['shipping_service']?.toString(),
      shippingCost: json['shipping_cost'],
      shippingWeight: json['shipping_weight'] != null ? int.tryParse(json['shipping_weight'].toString()) : null,
      shippingEtd: json['shipping_etd']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      items: itemsJson
          .cast<Map<String, dynamic>>()
          .map(OrderItemModel.fromJson)
          .toList(),
      raw: json,
    );
  }
}
