/// Migration v7: Add layout columns for layout mode tracking.
library;

import 'package:sqflite/sqflite.dart';

import '../tables/question_answers_table.dart';
import '../tables/quiz_sessions_table.dart';
import 'migration.dart';

/// Migration v7 - Adds layout mode tracking columns.
///
/// Changes:
/// 1. Adds 'layout_mode' column to 'quiz_sessions' table
/// 2. Adds 'layout_used' column to 'question_answers' table
class MigrationV7 extends Migration {
  /// Creates the v7 migration.
  const MigrationV7()
      : super(
          version: 7,
          description: 'Add layout mode tracking columns',
        );

  @override
  Future<void> migrate(Database db) async {
    // Add layout_mode column to quiz_sessions table
    // Stores the configured layout mode for the entire quiz session
    // (e.g., 'imageQuestionTextAnswers', 'textQuestionImageAnswers', 'mixed')
    await db.execute(
      'ALTER TABLE $quizSessionsTable ADD COLUMN ${QuizSessionsColumns.layoutMode} TEXT',
    );

    // Add layout_used column to question_answers table
    // Stores the actual layout used for each specific question
    // (resolves mixed layouts to concrete layout per question)
    await db.execute(
      'ALTER TABLE $questionAnswersTable ADD COLUMN ${QuestionAnswersColumns.layoutUsed} TEXT',
    );
  }

  @override
  Future<void> rollback(Database db) async {
    // SQLite doesn't support DROP COLUMN directly in older versions
    // For simplicity, we recreate the tables without the new columns
    // This is a destructive operation and should only be used in development

    // Rollback for quiz_sessions
    await db.execute('ALTER TABLE $quizSessionsTable DROP COLUMN ${QuizSessionsColumns.layoutMode}');

    // Rollback for question_answers
    await db.execute('ALTER TABLE $questionAnswersTable DROP COLUMN ${QuestionAnswersColumns.layoutUsed}');
  }
}
