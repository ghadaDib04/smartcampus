// MainScreen — the navigation shell of the app.
// Holds the bottom navigation bar and displays the selected screen.
// This is a StatefulWidget because it tracks which tab is selected.

import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'announcements_screen.dart';
import 'events_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Tracks which tab is currently selected.
  // 0 = Home, 1 = Announcements, 2 = Events, 3 = Settings
  int _currentIndex = 0;

  // The list of screens — one per tab.
  // We define this as a field so Flutter doesn't recreate
  // these widgets every time the tab changes.
  final List<Widget> _screens = const [
    HomeScreen(),
    AnnouncementsScreen(),
    EventsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack keeps all screens alive in memory.
      // When you switch tabs, the previous screen is not destroyed —
      // it stays in memory and its scroll position is preserved.
      // Alternative is just _screens[_currentIndex] but that
      // destroys and recreates screens on every tab switch.
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),

      // Bottom navigation bar with 4 tabs
      bottomNavigationBar: BottomNavigationBar(
        // Which tab is currently highlighted
        currentIndex: _currentIndex,

        // Called when user taps a tab
        // setState() tells Flutter to rebuild this widget
        // with the new _currentIndex value
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },

        // Use fixed type so all 4 labels are always visible
        type: BottomNavigationBarType.fixed,

        // Style
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign_outlined),
            activeIcon: Icon(Icons.campaign),
            label: 'Announcements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_outlined),
            activeIcon: Icon(Icons.event),
            label: 'Events',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}