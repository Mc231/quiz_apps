/// Migration v8: Add streak table for daily play tracking.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/streak_table.dart';
import 'migration.dart';

/// Migration v8 - Adds streak tracking table.
///
/// Changes:
/// 1. Creates 'streak' table for tracking daily play streaks
class MigrationV8 extends Migration {
  /// Creates the v8 migration.
  const MigrationV8()
      : super(
          version: 8,
          description: 'Add streak table for daily play tracking',
        );

  @override
  Future<void> migrate(Database db) async {
    // Create the streak table
    await db.execute(createStreakTable);

    // Insert the singleton row with initial values
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    await db.execute(insertStreakRow, [now, now]);
  }

  @override
  Future<void> rollback(Database db) async {
    await db.execute('DROP TABLE IF EXISTS $streakTable');
  }
}
