import '../../../order/domain/entities/order_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/shipping_method_entity.dart';
import '../../domain/repositories/checkout_repository.dart';
import '../datasources/checkout_remote_data_source.dart';

/// Implementasi [CheckoutRepository]: murni delegasi ke remote data source
/// (REST API). Tidak ada cache lokal.
class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remote;

  CheckoutRepositoryImpl({required this.remote});

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() => remote.getPaymentMethods();

  @override
  Future<List<ShippingMethodEntity>> getShippingMethods() => remote.getShippingMethods();

  @override
  Future<OrderEntity> createOrder({
    required String addressId,
    required int shippingMethodId,
    required int paymentMethodId,
  }) {
    return remote.createOrder(
      addressId: addressId,
      shippingMethodId: shippingMethodId,
      paymentMethodId: paymentMethodId,
    );
  }
}
