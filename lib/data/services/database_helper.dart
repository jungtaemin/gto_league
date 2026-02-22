import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper that manages the local GTO SQLite database.
///
/// Tables are created on first launch for the legacy push/call range system.
/// The primary GTO data source is now `gto_master_db.json` (loaded by
/// `gto_data_provider.dart`). This helper remains for backward compatibility
/// with [GtoRepository].
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  /// Bump this to force a full re-migration from CSV on next launch.
  static const int _dbVersion = 1;

  DatabaseHelper._init();

  // ---------------------------------------------------------------------------
  // Public API
  // ---------------------------------------------------------------------------

  /// Returns the opened (and migrated) database, initialising lazily.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('gto.db');
    return _database!;
  }

  /// Convenience entry-point – call once at app startup.
  Future<void> initDatabase() async {
    await database;
  }

  /// Closes the database connection and resets the singleton cache.
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  // ---------------------------------------------------------------------------
  // Initialisation
  // ---------------------------------------------------------------------------

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // ---------------------------------------------------------------------------
  // Schema creation
  // ---------------------------------------------------------------------------

  Future<void> _createDB(Database db, int version) async {
    await _createTables(db);
    await _createIndexes(db);
    debugPrint('[DatabaseHelper] Tables created (empty — CSV migration removed)');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Drop → recreate on any version bump.
    await db.execute('DROP TABLE IF EXISTS push_ranges');
    await db.execute('DROP TABLE IF EXISTS call_ranges');
    await _createTables(db);
    await _createIndexes(db);
    debugPrint('[DatabaseHelper] Tables recreated (v$oldVersion → v$newVersion)');
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE push_ranges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        position TEXT NOT NULL,
        hand TEXT NOT NULL,
        stack_bb INTEGER NOT NULL,
        action TEXT NOT NULL,
        ev_bb REAL NOT NULL,
        chart_type TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE call_ranges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        position TEXT NOT NULL,
        hand TEXT NOT NULL,
        stack_bb INTEGER NOT NULL,
        action TEXT NOT NULL,
        ev_bb REAL NOT NULL,
        chart_type TEXT NOT NULL,
        opponent_position TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    await db.execute('''
      CREATE INDEX idx_push_ranges
        ON push_ranges(position, stack_bb, chart_type)
    ''');

    await db.execute('''
      CREATE INDEX idx_call_ranges
        ON call_ranges(position, stack_bb, chart_type)
    ''');
  }

  // ---------------------------------------------------------------------------
  // Legacy CSV migration removed
  // ---------------------------------------------------------------------------
  //
  // The CSV files (gto_push_chart.csv, gto_call_chart.csv) have been superseded
  // by the GTO master database (assets/db/gto_master_db.json) which provides
  // 108,160 scenarios across 5 BB levels with full EV/frequency data.
  // See: lib/data/providers/gto_data_provider.dart

  // ---------------------------------------------------------------------------
  // Query helpers (convenience – extend as needed)
  // ---------------------------------------------------------------------------

  /// Fetch all push-range rows for the given [position] and [stackBb].
  Future<List<Map<String, dynamic>>> getPushRanges({
    required String position,
    required int stackBb,
  }) async {
    final db = await database;
    return db.query(
      'push_ranges',
      where: 'position = ? AND stack_bb = ?',
      whereArgs: [position, stackBb],
    );
  }

  /// Fetch all call-range rows for the given [position], [stackBb], and
  /// [opponentPosition].
  Future<List<Map<String, dynamic>>> getCallRanges({
    required String position,
    required int stackBb,
    required String opponentPosition,
  }) async {
    final db = await database;
    return db.query(
      'call_ranges',
      where: 'position = ? AND stack_bb = ? AND opponent_position = ?',
      whereArgs: [position, stackBb, opponentPosition],
    );
  }

  /// Returns the total row count for [tableName] (useful for verification).
  Future<int> getRowCount(String tableName) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM $tableName');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
