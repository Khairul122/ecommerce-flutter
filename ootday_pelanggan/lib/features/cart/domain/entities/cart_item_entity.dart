/// Representasi satu baris item keranjang di layer domain. Field-nya
/// mengikuti persis apa yang sebelumnya dipakai oleh `CartData` (lihat
/// `data/cart_data.dart` lama) supaya UI tidak perlu berubah drastis.
class CartItemEntity {
  final String id;
  final String variantId;
  final String productId;
  final String name;
  final String desc;
  final int price;
  final int quantity;
  final bool selected;
  final String image;

  const CartItemEntity({
    required this.id,
    required this.variantId,
    required this.productId,
    required this.name,
    required this.desc,
    required this.price,
    required this.quantity,
    required this.selected,
    required this.image,
  });

  CartItemEntity copyWith({
    int? quantity,
    bool? selected,
  }) {
    return CartItemEntity(
      id: id,
      variantId: variantId,
      productId: productId,
      name: name,
      desc: desc,
      price: price,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      image: image,
    );
  }
}
