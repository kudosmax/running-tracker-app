import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'database_helper.dart';

class RunProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  List<String> _runDates = [];
  bool _isLoading = false;

  List<String> get runDates => _runDates;
  bool get isLoading => _isLoading;

  RunProvider() {
    // Load initial data when the provider is created
    loadRuns();
  }

  /// Loads all run dates from the database and updates the state.
  Future<void> loadRuns() async {
    _setLoading(true);
    _runDates = await _dbHelper.getRuns();
    _setLoading(false);
  }

  /// Toggles the run status for today.
  /// Adds a run if it doesn't exist, deletes it if it does.
  Future<void> toggleToday() async {
    _setLoading(true);
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    if (_runDates.contains(today)) {
      await _dbHelper.deleteRun(today);
    } else {
      await _dbHelper.addRun(today);
    }

    // Reload the data from DB to ensure consistency
    await loadRuns();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
