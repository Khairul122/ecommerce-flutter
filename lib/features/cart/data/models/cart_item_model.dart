import '../../domain/entities/cart_item_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.variantId,
    required super.productId,
    required super.name,
    required super.desc,
    required super.price,
    required super.quantity,
    required super.selected,
    required super.image,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> item) {
    final variant = (item['variant'] as Map<String, dynamic>?) ?? {};
    final product = (variant['product'] as Map<String, dynamic>?) ?? {};
    final images = (product['images'] as List?) ?? [];

    String image = 'assets/images/Produk_1.png';
    if (images.isNotEmpty) {
      final primary = images.firstWhere(
        (img) => img is Map && img['is_primary'] == true,
        orElse: () => images.first,
      );
      if (primary is Map && primary['image_url'] != null) {
        image = primary['image_url'].toString();
      }
    }

    final double priceVal =
        double.tryParse((variant['price'] ?? product['price'] ?? 0).toString()) ?? 0;
    final dynamic qtyRaw = item['quantity'];
    final int quantity = qtyRaw is int ? qtyRaw : int.tryParse(qtyRaw.toString()) ?? 1;

    return CartItemModel(
      id: item['id'].toString(),
      variantId: (item['variant_id'] ?? variant['id'] ?? '').toString(),
      productId: (variant['product_id'] ?? product['id'] ?? '').toString(),
      name: product['name']?.toString() ?? '',
      desc: 'Warna: ${variant['color'] ?? 'Default'}, Ukuran: ${variant['size'] ?? 'M'}',
      price: priceVal.round(),
      quantity: quantity,
      selected: item['is_selected'] == true || item['is_selected'] == 1,
      image: image,
    );
  }
}
