import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // 실제 클라우드 JSON 저장소 (jsonbin.io)
  static const String _binId = '67442e39e41b4d34e457d278'; // Demo bin
  static const String _apiUrl = 'https://api.jsonbin.io/v3/b/$_binId';
  static const String _readUrl = 'https://api.jsonbin.io/v3/b/$_binId/latest';
  
  // API 키 (실제 운영에서는 환경변수 사용)
  static const String _apiKey = '\$2a\$10\$KLdAHKMZAV85hYoovyFaFujl0Xd4TlYGGtRZmdfKqOFNrm3t2P2k2';

  List<String> _cachedRuns = [];
  DateTime? _lastFetch;

  // 클라우드에서 데이터 가져오기
  Future<List<String>> _fetchFromCloud() async {
    try {
      print('🔍 Fetching data from cloud...');
      
      final response = await http.get(
        Uri.parse(_readUrl),
        headers: {
          'X-Master-Key': _apiKey,
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['record'] != null && data['record']['runs'] != null) {
          final List<dynamic> runsList = data['record']['runs'];
          _cachedRuns = runsList.cast<String>();
          _lastFetch = DateTime.now();
          print('✅ Loaded ${_cachedRuns.length} runs from cloud');
          return _cachedRuns;
        }
      } else {
        print('❌ Cloud fetch failed: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ Cloud fetch error: $e');
    }
    
    // 캐시된 데이터가 있으면 반환
    if (_cachedRuns.isNotEmpty) {
      print('📦 Using cached data (${_cachedRuns.length} runs)');
      return _cachedRuns;
    }
    
    return [];
  }

  // 클라우드에 데이터 저장
  Future<bool> _saveToCloud(List<String> runs) async {
    try {
      print('☁️ Saving ${runs.length} runs to cloud...');
      
      final response = await http.put(
        Uri.parse(_apiUrl),
        headers: {
          'X-Master-Key': _apiKey,
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'runs': runs,
          'lastUpdated': DateTime.now().toIso8601String(),
          'totalRuns': runs.length,
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        _cachedRuns = runs;
        _lastFetch = DateTime.now();
        print('✅ Successfully saved to cloud');
        return true;
      } else {
        print('❌ Cloud save failed: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('❌ Cloud save error: $e');
      return false;
    }
  }

  // 스마트 캐싱 (5분 내 데이터는 캐시 사용)
  Future<List<String>> _getRunsFromCloud() async {
    final now = DateTime.now();
    
    // 캐시가 5분 이내면 캐시 사용
    if (_lastFetch != null && 
        now.difference(_lastFetch!).inMinutes < 5 && 
        _cachedRuns.isNotEmpty) {
      print('⚡ Using fresh cache (${_cachedRuns.length} runs)');
      return _cachedRuns;
    }
    
    // 아니면 클라우드에서 새로 가져오기
    return await _fetchFromCloud();
  }

  // --- CRUD Operations ---

  Future<void> addRun(String date) async {
    final runs = await _getRunsFromCloud();
    if (!runs.contains(date)) {
      runs.add(date);
      runs.sort();
      final success = await _saveToCloud(runs);
      if (success) {
        print('➕ Added run: $date');
      } else {
        print('❌ Failed to add run: $date');
      }
    }
  }

  Future<void> deleteRun(String date) async {
    final runs = await _getRunsFromCloud();
    if (runs.remove(date)) {
      final success = await _saveToCloud(runs);
      if (success) {
        print('➖ Removed run: $date');
      } else {
        print('❌ Failed to remove run: $date');
      }
    }
  }

  Future<List<String>> getRuns() async {
    final runs = await _getRunsFromCloud();
    runs.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return runs;
  }

  Future<bool> runExists(String date) async {
    final runs = await _getRunsFromCloud();
    return runs.contains(date);
  }

  Future<bool> isDatabaseEmpty() async {
    final runs = await _getRunsFromCloud();
    return runs.isEmpty;
  }

  // 강제 새로고침 (캐시 무시하고 클라우드에서 최신 데이터 가져오기)
  Future<void> forceRefresh() async {
    _lastFetch = null;
    _cachedRuns.clear();
    await _fetchFromCloud();
  }

  // 연결 상태 확인
  Future<bool> isCloudConnected() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.jsonbin.io/v3/'),
        headers: {'X-Master-Key': _apiKey},
      ).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}