import 'package:flutter/foundation.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/usecases/product_usecases.dart';

/// State katalog produk untuk seluruh aplikasi, dibaca lewat
/// `context.watch<ProductProvider>()` / `context.read<ProductProvider>()`.
/// Dipakai bersama oleh home, search, dan product detail screen.
class ProductProvider extends ChangeNotifier {
  final GetProductsUseCase getProductsUseCase;
  final GetProductUseCase getProductUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductProvider({
    required this.getProductsUseCase,
    required this.getProductUseCase,
    required this.getCategoriesUseCase,
  });

  List<ProductEntity> _products = [];
  bool _isLoading = false;
  String? _error;
  List<CategoryEntity> _categories = [];

  List<ProductEntity> get products => _products;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CategoryEntity> get categories => _categories;

  Future<void> fetchProducts({
    int? storeId,
    int? categoryId,
    String? q,
    int perPage = 20,
    int page = 1,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await getProductsUseCase(GetProductsParams(
        storeId: storeId,
        categoryId: categoryId,
        q: q,
        perPage: perPage,
        page: page,
      ));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ambil satu produk by id. Tidak mengubah [products]/[isLoading] supaya
  /// bisa dipanggil dari layar detail tanpa mengganggu state daftar produk.
  Future<ProductEntity?> fetchProduct(int id) async {
    try {
      return await getProductUseCase(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<void> fetchCategories({int? storeId}) async {
    try {
      _categories = await getCategoriesUseCase(GetCategoriesParams(storeId: storeId));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
