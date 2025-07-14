import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class DataMigrationService {
  static const String _firebaseBaseUrl = 'https://run-tracker-c16ee-default-rtdb.asia-southeast1.firebasedatabase.app';
  
  // escriboy 계정의 가상 UID (실제 Firebase Auth UID가 아닌 임시 ID)
  static const String _legacyUserId = 'legacy_user_escriboy_wjrma7675949';
  
  /// 기존 Scriptable 데이터를 특정 사용자에게 마이그레이션
  static Future<void> migrateLegacyDataToUser() async {
    final prefs = await SharedPreferences.getInstance();
    const migrationKey = 'legacy_data_migration_completed';

    // 이미 마이그레이션이 완료되었는지 확인
    if (prefs.getBool(migrationKey) ?? false) {
      debugPrint("🎯 Legacy data migration already completed, skipping...");
      return;
    }

    try {
      debugPrint("🔄 Starting legacy data migration to escriboy account...");
      
      // Scriptable JSON 데이터 로드
      final String jsonString = await rootBundle.loadString('assets/running-log.json');
      final List<dynamic> scriptableData = json.decode(jsonString);
      
      // String 형태로 변환
      final List<String> runDates = scriptableData
          .where((item) => item is String)
          .map((item) => item as String)
          .toList();
      
      debugPrint("📂 Found ${runDates.length} runs in legacy data");

      // Firebase에 기존 데이터가 있는지 확인
      final existingData = await _fetchExistingLegacyData();
      
      if (existingData.isNotEmpty) {
        debugPrint("⚠️ Legacy user already has ${existingData.length} runs, merging...");
      }

      // 기존 데이터와 합치기 (중복 제거)
      final Set<String> allRuns = <String>{};
      allRuns.addAll(existingData);
      allRuns.addAll(runDates);
      
      final List<String> finalRunsList = allRuns.toList()..sort();
      
      debugPrint("📊 Total runs after merge: ${finalRunsList.length}");

      // Firebase에 업로드
      await _uploadLegacyData(finalRunsList);
      
      // 마이그레이션 완료 마크
      await prefs.setBool(migrationKey, true);
      
      debugPrint("✅ Legacy data migration completed successfully!");
      debugPrint("👤 Data assigned to user: $_legacyUserId");
      debugPrint("🏃 Total runs migrated: ${finalRunsList.length}");

    } catch (e) {
      debugPrint("❌ Error during legacy data migration: $e");
      // 실패 시 마이그레이션 완료로 마크하지 않음
    }
  }

  /// 기존 레거시 사용자 데이터 가져오기
  static Future<List<String>> _fetchExistingLegacyData() async {
    try {
      final url = '$_firebaseBaseUrl/users/$_legacyUserId/runs.json';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data is List) {
          return data.cast<String>();
        } else if (data != null && data is Map) {
          return data.values.toList().cast<String>();
        }
      }
    } catch (e) {
      debugPrint("⚠️ Could not fetch existing legacy data: $e");
    }
    
    return [];
  }

  /// 레거시 데이터를 Firebase에 업로드
  static Future<void> _uploadLegacyData(List<String> runs) async {
    try {
      final url = '$_firebaseBaseUrl/users/$_legacyUserId/runs.json';
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(runs),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        debugPrint("☁️ Successfully uploaded ${runs.length} runs to legacy user");
        
        // 메타데이터도 저장
        await _saveLegacyUserMetadata(runs.length);
      } else {
        throw Exception('Firebase upload failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint("❌ Failed to upload legacy data: $e");
      rethrow;
    }
  }

  /// 레거시 사용자 메타데이터 저장
  static Future<void> _saveLegacyUserMetadata(int totalRuns) async {
    try {
      final metadata = {
        'userId': _legacyUserId,
        'displayName': 'escriboy',
        'email': 'wjrma7675949@legacy.com',
        'isLegacyAccount': true,
        'totalRuns': totalRuns,
        'createdAt': DateTime.now().toIso8601String(),
        'lastMigrated': DateTime.now().toIso8601String(),
        'source': 'Scriptable Migration',
      };

      final url = '$_firebaseBaseUrl/users/$_legacyUserId/metadata.json';
      
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(metadata),
      );

      if (response.statusCode == 200) {
        debugPrint("📋 Legacy user metadata saved successfully");
      }
    } catch (e) {
      debugPrint("⚠️ Could not save legacy user metadata: $e");
    }
  }

  /// 레거시 데이터 확인용 메서드
  static Future<Map<String, dynamic>?> getLegacyUserData() async {
    try {
      final runsUrl = '$_firebaseBaseUrl/users/$_legacyUserId/runs.json';
      final metadataUrl = '$_firebaseBaseUrl/users/$_legacyUserId/metadata.json';
      
      final runsResponse = await http.get(Uri.parse(runsUrl));
      final metadataResponse = await http.get(Uri.parse(metadataUrl));
      
      List<String> runs = [];
      Map<String, dynamic>? metadata;
      
      if (runsResponse.statusCode == 200) {
        final runsData = json.decode(runsResponse.body);
        if (runsData is List) {
          runs = runsData.cast<String>();
        }
      }
      
      if (metadataResponse.statusCode == 200) {
        metadata = json.decode(metadataResponse.body);
      }
      
      return {
        'userId': _legacyUserId,
        'runs': runs,
        'totalRuns': runs.length,
        'metadata': metadata,
      };
    } catch (e) {
      debugPrint("❌ Error fetching legacy user data: $e");
      return null;
    }
  }
}