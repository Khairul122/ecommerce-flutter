import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/rajaongkir_cost_entity.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remote;

  CheckoutRepositoryImpl({required this.remote});

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() => remote.getPaymentMethods();

  @override
  Future<List<ShippingMethodEntity>> getShippingCost(String addressId) => remote.getShippingCost(addressId);

  @override
  Future<List<RajaOngkirCourierEntity>> checkShippingCost({
    required int destinationCityId,
    required int totalWeightGram,
    required String courier,
  }) {
    return remote.checkShippingCost(
      destinationCityId: destinationCityId,
      totalWeightGram: totalWeightGram,
      courier: courier,
    );
  }

  @override
  Future<OrderEntity> createOrder({
    required String addressId,
    int? shippingMethodId,
    required int paymentMethodId,
    String? shippingCourier,
    String? shippingService,
    int? shippingCost,
    String? shippingEtd,
  }) {
    return remote.createOrder(
      addressId: addressId,
      shippingMethodId: shippingMethodId,
      paymentMethodId: paymentMethodId,
      shippingCourier: shippingCourier,
      shippingService: shippingService,
      shippingCost: shippingCost,
      shippingEtd: shippingEtd,
    );
  }
}
