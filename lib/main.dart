// main.dart — Application entry point.
// Flutter starts here. This file should stay as simple as possible.
// All configuration lives in app.dart, not here.

import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  // Ensures Flutter's binding is initialized before we use any services.
  // Required whenever main() is async or uses platform services.
  // Must be the very first line inside main().
  WidgetsFlutterBinding.ensureInitialized();

  // Launch the app with our root widget.
  // Everything flows from SmartCampusApp downward.
  runApp(const SmartCampusApp());
}