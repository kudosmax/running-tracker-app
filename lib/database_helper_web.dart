import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Local storage key for runs data
  static const String _storageKey = 'running_tracker_runs';
  
  List<String> _cachedRuns = [];
  bool _isInitialized = false;

  /// Initialize from localStorage (web-only)
  Future<void> _initializeFromStorage() async {
    if (_isInitialized) return;
    
    try {
      final storedData = html.window.localStorage[_storageKey];
      if (storedData != null && storedData.isNotEmpty) {
        final List<dynamic> runsData = json.decode(storedData);
        _cachedRuns = runsData.cast<String>();
        print('✅ Loaded ${_cachedRuns.length} runs from localStorage');
      } else {
        _cachedRuns = [];
        print('📂 No existing data in localStorage, starting fresh');
      }
    } catch (e) {
      print('⚠️ Error loading from localStorage: $e');
      _cachedRuns = [];
    }
    
    _isInitialized = true;
  }

  /// Save runs to localStorage
  Future<void> _saveToStorage() async {
    try {
      final jsonData = json.encode(_cachedRuns);
      html.window.localStorage[_storageKey] = jsonData;
      print('💾 Saved ${_cachedRuns.length} runs to localStorage');
    } catch (e) {
      print('❌ Error saving to localStorage: $e');
    }
  }

  // --- CRUD Operations ---

  Future<void> addRun(String date) async {
    await _initializeFromStorage();
    
    if (!_cachedRuns.contains(date)) {
      _cachedRuns.add(date);
      _cachedRuns.sort();
      await _saveToStorage();
      print('➕ Added run: $date');
    }
  }

  Future<void> deleteRun(String date) async {
    await _initializeFromStorage();
    
    if (_cachedRuns.remove(date)) {
      await _saveToStorage();
      print('➖ Removed run: $date');
    }
  }

  Future<List<String>> getRuns() async {
    await _initializeFromStorage();
    
    // Return copy sorted descending (newest first)
    final sortedRuns = List<String>.from(_cachedRuns);
    sortedRuns.sort((a, b) => b.compareTo(a));
    return sortedRuns;
  }

  Future<bool> runExists(String date) async {
    await _initializeFromStorage();
    return _cachedRuns.contains(date);
  }

  Future<bool> isDatabaseEmpty() async {
    await _initializeFromStorage();
    return _cachedRuns.isEmpty;
  }

  // 강제 새로고침 (웹에서는 localStorage에서 다시 로드)
  Future<void> forceRefresh() async {
    _isInitialized = false;
    await _initializeFromStorage();
  }

  // 연결 상태 확인 (웹에서는 항상 true)
  Future<bool> isCloudConnected() async {
    return true; // localStorage is always available
  }

  // 데이터 내보내기
  String exportData() {
    return json.encode({
      'app': 'Running Tracker',
      'version': '1.0.0',
      'platform': 'web',
      'exported': DateTime.now().toIso8601String(),
      'runs': _cachedRuns,
      'totalRuns': _cachedRuns.length,
    });
  }

  // 데이터 가져오기 (JSON 문자열에서)
  Future<void> importData(String jsonData) async {
    try {
      final Map<String, dynamic> data = json.decode(jsonData);
      if (data['runs'] is List) {
        _cachedRuns = (data['runs'] as List).cast<String>();
        _cachedRuns.sort();
        await _saveToStorage();
        print('📥 Imported ${_cachedRuns.length} runs');
      }
    } catch (e) {
      print('❌ Error importing data: $e');
      throw Exception('Failed to import data: $e');
    }
  }
}