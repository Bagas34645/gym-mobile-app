import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../modules/chat/controllers/chat_controller.dart';
import '../../routes/app_routes.dart';

/// Shows OS local notifications for chat and admin broadcasts.
class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  static const _channelId = 'gym_notifications';
  static const _channelName = 'Notifikasi Gym';
  static const _channelDesc = 'Chat dan pengumuman dari admin';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;
  int _notificationId = 1000;

  Future<void> init() async {
    if (_ready) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      ),
      onDidReceiveNotificationResponse: _onTap,
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );

    await Permission.notification.request();
    _ready = true;
  }

  Future<void> show({
    required String title,
    required String body,
    required String payload,
  }) async {
    if (!_ready) {
      await init();
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      id: _notificationId++,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  /// Payload format: `chat` | `chat:<conversationId>` | `inbox` | `notification:<id>`
  void _onTap(NotificationResponse response) {
    final payload = response.payload ?? 'inbox';
    Future.microtask(() => openPayload(payload));
  }

  static Future<void> openPayload(String payload) async {
    if (payload.startsWith('chat')) {
      try {
        await ChatController.openFromMenu();
      } catch (_) {
        Get.toNamed(Routes.CHAT_DETAIL);
      }
      return;
    }

    if (Get.currentRoute != Routes.NOTIFICATION) {
      Get.toNamed(Routes.NOTIFICATION);
    }
  }
}
