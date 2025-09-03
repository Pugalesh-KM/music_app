import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize notification settings
  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();

    const settings = InitializationSettings(android: android, iOS: iOS);

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final payload = response.payload;
        // TODO: Handle notification tap here
        log('Notification tapped with payload: $payload');
      },
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    final status = await _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
    log('Notification permission status: $status');


  }

  /// Show an immediate notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    log("showNotification");
    const androidDetails = AndroidNotificationDetails(
      'main_channel',
      'Main Channel',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// Schedule a notification at a specific time
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    log("Requested to schedule notification at: $scheduledTime");

    final scheduledTZTime = tz.TZDateTime.local(
      scheduledTime.year,
      scheduledTime.month,
      scheduledTime.day,
      scheduledTime.hour,
      scheduledTime.minute,
      scheduledTime.second,
    );
    log("scheduleNotification at $scheduledTZTime");
    const androidDetails = AndroidNotificationDetails(
      'scheduled_channel',
      'Scheduled Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      scheduledTZTime,
      const NotificationDetails(android: androidDetails),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: null,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  /// Show a custom interval periodic notification
  static Future<void> showCustomPeriodicNotification({
    required int id,
    required String title,
    required String body,
    required Duration repeatInterval,
    Duration? displayDuration,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      'custom_periodic_channel',
      'Custom Periodic Notifications',
      importance: Importance.max,
      priority: Priority.high,
      timeoutAfter: displayDuration?.inMilliseconds,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _notifications.periodicallyShowWithDuration(
      id,
      title,
      body,
      repeatInterval,
      notificationDetails,
      payload: payload,
    );
  }

  /// Cancel a specific notification
  static Future<void> cancel(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
