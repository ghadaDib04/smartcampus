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
  String get displayName {
    switch (this) {
      case DayOfWeek.monday: return 'Monday';
      case DayOfWeek.tuesday: return 'Tuesday';
      case DayOfWeek.wednesday: return 'Wednesday';
      case DayOfWeek.thursday: return 'Thursday';
      case DayOfWeek.friday: return 'Friday';
      case DayOfWeek.saturday: return 'Saturday';
      case DayOfWeek.sunday: return 'Sunday';
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
  final String type;
  final String group;
  final String specialty;

  const TimetableItem({
    required this.id,
    required this.subject,
    required this.professor,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.type,
    required this.group,
    required this.specialty,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject': subject,
      'professor': professor,
      'room': room,
      'startTime': startTime,
      'endTime': endTime,
      'day': day.name,
      'type': type,
      'group': group,
      'specialty': specialty,
    };
  }

  factory TimetableItem.fromDb(Map<String, dynamic> db) {
    return TimetableItem(
      id: db['id'] as int,
      subject: db['subject'] as String,
      professor: db['professor'] as String,
      room: db['room'] as String,
      startTime: db['startTime'] as String,
      endTime: db['endTime'] as String,
      day: DayOfWeek.values.firstWhere((d) => d.name == db['day']),
      type: db['type'] as String,
      group: db['group'] as String,
      specialty: db['specialty'] as String,
    );
  }


  static List<TimetableItem> getSampleTimetable({
    String group = '1',
    String specialty = 'Computer Science',
  }) {
    final all = [
      // ── Computer Science — Group 1 ──────────────────
      const TimetableItem(
        id: 1,
        subject: 'Mobile Operating Systems',
        professor: 'Dr. Benali',
        room: 'Building A, Room 101',
        startTime: '11:30',
        endTime: '13:30',
        day: DayOfWeek.monday,
        type: 'Lecture',
        group: '1',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 2,
        subject: 'Database Systems',
        professor: 'Dr. Meziane',
        room: 'Lab 3',
        startTime: '15:30',
        endTime: '17:30',
        day: DayOfWeek.monday,
        type: 'Lab',
        group: '1',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 3,
        subject: 'Computer Networks',
        professor: 'Dr. Amrani',
        room: 'Building A, Room 105',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.wednesday,
        type: 'Lecture',
        group: '1',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 4,
        subject: 'Algorithms',
        professor: 'Dr. Hadj',
        room: 'Building A, Room 203',
        startTime: '14:00',
        endTime: '15:30',
        day: DayOfWeek.thursday,
        type: 'Lecture',
        group: '1',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 5,
        subject: 'Mobile Operating Systems',
        professor: 'Dr. Benali',
        room: 'Lab 2',
        startTime: '09:00',
        endTime: '11:00',
        day: DayOfWeek.friday,
        type: 'Lab',
        group: '1',
        specialty: 'Computer Science',
      ),

      // ── Computer Science — Group 2 ──────────────────
      const TimetableItem(
        id: 6,
        subject: 'Mobile Operating Systems',
        professor: 'Dr. Benali',
        room: 'Building A, Room 101',
        startTime: '10:00',
        endTime: '11:30',
        day: DayOfWeek.monday,
        type: 'Lecture',
        group: '2',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 7,
        subject: 'Database Systems',
        professor: 'Dr. Meziane',
        room: 'Lab 3',
        startTime: '13:00',
        endTime: '14:30',
        day: DayOfWeek.tuesday,
        type: 'Lab',
        group: '2',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 8,
        subject: 'Computer Networks',
        professor: 'Dr. Amrani',
        room: 'Building A, Room 105',
        startTime: '10:00',
        endTime: '11:30',
        day: DayOfWeek.wednesday,
        type: 'Lecture',
        group: '2',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 9,
        subject: 'Algorithms',
        professor: 'Dr. Hadj',
        room: 'Building B, Room 101',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.thursday,
        type: 'Lecture',
        group: '2',
        specialty: 'Computer Science',
      ),
      const TimetableItem(
        id: 10,
        subject: 'Mobile Operating Systems',
        professor: 'Dr. Benali',
        room: 'Lab 1',
        startTime: '13:00',
        endTime: '15:00',
        day: DayOfWeek.friday,
        type: 'Lab',
        group: '2',
        specialty: 'Computer Science',
      ),

      // ── Software Engineering — Group 1 ──────────────
      const TimetableItem(
        id: 11,
        subject: 'Software Engineering',
        professor: 'Dr. Khelil',
        room: 'Building B, Room 204',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.monday,
        type: 'Lecture',
        group: '1',
        specialty: 'Software Engineering',
      ),
      const TimetableItem(
        id: 12,
        subject: 'Design Patterns',
        professor: 'Dr. Zerrouk',
        room: 'Building B, Room 101',
        startTime: '10:00',
        endTime: '11:30',
        day: DayOfWeek.tuesday,
        type: 'Lecture',
        group: '1',
        specialty: 'Software Engineering',
      ),
      const TimetableItem(
        id: 13,
        subject: 'Software Testing',
        professor: 'Dr. Mammeri',
        room: 'Lab 4',
        startTime: '13:00',
        endTime: '15:00',
        day: DayOfWeek.wednesday,
        type: 'Lab',
        group: '1',
        specialty: 'Software Engineering',
      ),
      const TimetableItem(
        id: 14,
        subject: 'Agile Methods',
        professor: 'Dr. Khelil',
        room: 'Building C, Room 201',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.friday,
        type: 'Tutorial',
        group: '1',
        specialty: 'Software Engineering',
      ),

      // ── Software Engineering — Group 2 ──────────────
      const TimetableItem(
        id: 15,
        subject: 'Software Engineering',
        professor: 'Dr. Khelil',
        room: 'Building B, Room 205',
        startTime: '13:00',
        endTime: '14:30',
        day: DayOfWeek.monday,
        type: 'Lecture',
        group: '2',
        specialty: 'Software Engineering',
      ),
      const TimetableItem(
        id: 16,
        subject: 'Design Patterns',
        professor: 'Dr. Zerrouk',
        room: 'Building B, Room 102',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.wednesday,
        type: 'Lecture',
        group: '2',
        specialty: 'Software Engineering',
      ),
      const TimetableItem(
        id: 17,
        subject: 'Software Testing',
        professor: 'Dr. Mammeri',
        room: 'Lab 5',
        startTime: '10:00',
        endTime: '12:00',
        day: DayOfWeek.thursday,
        type: 'Lab',
        group: '2',
        specialty: 'Software Engineering',
      ),
      const TimetableItem(
        id: 18,
        subject: 'Agile Methods',
        professor: 'Dr. Khelil',
        room: 'Building C, Room 202',
        startTime: '13:00',
        endTime: '14:30',
        day: DayOfWeek.friday,
        type: 'Tutorial',
        group: '2',
        specialty: 'Software Engineering',
      ),

      // ── Networks & Security — Group 1 ───────────────
      const TimetableItem(
        id: 19,
        subject: 'Network Security',
        professor: 'Dr. Boukra',
        room: 'Building A, Room 302',
        startTime: '08:00',
        endTime: '09:30',
        day: DayOfWeek.monday,
        type: 'Lecture',
        group: '1',
        specialty: 'Networks & Security',
      ),
      const TimetableItem(
        id: 20,
        subject: 'Cryptography',
        professor: 'Dr. Saadi',
        room: 'Building A, Room 301',
        startTime: '10:00',
        endTime: '11:30',
        day: DayOfWeek.tuesday,
        type: 'Lecture',
        group: '1',
        specialty: 'Networks & Security',
      ),
      const TimetableItem(
        id: 21,
        subject: 'Network Administration',
        professor: 'Dr. Boukra',
        room: 'Lab Network 1',
        startTime: '13:00',
        endTime: '15:00',
        day: DayOfWeek.wednesday,
        type: 'Lab',
        group: '1',
        specialty: 'Networks & Security',
      ),
      const TimetableItem(
        id: 22,
        subject: 'Ethical Hacking',
        professor: 'Dr. Saadi',
        room: 'Lab Security',
        startTime: '08:00',
        endTime: '10:00',
        day: DayOfWeek.thursday,
        type: 'Lab',
        group: '1',
        specialty: 'Networks & Security',
      ),
      const TimetableItem(
        id: 23,
        subject: 'Cryptography',
        professor: 'Dr. Saadi',
        room: 'Building A, Room 301',
        startTime: '09:00',
        endTime: '10:30',
        day: DayOfWeek.friday,
        type: 'Tutorial',
        group: '1',
        specialty: 'Networks & Security',
      ),
      const TimetableItem(
           id: 101,
           subject: 'Mobile Operating Systems',
           professor: 'Dr. Benali',
           room: 'Room 101',
           startTime: '16:42',
           endTime: '17:15',
           day: DayOfWeek.tuesday,
           type: 'Lecture',
           group: '1',
           specialty: 'Computer Science',
      ),     
    ];

    return all
        .where((item) =>
    item.group == group && item.specialty == specialty)
        .toList();
  }

  @override
  String toString() {
    return 'TimetableItem(id: $id, subject: $subject, day: ${day.displayName}, startTime: $startTime)';
  }
}