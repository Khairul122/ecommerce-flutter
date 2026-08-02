import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remote;
  NotificationRepositoryImpl({required this.remote});

  @override
  Future<List<NotificationEntity>> getNotifications() => remote.getNotifications();

  @override
  Future<int> getUnreadCount() => remote.getUnreadCount();

  @override
  Future<NotificationEntity> markAsRead(int id) => remote.markAsRead(id);
}
