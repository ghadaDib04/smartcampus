class User {
  final String email;
  final String name;
  final String studentId;
  final String specialty;
  final String section;
  final String group;
  final int year;

  const User({
    required this.email,
    required this.name,
    required this.studentId,
    required this.specialty,
    required this.section,
    required this.group,
    required this.year,
  });
}

const List<Map<String, String>> kUsers = [
  {
    'email': 'ahmed.benali@unisy.dz',
    'password': 'campus123',
    'name': 'Ahmed Benali',
    'id': 'STU-2024-001',
    'specialty': 'Computer Science',
    'section': 'A',
    'group': '1',
    'year': '3',
  },
  {
    'email': 'sara.mammeri@unisy.dz',
    'password': 'campus123',
    'name': 'Sara Mammeri',
    'id': 'STU-2024-002',
    'specialty': 'Computer Science',
    'section': 'A',
    'group': '2',
    'year': '3',
  },
  {
    'email': 'youcef.hadj@unisy.dz',
    'password': 'campus123',
    'name': 'Youcef Hadj',
    'id': 'STU-2024-003',
    'specialty': 'Software Engineering',
    'section': 'B',
    'group': '1',
    'year': '2',
  },
  {
    'email': 'amina.boukra@unisy.dz',
    'password': 'campus123',
    'name': 'Amina Boukra',
    'id': 'STU-2024-004',
    'specialty': 'Software Engineering',
    'section': 'B',
    'group': '2',
    'year': '2',
  },
  {
    'email': 'karim.zerrouk@unisy.dz',
    'password': 'campus123',
    'name': 'Karim Zerrouk',
    'id': 'STU-2024-005',
    'specialty': 'Networks & Security',
    'section': 'C',
    'group': '1',
    'year': '4',
  },
];