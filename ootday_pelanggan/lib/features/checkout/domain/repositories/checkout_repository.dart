import '../../../order/domain/entities/order_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/rajaongkir_cost_entity.dart';
import '../entities/shipping_method_entity.dart';

abstract class CheckoutRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  Future<List<ShippingMethodEntity>> getShippingCost(String addressId);

  Future<List<RajaOngkirCourierEntity>> checkShippingCost({
    required int destinationCityId,
    required int totalWeightGram,
    required String courier,
  });

  Future<OrderEntity> createOrder({
    required String addressId,
    int? shippingMethodId,
    required int paymentMethodId,
    String? shippingCourier,
    String? shippingService,
    int? shippingCost,
    String? shippingEtd,
  });
}
