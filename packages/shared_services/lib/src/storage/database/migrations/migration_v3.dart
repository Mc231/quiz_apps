/// Migration v3: Add best_streak column to quiz_sessions table.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/quiz_sessions_table.dart';
import 'migration.dart';

/// Migration v3 - Adds best_streak tracking to quiz sessions.
///
/// Changes:
/// 1. Adds best_streak column to quiz_sessions table
class MigrationV3 extends Migration {
  /// Creates the v3 migration.
  const MigrationV3()
      : super(
          version: 3,
          description: 'Add best_streak column to quiz_sessions',
        );

  @override
  Future<void> migrate(Database db) async {
    // Check if column already exists (for idempotency)
    final tableInfo = await db.rawQuery('PRAGMA table_info($quizSessionsTable)');
    final columnExists = tableInfo.any(
      (column) => column['name'] == QuizSessionsColumns.bestStreak,
    );

    if (!columnExists) {
      // Add best_streak column to quiz_sessions table
      await db.execute('''
        ALTER TABLE $quizSessionsTable
        ADD COLUMN ${QuizSessionsColumns.bestStreak} INTEGER DEFAULT 0
      ''');
    }
  }

  @override
  Future<void> rollback(Database db) async {
    // SQLite doesn't support DROP COLUMN
    // For development, you may need to clear app data
  }
}
