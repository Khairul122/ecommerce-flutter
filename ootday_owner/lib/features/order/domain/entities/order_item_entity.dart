class OrderItemEntity {
  final int id;
  final String productName;
  final int quantity;
  final dynamic price;

  /// JSON mentah item, dipertahankan untuk field yang belum dimodelkan
  /// (mis. varian, gambar produk) supaya UI lama tetap bisa membacanya.
  final Map<String, dynamic> raw;

  const OrderItemEntity({
    required this.id,
    required this.productName,
    required this.quantity,
    this.price,
    required this.raw,
  });
}
