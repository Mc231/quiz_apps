/// Repository for practice progress operations.
///
/// Provides methods for tracking questions that users got wrong
/// and need to practice.
library;

import '../database/app_database.dart';
import '../database/tables/practice_progress_table.dart';
import '../models/practice_question.dart';
import '../models/question_answer.dart';
import '../models/quiz_session.dart';

/// Abstract interface for practice progress repository operations.
abstract class PracticeProgressRepository {
  /// Gets all questions that currently need practice.
  ///
  /// Returns questions where:
  /// - User answered incorrectly at least once
  /// - Either never practiced correctly, or got wrong again after last practice
  ///
  /// Questions are ordered by wrong_count descending (most missed first).
  Future<List<PracticeQuestion>> getQuestionsNeedingPractice();

  /// Gets the total count of questions needing practice.
  Future<int> getPracticeQuestionCount();

  /// Gets a specific practice question by ID.
  Future<PracticeQuestion?> getPracticeQuestion(String questionId);

  /// Updates practice progress after a regular quiz session completes.
  ///
  /// For each wrong answer in the session, either:
  /// - Creates a new practice_progress record, OR
  /// - Increments wrong_count and updates last_wrong_at
  ///
  /// [session] - The completed quiz session
  /// [wrongAnswers] - The list of wrong answers from the session
  Future<void> updatePracticeProgressFromSession(
    QuizSession session,
    List<QuestionAnswer> wrongAnswers,
  );

  /// Marks questions as practiced correctly.
  ///
  /// Called when a practice session completes. Updates
  /// last_practiced_correctly_at for all provided question IDs.
  ///
  /// [correctQuestionIds] - Question IDs that were answered correctly
  Future<void> markQuestionsAsPracticed(List<String> correctQuestionIds);

  /// Removes a question from practice progress.
  ///
  /// Used when a question is removed from the app or for cleanup.
  Future<void> removePracticeQuestion(String questionId);

  /// Removes all practice progress for questions from a specific session.
  ///
  /// Note: This decrements wrong_count rather than deleting, unless
  /// wrong_count reaches 0.
  Future<void> removePracticeProgressForSession(
    String sessionId,
    List<QuestionAnswer> wrongAnswers,
  );

  /// Clears all practice progress data.
  ///
  /// Used for testing or when user wants to reset.
  Future<void> clearAllPracticeProgress();

  /// Gets practice statistics.
  Future<PracticeStatistics> getPracticeStatistics();
}

/// Statistics about practice progress.
class PracticeStatistics {
  /// Creates [PracticeStatistics].
  const PracticeStatistics({
    required this.totalQuestionsToPractice,
    required this.totalWrongCount,
    required this.questionsPracticedCorrectly,
  });

  /// Total number of unique questions needing practice.
  final int totalQuestionsToPractice;

  /// Sum of all wrong counts across all questions.
  final int totalWrongCount;

  /// Number of questions that have been practiced correctly at least once.
  final int questionsPracticedCorrectly;

  /// Creates empty statistics.
  factory PracticeStatistics.empty() => const PracticeStatistics(
        totalQuestionsToPractice: 0,
        totalWrongCount: 0,
        questionsPracticedCorrectly: 0,
      );

  @override
  String toString() =>
      'PracticeStatistics(toPractice: $totalQuestionsToPractice, totalWrong: $totalWrongCount, practiced: $questionsPracticedCorrectly)';
}

/// Implementation of [PracticeProgressRepository].
class PracticeProgressRepositoryImpl implements PracticeProgressRepository {
  /// Creates a [PracticeProgressRepositoryImpl].
  PracticeProgressRepositoryImpl({
    required AppDatabase database,
  }) : _database = database;

  final AppDatabase _database;

  @override
  Future<List<PracticeQuestion>> getQuestionsNeedingPractice() async {
    final db = await _database.database;

    // Query for questions that need practice:
    // - last_practiced_correctly_at IS NULL (never practiced), OR
    // - last_wrong_at > last_practiced_correctly_at (wrong after practice)
    final results = await db.query(
      practiceProgressTable,
      where: '''
        ${PracticeProgressColumns.lastPracticedCorrectlyAt} IS NULL
        OR ${PracticeProgressColumns.lastWrongAt} > ${PracticeProgressColumns.lastPracticedCorrectlyAt}
      ''',
      orderBy: '${PracticeProgressColumns.wrongCount} DESC',
    );

    return results.map((row) => PracticeQuestion.fromMap(row)).toList();
  }

