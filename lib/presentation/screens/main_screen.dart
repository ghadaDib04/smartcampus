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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    AnnouncementsScreen(),
    EventsScreen(),
    SettingsScreen(),
  ];

  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_currentIndex != index) {
      _animController.reset();
      _animController.forward();
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Dark mode : fond sombre, light mode : blanc
    final navBgColor = isDark ? const Color(0xFF1A1A2E) : Colors.white;
    final shadowColor = isDark
        ? Colors.black.withOpacity(0.4)
        : const Color(0xFF1A1A2E).withOpacity(0.08);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBgColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              spreadRadius: 4,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: const Color(0xFF27C7D4).withOpacity(0.06),
              blurRadius: 40,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home, 'Home', isDark),
                _buildNavItem(1, Icons.campaign_outlined, Icons.campaign, 'News', isDark),
                _buildNavItem(2, Icons.event_outlined, Icons.event, 'Events', isDark),
                _buildNavItem(3, Icons.settings_outlined, Icons.settings, 'Settings', isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      int index,
      IconData icon,
      IconData activeIcon,
      String label,
      bool isDark,
      ) {
    final bool isSelected = _currentIndex == index;


    final unselectedColor =
    isDark ? Colors.white.withOpacity(0.5) : const Color(0xFF555555);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF27C7D4), Color(0xFF1A9EAA)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF27C7D4).withOpacity(0.35),
              blurRadius: 16,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Icon(
                isSelected ? activeIcon : icon,
                key: ValueKey<bool>(isSelected),
                color: isSelected ? Colors.white : unselectedColor,
                size: isSelected ? 26 : 24,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: isSelected ? 12 : 11,
                fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : unselectedColor,
                letterSpacing: isSelected ? 0.5 : 0,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}