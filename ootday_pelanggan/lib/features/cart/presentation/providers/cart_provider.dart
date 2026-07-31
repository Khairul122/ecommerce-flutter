import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/cart_usecases.dart';

/// State keranjang untuk seluruh aplikasi, dibaca lewat
/// `context.watch<CartProvider>()` / `context.read<CartProvider>()`.
/// Menggantikan pemanggilan `CartData` langsung dari widget di
/// `cart_screen.dart`.
class CartProvider extends ChangeNotifier {
  final GetCartItemsUseCase getCartItemsUseCase;
  final AddToCartUseCase addToCartUseCase;
  final BuyNowUseCase buyNowUseCase;
  final UpdateQuantityUseCase updateQuantityUseCase;
  final UpdateSelectionUseCase updateSelectionUseCase;
  final UpdateSelectAllUseCase updateSelectAllUseCase;
  final DeleteCartItemUseCase deleteCartItemUseCase;

  CartProvider({
    required this.getCartItemsUseCase,
    required this.addToCartUseCase,
    required this.buyNowUseCase,
    required this.updateQuantityUseCase,
    required this.updateSelectionUseCase,
    required this.updateSelectAllUseCase,
    required this.deleteCartItemUseCase,
  });

  List<CartItemEntity> _items = [];
  bool _isLoading = false;
  bool _hasError = false;

  List<CartItemEntity> get items => _items;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;

  bool get selectAll => _items.isNotEmpty && _items.every((e) => e.selected);

  int get totalPrice => _items
      .where((item) => item.selected)
      .fold(0, (sum, item) => sum + item.price * item.quantity);

  Future<void> loadCart() async {
    _isLoading = true;
    _hasError = false;
    notifyListeners();
    try {
      _items = await getCartItemsUseCase(const NoParams());
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _hasError = true;
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<CartItemEntity> addItem({required int variantId, int quantity = 1}) {
    return addToCartUseCase(AddToCartParams(variantId: variantId, quantity: quantity));
  }

  Future<String> buyNow({required int variantId, int quantity = 1}) {
    return buyNowUseCase(BuyNowParams(variantId: variantId, quantity: quantity));
  }

  Future<void> toggleSelectAll(bool isSelected) async {
    await updateSelectAllUseCase(isSelected);
    _items = _items.map((item) => item.copyWith(selected: isSelected)).toList();
    notifyListeners();
  }

  Future<void> updateSelection(String cartItemId, bool isSelected) async {
    await updateSelectionUseCase(
      UpdateSelectionParams(cartItemId: cartItemId, isSelected: isSelected),
    );
    _items = _items
        .map((item) => item.id == cartItemId ? item.copyWith(selected: isSelected) : item)
        .toList();
    notifyListeners();
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    await updateQuantityUseCase(
      UpdateQuantityParams(cartItemId: cartItemId, quantity: quantity),
    );
    _items = _items
        .map((item) => item.id == cartItemId ? item.copyWith(quantity: quantity) : item)
        .toList();
    notifyListeners();
  }

  Future<void> deleteItem(String cartItemId) async {
    await deleteCartItemUseCase(cartItemId);
    _items = _items.where((item) => item.id != cartItemId).toList();
    notifyListeners();
  }
}
