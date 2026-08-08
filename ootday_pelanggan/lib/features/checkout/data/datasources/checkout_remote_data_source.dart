import '../../../../core/services/api_service.dart';
import '../../../order/data/models/order_model.dart';
import '../models/payment_method_model.dart';
import '../models/rajaongkir_cost_model.dart';
import '../models/shipping_method_model.dart';

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

  Future<List<RajaOngkirCourierModel>> checkShippingCost({
    required int destinationCityId,
    required int totalWeightGram,
    required String courier,
  }) async {
    final result = await _api.post('/shipping/cost', {
      'destination': destinationCityId,
      'weight': totalWeightGram,
      'courier': courier,
    });
    final List raw = result['data'] ?? [];
    return raw
        .map((e) => RajaOngkirCourierModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<OrderModel> createOrder({
    required String addressId,
    int? shippingMethodId,
    required int paymentMethodId,
    String? shippingCourier,
    String? shippingService,
    int? shippingCost,
    String? shippingEtd,
  }) async {
    final result = await _api.post('/orders', {
      'address_id': int.tryParse(addressId) ?? addressId,
      if (shippingMethodId != null) 'shipping_method_id': shippingMethodId,
      'payment_method_id': paymentMethodId,
      if (shippingCourier != null) 'shipping_courier': shippingCourier,
      if (shippingService != null) 'shipping_service': shippingService,
      if (shippingCost != null) 'shipping_cost': shippingCost,
      if (shippingEtd != null) 'shipping_etd': shippingEtd,
    });
    return OrderModel.fromJson(Map<String, dynamic>.from(result['data'] ?? {}));
  }
}
