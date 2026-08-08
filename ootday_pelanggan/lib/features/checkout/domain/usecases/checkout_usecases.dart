import '../../../../core/usecase.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/shipping_method_entity.dart';
import '../repositories/checkout_repository.dart';

class GetPaymentMethodsUseCase extends UseCase<List<PaymentMethodEntity>, NoParams> {
  final CheckoutRepository repository;
  GetPaymentMethodsUseCase(this.repository);

  @override
  Future<List<PaymentMethodEntity>> call(NoParams params) =>
      repository.getPaymentMethods();
}

class GetShippingCostUseCase extends UseCase<List<ShippingMethodEntity>, String> {
  final CheckoutRepository repository;
  GetShippingCostUseCase(this.repository);

  @override
  Future<List<ShippingMethodEntity>> call(String addressId) => repository.getShippingCost(addressId);
}

class CreateOrderParams {
  final String addressId;
  final int shippingMethodId;
  final int paymentMethodId;
  final num? shippingCost;
  final String? shippingService;
  const CreateOrderParams({
    required this.addressId,
    required this.shippingMethodId,
    required this.paymentMethodId,
    this.shippingCost,
    this.shippingService,
  });
}

class CreateOrderUseCase extends UseCase<OrderEntity, CreateOrderParams> {
  final CheckoutRepository repository;
  CreateOrderUseCase(this.repository);

  @override
  Future<OrderEntity> call(CreateOrderParams params) => repository.createOrder(
        addressId: params.addressId,
        shippingMethodId: params.shippingMethodId,
        paymentMethodId: params.paymentMethodId,
        shippingCost: params.shippingCost,
        shippingService: params.shippingService,
      );
}
