import 'package:flutter/material.dart';
import '../../data/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _currentUser = const User(
    email: 'student@unisy.dz',
    name: 'Student',
    studentId: '20240001',
    group: '1',
    specialty: 'Computer Science',
    section: 'A',
    year: 3,
  );

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
