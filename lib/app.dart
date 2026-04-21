// app.dart — Root of the application.
// Sets up theme, routing, and provides all providers to the widget tree.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/announcement_provider.dart';
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
    // MultiProvider sits at the very top of the widget tree.
    // Every screen below it can access any provider listed here.
    // We will add EventProvider and SettingsProvider here in later weeks.
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider creates the AnnouncementProvider
        // and disposes it automatically when the app closes.
        ChangeNotifierProvider(
          create: (_) => AnnouncementProvider(),
        ),
      ],
      // MaterialApp is Flutter's root widget for Material Design apps.
      child: MaterialApp(
        title: AppConstants.appName,

        // Hide the debug banner in the top right corner
        debugShowCheckedModeBanner: false,

        // LIGHT THEME configuration
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2), // Primary blue from requirements
            secondary: const Color(0xFF00BCD4), // Cyan from requirements
          ),
          // Material 3 is the latest Material Design version
          useMaterial3: true,
          // Card theme — all cards in the app use these settings
          cardTheme: const CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
          ),
        ),

        // DARK THEME configuration
        // Flutter automatically switches based on device system setting
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1976D2),
            secondary: const Color(0xFF00BCD4),
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

        // ThemeMode.system means the app follows the device's dark/light setting
        themeMode: ThemeMode.system,

        // The first screen shown when the app launches
        initialRoute: '/',

        // onGenerateRoute maps route names to screen widgets.
        // This satisfies the teacher's requirement for named routes.
        // When you call Navigator.pushNamed(context, '/announcements'),
        // Flutter comes here and finds which widget to show.
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (_) => const MainScreen(),
                settings: settings,
              );
            case '/home':
              return MaterialPageRoute(
                builder: (_) => const HomeScreen(),
                settings: settings,
              );
            case '/announcements':
              return MaterialPageRoute(
                builder: (_) => const AnnouncementsScreen(),
                settings: settings,
              );
            case '/events':
              return MaterialPageRoute(
                builder: (_) => const EventsScreen(),
                settings: settings,
              );
            case '/settings':
              return MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
                settings: settings,
              );
            // If someone navigates to an unknown route,
            // show an error screen instead of crashing
            default:
              return MaterialPageRoute(
                builder: (_) => Scaffold(
                  body: Center(
                    child: Text('Route ${settings.name} not found'),
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}