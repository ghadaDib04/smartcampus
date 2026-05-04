import 'package:flutter/foundation.dart';
import '../../data/models/event.dart';
import '../../data/repositories/event_repository.dart';
import '../../core/network/connectivity_service.dart';

enum EventState { initial, loading, success, error, offline }

class EventProvider extends ChangeNotifier {
  final EventRepository _repository;
  final ConnectivityService _connectivityService;

  EventState _state = EventState.initial;
  List<Event> _events = [];
  String _errorMessage = '';

  EventProvider({
    EventRepository? repository,
    ConnectivityService? connectivityService,
  })  : _repository = repository ?? EventRepository(),
        _connectivityService = connectivityService ?? ConnectivityService();

  EventState get state => _state;
  List<Event> get events => _events;
  String get errorMessage => _errorMessage;

  bool get isLoading => _state == EventState.loading;
  bool get hasError => _state == EventState.error;
  bool get isOffline => _state == EventState.offline;
  bool get hasData => _state == EventState.success;

  Future<void> loadEvents() async {
    _setState(EventState.loading);
    try {
      final bool connected = await _connectivityService.isConnected();
      final List<Event> result = await _repository.getEvents();
      _events = result;
      if (!connected) {
        _errorMessage = 'You are offline. Showing cached content.';
        _setState(EventState.offline);
      } else {
        _setState(EventState.success);
      }
    } catch (e) {
      _errorMessage = 'Error: ${e.toString()}';
      _setState(EventState.error);
    }
  }

  void _setState(EventState newState) {
    _state = newState;
    notifyListeners();
  }
}
