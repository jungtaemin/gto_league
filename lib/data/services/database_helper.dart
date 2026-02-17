import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton helper that manages the local GTO SQLite database.
///
/// On first launch (or when [_dbVersion] is bumped) the CSV assets are
/// parsed and migrated into two tables: `push_ranges` and `call_ranges`.
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
    await _migrateCSVData(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    // Drop → recreate → re-migrate on any version bump.
    await db.execute('DROP TABLE IF EXISTS push_ranges');
    await db.execute('DROP TABLE IF EXISTS call_ranges');
    await _createTables(db);
    await _createIndexes(db);
    await _migrateCSVData(db);
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
  // CSV → SQLite migration
  // ---------------------------------------------------------------------------

  Future<void> _migrateCSVData(Database db) async {
    await _migratePushRanges(db);
    await _migrateCallRanges(db);
  }

  Future<void> _migratePushRanges(Database db) async {
    final data = await rootBundle.loadString('assets/db/gto_push_chart.csv');
    final rows = const CsvToListConverter().convert(data, eol: '\n');

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final row in rows.skip(1)) {
        batch.insert('push_ranges', {
          'position': row[0].toString().trim(),
          'hand': row[1].toString().trim(),
          'stack_bb': (row[2] is int) ? row[2] : int.parse(row[2].toString().trim()),
          'action': row[3].toString().trim(),
          'ev_bb': (row[4] is double)
              ? row[4]
              : double.parse(row[4].toString().trim()),
          'chart_type': row[5].toString().trim(),
        });
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> _migrateCallRanges(Database db) async {
    final data = await rootBundle.loadString('assets/db/gto_call_chart.csv');
    final rows = const CsvToListConverter().convert(data, eol: '\n');

    await db.transaction((txn) async {
      final batch = txn.batch();
      for (final row in rows.skip(1)) {
        batch.insert('call_ranges', {
          'position': row[0].toString().trim(),
          'hand': row[1].toString().trim(),
          'stack_bb': (row[2] is int) ? row[2] : int.parse(row[2].toString().trim()),
          'action': row[3].toString().trim(),
          'ev_bb': (row[4] is double)
              ? row[4]
              : double.parse(row[4].toString().trim()),
          'chart_type': row[5].toString().trim(),
          'opponent_position': row[6].toString().trim(),
        });
      }
      await batch.commit(noResult: true);
    });
  }

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
