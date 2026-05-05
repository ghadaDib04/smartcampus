# 📱 UniSy — Smart Campus Companion

> A cross-platform mobile application built with Flutter for Android, designed as an all-in-one academic management tool for university students. UniSy operates entirely **offline-first** with no backend dependency, leveraging native Android OS capabilities to deliver a complete campus experience.

---

## ✨ Features

| Feature | Description |
|--------|-------------|
| 🔐 **Secure Auth** | AES-256 encrypted credential storage via Android Keystore + biometric fingerprint login through the BiometricPrompt API |
| 📅 **Timetable** | Personalized weekly schedule with current-day highlighting and one-tap JSON export to the device Downloads folder |
| 📢 **Announcements** | Real-time API fetching with SQLite offline caching, category filtering, and urgent flagging |
| 🎉 **Events** | Campus event listing with runtime camera integration and per-event photo capture stored in sandboxed app storage |
| 📍 **Campus GPS** | Live positioning with full runtime permission state machine, coordinate display, and QR code location sharing |
| 🔔 **Notifications** | Local class reminders via Android AlarmManager — fires even in Doze mode, with deep-link navigation on tap |
| 🌙 **Theming** | Light/Dark mode toggle persisted across restarts via SharedPreferences |
| 📡 **Offline Mode** | Transparent SQLite fallback across all screens with visual offline banners |

---

## 🛠️ Tech Stack

![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.5-0175C2?style=for-the-badge&logo=dart)
![Android](https://img.shields.io/badge/Android-API_30+-3DDC84?style=for-the-badge&logo=android)

**State Management:** Provider · ChangeNotifier  
**Storage:** sqflite · FlutterSecureStorage · SharedPreferences  
**Hardware:** geolocator · image_picker · local_auth  
**Background:** flutter_local_notifications · AlarmManager · timezone  
**Network:** Dio · connectivity_plus  

---

## 📱 OS Concepts Demonstrated

- **Runtime Permissions** — Location, Camera, Notifications with full granted / denied / permanently denied state machines
- **Secure Storage** — Android Keystore AES-256 encryption via FlutterSecureStorage
- **Biometric Auth** — BiometricPrompt API via local_auth, hardware key material never exposed to the app
- **Background Execution** — AlarmManager with `exactAllowWhileIdle` for Doze-safe scheduling
- **SQLite Persistence** — Offline caching with Repository pattern and REPLACE conflict strategy
- **Process Isolation** — All app data stored in sandboxed private directory, inaccessible to other apps
- **Deep-Link Navigation** — Notification payload → `navigatorKey.pushNamed()` from any app lifecycle state

---

## 📚 Members 
- Kholladi Sara
- Seghiri Khadidja 
- Dib Ghada
