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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF000000),
        primaryColor: const Color(0xFF8B5CF6),
        fontFamily: 'SF Pro Display',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -1.2,
          ),
          displayMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.8,
          ),
          headlineLarge: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
          headlineMedium: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF94A3B8),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.1,
          ),
        ),
        colorScheme: const ColorScheme.dark(
          brightness: Brightness.dark,
          primary: Color(0xFF8B5CF6),
          onPrimary: Colors.white,
          secondary: Color(0xFF06B6D4),
          onSecondary: Colors.white,
          surface: Color(0xFF111827),
          onSurface: Colors.white,
          background: Color(0xFF000000),
          onBackground: Colors.white,
          error: Color(0xFFEF4444),
          onError: Colors.white,
        ),
        cardTheme: CardTheme(
          elevation: 0,
          color: const Color(0xFF111827),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}