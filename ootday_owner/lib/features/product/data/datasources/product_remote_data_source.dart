import 'dart:io';

import '../../../../core/services/api_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur produk & kategori owner.
/// Menggantikan query MySQL langsung (mysql_service.dart) dan Firebase
/// Storage. Semua data produk lewat endpoint `/owner/products` dan
/// `/categories`/`/owner/categories`; identitas toko diketahui lewat token
/// Sanctum di header, bukan lagi lewat owner_uid manual.
class ProductRemoteDataSource {
  final ApiService _api;
  ProductRemoteDataSource(this._api);

  /// Kategori toko (dipakai dropdown di tambah_produk_page.dart).
  /// Backend tidak butuh store_id eksplisit untuk owner karena kategori
  /// publik bisa difilter dengan store_id, tapi untuk owner kita ambil semua
  /// kategori milik toko sendiri lewat store yang sudah dimuat di /me.
  Future<List<CategoryModel>> getCategories(int? storeId) async {
    final query = storeId != null ? '?store_id=$storeId' : '';
    final res = await _api.get('/categories$query');
    final data = res['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CategoryModel> addCategory(String name) async {
    final res = await _api.post('/owner/categories', {'name': name});
    return CategoryModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<CategoryModel> updateCategory(int categoryId, String name) async {
    final res =
        await _api.put('/owner/categories/$categoryId', {'name': name});
    return CategoryModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int categoryId) async {
    await _api.delete('/owner/categories/$categoryId');
  }

  /// Semua produk milik toko owner yang sedang login (termasuk nonaktif).
  Future<List<ProductModel>> getMyProducts() async {
    final res = await _api.get('/owner/products');
    final data = res['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Upload gambar produk lewat POST /upload (menggantikan Firebase Storage).
  Future<String> uploadImage(File file) async {
    final res = await _api.uploadFile('/upload', file);
    return (res['data'] as Map<String, dynamic>)['url'] as String;
  }

  Future<ProductModel> addProduct({
    required String name,
    int? categoryId,
    required double price,
    required int stock,
    required String description,
    String? imageUrl,
    List<String> sizes = const ['S', 'M', 'L', 'XL'],
    Map<String, String>? variantImageUrls,
  }) async {
    final variantStock = sizes.isEmpty
        ? stock
        : (stock / sizes.length).ceil().clamp(0, stock == 0 ? 1 : stock);

    final variants = sizes
        .map((size) => {
              'size': size,
              'color': 'Default',
              'stock': variantStock,
              if (variantImageUrls?[size] != null) 'image_url': variantImageUrls![size],
            })
        .toList();

    final res = await _api.post('/owner/products', {
      'name': name,
      if (categoryId != null) 'category_id': categoryId,
      'price': price,
      'stock': stock,
      'description': description,
      if (imageUrl != null && imageUrl.isNotEmpty) 'images': [imageUrl],
      if (variants.isNotEmpty) 'variants': variants,
    });

    return ProductModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<ProductModel> updateProduct(
    int productId,
    Map<String, dynamic> fields,
  ) async {
    final res = await _api.put('/owner/products/$productId', fields);
    return ProductModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int productId) async {
    await _api.delete('/owner/products/$productId');
  }
}
