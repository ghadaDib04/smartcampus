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
    final timetable = TimetableItem.getSampleTimetable(
      group: user.group,
      specialty: user.specialty,
    );
    final now = DateTime.now();
    await NotificationService().cancelAll();
    for (final item in timetable) {
      if (item.day.index + 1 != now.weekday) continue;
      final parts = item.startTime.split(':');
      final classTime = DateTime(
        now.year, now.month, now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );
      if (classTime.subtract(const Duration(minutes: 10)).isAfter(now)) {
        await NotificationService().scheduleClassReminder(
          id: item.id,
          subject: item.subject,
          room: item.room,
          classTime: classTime,
        );
      }
    }
  }

  void _setState(AuthState newState) {
    _state = newState;
    notifyListeners();
  }
}