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

class GetShippingMethodsUseCase extends UseCase<List<ShippingMethodEntity>, NoParams> {
  final CheckoutRepository repository;
  GetShippingMethodsUseCase(this.repository);

  @override
  Future<List<ShippingMethodEntity>> call(NoParams params) =>
      repository.getShippingMethods();
}

class CreateOrderParams {
  final String addressId;
  final int shippingMethodId;
  final int paymentMethodId;
  const CreateOrderParams({
    required this.addressId,
    required this.shippingMethodId,
    required this.paymentMethodId,
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
      );
}
