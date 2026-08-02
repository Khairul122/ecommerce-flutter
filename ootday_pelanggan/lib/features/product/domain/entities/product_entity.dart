import 'category_entity.dart';

class ProductImageEntity {
  final int id;
  final String imageUrl;
  final bool isPrimary;
  final int sortOrder;

  const ProductImageEntity({
    required this.id,
    required this.imageUrl,
    this.isPrimary = false,
    this.sortOrder = 0,
  });
}

class ProductVariantEntity {
  final int id;
  final String size;
  final String color;
  final int stock;
  final double? price;
  final String? imageUrl;

  const ProductVariantEntity({
    required this.id,
    required this.size,
    required this.color,
    required this.stock,
    this.price,
    this.imageUrl,
  });
}

/// Info toko ringkas yang ikut disematkan pada detail produk (`GET
/// /products/{id}` meng-eager-load relasi `store`).
class ProductStoreEntity {
  final int id;
  final String name;
  final String? logoUrl;

  const ProductStoreEntity({
    required this.id,
    required this.name,
    this.logoUrl,
  });
}

class ProductEntity {
  final int id;
  final int storeId;
  final int? categoryId;
  final String name;
  final double price;
  final int stock;
  final String status;
  final String? description;
  final int soldCount;
  final List<ProductImageEntity> images;
  final List<ProductVariantEntity> variants;
  final CategoryEntity? category;
  final ProductStoreEntity? store;

  const ProductEntity({
    required this.id,
    required this.storeId,
    this.categoryId,
    required this.name,
    required this.price,
    required this.stock,
    this.status = 'active',
    this.description,
    this.soldCount = 0,
    this.images = const [],
    this.variants = const [],
    this.category,
    this.store,
  });

  List<String> get imageUrls => images.map((e) => e.imageUrl).toList();

  String get primaryImageUrl {
    if (images.isEmpty) return 'assets/images/Produk_1.png';
    for (final img in images) {
      if (img.isPrimary && img.imageUrl.isNotEmpty) return img.imageUrl;
    }
    return images.first.imageUrl.isNotEmpty
        ? images.first.imageUrl
        : 'assets/images/Produk_1.png';
  }
}
