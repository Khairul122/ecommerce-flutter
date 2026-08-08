import '../../../../core/services/api_service.dart';
import '../../../order/data/models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/shipping_method_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur checkout. Tidak
/// menyimpan state apa pun -- murni pemanggilan endpoint dan parsing
/// response. GET /payment-methods bersifat publik, POST /shipping/cost dan
/// POST /orders butuh login (token dikirim otomatis oleh ApiService kalau
/// tersedia).
class CheckoutRemoteDataSource {
  final ApiService _api;
  CheckoutRemoteDataSource(this._api);

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final result = await _api.get('/payment-methods');
    final List raw = result['data'] ?? [];
    return raw
        .map((e) => PaymentMethodModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Ongkir live per kurir aktif dari RajaOngkir, dihitung dari toko asal ke
  /// district alamat tujuan (ShippingController::cost).
  Future<List<ShippingMethodModel>> getShippingCost(String addressId) async {
    final result = await _api.post('/shipping/cost', {
      'address_id': int.tryParse(addressId) ?? addressId,
    });
    final List raw = result['data'] ?? [];
    return raw
        .map((e) => ShippingMethodModel.fromShippingCostJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Membuat pesanan baru dari item keranjang yang sedang is_selected=true di
  /// server. Mengembalikan data pesanan (termasuk id & order_code) yang
  /// dibutuhkan untuk melanjutkan ke layar instruksi pembayaran.
  Future<OrderModel> createOrder({
    required String addressId,
    required int shippingMethodId,
    required int paymentMethodId,
    num? shippingCost,
    String? shippingService,
  }) async {
    final result = await _api.post('/orders', {
      'address_id': int.tryParse(addressId) ?? addressId,
      'shipping_method_id': shippingMethodId,
      'payment_method_id': paymentMethodId,
      if (shippingCost != null) 'shipping_cost': shippingCost,
      if (shippingService != null) 'shipping_service': shippingService,
    });
    return OrderModel.fromJson(Map<String, dynamic>.from(result['data'] ?? {}));
  }
}
