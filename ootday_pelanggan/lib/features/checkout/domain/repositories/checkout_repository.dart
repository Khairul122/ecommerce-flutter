import '../../../order/domain/entities/order_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/shipping_method_entity.dart';

/// Kontrak layer domain untuk fitur checkout: metode pembayaran/pengiriman
/// (publik, tanpa login) dan pembuatan pesanan (POST /orders, perlu login).
/// Pesanan dibuat dari item keranjang yang is_selected=true di server --
/// bukan dikirim langsung dari klien.
abstract class CheckoutRepository {
  Future<List<PaymentMethodEntity>> getPaymentMethods();

  Future<List<ShippingMethodEntity>> getShippingMethods();

  Future<OrderEntity> createOrder({
    required String addressId,
    required int shippingMethodId,
    required int paymentMethodId,
  });
}
