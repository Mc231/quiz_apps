/// Migration v1: Initial database schema.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/daily_statistics_table.dart';
import '../tables/question_answers_table.dart';
import '../tables/quiz_sessions_table.dart';
import '../tables/settings_table.dart';
import '../tables/statistics_tables.dart';
import 'migration.dart';

/// Initial database migration - creates all tables.
class MigrationV1 extends Migration {
  /// Creates the v1 migration.
  const MigrationV1()
      : super(
          version: 1,
          description: 'Initial database schema with all core tables',
        );

  @override
  Future<void> migrate(Database db) async {
    // Create tables in order (respecting foreign key dependencies)
    await _createQuizSessionsTable(db);
    await _createQuestionAnswersTable(db);
    await _createGlobalStatisticsTable(db);
    await _createQuizTypeStatisticsTable(db);
    await _createDailyStatisticsTable(db);
    await _createUserSettingsTable(db);

    // Create indexes for performance
    await _createIndexes(db);

    // Initialize singleton tables
    await _initializeSingletonTables(db);
  }

  Future<void> _createQuizSessionsTable(Database db) async {
    await db.execute(createQuizSessionsTable);
  }

  Future<void> _createQuestionAnswersTable(Database db) async {
    await db.execute(createQuestionAnswersTable);
  }

  Future<void> _createGlobalStatisticsTable(Database db) async {
    await db.execute(createGlobalStatisticsTable);
  }

  Future<void> _createQuizTypeStatisticsTable(Database db) async {
    await db.execute(createQuizTypeStatisticsTable);
  }

  Future<void> _createDailyStatisticsTable(Database db) async {
    await db.execute(createDailyStatisticsTable);
  }

  Future<void> _createUserSettingsTable(Database db) async {
    await db.execute(createUserSettingsTable);
  }

  Future<void> _createIndexes(Database db) async {
    // Quiz sessions indexes
    for (final sql in createQuizSessionsIndexes) {
      await db.execute(sql);
    }

    // Question answers indexes
    for (final sql in createQuestionAnswersIndexes) {
      await db.execute(sql);
    }

    // Quiz type statistics indexes
    for (final sql in createQuizTypeStatisticsIndexes) {
      await db.execute(sql);
    }

    // Daily statistics indexes
    for (final sql in createDailyStatisticsIndexes) {
      await db.execute(sql);
    }
  }

  Future<void> _initializeSingletonTables(Database db) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Initialize global statistics singleton row
    await db.execute(insertGlobalStatisticsRow, [now, now]);

    // Initialize user settings singleton row
    await db.execute(insertUserSettingsRow, [now, now]);
  }

  @override
  Future<void> rollback(Database db) async {
    // Drop all tables in reverse order of creation
    await db.execute('DROP TABLE IF EXISTS $userSettingsTable');
    await db.execute('DROP TABLE IF EXISTS $dailyStatisticsTable');
    await db.execute('DROP TABLE IF EXISTS $quizTypeStatisticsTable');
    await db.execute('DROP TABLE IF EXISTS $globalStatisticsTable');
    await db.execute('DROP TABLE IF EXISTS $questionAnswersTable');
    await db.execute('DROP TABLE IF EXISTS $quizSessionsTable');
  }
}
