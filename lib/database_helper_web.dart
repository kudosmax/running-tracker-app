import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _runsKey = 'running_tracker_runs';

  // --- Web Storage Helper Methods using localStorage ---
  
  Future<List<String>> _getRunsFromStorage() async {
    try {
      final runsJson = html.window.localStorage[_runsKey];
      if (runsJson == null || runsJson.isEmpty) return [];
      
      final List<dynamic> runsList = json.decode(runsJson);
      return runsList.cast<String>();
    } catch (e) {
      print('Error reading from localStorage: $e');
      return [];
    }
  }

  Future<void> _saveRunsToStorage(List<String> runs) async {
    try {
      html.window.localStorage[_runsKey] = json.encode(runs);
      print('Saved ${runs.length} runs to localStorage');
    } catch (e) {
      print('Error saving to localStorage: $e');
    }
  }

  // --- CRUD (Create, Read, Delete) Operations ---

  /// Adds a new run record for a given date.
  /// The date should be in 'YYYY-MM-DD' format.
  Future<void> addRun(String date) async {
    final runs = await _getRunsFromStorage();
    if (!runs.contains(date)) {
      runs.add(date);
      runs.sort(); // Keep dates sorted
      await _saveRunsToStorage(runs);
    }
  }

  /// Deletes a run record for a given date.
  /// The date should be in 'YYYY-MM-DD' format.
  Future<void> deleteRun(String date) async {
    final runs = await _getRunsFromStorage();
    runs.remove(date);
    await _saveRunsToStorage(runs);
  }

  /// Retrieves all run dates from the database.
  /// Returns a list of strings in 'YYYY-MM-DD' format.
  Future<List<String>> getRuns() async {
    final runs = await _getRunsFromStorage();
    runs.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return runs;
  }

  /// Checks if a run record exists for a given date.
  Future<bool> runExists(String date) async {
    final runs = await _getRunsFromStorage();
    return runs.contains(date);
  }

  /// Checks if the database is empty.
  Future<bool> isDatabaseEmpty() async {
    final runs = await _getRunsFromStorage();
    return runs.isEmpty;
  }
}