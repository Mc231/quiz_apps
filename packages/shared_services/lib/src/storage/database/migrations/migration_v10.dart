/// Migration v10: Add daily challenge statistics to global_statistics.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/statistics_tables.dart';
import 'migration.dart';

/// Migration v10 - Adds daily challenge statistics columns to global_statistics.
///
/// Changes:
/// 1. Adds total_daily_challenges_completed column
/// 2. Adds daily_challenge_streak column
/// 3. Adds best_daily_challenge_streak column
/// 4. Adds perfect_daily_challenges column
class MigrationV10 extends Migration {
  /// Creates the v10 migration.
  const MigrationV10()
      : super(
          version: 10,
          description: 'Add daily challenge statistics to global_statistics',
        );

  @override
  Future<void> migrate(Database db) async {
    // Total daily challenges completed
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN total_daily_challenges_completed INTEGER DEFAULT 0
    ''');

    // Current daily challenge streak
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN daily_challenge_streak INTEGER DEFAULT 0
    ''');

    // Best daily challenge streak ever achieved
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN best_daily_challenge_streak INTEGER DEFAULT 0
    ''');

    // Number of perfect daily challenges (100% score)
    await db.execute('''
      ALTER TABLE $globalStatisticsTable
      ADD COLUMN perfect_daily_challenges INTEGER DEFAULT 0
    ''');
  }

  @override
  Future<void> rollback(Database db) async {
    // SQLite doesn't support DROP COLUMN before version 3.35.0
    // For development, you may need to clear app data.
  }
}

/// Column names for the daily challenge statistics columns added in v10.
class GlobalStatisticsColumnsV10 {
  GlobalStatisticsColumnsV10._();

  static const String totalDailyChallengesCompleted =
      'total_daily_challenges_completed';
  static const String dailyChallengeStreak = 'daily_challenge_streak';
  static const String bestDailyChallengeStreak = 'best_daily_challenge_streak';
  static const String perfectDailyChallenges = 'perfect_daily_challenges';
}
