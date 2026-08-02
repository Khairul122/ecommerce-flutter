import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/notification_usecases.dart';

/// State notifikasi, dibaca lewat `context.watch<NotificationProvider>()` /
/// `context.read<NotificationProvider>()`.
class NotificationProvider extends ChangeNotifier {
  final GetNotificationsUseCase getNotificationsUseCase;
  final GetUnreadCountUseCase getUnreadCountUseCase;
  final MarkNotificationReadUseCase markNotificationReadUseCase;

  NotificationProvider({
    required this.getNotificationsUseCase,
    required this.getUnreadCountUseCase,
    required this.markNotificationReadUseCase,
  });

  List<NotificationEntity> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = false;
  String? _error;

  List<NotificationEntity> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadNotifications() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notifications = await getNotificationsUseCase(const NoParams());
      _unreadCount = await getUnreadCountUseCase(const NoParams());
    } catch (e) {
      _error = 'Gagal memuat notifikasi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _notifications[index].isRead) return;

    final updated = NotificationEntity(
      id: _notifications[index].id,
      title: _notifications[index].title,
      body: _notifications[index].body,
      type: _notifications[index].type,
      relatedId: _notifications[index].relatedId,
      isRead: true,
      createdAt: _notifications[index].createdAt,
    );
    _notifications = [
      ..._notifications.sublist(0, index),
      updated,
      ..._notifications.sublist(index + 1),
    ];
    if (_unreadCount > 0) _unreadCount -= 1;
    notifyListeners();

    try {
      await markNotificationReadUseCase(id);
    } catch (_) {
      // Optimistic update dibiarkan meski gagal — refresh berikutnya akan sinkron ulang.
    }
  }
}
