import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // Firebase Realtime Database REST API (인증 없이 사용 가능)
  static const String _firebaseUrl = 'https://running-tracker-demo-default-rtdb.firebaseio.com/runs.json';
  
  List<String> _cachedRuns = [];
  DateTime? _lastFetch;

  // Firebase에서 데이터 가져오기
  Future<List<String>> _fetchFromFirebase() async {
    try {
      print('🔥 Fetching data from Firebase...');
      
      final response = await http.get(
        Uri.parse(_firebaseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is List) {
          final List<String> runs = data.cast<String>();
          _cachedRuns = runs;
          _lastFetch = DateTime.now();
          print('✅ Loaded ${runs.length} runs from Firebase');
          return runs;
        } else if (data != null && data is Map) {
          // Firebase가 객체로 반환하는 경우
          final List<String> runs = data.values.toList().cast<String>();
          _cachedRuns = runs;
          _lastFetch = DateTime.now();
          print('✅ Loaded ${runs.length} runs from Firebase (object format)');
          return runs;
        }
      } else {
        print('❌ Firebase fetch failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Firebase fetch error: $e');
    }
    
    // 실패 시 빈 배열 반환
    _cachedRuns = [];
    return [];
  }

  // Firebase에 데이터 저장
  Future<bool> _saveToFirebase(List<String> runs) async {
    try {
      print('🔥 Saving ${runs.length} runs to Firebase...');
      
      final response = await http.put(
        Uri.parse(_firebaseUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(runs),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _cachedRuns = runs;
        _lastFetch = DateTime.now();
        print('✅ Successfully saved to Firebase');
        return true;
      } else {
        print('❌ Firebase save failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Firebase save error: $e');
      return false;
    }
  }

  // 스마트 캐싱 (2분 내 데이터는 캐시 사용)
  Future<List<String>> _getRuns() async {
    final now = DateTime.now();
    
    // 캐시가 2분 이내면 캐시 사용
    if (_lastFetch != null && 
        now.difference(_lastFetch!).inMinutes < 2 && 
        _cachedRuns.isNotEmpty) {
      print('⚡ Using fresh cache (${_cachedRuns.length} runs)');
      return _cachedRuns;
    }
    
    // Firebase에서 최신 데이터 가져오기
    return await _fetchFromFirebase();
  }

  // --- CRUD Operations ---

  Future<void> addRun(String date) async {
    final runs = await _getRuns();
    if (!runs.contains(date)) {
      runs.add(date);
      runs.sort();
      final success = await _saveToFirebase(runs);
      if (success) {
        print('➕ Added run: $date');
      } else {
        print('❌ Failed to add run: $date');
        throw Exception('Failed to save to Firebase');
      }
    }
  }

  Future<void> deleteRun(String date) async {
    final runs = await _getRuns();
    if (runs.remove(date)) {
      final success = await _saveToFirebase(runs);
      if (success) {
        print('➖ Removed run: $date');
      } else {
        print('❌ Failed to remove run: $date');
        throw Exception('Failed to save to Firebase');
      }
    }
  }

  Future<List<String>> getRuns() async {
    final runs = await _getRuns();
    runs.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return runs;
  }

  Future<bool> runExists(String date) async {
    final runs = await _getRuns();
    return runs.contains(date);
  }

  Future<bool> isDatabaseEmpty() async {
    final runs = await _getRuns();
    return runs.isEmpty;
  }

  // 강제 새로고침
  Future<void> forceRefresh() async {
    _lastFetch = null;
    _cachedRuns.clear();
    await _fetchFromFirebase();
  }

  // 연결 상태 확인
  Future<bool> isCloudConnected() async {
    try {
      final response = await http.get(
        Uri.parse('https://running-tracker-demo-default-rtdb.firebaseio.com/.json'),
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // 데이터 내보내기
  String exportData() {
    return json.encode({
      'app': 'Running Tracker',
      'version': '1.0.0',
      'exported': DateTime.now().toIso8601String(),
      'runs': _cachedRuns,
      'totalRuns': _cachedRuns.length,
    });
  }
}