import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Pop-up notifikasi lokal (bukan push) — hanya muncul selagi app berjalan.
/// Dipicu oleh polling di [NotificationProvider], bukan server push, jadi
/// tidak butuh Firebase/FCM.
class LocalNotificationService {
  static final LocalNotificationService _instance = LocalNotificationService._();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> show({required int id, required String title, required String body}) async {
    if (!_initialized) await init();

    const androidDetails = AndroidNotificationDetails(
      'ootday_notifications',
      'Notifikasi Ootday',
      channelDescription: 'Notifikasi pesanan dan chat',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails, iOS: iosDetails),
    );
  }
}
