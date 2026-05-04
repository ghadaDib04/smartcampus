import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  Future<void> initialize() async {}

  Future<void> scheduleClassReminder({
    required int id,
    required String subject,
    required String room,
    required DateTime classTime,
  }) async {}

  Future<void> showTestNotification() async {}

  Future<void> cancelAll() async {}
}
