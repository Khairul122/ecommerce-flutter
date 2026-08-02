import 'dart:io';

import '../../../../core/usecase.dart';
import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetMyProductsUseCase extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;
  GetMyProductsUseCase(this.repository);

  @override
  Future<List<ProductEntity>> call(NoParams params) =>
      repository.getMyProducts();
}

class AddProductParams {
  final String name;
  final int? categoryId;
  final double price;
  final int stock;
  final String description;
  final String? imageUrl;
  final List<String> sizes;
  final Map<String, String>? variantImageUrls;

  const AddProductParams({
    required this.name,
    this.categoryId,
    required this.price,
    required this.stock,
    required this.description,
    this.imageUrl,
    this.sizes = const ['S', 'M', 'L', 'XL'],
    this.variantImageUrls,
  });
}

class AddProductUseCase extends UseCase<ProductEntity, AddProductParams> {
  final ProductRepository repository;
  AddProductUseCase(this.repository);

  @override
  Future<ProductEntity> call(AddProductParams params) => repository.addProduct(
        name: params.name,
        categoryId: params.categoryId,
        price: params.price,
        stock: params.stock,
        description: params.description,
        imageUrl: params.imageUrl,
        sizes: params.sizes,
        variantImageUrls: params.variantImageUrls,
      );
}

class UpdateProductParams {
  final int productId;
  final Map<String, dynamic> fields;
  const UpdateProductParams({required this.productId, required this.fields});
}

class UpdateProductUseCase extends UseCase<ProductEntity, UpdateProductParams> {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  @override
  Future<ProductEntity> call(UpdateProductParams params) =>
      repository.updateProduct(params.productId, params.fields);
}

class DeleteProductUseCase extends UseCase<void, int> {
  final ProductRepository repository;
  DeleteProductUseCase(this.repository);

  @override
  Future<void> call(int productId) => repository.deleteProduct(productId);
}

class GetCategoriesUseCase extends UseCase<List<CategoryEntity>, int?> {
  final ProductRepository repository;
  GetCategoriesUseCase(this.repository);

  @override
  Future<List<CategoryEntity>> call(int? storeId) =>
      repository.getCategories(storeId);
}

class AddCategoryUseCase extends UseCase<CategoryEntity, String> {
  final ProductRepository repository;
  AddCategoryUseCase(this.repository);

  @override
  Future<CategoryEntity> call(String name) => repository.addCategory(name);
}

class UpdateCategoryParams {
  final int categoryId;
  final String name;
  const UpdateCategoryParams({required this.categoryId, required this.name});
}

class UpdateCategoryUseCase
    extends UseCase<CategoryEntity, UpdateCategoryParams> {
  final ProductRepository repository;
  UpdateCategoryUseCase(this.repository);

  @override
  Future<CategoryEntity> call(UpdateCategoryParams params) =>
      repository.updateCategory(params.categoryId, params.name);
}

class DeleteCategoryUseCase extends UseCase<void, int> {
  final ProductRepository repository;
  DeleteCategoryUseCase(this.repository);

  @override
  Future<void> call(int categoryId) => repository.deleteCategory(categoryId);
}

class UploadProductImageUseCase extends UseCase<String, File> {
  final ProductRepository repository;
  UploadProductImageUseCase(this.repository);

  @override
  Future<String> call(File file) => repository.uploadImage(file);
}
