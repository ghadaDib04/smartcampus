import 'package:flutter/material.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF27C7D4),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Timetable',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: const Center(child: Text('Timetable coming soon')),
    );
  }
}