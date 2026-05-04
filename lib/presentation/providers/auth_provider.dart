import 'package:flutter/foundation.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/timetable_item.dart';
import '../../data/models/user.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthState _state = AuthState.initial;
  User? _currentUser;
  String _errorMessage = '';

  AuthState get state => _state;
  User? get currentUser => _currentUser;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  // ── Vérifier token au démarrage ────────────────────
  Future<void> checkAuth() async {
    _setState(AuthState.loading);
    final loggedIn = await _authService.isLoggedIn();
    if (loggedIn) {
      _currentUser = await _authService.getCurrentUser();
      _setState(AuthState.authenticated);
      await _scheduleNotifications(_currentUser!); // ← schedule au démarrage
    } else {
      _setState(AuthState.unauthenticated);
    }
  }

  // ── Login ──────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    _setState(AuthState.loading);
    _errorMessage = '';

    final user = await _authService.login(email, password);
    if (user != null) {
      _currentUser = user;
      _setState(AuthState.authenticated);
      await _scheduleNotifications(user); // ← schedule après login
      return true;
    } else {
      _errorMessage = 'Incorrect email or password';
      _setState(AuthState.unauthenticated);
      return false;
    }
  }

  Future<bool> loginWithBiometrics() async {
    _setState(AuthState.loading);
    final success = await _authService.authenticateWithBiometrics();
    if (success) {
      _currentUser = await _authService.getCurrentUser();
      if (_currentUser != null) {
        _setState(AuthState.authenticated);
        await _scheduleNotifications(_currentUser!); // ← schedule après biométrie
        return true;
      }
    }
    _setState(AuthState.unauthenticated);
    return false;
  }

  // ── Logout ─────────────────────────────────────────
  Future<void> logout() async {
    await _authService.logout();
    await NotificationService().cancelAll(); // ← annule tout au logout
    _currentUser = null;
    _setState(AuthState.unauthenticated);
  }

  // ── Schedule notifications du jour ─────────────────
  Future<void> _scheduleNotifications(User user) async {
    print('🔔 [AUTH] Starting notification scheduling...');

    final timetable = TimetableItem.getSampleTimetable(
      group: user.group,
      specialty: user.specialty,
    );
    final now = DateTime.now();

    print('🔔 [AUTH] Now: $now, Weekday: ${now.weekday}');
    print('🔔 [AUTH] User: ${user.name}, Group: ${user.group}, Specialty: ${user.specialty}');
    print('🔔 [AUTH] Total courses: ${timetable.length}');

    await NotificationService().cancelAll();
    int count = 0;

    for (final item in timetable) {
      final itemDay = item.day.index + 1;
      print('🔔 [AUTH] Checking: ${item.subject}, day: $itemDay, start: ${item.startTime}');

      if (itemDay != now.weekday) {
        print('🔔 [AUTH] Skipped: wrong day');
        continue;
      }

      final parts = item.startTime.split(':');
      final classTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      final reminderTime = classTime.subtract(const Duration(minutes: 10));
      print('🔔 [AUTH] ClassTime: $classTime, Reminder: $reminderTime');

      if (reminderTime.isAfter(now)) {
        print('🔔 [AUTH] Scheduling: ${item.subject}');
        await NotificationService().scheduleClassReminder(
          id: item.id,
          subject: item.subject,
          room: item.room,
          classTime: classTime,
        );
        count++;
      } else {
        print('🔔 [AUTH] Skipped: already passed');
      }
    }

    print('✅ [AUTH] Total scheduled: $count');


    await NotificationService().getPendingNotifications();
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}