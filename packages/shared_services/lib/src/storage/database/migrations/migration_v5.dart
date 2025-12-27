/// Migration v5: Add score column to quiz_sessions table.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/quiz_sessions_table.dart';
import 'migration.dart';

/// Migration v5 - Adds score column to quiz_sessions table.
///
/// Changes:
/// 1. Adds 'score' column to quiz_sessions table (INTEGER DEFAULT 0)
class MigrationV5 extends Migration {
  /// Creates the v5 migration.
  const MigrationV5()
      : super(
          version: 5,
          description: 'Add score column to quiz_sessions table',
        );

  @override
  Future<void> migrate(Database db) async {
    // Check if column already exists (for idempotent migrations)
    final columns = await db.rawQuery(
      "PRAGMA table_info($quizSessionsTable)",
    );
    final hasScoreColumn = columns.any((col) => col['name'] == 'score');

    if (!hasScoreColumn) {
      // Add score column with default value of 0
      await db.execute(
        'ALTER TABLE $quizSessionsTable ADD COLUMN score INTEGER DEFAULT 0',
      );
    }
  }

  @override
  Future<void> rollback(Database db) async {
    // SQLite doesn't support DROP COLUMN in older versions
    // For rollback, we'd need to recreate the table without the column
    // This is a simplified rollback that just logs the operation
    // In production, you might want to implement full table recreation
  }
}
