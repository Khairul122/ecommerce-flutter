import 'dart:io';

import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

/// Kontrak layer domain untuk fitur produk & kategori owner. Implementasinya
/// (data layer) menentukan dari mana data ini datang (REST API Laravel).
abstract class ProductRepository {
  /// Semua produk milik toko owner yang sedang login (termasuk nonaktif).
  Future<List<ProductEntity>> getMyProducts();

  Future<ProductEntity> addProduct({
    required String name,
    int? categoryId,
    required double price,
    required int stock,
    required String description,
    String? imageUrl,
    List<String> sizes,
  });

  Future<ProductEntity> updateProduct(
    int productId,
    Map<String, dynamic> fields,
  );

  Future<void> deleteProduct(int productId);

  /// Kategori toko (dipakai dropdown di tambah_produk_page.dart).
  Future<List<CategoryEntity>> getCategories(int? storeId);

  Future<CategoryEntity> addCategory(String name);

  Future<CategoryEntity> updateCategory(int categoryId, String name);

  Future<void> deleteCategory(int categoryId);

  /// Upload gambar produk lewat POST /upload, mengembalikan URL gambar.
  Future<String> uploadImage(File file);
}
