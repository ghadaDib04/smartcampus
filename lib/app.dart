import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/providers/announcement_provider.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/main_screen.dart';
import 'presentation/screens/announcements_screen.dart';
import 'presentation/screens/events_screen.dart';
import 'presentation/screens/settings_screen.dart';
import 'presentation/screens/home_screen.dart';
import 'core/constants/app_constants.dart';

class SmartCampusApp extends StatelessWidget {
  const SmartCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnnouncementProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..loadSettings()),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                secondary: const Color(0xFF00BCD4),
              ),
              useMaterial3: true,
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF1976D2),
                secondary: const Color(0xFF00BCD4),
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              cardTheme: const CardThemeData(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
              ),
            ),
            // Maintenant le thème réagit immédiatement au toggle
            themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const MainScreen());
                case '/home':
                  return MaterialPageRoute(builder: (_) => const HomeScreen());
                case '/announcements':
                  return MaterialPageRoute(builder: (_) => const AnnouncementsScreen());
                case '/events':
                  return MaterialPageRoute(builder: (_) => const EventsScreen());
                case '/settings':
                  return MaterialPageRoute(builder: (_) => const SettingsScreen());
                default:
                  return MaterialPageRoute(
                    builder: (_) => Scaffold(
                      body: Center(child: Text('Route ${settings.name} not found')),
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