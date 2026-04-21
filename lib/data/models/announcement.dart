
class Announcement {
  final int id;
  final String title;
  final String body;
  final String category;
  final bool isUrgent;
  final DateTime date;

  const Announcement({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.isUrgent,
    required this.date,
  });


  factory Announcement.fromJson(Map<String, dynamic> json) {
    final int id = json['id'] as int;
    final String category = _derivedCategory(id);
    final bool isUrgent = id % 2 != 0;

    final DateTime date = DateTime.now().subtract(Duration(days: id));

    return Announcement(
      id: id,
      title: json['title'] as String? ?? 'No Title',
      body: json['body'] as String? ?? 'No Content',
      category: category,
      isUrgent: isUrgent,
      date: date,
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'category': category,
      'isUrgent': isUrgent ? 1 : 0, 
      'date': date.toIso8601String(), 
    };
  }


  static String _derivedCategory(int id) {
    switch (id % 4) {
      case 0:
        return 'Academic';
      case 1:
        return 'Events';
      case 2:
        return 'General';
      case 3:
        return 'Emergency';
      default:
        return 'General';
    }
  }

  @override
  String toString() {
    return 'Announcement(id: $id, title: $title, category: $category, isUrgent: $isUrgent)';
  }
}