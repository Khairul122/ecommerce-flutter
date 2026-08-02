import '../../domain/entities/product_entity.dart';

class ProductImageModel extends ProductImageEntity {
  const ProductImageModel({required super.url, super.isPrimary});

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      url: json['image_url']?.toString() ?? '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
    );
  }
}

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.size,
    required super.color,
    required super.stock,
    super.imageUrl,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    final stock = json['stock'];
    return ProductVariantModel(
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      stock: stock is int ? stock : int.tryParse('$stock') ?? 0,
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.stock,
    required super.description,
    required super.status,
    super.categoryId,
    required super.images,
    required super.variants,
    required super.raw,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>? ?? [];
    final variantsJson = json['variants'] as List<dynamic>? ?? [];
    final price = json['price'];
    final stock = json['stock'];
    final categoryId = json['category_id'];

    return ProductModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
      price: price is num ? price.toDouble() : double.tryParse('$price') ?? 0,
      stock: stock is int ? stock : int.tryParse('$stock') ?? 0,
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      categoryId: categoryId == null
          ? null
          : (categoryId is int ? categoryId : int.tryParse('$categoryId')),
      images: imagesJson
          .map((e) => ProductImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      variants: variantsJson
          .map((e) => ProductVariantModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      raw: json,
    );
  }
}
