import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database_helper.dart';
import 'home_screen.dart';
import 'run_provider.dart';

Future<void> main() async {
  // Ensure that Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Run the data migration if it's the first launch
  await _migrateDataIfNeeded();

  runApp(
    ChangeNotifierProvider(
      create: (context) => RunProvider(),
      child: const MyApp(),
    ),
  );
}

/// Checks if data migration is needed and performs it.
Future<void> _migrateDataIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  const migrationKey = 'is_data_migrated';

  // Check if migration has already been done
  if (prefs.getBool(migrationKey) ?? false) {
    return;
  }

  final dbHelper = DatabaseHelper();

  // Check if the database is actually empty
  if (await dbHelper.isDatabaseEmpty()) {
    try {
      // Load the JSON file from assets
      final String jsonString = await rootBundle.loadString('assets/running-log.json');
      final List<dynamic> dates = json.decode(jsonString);

      // Insert each date into the database
      for (var date in dates) {
        if (date is String) {
          await dbHelper.addRun(date);
        }
      }
      
      // Mark migration as complete
      await prefs.setBool(migrationKey, true);
      debugPrint("Data migration completed successfully.");

    } catch (e) {
      debugPrint("Error during data migration: $e");
      // If migration fails, don't mark it as complete
    }
  } else {
    // If DB is not empty but flag is not set, set the flag to avoid future checks.
    await prefs.setBool(migrationKey, true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Running Tracker',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF1e1e1e),
      ),
      home: const HomeScreen(),
    );
  }
}