import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

/// Migrates Scriptable data to Firebase cloud database
Future<void> _migrateDataIfNeeded() async {
  final prefs = await SharedPreferences.getInstance();
  const migrationKey = 'firebase_migration_completed';

  // Check if Firebase migration has already been done
  if (prefs.getBool(migrationKey) ?? false) {
    debugPrint("Firebase migration already completed, skipping...");
    return;
  }

  final dbHelper = DatabaseHelper();

  try {
    debugPrint("🔄 Starting Scriptable → Firebase migration...");
    
    // Load the Scriptable JSON data from assets
    final String jsonString = await rootBundle.loadString('assets/running-log.json');
    final List<dynamic> scriptableDates = json.decode(jsonString);
    
    debugPrint("📂 Found ${scriptableDates.length} runs in Scriptable data");

    // Check if Firebase already has data
    final existingRuns = await dbHelper.getRuns();
    if (existingRuns.isNotEmpty) {
      debugPrint("☁️ Firebase already has ${existingRuns.length} runs, merging data...");
    }

    // Prepare the complete dataset (merge existing + Scriptable data)
    final Set<String> allRuns = <String>{};
    
    // Add existing Firebase data
    allRuns.addAll(existingRuns);
    
    // Add Scriptable data
    for (var date in scriptableDates) {
      if (date is String) {
        allRuns.add(date);
      }
    }

    // Convert to sorted list
    final List<String> finalRunsList = allRuns.toList()..sort();
    
    debugPrint("📊 Total unique runs after merge: ${finalRunsList.length}");

    // Upload all data to Firebase at once (efficient bulk operation)
    await _bulkUploadToFirebase(finalRunsList);
    
    // Mark migration as complete
    await prefs.setBool(migrationKey, true);
    debugPrint("✅ Scriptable → Firebase migration completed successfully!");
    debugPrint("🎯 Total runs now in Firebase: ${finalRunsList.length}");

  } catch (e) {
    debugPrint("❌ Error during Firebase migration: $e");
    // Don't mark as complete if migration fails
  }
}

/// Bulk upload data directly to Firebase (more efficient than individual adds)
Future<void> _bulkUploadToFirebase(List<String> runs) async {
  try {
    final response = await http.put(
      Uri.parse('https://run-tracker-c16ee-default-rtdb.asia-southeast1.firebasedatabase.app/runs.json'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(runs),
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      debugPrint("☁️ Successfully uploaded ${runs.length} runs to Firebase");
    } else {
      throw Exception('Firebase upload failed: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("❌ Firebase bulk upload error: $e");
    rethrow;
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