/// Migration v4: Add practice_progress table.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/practice_progress_table.dart';
import 'migration.dart';

/// Migration v4 - Adds practice progress tracking table.
///
/// Changes:
/// 1. Creates practice_progress table for tracking questions to practice
/// 2. Creates indexes for efficient querying
class MigrationV4 extends Migration {
  /// Creates the v4 migration.
  const MigrationV4()
      : super(
          version: 4,
          description: 'Add practice_progress table',
        );

  @override
  Future<void> migrate(Database db) async {
    // 1. Create practice_progress table
    await _createPracticeProgressTable(db);

    // 2. Create indexes
    await _createIndexes(db);
  }

  Future<void> _createPracticeProgressTable(Database db) async {
    await db.execute(createPracticeProgressTable);
  }

  Future<void> _createIndexes(Database db) async {
    for (final sql in createPracticeProgressIndexes) {
      await db.execute(sql);
    }
  }

  @override
  Future<void> rollback(Database db) async {
    // Drop the practice_progress table
    await db.execute('DROP TABLE IF EXISTS $practiceProgressTable');
  }
}
