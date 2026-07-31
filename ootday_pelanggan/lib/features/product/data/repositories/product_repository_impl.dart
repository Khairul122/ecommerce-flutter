import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

/// Implementasi [ProductRepository]: murni delegasi ke remote data source
/// (REST API), tidak ada state/cache — katalog selalu diambil segar.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remote;

  ProductRepositoryImpl({required this.remote});

  @override
  Future<List<ProductEntity>> getProducts({
    int? storeId,
    int? categoryId,
    String? q,
    int perPage = 20,
    int page = 1,
  }) {
    return remote.getProducts(
      storeId: storeId,
      categoryId: categoryId,
      q: q,
      perPage: perPage,
      page: page,
    );
  }

  @override
  Future<ProductEntity> getProduct(int id) => remote.getProduct(id);

  @override
  Future<List<CategoryEntity>> getCategories({int? storeId}) =>
      remote.getCategories(storeId: storeId);
}
