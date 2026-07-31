import '../../../../core/usecase.dart';
import '../entities/cart_item_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartItemsUseCase extends UseCase<List<CartItemEntity>, NoParams> {
  final CartRepository repository;
  GetCartItemsUseCase(this.repository);

  @override
  Future<List<CartItemEntity>> call(NoParams params) => repository.getCartItems();
}

class AddToCartParams {
  final int variantId;
  final int quantity;
  const AddToCartParams({required this.variantId, this.quantity = 1});
}

class AddToCartUseCase extends UseCase<CartItemEntity, AddToCartParams> {
  final CartRepository repository;
  AddToCartUseCase(this.repository);

  @override
  Future<CartItemEntity> call(AddToCartParams params) =>
      repository.addItem(variantId: params.variantId, quantity: params.quantity);
}

class BuyNowParams {
  final int variantId;
  final int quantity;
  const BuyNowParams({required this.variantId, this.quantity = 1});
}

class BuyNowUseCase extends UseCase<String, BuyNowParams> {
  final CartRepository repository;
  BuyNowUseCase(this.repository);

  @override
  Future<String> call(BuyNowParams params) =>
      repository.buyNow(variantId: params.variantId, quantity: params.quantity);
}

class UpdateQuantityParams {
  final String cartItemId;
  final int quantity;
  const UpdateQuantityParams({required this.cartItemId, required this.quantity});
}

class UpdateQuantityUseCase extends UseCase<void, UpdateQuantityParams> {
  final CartRepository repository;
  UpdateQuantityUseCase(this.repository);

  @override
  Future<void> call(UpdateQuantityParams params) =>
      repository.updateQuantity(params.cartItemId, params.quantity);
}

class UpdateSelectionParams {
  final String cartItemId;
  final bool isSelected;
  const UpdateSelectionParams({required this.cartItemId, required this.isSelected});
}

class UpdateSelectionUseCase extends UseCase<void, UpdateSelectionParams> {
  final CartRepository repository;
  UpdateSelectionUseCase(this.repository);

  @override
  Future<void> call(UpdateSelectionParams params) =>
      repository.updateSelection(params.cartItemId, params.isSelected);
}

class UpdateSelectAllUseCase extends UseCase<void, bool> {
  final CartRepository repository;
  UpdateSelectAllUseCase(this.repository);

  @override
  Future<void> call(bool isSelected) => repository.updateSelectAll(isSelected);
}

class DeleteCartItemUseCase extends UseCase<void, String> {
  final CartRepository repository;
  DeleteCartItemUseCase(this.repository);

  @override
  Future<void> call(String cartItemId) => repository.deleteItem(cartItemId);
}
