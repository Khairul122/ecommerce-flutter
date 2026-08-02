import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../../../core/usecase.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product_usecases.dart';

/// State produk & kategori owner untuk seluruh aplikasi, dibaca lewat
/// `context.watch<ProductProvider>()` / `context.read<ProductProvider>()`.
/// Menggantikan pemanggilan `ProductService()` langsung dari widget.
class ProductProvider extends ChangeNotifier {
  final GetMyProductsUseCase getMyProductsUseCase;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final UploadProductImageUseCase uploadProductImageUseCase;

  ProductProvider({
    required this.getMyProductsUseCase,
    required this.addProductUseCase,
    required this.updateProductUseCase,
    required this.deleteProductUseCase,
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.uploadProductImageUseCase,
  });

  List<ProductEntity> _products = [];
  List<CategoryEntity> _categories = [];
  bool _isLoadingProducts = false;
  bool _isLoadingCategories = false;
  String? _error;

  List<ProductEntity> get products => _products;
  List<CategoryEntity> get categories => _categories;
  bool get isLoadingProducts => _isLoadingProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  String? get error => _error;

  Future<void> loadProducts() async {
    _isLoadingProducts = true;
    _error = null;
    notifyListeners();
    try {
      _products = await getMyProductsUseCase(const NoParams());
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> loadCategories({int? storeId}) async {
    _isLoadingCategories = true;
    notifyListeners();
    try {
      _categories = await getCategoriesUseCase(storeId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<ProductEntity> addProduct({
    required String name,
    int? categoryId,
    required double price,
    required int stock,
    required String description,
    String? imageUrl,
    List<String> sizes = const ['S', 'M', 'L', 'XL'],
    Map<String, String>? variantImageUrls,
  }) async {
    final product = await addProductUseCase(AddProductParams(
      name: name,
      categoryId: categoryId,
      price: price,
      stock: stock,
      description: description,
      imageUrl: imageUrl,
      sizes: sizes,
      variantImageUrls: variantImageUrls,
    ));
    _products = [..._products, product];
    notifyListeners();
    return product;
  }

  Future<ProductEntity> updateProduct(
    int productId,
    Map<String, dynamic> fields,
  ) async {
    final updated = await updateProductUseCase(
      UpdateProductParams(productId: productId, fields: fields),
    );
    _products = [
      for (final p in _products) p.id == productId ? updated : p,
    ];
    notifyListeners();
    return updated;
  }

  Future<void> deleteProduct(int productId) async {
    await deleteProductUseCase(productId);
    _products = _products.where((p) => p.id != productId).toList();
    notifyListeners();
  }

  Future<CategoryEntity> addCategory(String name) async {
    final category = await addCategoryUseCase(name);
    _categories = [..._categories, category];
    notifyListeners();
    return category;
  }

  Future<CategoryEntity> updateCategory(int categoryId, String name) async {
    final updated = await updateCategoryUseCase(
      UpdateCategoryParams(categoryId: categoryId, name: name),
    );
    _categories = [
      for (final c in _categories) c.id == categoryId ? updated : c,
    ];
    notifyListeners();
    return updated;
  }

  Future<void> deleteCategory(int categoryId) async {
    await deleteCategoryUseCase(categoryId);
    _categories = _categories.where((c) => c.id != categoryId).toList();
    notifyListeners();
  }

  Future<String> uploadImage(File file) => uploadProductImageUseCase(file);
}
