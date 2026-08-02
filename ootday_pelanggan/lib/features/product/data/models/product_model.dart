import '../../domain/entities/product_entity.dart';
import 'category_model.dart';

int _toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

int? _toIntOrNull(dynamic v) {
  if (v == null) return null;
  return v is int ? v : int.tryParse(v.toString());
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

class ProductImageModel extends ProductImageEntity {
  const ProductImageModel({
    required super.id,
    required super.imageUrl,
    super.isPrimary,
    super.sortOrder,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: _toInt(json['id']),
      imageUrl: json['image_url']?.toString() ?? '',
      isPrimary: json['is_primary'] == true || json['is_primary'] == 1,
      sortOrder: _toInt(json['sort_order']),
    );
  }
}

class ProductVariantModel extends ProductVariantEntity {
  const ProductVariantModel({
    required super.id,
    required super.size,
    required super.color,
    required super.stock,
    super.price,
    super.imageUrl,
  });

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: _toInt(json['id']),
      size: json['size']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      stock: _toInt(json['stock']),
      price: _toDouble(json['price']),
      imageUrl: json['image_url']?.toString(),
    );
  }
}

class ProductStoreModel extends ProductStoreEntity {
  const ProductStoreModel({
    required super.id,
    required super.name,
    super.logoUrl,
  });

  factory ProductStoreModel.fromJson(Map<String, dynamic> json) {
    return ProductStoreModel(
      id: _toInt(json['id']),
      name: json['store_name']?.toString() ?? json['name']?.toString() ?? '',
      logoUrl: json['logo_url']?.toString(),
    );
  }
}

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.storeId,
    super.categoryId,
    required super.name,
    required super.price,
    required super.stock,
    super.status,
    super.description,
    super.soldCount,
    super.images,
    super.variants,
    super.category,
    super.store,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List? ?? const [];
    final variantsJson = json['variants'] as List? ?? const [];
    final categoryJson = _asMap(json['category']);
    final storeJson = _asMap(json['store']);

    return ProductModel(
      id: _toInt(json['id']),
      storeId: _toInt(json['store_id']),
      categoryId: _toIntOrNull(json['category_id']),
      name: json['name']?.toString() ?? '',
      price: _toDouble(json['price']) ?? 0,
      stock: _toInt(json['stock']),
      status: json['status']?.toString() ?? 'active',
      description: json['description']?.toString(),
      soldCount: _toInt(json['sold_count']),
      images: imagesJson
          .whereType<Map>()
          .map((e) => ProductImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      variants: variantsJson
          .whereType<Map>()
          .map((e) => ProductVariantModel.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      category: categoryJson != null ? CategoryModel.fromJson(categoryJson) : null,
      store: storeJson != null ? ProductStoreModel.fromJson(storeJson) : null,
    );
  }
}