  @override
  Future<int> getPracticeQuestionCount() async {
    final db = await _database.database;

    final result = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $practiceProgressTable
      WHERE ${PracticeProgressColumns.lastPracticedCorrectlyAt} IS NULL
        OR ${PracticeProgressColumns.lastWrongAt} > ${PracticeProgressColumns.lastPracticedCorrectlyAt}
    ''');

    return result.first['count'] as int? ?? 0;
  }

  @override
  Future<PracticeQuestion?> getPracticeQuestion(String questionId) async {
    final db = await _database.database;

    final results = await db.query(
      practiceProgressTable,
      where: '${PracticeProgressColumns.questionId} = ?',
      whereArgs: [questionId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return PracticeQuestion.fromMap(results.first);
  }

  @override
  Future<void> updatePracticeProgressFromSession(
    QuizSession session,
    List<QuestionAnswer> wrongAnswers,
  ) async {
    if (wrongAnswers.isEmpty) return;

    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await db.transaction((txn) async {
      for (final answer in wrongAnswers) {
        // Check if this question already exists in practice_progress
        final existing = await txn.query(
          practiceProgressTable,
          where: '${PracticeProgressColumns.questionId} = ?',
          whereArgs: [answer.questionId],
          limit: 1,
        );

        if (existing.isEmpty) {
          // Insert new record
          await txn.insert(
            practiceProgressTable,
            {
              PracticeProgressColumns.questionId: answer.questionId,
              PracticeProgressColumns.wrongCount: 1,
              PracticeProgressColumns.firstWrongAt: now,
              PracticeProgressColumns.lastWrongAt: now,
              PracticeProgressColumns.lastPracticedCorrectlyAt: null,
            },
          );
        } else {
          // Update existing record
          await txn.update(
            practiceProgressTable,
            {
              PracticeProgressColumns.wrongCount:
                  (existing.first[PracticeProgressColumns.wrongCount] as int) +
                      1,
              PracticeProgressColumns.lastWrongAt: now,
            },
            where: '${PracticeProgressColumns.questionId} = ?',
            whereArgs: [answer.questionId],
          );
        }
      }
    });
  }

  @override
  Future<void> markQuestionsAsPracticed(List<String> correctQuestionIds) async {
    if (correctQuestionIds.isEmpty) return;

    final db = await _database.database;
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    // Use batch for efficiency
    final batch = db.batch();

    for (final questionId in correctQuestionIds) {
      batch.update(
        practiceProgressTable,
        {PracticeProgressColumns.lastPracticedCorrectlyAt: now},
        where: '${PracticeProgressColumns.questionId} = ?',
        whereArgs: [questionId],
      );
    }

    await batch.commit(noResult: true);
  }

  @override
  Future<void> removePracticeQuestion(String questionId) async {
    final db = await _database.database;

    await db.delete(
      practiceProgressTable,
      where: '${PracticeProgressColumns.questionId} = ?',
      whereArgs: [questionId],
    );
  }

  @override
  Future<void> removePracticeProgressForSession(
    String sessionId,
    List<QuestionAnswer> wrongAnswers,
  ) async {
    if (wrongAnswers.isEmpty) return;

    final db = await _database.database;

    await db.transaction((txn) async {
      for (final answer in wrongAnswers) {
        // Get current record
        final existing = await txn.query(
          practiceProgressTable,
          where: '${PracticeProgressColumns.questionId} = ?',
          whereArgs: [answer.questionId],
          limit: 1,
        );

        if (existing.isNotEmpty) {
          final currentCount =
              existing.first[PracticeProgressColumns.wrongCount] as int;

          if (currentCount <= 1) {
            // Delete the record
            await txn.delete(
              practiceProgressTable,
              where: '${PracticeProgressColumns.questionId} = ?',
              whereArgs: [answer.questionId],
            );
          } else {
            // Decrement wrong_count
            await txn.update(
              practiceProgressTable,
              {PracticeProgressColumns.wrongCount: currentCount - 1},
              where: '${PracticeProgressColumns.questionId} = ?',
              whereArgs: [answer.questionId],
            );
          }
        }
      }
    });
  }

  @override
  Future<void> clearAllPracticeProgress() async {
    final db = await _database.database;
    await db.delete(practiceProgressTable);
  }

  @override
  Future<PracticeStatistics> getPracticeStatistics() async {
    final db = await _database.database;

    // Count questions needing practice
    final needingPractice = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $practiceProgressTable
      WHERE ${PracticeProgressColumns.lastPracticedCorrectlyAt} IS NULL
        OR ${PracticeProgressColumns.lastWrongAt} > ${PracticeProgressColumns.lastPracticedCorrectlyAt}
    ''');

    // Sum of wrong counts
    final totalWrong = await db.rawQuery('''
      SELECT COALESCE(SUM(${PracticeProgressColumns.wrongCount}), 0) as total
      FROM $practiceProgressTable
    ''');

    // Count questions practiced correctly
    final practicedCorrectly = await db.rawQuery('''
      SELECT COUNT(*) as count FROM $practiceProgressTable
      WHERE ${PracticeProgressColumns.lastPracticedCorrectlyAt} IS NOT NULL
    ''');

    return PracticeStatistics(
      totalQuestionsToPractice: needingPractice.first['count'] as int? ?? 0,
      totalWrongCount: (totalWrong.first['total'] as int?) ?? 0,
      questionsPracticedCorrectly:
          practicedCorrectly.first['count'] as int? ?? 0,
    );
  }
}
