import 'package:flutter/foundation.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/event.dart';
import '../models/timetable_item.dart';
import '../../core/network/connectivity_service.dart';

class EventRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource? _localDataSource;
  final ConnectivityService _connectivityService;

  EventRepository({
    RemoteDataSource? remoteDataSource,
    ConnectivityService? connectivityService,
  })  : _remoteDataSource = remoteDataSource ?? RemoteDataSource(),
        _localDataSource = kIsWeb ? null : LocalDataSource(),
        _connectivityService = connectivityService ?? ConnectivityService();

  Future<List<Event>> getEvents() async {
    final bool connected = await _connectivityService.isConnected();

    if (connected) {
      final List<Event> fresh = await _remoteDataSource.fetchEvents();
      if (!kIsWeb && _localDataSource != null) {
        await _localDataSource!.saveEvents(fresh);
      }
      return fresh;
    } else {
      if (!kIsWeb && _localDataSource != null) {
        return await _localDataSource!.getEvents();
      }
      return [];
    }
  }

  List<TimetableItem> getTimetable() {
    return TimetableItem.getSampleTimetable();
  }
}
