class OrderItemEntity {
  final String productName;
  final String? variantLabel;
  final String imageUrl;
  final num price;
  final int quantity;

  const OrderItemEntity({
    required this.productName,
    this.variantLabel,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}
