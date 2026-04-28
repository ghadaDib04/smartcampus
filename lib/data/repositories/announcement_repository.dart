import 'package:flutter/foundation.dart';
import '../datasources/remote_data_source.dart';
import '../datasources/local_data_source.dart';
import '../models/announcement.dart';
import '../../core/network/connectivity_service.dart';

class AnnouncementRepository {
  final RemoteDataSource _remoteDataSource;
  final LocalDataSource? _localDataSource;
  final ConnectivityService _connectivityService;

  AnnouncementRepository({
    RemoteDataSource? remoteDataSource,
    ConnectivityService? connectivityService,
  })  : _remoteDataSource = remoteDataSource ?? RemoteDataSource(),
        _localDataSource = kIsWeb ? null : LocalDataSource(),
        _connectivityService = connectivityService ?? ConnectivityService();

  Future<List<Announcement>> getAnnouncements() async {
    final bool connected = await _connectivityService.isConnected();

    if (connected) {
      // Online : fetch depuis API
      final List<Announcement> fresh =
      await _remoteDataSource.fetchAnnouncements();
      // Sauvegarde SQLite uniquement sur mobile
      if (!kIsWeb && _localDataSource != null) {
        await _localDataSource!.saveAnnouncements(fresh);
      }
      return fresh;
    } else {
      // Offline : SQLite sur mobile, liste vide sur web
      if (!kIsWeb && _localDataSource != null) {
        return await _localDataSource!.getAnnouncements();
      }
      return [];
    }
  }
}