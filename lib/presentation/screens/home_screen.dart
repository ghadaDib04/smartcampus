import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../data/models/timetable_item.dart';
import 'main_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  DayOfWeek _todayAsDayOfWeek() {
    final w = DateTime.now().weekday;
    switch (w) {
      case 1: return DayOfWeek.monday;
      case 2: return DayOfWeek.tuesday;
      case 3: return DayOfWeek.wednesday;
      case 4: return DayOfWeek.thursday;
      case 5: return DayOfWeek.friday;
      case 6: return DayOfWeek.saturday;
      default: return DayOfWeek.sunday;
    }
  }

  TimetableItem? _getNextClass(List<TimetableItem> items) {
    final today = _todayAsDayOfWeek();
    final now = TimeOfDay.now();
    final todayItems = items.where((item) => item.day == today).toList();
    todayItems.sort((a, b) => a.startTime.compareTo(b.startTime));
    for (final item in todayItems) {
      final parts = item.startTime.split(':');
      final itemHour = int.parse(parts[0]);
      final itemMin = int.parse(parts[1]);
      if (itemHour > now.hour ||
          (itemHour == now.hour && itemMin > now.minute)) {
        return item;
      }
    }
    return null;
  }

  String _minutesUntil(String startTime) {
    final parts = startTime.split(':');
    final now = DateTime.now();
    final classTime = DateTime(
      now.year, now.month, now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    final diff = classTime.difference(now).inMinutes;
    if (diff < 60) return 'In $diff min';
    final h = diff ~/ 60;
    final m = diff % 60;
    return m == 0 ? 'In ${h}h' : 'In ${h}h ${m}m';
  }

  String _greetingPrefix() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  int _countTodayCourses(List<TimetableItem> items) {
    return items.where((item) => item.day == _todayAsDayOfWeek()).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;
    final timetable = TimetableItem.getSampleTimetable(
      group: user?.group ?? '1',
      specialty: user?.specialty ?? 'Computer Science',
    );
    final userName = authProvider.currentUser?.name ?? 'Student';

    final nextClass = _getNextClass(timetable);
    final todayCourseCount = _countTodayCourses(timetable);
    final cardColor =
        isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27C7D4),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(
                greeting: _greetingPrefix(),
                user: user,
                userName: userName,
              ),
              const SizedBox(height: 20),
              _DashboardStatsRow(
                todayCourseCount: todayCourseCount,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Next Course', isDark: isDark),
              const SizedBox(height: 10),
              _NextCourseCard(
                nextClass: nextClass,
                minutesUntil: nextClass != null
                    ? _minutesUntil(nextClass.startTime)
                    : null,
                cardColor: cardColor,
                isDark: isDark,
              ),
              const SizedBox(height: 20),
              _SectionLabel(label: 'Quick Actions', isDark: isDark),
              const SizedBox(height: 10),
              _QuickActionsRow(cardColor: cardColor, isDark: isDark),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Welcome Card
// ─────────────────────────────────────────────────────────────
class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.greeting,
    required this.user,
    required this.userName,
  });

  final String greeting;
  final dynamic user;
  final String userName;

  String _formatDate() {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday'
    ];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF27C7D4), Color(0xFF1AAAB6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF27C7D4).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $userName 👋',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDate(),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                  ),
                ),
                if (user != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${user.specialty}  •  Year ${user.year}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withValues(alpha: 0.25),
            child: Text(
              userName[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Dashboard Stats Row — 3 mini cards
// ─────────────────────────────────────────────────────────────
class _DashboardStatsRow extends StatelessWidget {
  const _DashboardStatsRow({
    required this.todayCourseCount,
    required this.isDark,
  });

  final int todayCourseCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _DashboardStatCard(
          icon: Icons.book_outlined,
          value: '$todayCourseCount',
          label: 'Courses today',
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _DashboardStatCard(
          icon: Icons.campaign_outlined,
          value: '3',
          label: 'Announcements',
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _DashboardStatCard(
          icon: Icons.event_outlined,
          value: '5',
          label: 'Events',
          isDark: isDark,
        ),
      ],
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.isDark,
  });

  final IconData icon;
  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF27C7D4), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF555555),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Next Course Card — cyan left border accent
// ─────────────────────────────────────────────────────────────
class _NextCourseCard extends StatelessWidget {
  const _NextCourseCard({
    required this.nextClass,
    required this.minutesUntil,
    required this.cardColor,
    required this.isDark,
  });

  final TimetableItem? nextClass;
  final String? minutesUntil;
  final Color cardColor;
  final bool isDark;

  Color _typeColor(String type) {
    switch (type) {
      case 'Lab': return const Color(0xFFFE9063);
      case 'Tutorial': return const Color(0xFFEA5863);
      default: return const Color(0xFF27C7D4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Cyan left border accent
              Container(width: 4, color: const Color(0xFF27C7D4)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: nextClass != null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    nextClass!.subject,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1A1A2E),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (minutesUntil != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF27C7D4)
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      minutesUntil!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF27C7D4),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.room_outlined,
                                    size: 14, color: Color(0xFF555555)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    nextClass!.room,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF555555)),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.access_time_outlined,
                                    size: 14, color: Color(0xFF555555)),
                                const SizedBox(width: 4),
                                Text(
                                  '${nextClass!.startTime} – ${nextClass!.endTime}',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF555555)),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _typeColor(nextClass!.type)
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    nextClass!.type,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _typeColor(nextClass!.type),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Text(
                              'No course today 🎉',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF555555),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Quick Actions Row — 2 outlined tab-switching cards
// ─────────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({
    required this.cardColor,
    required this.isDark,
  });

  final Color cardColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.calendar_today_outlined,
            label: 'Timetable',
            onTap: () => MainScreen.switchTab?.call(4),
            cardColor: cardColor,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.event_outlined,
            label: 'Events',
            onTap: () => MainScreen.switchTab?.call(2),
            cardColor: cardColor,
            isDark: isDark,
          ),
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.cardColor,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color cardColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF27C7D4).withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF27C7D4).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon,
                  color: const Color(0xFF27C7D4), size: 20),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Section Label
// ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.isDark});

  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
    );
  }
}
