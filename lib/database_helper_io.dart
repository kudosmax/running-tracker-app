import 'dart:async';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    
    // Initialize sqflite for different platforms
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'running_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE runs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE
      )
    ''');
  }

  // --- CRUD (Create, Read, Delete) Operations ---

  /// Adds a new run record for a given date.
  /// The date should be in 'YYYY-MM-DD' format.
  Future<void> addRun(String date) async {
    final db = await database;
    await db.insert(
      'runs',
      {'date': date},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Deletes a run record for a given date.
  /// The date should be in 'YYYY-MM-DD' format.
  Future<void> deleteRun(String date) async {
    final db = await database;
    await db.delete(
      'runs',
      where: 'date = ?',
      whereArgs: [date],
    );
  }

  /// Retrieves all run dates from the database.
  /// Returns a list of strings in 'YYYY-MM-DD' format.
  Future<List<String>> getRuns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('runs', orderBy: 'date DESC');
    
    if (maps.isEmpty) {
      return [];
    }

    return List.generate(maps.length, (i) {
      return maps[i]['date'] as String;
    });
  }

  /// Checks if a run record exists for a given date.
  Future<bool> runExists(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'runs',
      where: 'date = ?',
      whereArgs: [date],
    );
    return maps.isNotEmpty;
  }

  /// Checks if the database is empty.
  Future<bool> isDatabaseEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM runs'));
    return count == 0;
  }
}