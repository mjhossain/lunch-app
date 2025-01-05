// lib/services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initializationSettings);
  }

  Future<void> showNotification({
    required String title,
    required String body,
    bool playSound = true,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'lunch_timer_channel',
      'Lunch Timer Notifications',
      channelDescription: 'Notifications for lunch timer app',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
    );

    const iosDetails = DarwinNotificationDetails(
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}