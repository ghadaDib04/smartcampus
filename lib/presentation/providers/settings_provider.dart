import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class SettingsProvider extends ChangeNotifier {
  bool _darkMode = false;
  bool _notifications = true;

  bool get darkMode => _darkMode;
  bool get notifications => _notifications;

  Future<void> loadSettings() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool(AppConstants.keyDarkMode) ?? false;
    _notifications = prefs.getBool(AppConstants.keyNotifications) ?? true;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyDarkMode, value);
    _darkMode = value;
    notifyListeners();
  }

  Future<void> setNotifications(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyNotifications, value);
    _notifications = value;
    notifyListeners();
  }
}