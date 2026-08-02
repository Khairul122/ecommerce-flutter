import 'dart:io';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Implementasi [ProductRepository] untuk owner: mengoordinasikan remote
/// data source (REST API Laravel) untuk produk & kategori.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;

  ProductRepositoryImpl({required this.remote});

  @override
  Future<List<ProductEntity>> getMyProducts() => remote.getMyProducts();

  @override
  Future<ProductEntity> addProduct({
    required String name,
    int? categoryId,
    required double price,
    required int stock,
    required String description,
    String? imageUrl,
    List<String> sizes = const ['S', 'M', 'L', 'XL'],
    Map<String, String>? variantImageUrls,
  }) {
    return remote.addProduct(
      name: name,
      categoryId: categoryId,
      price: price,
      stock: stock,
      description: description,
      imageUrl: imageUrl,
      sizes: sizes,
      variantImageUrls: variantImageUrls,
    );
  }

  @override
  Future<ProductEntity> updateProduct(
    int productId,
    Map<String, dynamic> fields,
  ) {
    return remote.updateProduct(productId, fields);
  }

  @override
  Future<void> deleteProduct(int productId) => remote.deleteProduct(productId);

  @override
  Future<List<CategoryEntity>> getCategories(int? storeId) =>
      remote.getCategories(storeId);

  @override
  Future<CategoryEntity> addCategory(String name) => remote.addCategory(name);

  @override
  Future<CategoryEntity> updateCategory(int categoryId, String name) =>
      remote.updateCategory(categoryId, name);

  @override
  Future<void> deleteCategory(int categoryId) =>
      remote.deleteCategory(categoryId);

  @override
  Future<String> uploadImage(File file) => remote.uploadImage(file);
}
