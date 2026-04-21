
enum DayOfWeek {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday,
}


extension DayOfWeekExtension on DayOfWeek {
  // Returns the human-readable name of the day
  String get displayName {
    switch (this) {
      case DayOfWeek.monday:
        return 'Monday';
      case DayOfWeek.tuesday:
        return 'Tuesday';
      case DayOfWeek.wednesday:
        return 'Wednesday';
      case DayOfWeek.thursday:
        return 'Thursday';
      case DayOfWeek.friday:
        return 'Friday';
      case DayOfWeek.saturday:
        return 'Saturday';
      case DayOfWeek.sunday:
        return 'Sunday';
    }
  }
}

class TimetableItem {
  final int id;
  final String subject;
  final String professor;
  final String room;
  final String startTime;
  final String endTime;
  final DayOfWeek day;
  final String type; // 'Lecture', 'Lab', 'Tutorial', 'Workshop'

  const TimetableItem({
    required this.id,
    required this.subject,
    required this.professor,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.type,
  });

  // toJson for SQLite storage in Week 3.
  // Notice we store the enum as a string using .name
  // DayOfWeek.monday.name returns the string 'monday'
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'professor': professor,
      'room': room,
      'startTime': startTime,
      'endTime': endTime,
      // .name converts the enum value to its string name
      'day': day.name,
      'type': type,
    };
  }

  // fromDb — reads a TimetableItem back from SQLite.
  factory TimetableItem.fromDb(Map<String, dynamic> db) {
    return TimetableItem(
      id: db['id'] as int,
      subject: db['subject'] as String,
      professor: db['professor'] as String,
      room: db['room'] as String,
      startTime: db['startTime'] as String,
      endTime: db['endTime'] as String,
      // Convert the stored string back to a DayOfWeek enum value.
      // DayOfWeek.values is the list of all enum values.
      // .firstWhere finds the one whose .name matches the stored string.
      day: DayOfWeek.values.firstWhere(
        (d) => d.name == db['day'] as String,
      ),
      type: db['type'] as String,
    );
  }

  // Static method that returns a hardcoded weekly timetable.
  // This is what the repository will return instead of making an API call.
  // Static means you call it as TimetableItem.getSampleTimetable()
  // without needing to create a TimetableItem object first.
  static List<TimetableItem> getSampleTimetable() {
    return [
      const TimetableItem(
        id: 1,
        subject: 'Mobile Operating Systems',
        professor: 'Dr. Benali',
        room: 'Building A, Room 101',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.monday,
        type: 'Lecture',
      ),
      const TimetableItem(
        id: 2,
        subject: 'Database Systems',
        professor: 'Dr. Meziane',
        room: 'Lab 3',
        startTime: '10:00',
        endTime: '11:30',
        day: DayOfWeek.monday,
        type: 'Lab',
      ),
      const TimetableItem(
        id: 3,
        subject: 'Software Engineering',
        professor: 'Dr. Khelil',
        room: 'Building B, Room 204',
        startTime: '13:00',
        endTime: '14:30',
        day: DayOfWeek.tuesday,
        type: 'Lecture',
      ),
      const TimetableItem(
        id: 4,
        subject: 'Computer Networks',
        professor: 'Dr. Amrani',
        room: 'Building A, Room 105',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.wednesday,
        type: 'Lecture',
      ),
      const TimetableItem(
        id: 5,
        subject: 'Mobile Operating Systems',
        professor: 'Dr. Benali',
        room: 'Lab 2',
        startTime: '10:00',
        endTime: '12:00',
        day: DayOfWeek.wednesday,
        type: 'Lab',
      ),
      const TimetableItem(
        id: 6,
        subject: 'Human Computer Interaction',
        professor: 'Dr. Saadi',
        room: 'Building C, Room 301',
        startTime: '14:00',
        endTime: '15:30',
        day: DayOfWeek.thursday,
        type: 'Tutorial',
      ),
      const TimetableItem(
        id: 7,
        subject: 'Database Systems',
        professor: 'Dr. Meziane',
        room: 'Building B, Room 202',
        startTime: '09:00',
        endTime: '10:30',
        day: DayOfWeek.friday,
        type: 'Lecture',
      ),
    ];
  }

  @override
  String toString() {
    return 'TimetableItem(id: $id, subject: $subject, day: ${day.displayName}, startTime: $startTime)';
  }
}