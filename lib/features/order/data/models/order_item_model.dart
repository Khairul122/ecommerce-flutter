import '../../domain/entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.productName,
    super.variantLabel,
    required super.imageUrl,
    required super.price,
    required super.quantity,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      productName: json['product_name']?.toString() ?? 'Produk',
      variantLabel: json['variant_label']?.toString(),
      imageUrl: json['image_url']?.toString() ?? 'assets/images/Produk_1.png',
      price: num.tryParse(json['price']?.toString() ?? '0') ?? 0,
      quantity: json['quantity'] is int
          ? json['quantity'] as int
          : int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
    );
  }
}
