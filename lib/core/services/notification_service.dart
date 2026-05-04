import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../../data/models/timetable_item.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Algiers'));
    const AndroidInitializationSettings android =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: android,
        iOS: ios,
      ),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'class_reminders',
        'Class Reminders',
        description: 'Reminders before your classes',
        importance: Importance.high,
      ),
    );

    _initialized = true;
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == 'timetable') {
      navigatorKey.currentState?.pushNamed('/timetable');
    }
  }

  /// Schedule a notification 10 minutes before class time
  Future<void> scheduleClassReminder({
    required int id,
    required String subject,
    required String room,
    required DateTime classTime,
  }) async {
    final reminderTime = classTime.subtract(const Duration(minutes: 10));

    // Don't schedule if already passed
    if (reminderTime.isBefore(DateTime.now())) return;

    final tzDateTime = tz.TZDateTime.from(reminderTime, tz.getLocation('Africa/Algiers'));

    await _plugin.zonedSchedule(
      id,
      'Class Starting Soon',
      '$subject in $room starts in 10 minutes',
      tzDateTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminders',
          'Class Reminders',
          channelDescription: 'Reminders before your classes',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: const BigTextStyleInformation(
            '',
            contentTitle: 'Class Starting Soon',
            summaryText: 'UniSy Reminder',
          ),
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
      payload: 'timetable',
    );
  }

  /// Test notification (fires in 5 seconds)
  Future<void> showTestNotification() async {
    await _plugin.show(
      999,
      'Notification',
      'This is from UniSy! Tap to open Timetable.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminders',
          'Class Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'timetable',
    );
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> scheduleAllTodayReminders({
    required List<TimetableItem> timetable,
  }) async {
    await cancelAll();
    final now = DateTime.now();

    for (final item in timetable) {
      final itemDay = item.day.index + 1;
      if (itemDay != now.weekday) continue;

      final parts = item.startTime.split(':');
      final classTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]), int.parse(parts[1]),
      );

      if (classTime.subtract(const Duration(minutes: 10)).isAfter(now)) {
        await scheduleClassReminder(
          id: item.id,
          subject: item.subject,
          room: item.room,
          classTime: classTime,
        );
      }
    }
  }
}