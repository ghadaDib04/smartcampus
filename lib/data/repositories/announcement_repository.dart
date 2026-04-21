// AnnouncementRepository — the middleman between UI and data sources.
// The UI calls this. This decides where data comes from.
// Right now: always from the API.
// Week 3: from SQLite when offline, API when online.

import '../datasources/remote_data_source.dart';
import '../models/announcement.dart';

class AnnouncementRepository {
  // The repository owns an instance of RemoteDataSource.
  // It never exposes this to the outside — it is private.
  final RemoteDataSource _remoteDataSource;

  // Constructor — we pass the RemoteDataSource in from outside.
  // This is called Dependency Injection — instead of creating
  // RemoteDataSource inside this class, we receive it as a parameter.
  // This makes testing easier and keeps classes loosely coupled.
  AnnouncementRepository({
    RemoteDataSource? remoteDataSource,
  }) : _remoteDataSource = remoteDataSource ?? RemoteDataSource();

  // Fetches announcements.
  // Currently always goes to the API.
  // Returns the list on success, throws NetworkException on failure.
  Future<List<Announcement>> getAnnouncements() async {
    return await _remoteDataSource.fetchAnnouncements();
  }
}