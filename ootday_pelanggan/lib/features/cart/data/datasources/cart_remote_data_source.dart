import '../../../../core/services/api_service.dart';
import '../models/cart_item_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur keranjang. Tidak
/// menyimpan state apa pun -- murni pemanggilan endpoint dan parsing
/// response (lihat backend_laravel/API_CONTRACT.md).
class CartRemoteDataSource {
  final ApiService _api;
  CartRemoteDataSource(this._api);

  Future<List<CartItemModel>> getCartItems() async {
    final result = await _api.get('/cart');
    final List rawItems = result['data'] ?? [];
    return rawItems
        .map((item) => CartItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<CartItemModel> addItem({required int variantId, int quantity = 1}) async {
    final result = await _api.post('/cart', {
      'variant_id': variantId,
      'quantity': quantity,
    });
    return CartItemModel.fromJson(Map<String, dynamic>.from(result['data'] ?? {}));
  }

  Future<void> updateQuantity(String cartItemId, int quantity) {
    return _api.put('/cart/$cartItemId', {'quantity': quantity});
  }

  Future<void> updateSelection(String cartItemId, bool isSelected) {
    return _api.put('/cart/$cartItemId', {'is_selected': isSelected});
  }

  Future<void> updateSelectAll(bool isSelected) {
    return _api.post('/cart/select-all', {'is_selected': isSelected});
  }

  Future<void> deleteItem(String cartItemId) {
    return _api.delete('/cart/$cartItemId');
  }
}
