import '../../../../core/services/api_service.dart';
import '../models/notification_model.dart';

/// Sumber data remote (REST API Laravel) untuk fitur notifikasi. Tidak
/// menyimpan state apa pun — murni pemanggilan endpoint dan parsing response.
class NotificationRemoteDataSource {
  final ApiService _api;
  NotificationRemoteDataSource(this._api);

  Future<List<NotificationModel>> getNotifications() async {
    final result = await _api.get('/notifications');
    final List raw = result['data'] ?? [];
    return raw
        .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> getUnreadCount() async {
    final result = await _api.get('/notifications/unread-count');
    final data = Map<String, dynamic>.from(result['data'] ?? {});
    return data['count'] is int
        ? data['count'] as int
        : int.tryParse(data['count']?.toString() ?? '') ?? 0;
  }

  Future<NotificationModel> markAsRead(int id) async {
    final result = await _api.post('/notifications/$id/read', {});
    final data = Map<String, dynamic>.from(result['data'] ?? {});
    return NotificationModel.fromJson(data);
  }
}
