import 'package:flutter/material.dart';
import '../../data/models/timetable_item.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  DayOfWeek _todayAsDayOfWeek() {
    final w = DateTime.now().weekday;
    switch (w) {
      case 1:
        return DayOfWeek.monday;
      case 2:
        return DayOfWeek.tuesday;
      case 3:
        return DayOfWeek.wednesday;
      case 4:
        return DayOfWeek.thursday;
      case 5:
        return DayOfWeek.friday;
      case 6:
        return DayOfWeek.saturday;
      default:
        return DayOfWeek.sunday;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final today = _todayAsDayOfWeek();
    final timetable = TimetableItem.getSampleTimetable();

    // Group by day in enum order
    final Map<DayOfWeek, List<TimetableItem>> grouped = {};
    for (final day in DayOfWeek.values) {
      final items = timetable.where((item) => item.day == day).toList();
      if (items.isNotEmpty) {
        items.sort((a, b) => a.startTime.compareTo(b.startTime));
        grouped[day] = items;
      }
    }

    // Flatten: [DayOfWeek header, TimetableItem, TimetableItem, ...]
    final List<Object> flatList = [];
    for (final entry in grouped.entries) {
      flatList.add(entry.key);
      flatList.addAll(entry.value);
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27C7D4),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Timetable',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: flatList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 56,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No courses found',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 15),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    itemCount: flatList.length,
                    itemBuilder: (context, index) {
                      final item = flatList[index];
                      if (item is DayOfWeek) {
                        return _DayHeader(
                          day: item,
                          isToday: item == today,
                          isDark: isDark,
                        );
                      }
                      final course = item as TimetableItem;
                      return _CourseCard(
                        item: course,
                        isToday: course.day == today,
                        isDark: isDark,
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF27C7D4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 32, vertical: 14),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Export feature coming from Person 3'),
                      backgroundColor: Color(0xFF27C7D4),
                    ),
                  );
                },
                child: const Text(
                  'Export JSON',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Day Section Header
// ─────────────────────────────────────────────────────────────
class _DayHeader extends StatelessWidget {
  const _DayHeader({
    required this.day,
    required this.isToday,
    required this.isDark,
  });

  final DayOfWeek day;
  final bool isToday;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 6),
      child: Row(
        children: [
          Text(
            day.displayName.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isToday
                  ? const Color(0xFF27C7D4)
                  : isDark
                      ? Colors.white60
                      : const Color(0xFF555555),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          if (isToday)
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF27C7D4).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TODAY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF27C7D4),
                ),
              ),
            ),
          Expanded(
            child: Divider(
              indent: 8,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.1),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Course Card
// ─────────────────────────────────────────────────────────────
class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.item,
    required this.isToday,
    required this.isDark,
  });

  final TimetableItem item;
  final bool isToday;
  final bool isDark;

  Color _typeColor(String type) {
    switch (type) {
      case 'Lab':
        return const Color(0xFFFE9063);
      case 'Tutorial':
        return const Color(0xFFEA5863);
      default:
        return const Color(0xFF27C7D4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(item.type);

    final cardColor = isToday
        ? const Color(0xFF27C7D4)
        : isDark
            ? const Color(0xFF1A1A2E)
            : const Color(0xFFFDF0E7);

    final textPrimary = isToday
        ? Colors.white
        : isDark
            ? Colors.white
            : const Color(0xFF1A1A2E);

    final textSecondary = isToday
        ? Colors.white.withValues(alpha: 0.85)
        : const Color(0xFF555555);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isToday
                    ? Colors.white.withValues(alpha: 0.2)
                    : typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.school_outlined,
                color: isToday ? Colors.white : typeColor,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.subject,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.room,
                    style:
                        TextStyle(fontSize: 12, color: textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: isToday
                        ? Colors.white.withValues(alpha: 0.2)
                        : typeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item.type,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.white : typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.startTime}–${item.endTime}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
