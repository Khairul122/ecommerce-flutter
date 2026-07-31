import '../../../../core/services/api_service.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur produk. Semua endpoint
/// yang dipakai di sini publik (tanpa auth) — lihat API_CONTRACT.md.
class ProductRemoteDataSource {
  final ApiService _api;
  ProductRemoteDataSource(this._api);

  Future<List<ProductModel>> getProducts({
    int? storeId,
    int? categoryId,
    String? q,
    int perPage = 20,
    int page = 1,
  }) async {
    final params = <String, String>{
      'per_page': perPage.toString(),
      'page': page.toString(),
      if (storeId != null) 'store_id': storeId.toString(),
      if (categoryId != null) 'category_id': categoryId.toString(),
      if (q != null && q.isNotEmpty) 'q': q,
    };
    final query = Uri(queryParameters: params).query;
    final result = await _api.get('/products?$query', withAuth: false);
    final data = (result['data'] ?? {}) as Map<String, dynamic>;
    final list = (data['data'] as List? ?? const []);
    return list
        .whereType<Map>()
        .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<ProductModel> getProduct(int id) async {
    final result = await _api.get('/products/$id', withAuth: false);
    final data = (result['data'] ?? {}) as Map<String, dynamic>;
    return ProductModel.fromJson(data);
  }

  Future<List<CategoryModel>> getCategories({int? storeId}) async {
    final endpoint = storeId != null ? '/categories?store_id=$storeId' : '/categories';
    final result = await _api.get(endpoint, withAuth: false);
    final list = (result['data'] as List? ?? const []);
    return list
        .whereType<Map>()
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}
