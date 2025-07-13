import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:html' as html;

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static const String _runsKey = 'running_tracker_runs';
  static const String _collectionName = 'runs';
  static const String _documentId = 'user_runs';
  
  FirebaseFirestore? _firestore;
  bool _isInitialized = false;

  // Initialize Firebase
  Future<void> _initializeFirebase() async {
    if (_isInitialized) return;
    
    try {
      // Firebase config - we'll set this up with a demo project
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'demo-key', // Will be replaced with real config
          appId: 'demo-app',
          messagingSenderId: 'demo-sender',
          projectId: 'running-tracker-demo',
        ),
      );
      _firestore = FirebaseFirestore.instance;
      _isInitialized = true;
      print('Firebase initialized successfully');
    } catch (e) {
      print('Firebase initialization failed: $e');
      // Fallback to localStorage if Firebase fails
      _isInitialized = false;
    }
  }

  // Hybrid storage: Try Firebase first, fallback to localStorage
  Future<List<String>> _getRunsFromStorage() async {
    await _initializeFirebase();
    
    // Try Firebase first
    if (_isInitialized && _firestore != null) {
      try {
        final doc = await _firestore!
            .collection(_collectionName)
            .doc(_documentId)
            .get();
            
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data['runs'] != null) {
            final List<dynamic> runsList = data['runs'];
            print('Loaded ${runsList.length} runs from Firebase');
            return runsList.cast<String>();
          }
        }
      } catch (e) {
        print('Firebase read error: $e');
      }
    }
    
    // Fallback to localStorage
    try {
      final runsJson = html.window.localStorage[_runsKey];
      if (runsJson != null && runsJson.isNotEmpty) {
        final List<dynamic> runsList = json.decode(runsJson);
        print('Loaded ${runsList.length} runs from localStorage');
        return runsList.cast<String>();
      }
    } catch (e) {
      print('localStorage read error: $e');
    }
    
    return [];
  }

  Future<void> _saveRunsToStorage(List<String> runs) async {
    // Always save to localStorage first (immediate backup)
    try {
      html.window.localStorage[_runsKey] = json.encode(runs);
      print('Saved ${runs.length} runs to localStorage');
    } catch (e) {
      print('localStorage save error: $e');
    }
    
    // Then try to save to Firebase
    await _initializeFirebase();
    if (_isInitialized && _firestore != null) {
      try {
        await _firestore!
            .collection(_collectionName)
            .doc(_documentId)
            .set({
              'runs': runs,
              'lastUpdated': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
        print('Saved ${runs.length} runs to Firebase');
      } catch (e) {
        print('Firebase save error: $e');
      }
    }
  }

  // --- CRUD Operations ---

  Future<void> addRun(String date) async {
    final runs = await _getRunsFromStorage();
    if (!runs.contains(date)) {
      runs.add(date);
      runs.sort();
      await _saveRunsToStorage(runs);
    }
  }

  Future<void> deleteRun(String date) async {
    final runs = await _getRunsFromStorage();
    runs.remove(date);
    await _saveRunsToStorage(runs);
  }

  Future<List<String>> getRuns() async {
    final runs = await _getRunsFromStorage();
    runs.sort((a, b) => b.compareTo(a)); // Sort descending
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
}