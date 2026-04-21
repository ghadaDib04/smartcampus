// AnnouncementProvider — manages the state of announcements for the UI.
// Extends ChangeNotifier so the UI can listen and rebuild automatically.

import 'package:flutter/foundation.dart';
import '../../data/models/announcement.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../core/network/connectivity_service.dart';
import '../../data/datasources/remote_data_source.dart';

// Enum representing every possible state of the announcements screen.
// Using an enum makes state checks readable: 
// announcementState == AnnouncementState.loading
// instead of checking multiple boolean flags.
enum AnnouncementState { initial, loading, success, error, offline }

class AnnouncementProvider extends ChangeNotifier {
  // Dependencies — injected through the constructor.
  final AnnouncementRepository _repository;
  final ConnectivityService _connectivityService;

  // Private state variables — only this class can modify them.
  // The UI reads them through getters below.
  AnnouncementState _state = AnnouncementState.initial;
  List<Announcement> _announcements = [];
  String _errorMessage = '';

  // Constructor with dependency injection.
  // If no repository is provided, creates a default one.
  // This pattern makes the class testable — in tests you can
  // pass a fake repository that returns controlled data.
  AnnouncementProvider({
    AnnouncementRepository? repository,
    ConnectivityService? connectivityService,
  })  : _repository = repository ?? AnnouncementRepository(),
        _connectivityService = connectivityService ?? ConnectivityService();

  // PUBLIC GETTERS — the UI reads state through these.
  // The UI cannot modify state directly — it can only call methods.
  // This is encapsulation — a core OOP principle.
  AnnouncementState get state => _state;
  List<Announcement> get announcements => _announcements;
  String get errorMessage => _errorMessage;

  // Convenience getters — make UI code more readable.
  // Instead of: provider.state == AnnouncementState.loading
  // You write: provider.isLoading
  bool get isLoading => _state == AnnouncementState.loading;
  bool get hasError => _state == AnnouncementState.error;
  bool get isOffline => _state == AnnouncementState.offline;
  bool get hasData => _state == AnnouncementState.success;

  // The main method the UI calls to load announcements.
  // This is the only public method — the UI has one job: call this.
  Future<void> loadAnnouncements() async {
    // Step 1 — Set state to loading and notify UI to show spinner.
    _setState(AnnouncementState.loading);

    // Step 2 — Check connectivity before making the API call.
    final bool connected = await _connectivityService.isConnected();

    if (!connected) {
      // Device is offline — set offline state and stop here.
      // In Week 3 we will add: load from SQLite cache here instead.
      _errorMessage = 'You are offline. Cached content will appear here soon.';
      _setState(AnnouncementState.offline);
      return; // Exit the method early — no point calling the API
    }

    // Step 3 — Device is online, fetch from API.
    try {
      final List<Announcement> result =
          await _repository.getAnnouncements();

      // Success — store the data and notify UI to show the list.
      _announcements = result;
      _setState(AnnouncementState.success);

    } on NetworkException catch (e) {
      // NetworkException was thrown by our RemoteDataSource.
      // Store the message and set error state.
      _errorMessage = e.message;
      _setState(AnnouncementState.error);

    } catch (e) {
      // Catch-all for any unexpected error.
      _errorMessage = 'Something went wrong. Please try again.';
      _setState(AnnouncementState.error);
    }
  }

  // Private helper — updates state and calls notifyListeners().
  // Every state change goes through here — no direct assignments outside.
  // This ensures notifyListeners() is NEVER forgotten after a state change.
  void _setState(AnnouncementState newState) {
    _state = newState;
    // This is the magic line — tells every listening widget to rebuild.
    notifyListeners();
  }
}