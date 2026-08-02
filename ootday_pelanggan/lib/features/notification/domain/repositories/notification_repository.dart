import '../entities/notification_entity.dart';

/// Kontrak layer domain untuk fitur notifikasi. Implementasinya (data layer)
/// berbicara ke REST API `/notifications` (lihat API_CONTRACT.md).
abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();

  Future<int> getUnreadCount();

  Future<NotificationEntity> markAsRead(int id);
}
