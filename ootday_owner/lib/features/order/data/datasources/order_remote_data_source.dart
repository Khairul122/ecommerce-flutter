import '../../../../core/services/api_service.dart';
import '../models/order_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur manajemen pesanan owner.
class OrderRemoteDataSource {
  final ApiService _api;
  OrderRemoteDataSource(this._api);

  Future<List<OrderModel>> getOrders({String? status}) async {
    final query = (status != null && status.isNotEmpty) ? '?status=$status' : '';
    final res = await _api.get('/owner/orders$query');
    final data = res['data'] as List<dynamic>? ?? [];
    return data.cast<Map<String, dynamic>>().map(OrderModel.fromJson).toList();
  }

  Future<OrderModel> getOrder(int id) async {
    final res = await _api.get('/owner/orders/$id');
    return OrderModel.fromJson(res['data'] as Map<String, dynamic>);
  }

  Future<void> updateStatus(
    int id, {
    required String status,
    String? cancelReason,
    String? trackingNumber,
  }) {
    return _api.put('/owner/orders/$id/status', {
      'status': status,
      if (cancelReason != null && cancelReason.isNotEmpty) 'cancel_reason': cancelReason,
      if (trackingNumber != null && trackingNumber.isNotEmpty) 'tracking_number': trackingNumber,
    });
  }

  Future<void> confirmPayment(int id) {
    return _api.post('/owner/orders/$id/confirm-payment', {});
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _api.get('/owner/stats');
    return res['data'] as Map<String, dynamic>? ?? {};
  }
}
