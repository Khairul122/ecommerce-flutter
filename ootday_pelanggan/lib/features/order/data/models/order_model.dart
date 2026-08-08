import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.orderCode,
    required super.status,
    required super.paymentStatus,
    required super.totalPrice,
    super.subtotal,
    super.shippingCost,
    super.cancelReason,
    super.storeId,
    super.storeName,
    super.shippingMethodName,
    super.paymentMethodName,
    super.shippingCourier,
    super.shippingService,
    super.shippingWeight,
    super.shippingEtd,
    super.trackingNumber,
    super.receiverName,
    super.receiverPhone,
    super.shippingAddress,
    super.orderedAt,
    super.snapToken,
    super.snapRedirectUrl,
    super.paymentType,
    super.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final store = json['store'] as Map<String, dynamic>?;
    final shippingMethod = json['shipping_method'] as Map<String, dynamic>?;
    final paymentMethod = json['payment_method'] as Map<String, dynamic>?;
    final rawItems = (json['items'] as List?) ?? [];

    return OrderModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      orderCode: json['order_code']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      paymentStatus: json['payment_status']?.toString() ?? '',
      totalPrice: num.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      subtotal: num.tryParse(json['subtotal']?.toString() ?? '0') ?? 0,
      shippingCost: num.tryParse(json['shipping_cost']?.toString() ?? '0') ?? 0,
      cancelReason: json['cancel_reason']?.toString(),
      storeId: store?['id'] is int
          ? store!['id'] as int
          : int.tryParse(store?['id']?.toString() ?? ''),
      storeName: store?['store_name']?.toString(),
      shippingMethodName: shippingMethod?['name']?.toString(),
      paymentMethodName: paymentMethod?['name']?.toString(),
      shippingCourier: json['shipping_courier']?.toString(),
      shippingService: json['shipping_service']?.toString(),
      shippingWeight: json['shipping_weight'] != null ? int.tryParse(json['shipping_weight'].toString()) : null,
      shippingEtd: json['shipping_etd']?.toString(),
      trackingNumber: json['tracking_number']?.toString(),
      receiverName: json['receiver_name']?.toString(),
      receiverPhone: json['receiver_phone']?.toString(),
      shippingAddress: json['shipping_address']?.toString(),
      orderedAt: json['ordered_at']?.toString() ?? json['created_at']?.toString(),
      snapToken: json['snap_token']?.toString(),
      snapRedirectUrl: json['snap_redirect_url']?.toString(),
      paymentType: json['payment_type']?.toString(),
      items: <OrderItemEntity>[
        for (final item in rawItems) OrderItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
      ],
    );
  }
}
