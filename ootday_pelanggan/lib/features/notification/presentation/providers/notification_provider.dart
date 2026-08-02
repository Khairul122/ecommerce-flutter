import 'dart:async';

import 'package:flutter/foundation.dart';
import '../../../../core/usecase.dart';
import '../../../../core/services/local_notification_service.dart';
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
  Timer? _pollTimer;
  int? _lastSeenId;

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

  /// Polling app-wide (bukan cuma saat layar Notifikasi dibuka) supaya pop-up
  /// lokal bisa muncul di layar manapun. Aman dipanggil sebelum login — gagal
  /// diam-diam (401) sampai user login.
  void startPolling({Duration interval = const Duration(seconds: 15)}) {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(interval, (_) => _poll());
  }

  Future<void> _poll() async {
    try {
      final fresh = await getNotificationsUseCase(const NoParams());
      final unread = await getUnreadCountUseCase(const NoParams());
      if (fresh.isEmpty) return;

      final newestId = fresh.map((n) => n.id).reduce((a, b) => a > b ? a : b);

      if (_lastSeenId == null) {
        _lastSeenId = newestId;
      } else {
        for (final n in fresh) {
          if (n.id > _lastSeenId! && !n.isRead) {
            LocalNotificationService().show(id: n.id, title: n.title, body: n.body);
          }
        }
        _lastSeenId = newestId;
      }

      _notifications = fresh;
      _unreadCount = unread;
      notifyListeners();
    } catch (_) {
      // Diam-diam gagal (mis. belum login) — coba lagi tick berikutnya.
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
