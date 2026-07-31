import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

/// Implementasi [CartRepository]: murni delegasi ke [CartRemoteDataSource],
/// tidak ada cache lokal (server adalah satu-satunya sumber kebenaran untuk
/// keranjang).
class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remote;

  CartRepositoryImpl({required this.remote});

  @override
  Future<List<CartItemEntity>> getCartItems() => remote.getCartItems();

  @override
  Future<CartItemEntity> addItem({required int variantId, int quantity = 1}) {
    return remote.addItem(variantId: variantId, quantity: quantity);
  }

  @override
  Future<String> buyNow({required int variantId, int quantity = 1}) async {
    final created = await remote.addItem(variantId: variantId, quantity: quantity);
    final newId = created.id;
    await remote.updateSelectAll(false);
    await remote.updateSelection(newId, true);
    return newId;
  }

  @override
  Future<void> updateQuantity(String cartItemId, int quantity) {
    return remote.updateQuantity(cartItemId, quantity);
  }

  @override
  Future<void> updateSelection(String cartItemId, bool isSelected) {
    return remote.updateSelection(cartItemId, isSelected);
  }

  @override
  Future<void> updateSelectAll(bool isSelected) {
    return remote.updateSelectAll(isSelected);
  }

  @override
  Future<void> deleteItem(String cartItemId) {
    return remote.deleteItem(cartItemId);
  }
}
