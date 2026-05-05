# UniSy — Smart Campus Companion

A cross-platform mobile application built with Flutter for Android, designed as an all-in-one academic management tool for university students. UniSy operates entirely offline-first with no backend dependency, leveraging native Android OS capabilities to deliver a complete campus experience.
Features:

🔐 Secure authentication with AES-256 encrypted storage via Android Keystore, plus biometric fingerprint login through the BiometricPrompt API
📅 Personalized weekly timetable with current-day highlighting and one-tap JSON export to the device Downloads folder
📢 Campus announcements with real-time API fetching, SQLite offline caching, category filtering, and urgent flagging
🎉 Event management with runtime camera integration, per-event photo capture stored in app-private sandboxed storage
📍 Live campus GPS positioning with full runtime permission state machine and QR code location sharing
🔔 Local class reminders using Android AlarmManager — fires even in Doze mode, with deep-link navigation on tap
🌙 Light/Dark theme toggle persisted via SharedPreferences
📡 Offline mode across all screens with transparent SQLite fallback and visual indicators

Tech Stack: Flutter 3.24 · Dart 3.5 · Provider · sqflite · FlutterSecureStorage · local_auth · geolocator · flutter_local_notifications · connectivity_plus
