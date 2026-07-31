import '../../../../core/services/api_service.dart';
import '../models/order_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur pesanan. Tidak
/// menyimpan state apa pun — murni pemanggilan endpoint dan parsing response.
class OrderRemoteDataSource {
  final ApiService _api;
  OrderRemoteDataSource(this._api);

  /// status: menunggu_pembayaran | diproses | dikirim | selesai | dibatalkan
  /// Kosongkan/biarkan null untuk mengambil semua status.
  Future<List<OrderModel>> getOrders({String? status}) async {
    final query = (status != null && status.isNotEmpty) ? '?status=$status' : '';
    final result = await _api.get('/orders$query');
    final List rawList = result['data'] ?? [];
    return rawList
        .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<OrderModel> getOrder(String orderId) async {
    final result = await _api.get('/orders/$orderId');
    return OrderModel.fromJson(Map<String, dynamic>.from(result['data'] ?? {}));
  }

  Future<OrderModel> confirmPayment(String orderId, {String? paymentProofUrl}) async {
    final result = await _api.post('/orders/$orderId/confirm-payment', {
      if (paymentProofUrl != null) 'payment_proof_url': paymentProofUrl,
    });
    return OrderModel.fromJson(Map<String, dynamic>.from(result['data'] ?? {}));
  }

  Future<OrderModel> cancelOrder(String orderId, {String? reason}) async {
    final result = await _api.post('/orders/$orderId/cancel', {
      if (reason != null) 'reason': reason,
    });
    return OrderModel.fromJson(Map<String, dynamic>.from(result['data'] ?? {}));
  }
}
