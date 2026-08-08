import '../../../../core/usecase.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/rajaongkir_cost_entity.dart';
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

class CheckShippingCostParams {
  final int destinationCityId;
  final int totalWeightGram;
  final String courier;
  const CheckShippingCostParams({
    required this.destinationCityId,
    required this.totalWeightGram,
    required this.courier,
  });
}

class CheckShippingCostUseCase extends UseCase<List<RajaOngkirCourierEntity>, CheckShippingCostParams> {
  final CheckoutRepository repository;
  CheckShippingCostUseCase(this.repository);

  @override
  Future<List<RajaOngkirCourierEntity>> call(CheckShippingCostParams params) =>
      repository.checkShippingCost(
        destinationCityId: params.destinationCityId,
        totalWeightGram: params.totalWeightGram,
        courier: params.courier,
      );
}

class CreateOrderParams {
  final String addressId;
  final int? shippingMethodId;
  final int paymentMethodId;
  final String? shippingCourier;
  final String? shippingService;
  final int? shippingCost;
  final String? shippingEtd;
  const CreateOrderParams({
    required this.addressId,
    this.shippingMethodId,
    required this.paymentMethodId,
    this.shippingCourier,
    this.shippingService,
    this.shippingCost,
    this.shippingEtd,
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
        shippingCourier: params.shippingCourier,
        shippingService: params.shippingService,
        shippingCost: params.shippingCost,
        shippingEtd: params.shippingEtd,
      );
}
