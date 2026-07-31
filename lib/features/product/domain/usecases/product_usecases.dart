import '../../../../core/usecase.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProductsParams {
  final int? storeId;
  final int? categoryId;
  final String? q;
  final int perPage;
  final int page;

  const GetProductsParams({
    this.storeId,
    this.categoryId,
    this.q,
    this.perPage = 20,
    this.page = 1,
  });
}

class GetProductsUseCase extends UseCase<List<ProductEntity>, GetProductsParams> {
  final ProductRepository repository;
  GetProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(GetProductsParams params) => repository.getProducts(
        storeId: params.storeId,
        categoryId: params.categoryId,
        q: params.q,
        perPage: params.perPage,
        page: params.page,
      );
}

class GetProductUseCase extends UseCase<ProductEntity, int> {
  final ProductRepository repository;
  GetProductUseCase(this.repository);

  @override
  Future<ProductEntity> call(int id) => repository.getProduct(id);
}

class GetCategoriesParams {
  final int? storeId;
  const GetCategoriesParams({this.storeId});
}

class GetCategoriesUseCase extends UseCase<List<CategoryEntity>, GetCategoriesParams> {
  final ProductRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<List<CategoryEntity>> call(GetCategoriesParams params) =>
      repository.getCategories(storeId: params.storeId);
}
