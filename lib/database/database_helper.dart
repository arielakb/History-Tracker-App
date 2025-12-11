import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/location_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = '${documentsDirectory.path}/location_history.db';

    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE location_entries (
        id TEXT PRIMARY KEY,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp TEXT NOT NULL,
        address TEXT,
        accuracy TEXT
      )
      ''');

    // Create index on timestamp for faster queries
    await db.execute(
      'CREATE INDEX idx_timestamp ON location_entries(timestamp)',
    );
  }

  // Insert a location entry
  Future<void> insertLocationEntry(LocationEntry entry) async {
    final db = await database;
    await db.insert(
      'location_entries',
      entry.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Get all location entries
  Future<List<LocationEntry>> getAllLocationEntries() async {
    final db = await database;
    final maps = await db.query('location_entries', orderBy: 'timestamp DESC');

    return List.generate(maps.length, (i) => LocationEntry.fromMap(maps[i]));
  }

  // Get location entries for a specific date
  Future<List<LocationEntry>> getLocationEntriesByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final maps = await db.query(
      'location_entries',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => LocationEntry.fromMap(maps[i]));
  }

  // Get location entries for a specific day of week
  // dayOfWeek: 1 = Monday, 7 = Sunday
  Future<List<LocationEntry>> getLocationEntriesByDayOfWeek(
    int dayOfWeek,
  ) async {
    final allEntries = await getAllLocationEntries();

    return allEntries
        .where((entry) => entry.timestamp.weekday == dayOfWeek)
        .toList();
  }

  // Get location entries within a date range
  Future<List<LocationEntry>> getLocationEntriesInRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'location_entries',
      where: 'timestamp >= ? AND timestamp <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) => LocationEntry.fromMap(maps[i]));
  }

  // Update location entry (used for adding address after geocoding)
  Future<void> updateLocationEntry(LocationEntry entry) async {
    final db = await database;
    await db.update(
      'location_entries',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  // Delete a location entry
  Future<void> deleteLocationEntry(String id) async {
    final db = await database;
    await db.delete('location_entries', where: 'id = ?', whereArgs: [id]);
  }

  // Delete all location entries
  Future<void> deleteAllLocationEntries() async {
    final db = await database;
    await db.delete('location_entries');
  }

  // Get count of location entries
  Future<int> getLocationEntriesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM location_entries',
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Close database
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
