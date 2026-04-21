// AnnouncementsScreen — displays announcements fetched from the API.
// Demonstrates: networking, state management, loading/error/offline states.
// This screen is the primary Week 2 deliverable.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/announcement_provider.dart';
import '../../data/models/announcement.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  @override
  void initState() {
    super.initState();
    // Trigger data load after the first frame is rendered.
    // We use addPostFrameCallback to ensure the widget tree is
    // fully built before we start modifying provider state.
    // This is the correct pattern — never call provider methods
    // directly in initState() without this wrapper.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // read() gets the provider once without listening.
      // We use read() here instead of watch() because we are
      // inside a callback, not inside build().
      context.read<AnnouncementProvider>().loadAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
        centerTitle: true,
        // Pull to refresh action button
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () {
              context.read<AnnouncementProvider>().loadAnnouncements();
            },
          ),
        ],
      ),

      // Consumer listens to AnnouncementProvider.
      // Rebuilds only this subtree when notifyListeners() is called.
      // 'provider' is the AnnouncementProvider instance.
      // 'child' is an optional widget that never rebuilds — we don't use it here.
      body: Consumer<AnnouncementProvider>(
        builder: (context, provider, child) {
          // OFFLINE STATE
          if (provider.isOffline) {
            return _buildOfflineState(provider.errorMessage);
          }

          // LOADING STATE
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          // ERROR STATE
          if (provider.hasError) {
            return _buildErrorState(provider.errorMessage, provider);
          }

          // SUCCESS STATE — show the list
          if (provider.hasData) {
            return _buildAnnouncementList(provider.announcements);
          }

          // INITIAL STATE — before anything has been triggered
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // LOADING STATE widget — shown while API call is in progress
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Fetching announcements...',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // ERROR STATE widget — shown when API call fails
  Widget _buildErrorState(String message, AnnouncementProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => provider.loadAnnouncements(),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // OFFLINE STATE widget — shown when device has no internet
  Widget _buildOfflineState(String message) {
    return Column(
      children: [
        // Offline banner at the top
        Container(
          width: double.infinity,
          color: Colors.orange.shade100,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.cloud_off,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.orange,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Empty state below the banner
        const Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No cached content yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Connect to the internet to load announcements',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // SUCCESS STATE — builds the scrollable list of announcements
  Widget _buildAnnouncementList(List<Announcement> announcements) {
    return RefreshIndicator(
      // Pull to refresh — calls loadAnnouncements() again
      onRefresh: () async {
        await context.read<AnnouncementProvider>().loadAnnouncements();
      },
      child: ListView.builder(
        // Add padding so last item isn't hidden behind nav bar
        padding: const EdgeInsets.all(12),
        itemCount: announcements.length,
        // ListView.builder only builds items currently visible on screen.
        // Much more efficient than building all 20 items at once.
        // This directly demonstrates list optimization for your report.
        itemBuilder: (context, index) {
          final Announcement announcement = announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  // Builds one announcement card
  Widget _buildAnnouncementCard(Announcement announcement) {
    // Map category names to colors for visual distinction
    final Map<String, Color> categoryColors = {
      'Academic': Colors.blue,
      'Events': Colors.green,
      'General': Colors.grey,
      'Emergency': Colors.red,
    };

    final Color categoryColor =
        categoryColors[announcement.category] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row — category badge + urgent indicator + date
            Row(
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: categoryColor),
                  ),
                  child: Text(
                    announcement.category,
                    style: TextStyle(
                      color: categoryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Urgent badge — only shown for urgent announcements
                if (announcement.isUrgent) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red),
                    ),
                    child: const Text(
                      'URGENT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],

                const Spacer(),

                // Date
                Text(
                  _formatDate(announcement.date),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              announcement.title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            // Body preview — limited to 2 lines
            Text(
              announcement.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Formats a DateTime to a readable string like 'Apr 21'
  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }
}