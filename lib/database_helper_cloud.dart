import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _runsKey = 'running_tracker_runs';
  static const String _syncKey = 'last_sync_time';
  
  // 클라우드 동기화를 위한 간단한 API (JSONPlaceholder 스타일)
  static const String _apiUrl = 'https://httpbin.org/post'; // Demo endpoint for testing

  // 하이브리드 저장소: 로컬 우선 + 클라우드 백업
  Future<List<String>> _getRunsFromStorage() async {
    // 로컬스토리지에서 데이터 로드
    try {
      final runsJson = html.window.localStorage[_runsKey];
      if (runsJson != null && runsJson.isNotEmpty) {
        final List<dynamic> runsList = json.decode(runsJson);
        print('✅ Loaded ${runsList.length} runs from localStorage');
        
        // 백그라운드에서 클라우드 동기화 시도
        _tryCloudSync();
        
        return runsList.cast<String>();
      }
    } catch (e) {
      print('❌ localStorage read error: $e');
    }
    
    return [];
  }

  Future<void> _saveRunsToStorage(List<String> runs) async {
    // 로컬스토리지에 즉시 저장
    try {
      html.window.localStorage[_runsKey] = json.encode(runs);
      html.window.localStorage[_syncKey] = DateTime.now().millisecondsSinceEpoch.toString();
      print('✅ Saved ${runs.length} runs to localStorage');
      
      // 백그라운드에서 클라우드 백업
      _backupToCloud(runs);
    } catch (e) {
      print('❌ localStorage save error: $e');
    }
  }

  // 백그라운드 클라우드 백업 (실패해도 앱 동작에 영향 없음)
  void _backupToCloud(List<String> runs) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'app': 'running_tracker',
          'data': runs,
          'timestamp': DateTime.now().toIso8601String(),
          'device': _getDeviceId(),
        }),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('☁️ Backup successful (${runs.length} runs)');
      } else {
        print('⚠️ Backup failed: ${response.statusCode}');
      }
    } catch (e) {
      print('⚠️ Backup error (non-critical): $e');
    }
  }

  // 백그라운드 동기화 확인
  void _tryCloudSync() async {
    try {
      final lastSync = html.window.localStorage[_syncKey];
      if (lastSync != null) {
        final lastSyncTime = DateTime.fromMillisecondsSinceEpoch(int.parse(lastSync));
        final timeDiff = DateTime.now().difference(lastSyncTime);
        
        if (timeDiff.inHours > 1) {
          print('🔄 Checking for cloud updates...');
          // 여기서 클라우드에서 최신 데이터를 가져와서 병합할 수 있음
        }
      }
    } catch (e) {
      print('⚠️ Sync check error: $e');
    }
  }

  String _getDeviceId() {
    try {
      // 브라우저 기반 고유 ID 생성
      final userAgent = html.window.navigator.userAgent;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      return 'web_${userAgent.hashCode}_$timestamp'.substring(0, 16);
    } catch (e) {
      return 'web_device_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  // --- CRUD Operations ---

  Future<void> addRun(String date) async {
    final runs = await _getRunsFromStorage();
    if (!runs.contains(date)) {
      runs.add(date);
      runs.sort();
      await _saveRunsToStorage(runs);
      print('➕ Added run: $date');
    }
  }

  Future<void> deleteRun(String date) async {
    final runs = await _getRunsFromStorage();
    if (runs.remove(date)) {
      await _saveRunsToStorage(runs);
      print('➖ Removed run: $date');
    }
  }

  Future<List<String>> getRuns() async {
    final runs = await _getRunsFromStorage();
    runs.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)
    return runs;
  }

  Future<bool> runExists(String date) async {
    final runs = await _getRunsFromStorage();
    return runs.contains(date);
  }

  Future<bool> isDatabaseEmpty() async {
    final runs = await _getRunsFromStorage();
    return runs.isEmpty;
  }

  // 수동 백업 기능 (나중에 UI에서 사용 가능)
  Future<String> exportData() async {
    final runs = await _getRunsFromStorage();
    final exportData = {
      'app': 'Running Tracker',
      'version': '1.0.0',
      'exported': DateTime.now().toIso8601String(),
      'runs': runs,
      'stats': {
        'total_runs': runs.length,
        'first_run': runs.isNotEmpty ? runs.first : null,
        'last_run': runs.isNotEmpty ? runs.last : null,
      }
    };
    return json.encode(exportData);
  }
}