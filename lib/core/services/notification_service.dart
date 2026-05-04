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

    print('🔔 [NOTIF] Timezone initialized: ${tz.local}');

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
        importance: Importance.max,
      ),
    );

    _initialized = true;
    print('🔔 [NOTIF] Initialized successfully');
  }

  void _onNotificationTap(NotificationResponse response) {
    print('🔔 [NOTIF] Tapped! Payload: ${response.payload}');
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
    final now = DateTime.now();
    final reminderTime = classTime.subtract(const Duration(minutes: 10));

    print('🔔 [NOTIF] Now: $now');
    print('🔔 [NOTIF] Class time: $classTime');
    print('🔔 [NOTIF] Reminder time: $reminderTime');

    // Don't schedule if already passed
    if (reminderTime.isBefore(now)) {
      print('🔔 [NOTIF] SKIPPED: reminder time already passed');
      return;
    }

    // CORRECTION CRUCIALE : Utiliser TZDateTime.local() au lieu de TZDateTime.from()
    final tzDateTime = tz.TZDateTime.local(
      reminderTime.year,
      reminderTime.month,
      reminderTime.day,
      reminderTime.hour,
      reminderTime.minute,
      reminderTime.second,
    );

    print('🔔 [NOTIF] TZDateTime scheduled: $tzDateTime');

    try {
      await _plugin.zonedSchedule(
        id,
        '📚 Class Starting Soon',
        '$subject in $room starts in 10 minutes',
        tzDateTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'class_reminders',
            'Class Reminders',
            channelDescription: 'Reminders before your classes',
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
            largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
            styleInformation: BigTextStyleInformation(
              '$subject in $room starts in 10 minutes\nDon\'t be late!',
              contentTitle: '📚 Class Starting Soon',
              summaryText: 'UniSy Reminder',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'timetable',
      );
      print('✅ [NOTIF] SCHEDULED SUCCESS: $subject at $tzDateTime');
    } catch (e) {
      print('❌ [NOTIF] SCHEDULE ERROR: $e');
    }
  }

  /// Test notification (fires immediately)
  Future<void> showTestNotification() async {
    print('🔔 [NOTIF] Showing test notification...');
    await _plugin.show(
      999,
      '🔔 UniSy Test',
      'This is a test notification from UniSy!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'class_reminders',
          'Class Reminders',
          importance: Importance.max,
          priority: Priority.max,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: 'timetable',
    );
    print('✅ [NOTIF] Test notification shown');
  }

  /// Cancel all notifications
  Future<void> cancelAll() async {
    print('🔔 [NOTIF] Cancelling all notifications');
    await _plugin.cancelAll();
  }

  /// Cancel specific notification
  Future<void> cancel(int id) async {
    await _plugin.cancel(id);
  }

  /// Schedule all reminders for today
  Future<void> scheduleAllTodayReminders({
    required List<TimetableItem> timetable,
  }) async {
    print('🔔 [NOTIF] Scheduling all today reminders...');
    await cancelAll();
    final now = DateTime.now();
    int count = 0;

    for (final item in timetable) {
      final itemDay = item.day.index + 1;
      if (itemDay != now.weekday) continue;

      final parts = item.startTime.split(':');
      final classTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final reminderTime = classTime.subtract(const Duration(minutes: 10));

      if (reminderTime.isAfter(now)) {
        await scheduleClassReminder(
          id: item.id,
          subject: item.subject,
          room: item.room,
          classTime: classTime,
        );
        count++;
      } else {
        print('🔔 [NOTIF] Skipped (passed): ${item.subject} at ${item.startTime}');
      }
    }

    print('✅ [NOTIF] Total scheduled today: $count');
  }

  /// DEBUG: Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    final pending = await _plugin.pendingNotificationRequests();
    print('🔔 [NOTIF] Pending notifications: ${pending.length}');
    for (final p in pending) {
      print('🔔 [NOTIF] Pending: id=${p.id}, title=${p.title}, body=${p.body}');
    }
    return pending;
  }

  /// TEST: Schedule notification in X seconds (for demo)
  Future<void> scheduleTestInSeconds(int seconds) async {
    final now = DateTime.now();
    final classTime = now.add(Duration(seconds: seconds + 10));

    print('🔔 [NOTIF] TEST: Scheduling for $seconds seconds from now');

    await scheduleClassReminder(
      id: 88888,
      subject: 'TEST CLASS',
      room: 'Test Room',
      classTime: classTime,
    );
  }
}