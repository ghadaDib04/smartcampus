import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/announcement_provider.dart';
import '../../data/models/timetable_item.dart';

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
    if (diff < 60) return 'In $diff minutes';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final announcements =
        context.watch<AnnouncementProvider>().announcements;

    final timetable = user != null
        ? TimetableItem.getSampleTimetable(
      group: user.group,
      specialty: user.specialty,
    )
        : <TimetableItem>[];

    final nextClass = _getNextClass(timetable);
    final urgentCount =
        announcements.where((a) => a.isUrgent).length;

    final cardColor = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _WelcomeCard(
                greeting: _greetingPrefix(),
                user: user,
                cardColor: cardColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _NextClassCard(
                nextClass: nextClass,
                minutesUntil: nextClass != null
                    ? _minutesUntil(nextClass.startTime)
                    : null,
                cardColor: cardColor,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _StatsRow(
                announcementCount: announcements.length,
                urgentCount: urgentCount,
                courseCount: timetable.length,
                isDark: isDark,
              ),
              const SizedBox(height: 16),
              _SectionLabel(label: 'Quick Access', isDark: isDark),
              const SizedBox(height: 10),
              _QuickAccessGrid(isDark: isDark),
              const SizedBox(height: 16),
              _SectionLabel(label: 'Campus Info', isDark: isDark),
              const SizedBox(height: 10),
              _CampusInfoCard(cardColor: cardColor, isDark: isDark),
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
    required this.cardColor,
    required this.isDark,
  });

  final String greeting;
  final dynamic user;
  final Color cardColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final firstName = user != null
        ? (user.name as String).split(' ').first
        : 'Student';

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
            color: const Color(0xFF27C7D4).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting, $firstName',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.waving_hand,
                  color: Colors.white,
                  size: 22,
                ),
                const SizedBox(height: 6),
                if (user != null) ...[
                  Text(
                    user.studentId as String,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${user.specialty}  •  Year ${user.year}  •  Group ${user.group}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Section ${user.section}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              user != null
                  ? (user.name as String)[0].toUpperCase()
                  : 'S',
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
// Next Class Card
// ─────────────────────────────────────────────────────────────
class _NextClassCard extends StatelessWidget {
  const _NextClassCard({
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
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: nextClass != null
                  ? _typeColor(nextClass!.type).withOpacity(0.15)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.school_outlined,
              color: nextClass != null
                  ? _typeColor(nextClass!.type)
                  : Colors.grey,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: nextClass != null
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Next Class',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF555555),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _typeColor(nextClass!.type)
                            .withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        nextClass!.type,
                        style: TextStyle(
                          fontSize: 10,
                          color: _typeColor(nextClass!.type),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  nextClass!.subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '${nextClass!.room}  •  ${nextClass!.startTime}–${nextClass!.endTime}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Next Class',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No more classes today',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
          if (nextClass != null && minutesUntil != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF27C7D4).withOpacity(0.12),
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
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Stats Row
// ─────────────────────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.announcementCount,
    required this.urgentCount,
    required this.courseCount,
    required this.isDark,
  });

  final int announcementCount;
  final int urgentCount;
  final int courseCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          label: 'Announcements',
          value: '$announcementCount',
          icon: Icons.campaign_outlined,
          color: const Color(0xFF27C7D4),
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'Urgent',
          value: '$urgentCount',
          icon: Icons.warning_amber_rounded,
          color: const Color(0xFFEA5863),
          isDark: isDark,
        ),
        const SizedBox(width: 10),
        _StatCard(
          label: 'My Courses',
          value: '$courseCount',
          icon: Icons.book_outlined,
          color: const Color(0xFFFE9063),
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Quick Access Grid
// ─────────────────────────────────────────────────────────────
class _QuickAccessGrid extends StatelessWidget {
  const _QuickAccessGrid({required this.isDark});

  final bool isDark;

  static const _items = [
    (icon: Icons.campaign_outlined, label: 'Announcements', route: '/announcements', color: Color(0xFF27C7D4)),
    (icon: Icons.event_outlined, label: 'Events', route: '/events', color: Color(0xFFFE9063)),
    (icon: Icons.calendar_today_outlined, label: 'Timetable', route: '/timetable', color: Color(0xFF27C7D4)),
    (icon: Icons.map_outlined, label: 'Map', route: '/map', color: Color(0xFFEA5863)),
    (icon: Icons.settings_outlined, label: 'Settings', route: '/settings', color: Color(0xFF555555)),
    (icon: Icons.notifications_outlined, label: 'Notifications', route: '/notifications', color: Color(0xFFFE9063)),
  ];

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.05,
      children: _items.map((item) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, item.route),
          child: Container(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Campus Info Card
// ─────────────────────────────────────────────────────────────
class _CampusInfoCard extends StatelessWidget {
  const _CampusInfoCard({required this.cardColor, required this.isDark});

  final Color cardColor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _CampusStat(value: '1,200', label: 'Students', isDark: isDark),
          _Divider(isDark: isDark),
          _CampusStat(value: '48', label: 'Courses', isDark: isDark),
          _Divider(isDark: isDark),
          _CampusStat(value: '12', label: 'Buildings', isDark: isDark),
        ],
      ),
    );
  }
}

class _CampusStat extends StatelessWidget {
  const _CampusStat({
    required this.value,
    required this.label,
    required this.isDark,
  });

  final String value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF27C7D4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white60 : const Color(0xFF555555),
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      color: isDark
          ? Colors.white.withOpacity(0.1)
          : Colors.black.withOpacity(0.1),
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