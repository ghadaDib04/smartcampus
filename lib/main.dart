import 'package:flutter/material.dart';
import 'app.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().initialize();
  runApp(const SmartCampusApp());
  // ── TESTING BYPASS — remove the 3 lines below to revert ──────
  WidgetsBinding.instance.addPostFrameCallback((_) {
    navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (_) => false);
  });
  // ─────────────────────────────────────────────────────────────
}