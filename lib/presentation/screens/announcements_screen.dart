import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import '../../data/models/announcement.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _tabs = ['All', 'Academic', 'Events', 'General', 'Emergency'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnnouncementProvider>().loadAnnouncements();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Announcement> _filtered(List<Announcement> all, int tabIndex) {
    if (tabIndex == 0) return all;
    return all.where((a) => a.category == _tabs[tabIndex]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: const Color(0xFF27C7D4),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Announcements',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AnnouncementProvider>().loadAnnouncements(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabAlignment: TabAlignment.start,
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) return _buildLoading();
          if (provider.hasError) return _buildError(provider, isDark);
          if (provider.isOffline) return _buildOffline(provider, isDark);
          if (provider.hasData) {
            return TabBarView(
              controller: _tabController,
              children: _tabs.asMap().entries.map((entry) {
                final filtered = _filtered(provider.announcements, entry.key);
                return _buildList(filtered, isDark);
              }).toList(),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Loading ───────────────────────────────────────
  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Color(0xFF27C7D4)),
          const SizedBox(height: 16),
          Text(
            'Fetching announcements...',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
        ],
      ),
    );
  }

  // ── Error ─────────────────────────────────────────
  Widget _buildError(AnnouncementProvider provider, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEA5863).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded,
                  size: 40, color: Color(0xFFEA5863)),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF555555), fontSize: 13),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF27C7D4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () => provider.loadAnnouncements(),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  // ── Offline ───────────────────────────────────────
  Widget _buildOffline(AnnouncementProvider provider, bool isDark) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFFE9063).withOpacity(0.15),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFFE9063).withOpacity(0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.cloud_off_rounded,
                  color: Color(0xFFFE9063), size: 18),
              const SizedBox(width: 8),
              const Text(
                'Offline — showing cached content',
                style: TextStyle(
                  color: Color(0xFFFE9063),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFE9063).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${provider.announcements.length} cached',
                  style: const TextStyle(
                    color: Color(0xFFFE9063),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: provider.announcements.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.wifi_off_rounded,
                      size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                const Text(
                  'No cached content yet',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect to internet to load announcements',
                  style:
                  TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
              : TabBarView(
            controller: _tabController,
            children: _tabs.asMap().entries.map((entry) {
              final filtered = _filtered(provider.announcements, entry.key);
              return _buildList(filtered, isDark);
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ── List ──────────────────────────────────────────
  Widget _buildList(List<Announcement> announcements, bool isDark) {
    if (announcements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_rounded,
                size: 56, color: Colors.grey.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No announcements',
                style: TextStyle(color: Colors.grey, fontSize: 15)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xFF27C7D4),
      onRefresh: () async =>
          context.read<AnnouncementProvider>().loadAnnouncements(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          return _AnnouncementCard(
            announcement: announcements[index],
            isDark: isDark,
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Announcement Card
// ─────────────────────────────────────────────────────────────
class _AnnouncementCard extends StatelessWidget {
  const _AnnouncementCard({
    required this.announcement,
    required this.isDark,
  });

  final Announcement announcement;
  final bool isDark;

  Color _categoryColor(String category) {
    switch (category) {
      case 'Academic': return const Color(0xFF27C7D4);
      case 'Events': return const Color(0xFFFE9063);
      case 'Emergency': return const Color(0xFFEA5863);
      default: return const Color(0xFF555555);
    }
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'Academic': return Icons.school_outlined;
      case 'Events': return Icons.event_outlined;
      case 'Emergency': return Icons.warning_amber_rounded;
      default: return Icons.campaign_outlined;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final cardColor =
    isDark ? const Color(0xFF1A1A2E) : const Color(0xFFFDF0E7);
    final color = _categoryColor(announcement.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: announcement.isUrgent
            ? Border.all(color: const Color(0xFFEA5863).withOpacity(0.5), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top color bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(_categoryIcon(announcement.category),
                          color: color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  announcement.category,
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (announcement.isUrgent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEA5863)
                                        .withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.priority_high_rounded,
                                          size: 10,
                                          color: Color(0xFFEA5863)),
                                      SizedBox(width: 2),
                                      Text(
                                        'URGENT',
                                        style: TextStyle(
                                          color: Color(0xFFEA5863),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const Spacer(),
                              Text(
                                _formatDate(announcement.date),
                                style: const TextStyle(
                                  color: Color(0xFF555555),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Title
                Text(
                  announcement.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                // Body
                Text(
                  announcement.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                    height: 1.5,
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