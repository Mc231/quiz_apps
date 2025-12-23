/// Base migration interface and utilities.
library;

import 'package:sqflite/sqflite.dart';

/// Represents a database migration.
abstract class Migration {
  /// Creates a new migration.
  const Migration({
    required this.version,
    required this.description,
  });

  /// The version this migration upgrades to.
  final int version;

  /// Human-readable description of the migration.
  final String description;

  /// Executes the migration on the given database.
  Future<void> migrate(Database db);

  /// Rolls back the migration (optional, for development).
  Future<void> rollback(Database db) async {
    // Default: no rollback support
    throw UnimplementedError('Rollback not implemented for migration v$version');
  }
}

/// Manages database migrations.
class MigrationRunner {
  /// Creates a new migration runner.
  const MigrationRunner({
    required this.migrations,
  });

  /// All available migrations, ordered by version.
  final List<Migration> migrations;

  /// Runs all migrations from [fromVersion] to [toVersion].
  Future<void> runMigrations(
    Database db,
    int fromVersion,
    int toVersion,
  ) async {
    // Get migrations that need to run
    final migrationsToRun = migrations
        .where((m) => m.version > fromVersion && m.version <= toVersion)
        .toList()
      ..sort((a, b) => a.version.compareTo(b.version));

    for (final migration in migrationsToRun) {
      await migration.migrate(db);
    }
  }

  /// Gets the latest migration version.
  int get latestVersion {
    if (migrations.isEmpty) return 0;
    return migrations.map((m) => m.version).reduce((a, b) => a > b ? a : b);
  }
}
