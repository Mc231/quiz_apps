/// Migration v9: Add daily challenge tables.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/daily_challenge_table.dart';
import 'migration.dart';

/// Migration v9 - Adds daily challenge tables.
///
/// Changes:
/// 1. Creates 'daily_challenges' table for storing challenge definitions
/// 2. Creates 'daily_challenge_results' table for storing user results
/// 3. Creates indexes for efficient querying
class MigrationV9 extends Migration {
  /// Creates the v9 migration.
  const MigrationV9()
      : super(
          version: 9,
          description: 'Add daily challenge tables',
        );

  @override
  Future<void> migrate(Database db) async {
    // Create daily challenges table
    await db.execute(createDailyChallengesTable);
    await db.execute(createDailyChallengesDateIndex);

    // Create daily challenge results table
    await db.execute(createDailyChallengeResultsTable);
    await db.execute(createDailyChallengeResultsChallengeIndex);
    await db.execute(createDailyChallengeResultsCompletedAtIndex);
  }

  @override
  Future<void> rollback(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $dailyChallengeResultsTable');
    await db.execute('DROP TABLE IF EXISTS $dailyChallengesTable');
  }
}
