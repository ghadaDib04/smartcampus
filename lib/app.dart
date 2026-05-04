import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/announcement_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/event_provider.dart';
import 'presentation/screens/timetable_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/announcements_screen.dart';
import 'presentation/screens/events_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'core/constants/app_constants.dart';
import 'core/services/notification_service.dart';

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            navigatorKey: navigatorKey,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF27C7D4),
                secondary: const Color(0xFFFE9063),
              ),
              useMaterial3: true,
              cardTheme: const CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF27C7D4),
                secondary: const Color(0xFFFE9063),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              cardTheme: const CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/splash',
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/splash':
                  return MaterialPageRoute(
                      builder: (_) => const SplashScreen());
                case '/login':
                  return MaterialPageRoute(
                      builder: (_) => const LoginScreen());
                case '/':
                  return MaterialPageRoute(
                      builder: (_) => const MainScreen());
                case '/home':
                  return MaterialPageRoute(
                      builder: (_) => const HomeScreen());
                case '/announcements':
                  return MaterialPageRoute(
                      builder: (_) => const AnnouncementsScreen());
                case '/events':
                  return MaterialPageRoute(
                      builder: (_) => const EventsScreen());
                case '/settings':
                  return MaterialPageRoute(
                      builder: (_) => const SettingsScreen());
                case '/timetable':
                  return MaterialPageRoute(
                      builder: (_) => const TimetableScreen());
                default:
                  return MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: Center(
                          child: Text('Route ${settings.name} not found')),
                    ),
                  );
              }
            },
          );
        },
      ),
    );
  }
}