
class Event {
  final int id;
  final String title;
  final String location;
  final DateTime date;
  final String startTime;
  final String endTime;
  final String category;
  final List<String> tags;
  final bool isBookmarked;

  const Event({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.category,
    required this.tags,
    required this.isBookmarked,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int;

    final String location = _derivedLocation(id);


    final int hour = 8 + (id % 8);
    final String startTime =
        '${hour.toString().padLeft(2, '0')}:00';

    final int endHour = hour + 1;
    const int endMinute = 30;
    final String endTime =
        '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';

    final DateTime date =
        DateTime.now().add(const Duration(days: 14));

    // Derive category
    final String category = _derivedCategory(id);

    // Derive tags — each event gets 1 or 2 tags based on id
    final List<String> tags = _derivedTags(id);

    return Event(
      id: id,
      title: json['title'] as String? ?? 'Untitled Event',
      location: location,
      date: date,
      startTime: startTime,
      endTime: endTime,
      category: category,
      tags: tags,

      isBookmarked: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'category': category,
      // join() converts the list to a string for SQLite storage
      'tags': tags.join(','),
      'isBookmarked': isBookmarked ? 1 : 0,
    };
  }


  factory Event.fromDb(Map<String, dynamic> db) {
    return Event(
      id: db['id'] as int,
      title: db['title'] as String,
      location: db['location'] as String,
      date: DateTime.parse(db['date'] as String),
      startTime: db['startTime'] as String,
      endTime: db['endTime'] as String,
      category: db['category'] as String,
      tags: (db['tags'] as String).split(','),
      isBookmarked: (db['isBookmarked'] as int) == 1,
    );
  }


  static String _derivedLocation(int id) {
    const locations = [
      'Amphitheater Hall',
      'Building B, Room 204',
      'Main Library',
      'Science Lab 3',
      'Sports Complex',
      'Conference Room A',
    ];
    return locations[id % locations.length];
  }

  static String _derivedCategory(int id) {
    switch (id % 4) {
      case 0:
        return 'Academic';
      case 1:
        return 'Social';
      case 2:
        return 'Sports';
      case 3:
        return 'Workshop';
      default:
        return 'General';
    }
  }

  static List<String> _derivedTags(int id) {
    final allTags = [
      ['Lecture', 'Core'],
      ['Workshop', 'Lab'],
      ['Seminar', 'Elective'],
      ['Club', 'Social'],
    ];
    return allTags[id % allTags.length];
  }

  @override
  String toString() {
    return 'Event(id: $id, title: $title, location: $location, date: $date)';
  }
}