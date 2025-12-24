/// Migration v2: Add achievements table and extended statistics.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/achievements_table.dart';
import '../tables/statistics_tables.dart';
import 'migration.dart';

/// Migration v2 - Adds achievements support and extended statistics.
///
/// Changes:
/// 1. Creates unlocked_achievements table
/// 2. Adds achievement-related columns to global_statistics
class MigrationV2 extends Migration {
  /// Creates the v2 migration.
  const MigrationV2()
      : super(
          version: 2,
          description: 'Add achievements table and extended statistics',
        );

  @override
  Future<void> migrate(Database db) async {
    // 1. Create unlocked_achievements table
    await _createUnlockedAchievementsTable(db);

    // 2. Add new columns to global_statistics for achievement tracking
    await _addAchievementStatisticsColumns(db);

    // 3. Create indexes for the new table
    await _createIndexes(db);
  }

  Future<void> _createUnlockedAchievementsTable(Database db) async {
    await db.execute(createUnlockedAchievementsTable);
  }

  Future<void> _addAchievementStatisticsColumns(Database db) async {
    // Add columns for tracking achievement-related statistics
    // These are needed for achievements like "play 7 days in a row"

    // Consecutive days played tracking
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN consecutive_days_played INTEGER DEFAULT 0
    ''');

    // Last play date for tracking consecutive days (stored as date string YYYY-MM-DD)
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN last_play_date TEXT
    ''');

    // Quick answers count (answers in under 2 seconds)
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN quick_answers_count INTEGER DEFAULT 0
    ''');

    // Sessions completed without using hints
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN sessions_no_hints INTEGER DEFAULT 0
    ''');

    // Sessions with 90%+ score
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN high_score_90_count INTEGER DEFAULT 0
    ''');

    // Sessions with 95%+ score
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN high_score_95_count INTEGER DEFAULT 0
    ''');

    // Consecutive perfect scores (for perfect streak achievements)
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN consecutive_perfect_scores INTEGER DEFAULT 0
    ''');

    // Total achievements unlocked (cached for quick display)
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN total_achievements_unlocked INTEGER DEFAULT 0
    ''');

    // Total achievement points (cached for quick display)
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN total_achievement_points INTEGER DEFAULT 0
    ''');
  }

  Future<void> _createIndexes(Database db) async {
    for (final sql in createUnlockedAchievementsIndexes) {
      await db.execute(sql);
    }
  }

  @override
  Future<void> rollback(Database db) async {
    // Drop the achievements table
    await db.execute('DROP TABLE IF EXISTS $unlockedAchievementsTable');

    // Note: SQLite doesn't support DROP COLUMN, so we can't rollback the
    // global_statistics changes without recreating the table.
    // For development, you may need to clear app data.
  }
}

/// Column names for the new global_statistics columns added in v2.
class GlobalStatisticsColumnsV2 {
  GlobalStatisticsColumnsV2._();

  static const String consecutiveDaysPlayed = 'consecutive_days_played';
  static const String lastPlayDate = 'last_play_date';
  static const String quickAnswersCount = 'quick_answers_count';
  static const String sessionsNoHints = 'sessions_no_hints';
  static const String highScore90Count = 'high_score_90_count';
  static const String highScore95Count = 'high_score_95_count';
  static const String consecutivePerfectScores = 'consecutive_perfect_scores';
  static const String totalAchievementsUnlocked = 'total_achievements_unlocked';
  static const String totalAchievementPoints = 'total_achievement_points';
}
