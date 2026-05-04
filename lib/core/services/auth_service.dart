import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../data/models/user.dart';
import 'package:local_auth/local_auth.dart';


class AuthService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const String _keyToken = 'auth_token';
  static const String _keyEmail = 'user_email';
  static const String _keyName = 'user_name';
  static const String _keyStudentId = 'user_student_id';
  static const String _keySpecialty = 'user_specialty';
  static const String _keySection = 'user_section';
  static const String _keyGroup = 'user_group';
  static const String _keyYear = 'user_year';

  Future<User?> login(String email, String password) async {
    final userMap = kUsers.firstWhere(
          (u) =>
      u['email'] == email.trim().toLowerCase() &&
          u['password'] == password.trim(),
      orElse: () => {},
    );

    if (userMap.isEmpty) return null;

    final token = 'unisy_token_${userMap['id']}';
    await _storage.write(key: _keyToken, value: token);
    await _storage.write(key: _keyEmail, value: userMap['email']!);
    await _storage.write(key: _keyName, value: userMap['name']!);
    await _storage.write(key: _keyStudentId, value: userMap['id']!);
    await _storage.write(key: _keySpecialty, value: userMap['specialty']!);
    await _storage.write(key: _keySection, value: userMap['section']!);
    await _storage.write(key: _keyGroup, value: userMap['group']!);
    await _storage.write(key: _keyYear, value: userMap['year']!);

    return User(
      email: userMap['email']!,
      name: userMap['name']!,
      studentId: userMap['id']!,
      specialty: userMap['specialty']!,
      section: userMap['section']!,
      group: userMap['group']!,
      year: int.tryParse(userMap['year']!) ?? 1,
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: _keyToken);
  }

  Future<bool> isLoggedIn() async {
    try {
      final token = await _storage.read(key: _keyToken);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final email = await _storage.read(key: _keyEmail);
      if (email == null) return null;
      return User(
        email: email,
        name: await _storage.read(key: _keyName) ?? '',
        studentId: await _storage.read(key: _keyStudentId) ?? '',
        specialty: await _storage.read(key: _keySpecialty) ?? '',
        section: await _storage.read(key: _keySection) ?? '',
        group: await _storage.read(key: _keyGroup) ?? '',
        year: int.tryParse(
          await _storage.read(key: _keyYear) ?? '1',
        ) ?? 1,
      );
    } catch (e) {
      return null;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    final auth = LocalAuthentication();
    try {
      final canCheck = await auth.canCheckBiometrics;
      print('canCheckBiometrics: $canCheck');

      final availableBiometrics = await auth.getAvailableBiometrics();
      print('availableBiometrics: $availableBiometrics');

      final user = await getCurrentUser();
      print('currentUser in storage: ${user?.email}');

      if (!canCheck) return false;

      final result = await auth.authenticate(
        localizedReason: 'Unlock UniSy with biometrics',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
      print('auth result: $result');
      return result;
    } catch (e) {
      print('biometric error: $e');
      return false;
    }
  }
}