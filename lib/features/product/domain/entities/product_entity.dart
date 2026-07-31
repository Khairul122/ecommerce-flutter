class ProductImageEntity {
  final String url;
  final bool isPrimary;

  const ProductImageEntity({required this.url, this.isPrimary = false});
}

class ProductVariantEntity {
  final String size;
  final String color;
  final int stock;

  const ProductVariantEntity({
    required this.size,
    required this.color,
    required this.stock,
  });
}

class ProductEntity {
  final int id;
  final String name;
  final double price;
  final int stock;
  final String description;
  final String status;
  final int? categoryId;
  final List<ProductImageEntity> images;
  final List<ProductVariantEntity> variants;

  /// JSON mentah dari server, dipertahankan supaya field tambahan (mis.
  /// category bersarang, created_at) masih bisa diakses tanpa memodelkan
  /// ulang semuanya di sini.
  final Map<String, dynamic> raw;

  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.description,
    required this.status,
    this.categoryId,
    required this.images,
    required this.variants,
    required this.raw,
  });

  String get primaryImageUrl {
    if (images.isEmpty) return '';
    final primary = images.firstWhere(
      (img) => img.isPrimary,
      orElse: () => images.first,
    );
    return primary.url;
  }
}
