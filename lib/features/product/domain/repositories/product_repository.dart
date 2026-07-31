import '../entities/category_entity.dart';
import '../entities/product_entity.dart';

/// Kontrak layer domain untuk fitur produk (katalog publik, tanpa auth).
abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts({
    int? storeId,
    int? categoryId,
    String? q,
    int perPage,
    int page,
  });

  Future<ProductEntity> getProduct(int id);

  Future<List<CategoryEntity>> getCategories({int? storeId});
}
