class OrderItemEntity {
  final int productId;
  final String productName;
  final String? variantLabel;
  final String imageUrl;
  final num price;
  final int quantity;

  const OrderItemEntity({
    this.productId = 0,
    required this.productName,
    this.variantLabel,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });
}
