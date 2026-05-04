import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../../core/services/notification_service.dart';
import '../../data/models/timetable_item.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = context.watch<AuthProvider>().currentUser;
    final cardColor =
    isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27C7D4),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // ── Profile Card ──────────────────────────────
              _ProfileCard(user: user, isDark: isDark),
              const SizedBox(height: 24),

              // ── Appearance ────────────────────────────────
              _SectionLabel(label: 'Appearance', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _SwitchTile(
                    icon: Icons.dark_mode_outlined,
                    iconColor: const Color(0xFF27C7D4),
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark theme',
                    value: settings.darkMode,
                    onChanged: (v) => settings.setDarkMode(v),
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Notifications ─────────────────────────────
              _SectionLabel(label: 'Notifications', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _SwitchTile(
                    icon: Icons.notifications_outlined,
                    iconColor: const Color(0xFFFE9063),
                    title: 'Enable Notifications',
                    subtitle: 'Class reminders before each course',
                    value: settings.notifications,
                    onChanged: (v) async {
                      settings.setNotifications(v);
                      if (v) {
                        // Activer : programmer le rappel pour le prochain cours
                        final user = context.read<AuthProvider>().currentUser;
                        if (user != null) {
                          final timetable = TimetableItem.getSampleTimetable(
                            group: user.group,
                            specialty: user.specialty,
                          );
                          // Trouver le prochain cours d'aujourd'hui
                          final now = DateTime.now();
                          final todayItems = timetable.where((item) {
                            final dayIndex = now.weekday; // 1=Monday, 5=Friday
                            final itemDay = item.day.index + 1;
                            return itemDay == dayIndex;
                          }).toList();

                          if (todayItems.isNotEmpty) {
                            // Prendre le prochain cours pas encore passé
                            todayItems.sort((a, b) => a.startTime.compareTo(b.startTime));
                            final nextClass = todayItems.firstWhere(
                                  (item) {
                                final parts = item.startTime.split(':');
                                final classTime = DateTime(now.year, now.month, now.day,
                                    int.parse(parts[0]), int.parse(parts[1]));
                                return classTime.isAfter(now);
                              },
                              orElse: () => todayItems.last,
                            );

                            final parts = nextClass.startTime.split(':');
                            final classTime = DateTime(
                              now.year, now.month, now.day,
                              int.parse(parts[0]), int.parse(parts[1]),
                            );

                            await NotificationService().scheduleClassReminder(
                              id: nextClass.id,
                              subject: nextClass.subject,
                              room: nextClass.room,
                              classTime: classTime,
                            );
                            await NotificationService().showTestNotification();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reminder set for ${nextClass.subject} at ${nextClass.startTime}'),
                                backgroundColor: const Color(0xFF27C7D4),
                              ),
                            );
                          }
                        }
                      } else {
                        // Désactiver : annuler toutes les notifications
                        await NotificationService().cancelAll();
                      }
                    },
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Account ───────────────────────────────────
              _SectionLabel(label: 'Account', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _InfoTile(
                    icon: Icons.person_outline,
                    iconColor: const Color(0xFF27C7D4),
                    title: 'Full Name',
                    value: user?.name ?? '—',
                    isDark: isDark,
                  ),
                  _Separator(isDark: isDark),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    iconColor: const Color(0xFFFE9063),
                    title: 'Student ID',
                    value: user?.studentId ?? '—',
                    isDark: isDark,
                  ),
                  _Separator(isDark: isDark),
                  _InfoTile(
                    icon: Icons.school_outlined,
                    iconColor: const Color(0xFF27C7D4),
                    title: 'Specialty',
                    value: user?.specialty ?? '—',
                    isDark: isDark,
                  ),
                  _Separator(isDark: isDark),
                  _InfoTile(
                    icon: Icons.group_outlined,
                    iconColor: const Color(0xFFFE9063),
                    title: 'Section / Group',
                    value: user != null
                        ? 'Section ${user.section}  •  Group ${user.group}'
                        : '—',
                    isDark: isDark,
                  ),
                  _Separator(isDark: isDark),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    iconColor: const Color(0xFF27C7D4),
                    title: 'Year',
                    value: user != null ? 'Year ${user.year}' : '—',
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── About ─────────────────────────────────────
              _SectionLabel(label: 'About', isDark: isDark),
              const SizedBox(height: 8),
              _SettingsCard(
                isDark: isDark,
                children: [
                  _InfoTile(
                    icon: Icons.info_outline,
                    iconColor: const Color(0xFF27C7D4),
                    title: 'Version',
                    value: '1.0.0',
                    isDark: isDark,
                  ),
                  _Separator(isDark: isDark),
                  _InfoTile(
                    icon: Icons.apartment_outlined,
                    iconColor: const Color(0xFFFE9063),
                    title: 'App',
                    value: 'SmartCampus Companion',
                    isDark: isDark,
                  ),
                  _Separator(isDark: isDark),
                  _InfoTile(
                    icon: Icons.devices_outlined,
                    iconColor: const Color(0xFF27C7D4),
                    title: 'Course',
                    value: 'Mobile Operating Systems',
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ── Logout Button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEA5863),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _confirmLogout(context),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF555555)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA5863),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Profile Card
// ─────────────────────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user, required this.isDark});

  final dynamic user;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final initial =
    user != null ? (user.name as String)[0].toUpperCase() : 'S';
    final name = user?.name ?? 'Student';
    final email = user?.email ?? '—';
    final studentId = user?.studentId ?? '—';

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
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white.withOpacity(0.25),
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    studentId,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark
              ? const Color(0xFF27C7D4)
              : const Color(0xFF27C7D4),
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Settings Card Container
// ─────────────────────────────────────────────────────────────
class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, required this.isDark});

  final List<Widget> children;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);
    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Switch Tile
// ─────────────────────────────────────────────────────────────
class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF27C7D4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Info Tile (read-only)
// ─────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF555555),
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Separator
// ─────────────────────────────────────────────────────────────
class _Separator extends StatelessWidget {
  const _Separator({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      indent: 68,
      endIndent: 16,
      color: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.black.withOpacity(0.08),
    );
  }
}