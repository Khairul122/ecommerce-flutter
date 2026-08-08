import 'package:flutter/foundation.dart';
import '../../../../core/services/api_service.dart';

class WishlistProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Map<String, dynamic>> _wishlistProducts = [];
  Set<int> _wishlistProductIds = {};
  bool _isLoading = false;

  WishlistProvider(this._apiService);

  List<Map<String, dynamic>> get wishlistProducts => _wishlistProducts;
  Set<int> get wishlistProductIds => _wishlistProductIds;
  bool get isLoading => _isLoading;

  bool isWishlist(int productId) => _wishlistProductIds.contains(productId);

  Future<void> fetchWishlist() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.get('/wishlist');
      if (response != null && response['success'] == true) {
        final List items = response['data'] ?? [];
        _wishlistProducts = items.map((e) => Map<String, dynamic>.from(e)).toList();
        _wishlistProductIds = _wishlistProducts
            .map((e) => int.tryParse(e['id'].toString()) ?? 0)
            .where((id) => id > 0)
            .toSet();
      }
    } catch (e) {
      debugPrint('Error fetching wishlist: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleWishlist(Map<String, dynamic> product) async {
    final productId = int.tryParse(product['id'].toString()) ?? 0;
    if (productId == 0) return false;

    final wasInWishlist = _wishlistProductIds.contains(productId);
    if (wasInWishlist) {
      _wishlistProductIds.remove(productId);
      _wishlistProducts.removeWhere((p) => (int.tryParse(p['id'].toString()) ?? 0) == productId);
    } else {
      _wishlistProductIds.add(productId);
      _wishlistProducts.insert(0, product);
    }
    notifyListeners();

    try {
      final response = await _apiService.post('/wishlist/toggle/$productId', {});
      if (response != null && response['success'] == true) {
        return response['is_wishlist'] ?? !wasInWishlist;
      }
    } catch (e) {
      debugPrint('Error toggling wishlist: $e');
      // Revert if error
      if (wasInWishlist) {
        _wishlistProductIds.add(productId);
        _wishlistProducts.add(product);
      } else {
        _wishlistProductIds.remove(productId);
        _wishlistProducts.removeWhere((p) => (int.tryParse(p['id'].toString()) ?? 0) == productId);
      }
      notifyListeners();
    }
    return !wasInWishlist;
  }
}
