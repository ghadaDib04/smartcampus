import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/announcement.dart';
import '../models/event.dart';

class LocalDataSource {
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    try {
      final String path = join(await getDatabasesPath(), 'smartcampus.db');
      return await openDatabase(
        path,
        version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE announcements (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            body TEXT NOT NULL,
            category TEXT NOT NULL,
            isUrgent INTEGER NOT NULL,
            date TEXT NOT NULL
          )
        ''');
          await db.execute('''
          CREATE TABLE events (
            id INTEGER PRIMARY KEY,
            title TEXT NOT NULL,
            location TEXT NOT NULL,
            date TEXT NOT NULL,
            startTime TEXT NOT NULL,
            endTime TEXT NOT NULL,
            category TEXT NOT NULL,
            tags TEXT NOT NULL,
            isBookmarked INTEGER NOT NULL
          )
        ''');
        },
      );
    } catch (e) {
      rethrow;
    }
  }

  // ── Announcements ──────────────────────────────────

  Future<void> saveAnnouncements(List<Announcement> items) async {
    final Database db = await database;
    final Batch batch = db.batch();
    for (final Announcement item in items) {
      batch.insert(
        'announcements',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Announcement>> getAnnouncements() async {
    final Database db = await database;
    final List<Map<String, dynamic>> rows =
    await db.query('announcements', orderBy: 'id DESC');
    return rows.map((row) => Announcement.fromJson({
      'id': row['id'],
      'title': row['title'],
      'body': row['body'],
      'category': row['category'],
      'isUrgent': row['isUrgent'] == 1,
      'date': row['date'],
    })).toList();
  }

  // ── Events ─────────────────────────────────────────

  Future<void> saveEvents(List<Event> items) async {
    final Database db = await database;
    final Batch batch = db.batch();
    for (final Event item in items) {
      batch.insert(
        'events',
        item.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Event>> getEvents() async {
    final Database db = await database;
    final List<Map<String, dynamic>> rows =
    await db.query('events', orderBy: 'id DESC');
    return rows.map((row) => Event.fromDb(row)).toList();
  }
}