import 'package:flutter/foundation.dart';
import '../../data/models/announcement.dart';
import '../../data/repositories/announcement_repository.dart';
import '../../core/network/connectivity_service.dart';

enum AnnouncementState { initial, loading, success, error, offline }

class AnnouncementProvider extends ChangeNotifier {
  final AnnouncementRepository _repository;
  final ConnectivityService _connectivityService;

  AnnouncementState _state = AnnouncementState.initial;
  List<Announcement> _announcements = [];
  String _errorMessage = '';

  AnnouncementProvider({
    AnnouncementRepository? repository,
    ConnectivityService? connectivityService,
  })  : _repository = repository ?? AnnouncementRepository(),
        _connectivityService = connectivityService ?? ConnectivityService();

  AnnouncementState get state => _state;
  List<Announcement> get announcements => _announcements;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == AnnouncementState.loading;
  bool get hasError => _state == AnnouncementState.error;
  bool get isOffline => _state == AnnouncementState.offline;
  bool get hasData => _state == AnnouncementState.success;

  Future<void> loadAnnouncements() async {
    _setState(AnnouncementState.loading);

    try {
      final bool connected = await _connectivityService.isConnected();

      // Que ce soit online ou offline, le repository gère tout.
      // Online → API + sauvegarde SQLite
      // Offline → lit depuis SQLite
      final List<Announcement> result = await _repository.getAnnouncements();

      _announcements = result;

      if (!connected) {
        // On a des données mais on est offline → état offline avec données
        _errorMessage = 'Vous êtes hors ligne. Contenu mis en cache affiché.';
        _setState(AnnouncementState.offline);
      } else {
        _setState(AnnouncementState.success);
      }
    } catch (e) {
      _errorMessage = 'Erreur : ${e.toString()}';
      _setState(AnnouncementState.error);
    }
  }

  void _setState(AnnouncementState newState) {
    _state = newState;
    notifyListeners();
  }
}