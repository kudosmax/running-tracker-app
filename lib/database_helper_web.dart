import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _runsKey = 'running_tracker_runs';

  // --- Web Storage Helper Methods ---
  
  Future<List<String>> _getRunsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final runsJson = prefs.getString(_runsKey);
    if (runsJson == null) return [];
    
    try {
      final List<dynamic> runsList = json.decode(runsJson);
      return runsList.cast<String>();
    } catch (e) {
      return [];
    }
  }

  Future<void> _saveRunsToPrefs(List<String> runs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_runsKey, json.encode(runs));
  }

  // --- CRUD (Create, Read, Delete) Operations ---

  /// Adds a new run record for a given date.
  /// The date should be in 'YYYY-MM-DD' format.
  Future<void> addRun(String date) async {
    final runs = await _getRunsFromPrefs();
    if (!runs.contains(date)) {
      runs.add(date);
      runs.sort(); // Keep dates sorted
      await _saveRunsToPrefs(runs);
    }
  }

  /// Deletes a run record for a given date.
  /// The date should be in 'YYYY-MM-DD' format.
  Future<void> deleteRun(String date) async {
    final runs = await _getRunsFromPrefs();
    runs.remove(date);
    await _saveRunsToPrefs(runs);
  }

  /// Retrieves all run dates from the database.
  /// Returns a list of strings in 'YYYY-MM-DD' format.
  Future<List<String>> getRuns() async {
    final runs = await _getRunsFromPrefs();
    runs.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return runs;
  }

  /// Checks if a run record exists for a given date.
  Future<bool> runExists(String date) async {
    final runs = await _getRunsFromPrefs();
    return runs.contains(date);
  }

  /// Checks if the database is empty.
  Future<bool> isDatabaseEmpty() async {
    final runs = await _getRunsFromPrefs();
    return runs.isEmpty;
  }
}