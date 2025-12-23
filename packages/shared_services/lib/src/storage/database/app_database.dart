/// Main database class for the quiz app.
library;

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import 'database_config.dart';
import 'migrations/migration.dart';
import 'migrations/migration_v1.dart';

/// The main database class that handles initialization and provides access.
class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  Database? _database;

  /// Gets the singleton instance of the database.
  static AppDatabase get instance {
    _instance ??= AppDatabase._();
    return _instance!;
  }

  /// All available migrations.
  static final List<Migration> _migrations = [
    const MigrationV1(),
  ];

  /// The migration runner.
  static final MigrationRunner _migrationRunner = MigrationRunner(
    migrations: _migrations,
  );

  /// Whether the database is initialized.
  bool get isInitialized => _database != null;

  /// Gets the database instance, initializing if necessary.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the database.
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, DatabaseConfig.databaseName);

    return await openDatabase(
      dbPath,
      version: DatabaseConfig.currentVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
      onConfigure: _onConfigure,
      onOpen: _onOpen,
    );
  }

  /// Configures the database connection.
  Future<void> _onConfigure(Database db) async {
    if (DatabaseConfig.enableForeignKeys) {
      // Use rawQuery for PRAGMA on Android (execute doesn't work for PRAGMA)
      await db.rawQuery('PRAGMA foreign_keys = ON');
    }
    if (DatabaseConfig.enableWalMode) {
      // Use rawQuery for PRAGMA on Android (execute doesn't work for PRAGMA)
      await db.rawQuery('PRAGMA journal_mode = WAL');
    }
  }

  /// Called when the database is opened.
  Future<void> _onOpen(Database db) async {
    // Verify foreign keys are enabled
    if (DatabaseConfig.enableForeignKeys) {
      final result = await db.rawQuery('PRAGMA foreign_keys');
      final foreignKeysEnabled = result.first.values.first == 1;
      if (!foreignKeysEnabled) {
        throw StateError('Foreign keys are not enabled');
      }
    }
  }

  /// Called when the database is created for the first time.
  Future<void> _onCreate(Database db, int version) async {
    await _migrationRunner.runMigrations(db, 0, version);
  }

  /// Called when the database needs to be upgraded.
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await _migrationRunner.runMigrations(db, oldVersion, newVersion);
  }

  /// Called when the database needs to be downgraded.
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    // For development: drop and recreate
    // In production, you might want to handle this differently
    throw UnsupportedError(
      'Database downgrade from v$oldVersion to v$newVersion is not supported. '
      'Please clear app data or uninstall/reinstall the app.',
    );
  }

  /// Closes the database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Deletes the database file and resets the instance.
  ///
  /// WARNING: This permanently deletes all data!
  Future<void> deleteDatabase() async {
    await close();
    final databasePath = await getDatabasesPath();
    final dbPath = path.join(databasePath, DatabaseConfig.databaseName);
    await databaseFactory.deleteDatabase(dbPath);
    _instance = null;
  }

  /// Resets the database by deleting and recreating it.
  ///
  /// WARNING: This permanently deletes all data!
  Future<void> reset() async {
    await deleteDatabase();
    _instance = AppDatabase._();
    await _instance!.database;
  }

  /// Gets the current database version.
  Future<int> getVersion() async {
    final db = await database;
    return await db.getVersion();
  }

  /// Executes a raw SQL query.
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Executes a raw SQL statement.
  Future<void> execute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    await db.execute(sql, arguments);
  }

  /// Executes multiple statements in a transaction.
  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  /// Inserts a row into a table.
  Future<int> insert(
    String table,
    Map<String, dynamic> values, {
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return await db.insert(table, values, conflictAlgorithm: conflictAlgorithm);
  }

  /// Updates rows in a table.
  Future<int> update(
    String table,
    Map<String, dynamic> values, {
    String? where,
    List<dynamic>? whereArgs,
    ConflictAlgorithm? conflictAlgorithm,
  }) async {
    final db = await database;
    return await db.update(
      table,
      values,
      where: where,
      whereArgs: whereArgs,
      conflictAlgorithm: conflictAlgorithm,
    );
  }

  /// Deletes rows from a table.
  Future<int> delete(
    String table, {
    String? where,
    List<dynamic>? whereArgs,
  }) async {
    final db = await database;
    return await db.delete(table, where: where, whereArgs: whereArgs);
  }

  /// Queries a table.
  Future<List<Map<String, dynamic>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<dynamic>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async {
    final db = await database;
    return await db.query(
      table,
      distinct: distinct,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
      groupBy: groupBy,
      having: having,
      orderBy: orderBy,
      limit: limit,
      offset: offset,
    );
  }

  /// Executes a batch of operations.
  Future<List<dynamic>> batch(void Function(Batch batch) operations) async {
    final db = await database;
    final batch = db.batch();
    operations(batch);
    return await batch.commit();
  }

  /// Gets table information (for debugging).
  Future<List<String>> getTableNames() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' AND name NOT LIKE 'android_%'",
    );
    return result.map((row) => row['name'] as String).toList();
  }

  /// Gets the row count for a table (for debugging).
  Future<int> getTableRowCount(String table) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table');
    return result.first['count'] as int;
  }

  /// Checks if a table exists.
  Future<bool> tableExists(String table) async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [table],
    );
    return result.isNotEmpty;
  }
}
