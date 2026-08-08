class CartItemEntity {
  final String id;
  final String variantId;
  final String productId;
  final String name;
  final String desc;
  final int price;
  final int weight;
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
    this.weight = 500,
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
      weight: weight,
      quantity: quantity ?? this.quantity,
      selected: selected ?? this.selected,
      image: image,
    );
  }
}
