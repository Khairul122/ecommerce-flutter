import '../../../../core/usecase.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase extends UseCase<List<NotificationEntity>, NoParams> {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  @override
  Future<List<NotificationEntity>> call(NoParams params) =>
      repository.getNotifications();
}

class GetUnreadCountUseCase extends UseCase<int, NoParams> {
  final NotificationRepository repository;
  GetUnreadCountUseCase(this.repository);

  @override
  Future<int> call(NoParams params) => repository.getUnreadCount();
}

class MarkNotificationReadUseCase extends UseCase<NotificationEntity, int> {
  final NotificationRepository repository;
  MarkNotificationReadUseCase(this.repository);

  @override
  Future<NotificationEntity> call(int id) => repository.markAsRead(id);
}
