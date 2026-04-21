// EventRepository — same pattern as AnnouncementRepository.
// Middleman between UI and data sources for Events.

import '../datasources/remote_data_source.dart';
import '../models/event.dart';
import '../models/timetable_item.dart';

class EventRepository {
  final RemoteDataSource _remoteDataSource;

  EventRepository({
    RemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? RemoteDataSource();

  // Fetches events from the API.
  Future<List<Event>> getEvents() async {
    return await _remoteDataSource.fetchEvents();
  }

  // Returns the hardcoded timetable.
  // No API call needed — data lives in the model itself.
  // This is synchronous — no async/await needed because
  // we are not waiting for any network or disk operation.
  List<TimetableItem> getTimetable() {
    return TimetableItem.getSampleTimetable();
  }
}