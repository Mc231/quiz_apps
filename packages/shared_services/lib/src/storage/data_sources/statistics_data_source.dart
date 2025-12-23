/// Data source for statistics database operations.
library;

import '../database/app_database.dart';
import '../database/tables/daily_statistics_table.dart';
import '../database/tables/statistics_tables.dart';
import '../models/daily_statistics.dart';
import '../models/global_statistics.dart';
import '../models/quiz_session.dart';
import '../models/quiz_type_statistics.dart';

/// Abstract interface for statistics data operations.
abstract class StatisticsDataSource {
  // Global Statistics
  /// Gets the global statistics.
  Future<GlobalStatistics> getGlobalStatistics();

  /// Updates global statistics after a session completes.
  Future<void> updateGlobalStatisticsForSession(QuizSession session);

  /// Resets global statistics.
  Future<void> resetGlobalStatistics();

  // Quiz Type Statistics
  /// Gets statistics for a specific quiz type and optional category.
  Future<QuizTypeStatistics?> getQuizTypeStatistics(
    String quizType, {
    String? category,
  });

  /// Gets all quiz type statistics.
  Future<List<QuizTypeStatistics>> getAllQuizTypeStatistics();

  /// Updates quiz type statistics after a session completes.
  Future<void> updateQuizTypeStatisticsForSession(QuizSession session);

  /// Deletes statistics for a specific quiz type.
  Future<void> deleteQuizTypeStatistics(String quizType, {String? category});

  // Daily Statistics
  /// Gets daily statistics for a specific date.
  Future<DailyStatistics?> getDailyStatistics(DateTime date);

  /// Gets daily statistics for a date range.
  Future<List<DailyStatistics>> getDailyStatisticsRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets the last N days of statistics.
  Future<List<DailyStatistics>> getRecentDailyStatistics(int days);

  /// Updates daily statistics after a session completes.
  Future<void> updateDailyStatisticsForSession(QuizSession session);

  // Aggregation helpers
  /// Recalculates all statistics from session data.
  Future<void> recalculateAllStatistics();
}

/// SQLite implementation of [StatisticsDataSource].
class StatisticsDataSourceImpl implements StatisticsDataSource {
  /// Creates a new [StatisticsDataSourceImpl].
  StatisticsDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  // ==========================================================================
  // Global Statistics
  // ==========================================================================

  @override
  Future<GlobalStatistics> getGlobalStatistics() async {
    final results = await _database.query(
      globalStatisticsTable,
      where: '${GlobalStatisticsColumns.id} = 1',
      limit: 1,
    );

    if (results.isEmpty) {
      // This shouldn't happen since we initialize the singleton row
      return GlobalStatistics.empty();
    }

    return GlobalStatistics.fromMap(results.first);
  }

  @override
  Future<void> updateGlobalStatisticsForSession(QuizSession session) async {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch ~/ 1000;

    final isCompleted = session.completionStatus == CompletionStatus.completed;
    final isCancelled = session.completionStatus == CompletionStatus.cancelled;
    final isPerfect = session.scorePercentage >= 100.0;

    await _database.rawQuery('''
      UPDATE $globalStatisticsTable SET
        ${GlobalStatisticsColumns.totalSessions} = ${GlobalStatisticsColumns.totalSessions} + 1,
        ${GlobalStatisticsColumns.totalCompletedSessions} = ${GlobalStatisticsColumns.totalCompletedSessions} + ${isCompleted ? 1 : 0},
        ${GlobalStatisticsColumns.totalCancelledSessions} = ${GlobalStatisticsColumns.totalCancelledSessions} + ${isCancelled ? 1 : 0},
        ${GlobalStatisticsColumns.totalQuestionsAnswered} = ${GlobalStatisticsColumns.totalQuestionsAnswered} + ?,
        ${GlobalStatisticsColumns.totalCorrectAnswers} = ${GlobalStatisticsColumns.totalCorrectAnswers} + ?,
        ${GlobalStatisticsColumns.totalIncorrectAnswers} = ${GlobalStatisticsColumns.totalIncorrectAnswers} + ?,
        ${GlobalStatisticsColumns.totalSkippedQuestions} = ${GlobalStatisticsColumns.totalSkippedQuestions} + ?,
        ${GlobalStatisticsColumns.totalTimePlayedSeconds} = ${GlobalStatisticsColumns.totalTimePlayedSeconds} + ?,
        ${GlobalStatisticsColumns.totalHints5050Used} = ${GlobalStatisticsColumns.totalHints5050Used} + ?,
        ${GlobalStatisticsColumns.totalHintsSkipUsed} = ${GlobalStatisticsColumns.totalHintsSkipUsed} + ?,
        ${GlobalStatisticsColumns.bestScorePercentage} = MAX(${GlobalStatisticsColumns.bestScorePercentage}, ?),
        ${GlobalStatisticsColumns.totalPerfectScores} = ${GlobalStatisticsColumns.totalPerfectScores} + ${isPerfect ? 1 : 0},
        ${GlobalStatisticsColumns.firstSessionDate} = COALESCE(${GlobalStatisticsColumns.firstSessionDate}, ?),
        ${GlobalStatisticsColumns.lastSessionDate} = ?,
        ${GlobalStatisticsColumns.updatedAt} = ?
      WHERE ${GlobalStatisticsColumns.id} = 1
    ''', [
      session.totalAnswered,
      session.totalCorrect,
      session.totalFailed,
      session.totalSkipped,
      session.durationSeconds ?? 0,
      session.hintsUsed5050,
      session.hintsUsedSkip,
      session.scorePercentage,
      session.startTime.millisecondsSinceEpoch ~/ 1000,
      session.startTime.millisecondsSinceEpoch ~/ 1000,
      timestamp,
    ]);

    // Update average score separately (requires calculation)
    await _updateAverageScore();
  }

  Future<void> _updateAverageScore() async {
    await _database.execute('''
      UPDATE $globalStatisticsTable SET
        ${GlobalStatisticsColumns.averageScorePercentage} = (
          SELECT COALESCE(AVG(score_percentage), 0)
          FROM quiz_sessions
          WHERE completion_status = 'completed'
        )
      WHERE ${GlobalStatisticsColumns.id} = 1
    ''');
  }

  @override
  Future<void> resetGlobalStatistics() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.update(
      globalStatisticsTable,
      {
        GlobalStatisticsColumns.totalSessions: 0,
        GlobalStatisticsColumns.totalCompletedSessions: 0,
        GlobalStatisticsColumns.totalCancelledSessions: 0,
        GlobalStatisticsColumns.totalQuestionsAnswered: 0,
        GlobalStatisticsColumns.totalCorrectAnswers: 0,
        GlobalStatisticsColumns.totalIncorrectAnswers: 0,
        GlobalStatisticsColumns.totalSkippedQuestions: 0,
        GlobalStatisticsColumns.totalTimePlayedSeconds: 0,
        GlobalStatisticsColumns.totalHints5050Used: 0,
        GlobalStatisticsColumns.totalHintsSkipUsed: 0,
        GlobalStatisticsColumns.averageScorePercentage: 0,
        GlobalStatisticsColumns.bestScorePercentage: 0,
        GlobalStatisticsColumns.worstScorePercentage: 0,
        GlobalStatisticsColumns.currentStreak: 0,
        GlobalStatisticsColumns.bestStreak: 0,
        GlobalStatisticsColumns.totalPerfectScores: 0,
        GlobalStatisticsColumns.firstSessionDate: null,
        GlobalStatisticsColumns.lastSessionDate: null,
        GlobalStatisticsColumns.updatedAt: now,
      },
      where: '${GlobalStatisticsColumns.id} = 1',
    );
  }

  // ==========================================================================
  // Quiz Type Statistics
  // ==========================================================================

  @override
  Future<QuizTypeStatistics?> getQuizTypeStatistics(
    String quizType, {
    String? category,
  }) async {
    final id = QuizTypeStatistics.generateId(quizType, category);

    final results = await _database.query(
      quizTypeStatisticsTable,
      where: '${QuizTypeStatisticsColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return QuizTypeStatistics.fromMap(results.first);
  }

  @override
  Future<List<QuizTypeStatistics>> getAllQuizTypeStatistics() async {
    final results = await _database.query(
      quizTypeStatisticsTable,
      orderBy: '${QuizTypeStatisticsColumns.lastPlayedAt} DESC',
    );

    return results.map(QuizTypeStatistics.fromMap).toList();
  }

  @override
  Future<void> updateQuizTypeStatisticsForSession(QuizSession session) async {
    final id = QuizTypeStatistics.generateId(
      session.quizType,
      session.quizCategory,
    );
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch ~/ 1000;

    final isCompleted = session.completionStatus == CompletionStatus.completed;
    final isPerfect = session.scorePercentage >= 100.0;

    // Try to insert or update
    await _database.execute('''
      INSERT INTO $quizTypeStatisticsTable (
        ${QuizTypeStatisticsColumns.id},
        ${QuizTypeStatisticsColumns.quizType},
        ${QuizTypeStatisticsColumns.quizCategory},
        ${QuizTypeStatisticsColumns.totalSessions},
        ${QuizTypeStatisticsColumns.totalCompletedSessions},
        ${QuizTypeStatisticsColumns.totalQuestions},
        ${QuizTypeStatisticsColumns.totalCorrect},
        ${QuizTypeStatisticsColumns.totalIncorrect},
        ${QuizTypeStatisticsColumns.totalSkipped},
        ${QuizTypeStatisticsColumns.bestScorePercentage},
        ${QuizTypeStatisticsColumns.bestSessionId},
        ${QuizTypeStatisticsColumns.totalTimePlayedSeconds},
        ${QuizTypeStatisticsColumns.totalPerfectScores},
        ${QuizTypeStatisticsColumns.lastPlayedAt},
        ${QuizTypeStatisticsColumns.createdAt},
        ${QuizTypeStatisticsColumns.updatedAt}
      ) VALUES (?, ?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(${QuizTypeStatisticsColumns.id}) DO UPDATE SET
        ${QuizTypeStatisticsColumns.totalSessions} = ${QuizTypeStatisticsColumns.totalSessions} + 1,
        ${QuizTypeStatisticsColumns.totalCompletedSessions} = ${QuizTypeStatisticsColumns.totalCompletedSessions} + ?,
        ${QuizTypeStatisticsColumns.totalQuestions} = ${QuizTypeStatisticsColumns.totalQuestions} + ?,
        ${QuizTypeStatisticsColumns.totalCorrect} = ${QuizTypeStatisticsColumns.totalCorrect} + ?,
        ${QuizTypeStatisticsColumns.totalIncorrect} = ${QuizTypeStatisticsColumns.totalIncorrect} + ?,
        ${QuizTypeStatisticsColumns.totalSkipped} = ${QuizTypeStatisticsColumns.totalSkipped} + ?,
        ${QuizTypeStatisticsColumns.bestScorePercentage} = MAX(${QuizTypeStatisticsColumns.bestScorePercentage}, ?),
        ${QuizTypeStatisticsColumns.bestSessionId} = CASE
          WHEN ? > ${QuizTypeStatisticsColumns.bestScorePercentage} THEN ?
          ELSE ${QuizTypeStatisticsColumns.bestSessionId}
        END,
        ${QuizTypeStatisticsColumns.totalTimePlayedSeconds} = ${QuizTypeStatisticsColumns.totalTimePlayedSeconds} + ?,
        ${QuizTypeStatisticsColumns.totalPerfectScores} = ${QuizTypeStatisticsColumns.totalPerfectScores} + ?,
        ${QuizTypeStatisticsColumns.lastPlayedAt} = ?,
        ${QuizTypeStatisticsColumns.updatedAt} = ?
    ''', [
      // INSERT values
      id,
      session.quizType,
      session.quizCategory,
      isCompleted ? 1 : 0,
      session.totalAnswered,
      session.totalCorrect,
      session.totalFailed,
      session.totalSkipped,
      session.scorePercentage,
      session.id,
      session.durationSeconds ?? 0,
      isPerfect ? 1 : 0,
      timestamp,
      timestamp,
      timestamp,
      // UPDATE values
      isCompleted ? 1 : 0,
      session.totalAnswered,
      session.totalCorrect,
      session.totalFailed,
      session.totalSkipped,
      session.scorePercentage,
      session.scorePercentage,
      session.id,
      session.durationSeconds ?? 0,
      isPerfect ? 1 : 0,
      timestamp,
      timestamp,
    ]);

    // Update average score and time per question
    await _updateQuizTypeAverages(id);
  }

  Future<void> _updateQuizTypeAverages(String id) async {
    await _database.execute('''
      UPDATE $quizTypeStatisticsTable SET
        ${QuizTypeStatisticsColumns.averageScorePercentage} = (
          SELECT COALESCE(AVG(score_percentage), 0)
          FROM quiz_sessions
          WHERE (quiz_type || COALESCE('_' || quiz_category, '')) = ?
            AND completion_status = 'completed'
        ),
        ${QuizTypeStatisticsColumns.averageTimePerQuestion} = CASE
          WHEN ${QuizTypeStatisticsColumns.totalQuestions} > 0
          THEN CAST(${QuizTypeStatisticsColumns.totalTimePlayedSeconds} AS REAL) / ${QuizTypeStatisticsColumns.totalQuestions}
          ELSE 0
        END
      WHERE ${QuizTypeStatisticsColumns.id} = ?
    ''', [id, id]);
  }

  @override
  Future<void> deleteQuizTypeStatistics(
    String quizType, {
    String? category,
  }) async {
    final id = QuizTypeStatistics.generateId(quizType, category);
    await _database.delete(
      quizTypeStatisticsTable,
      where: '${QuizTypeStatisticsColumns.id} = ?',
      whereArgs: [id],
    );
  }

  // ==========================================================================
  // Daily Statistics
  // ==========================================================================

  @override
  Future<DailyStatistics?> getDailyStatistics(DateTime date) async {
    final dateStr = DailyStatistics.formatDate(date);

    final results = await _database.query(
      dailyStatisticsTable,
      where: '${DailyStatisticsColumns.date} = ?',
      whereArgs: [dateStr],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DailyStatistics.fromMap(results.first);
  }

  @override
  Future<List<DailyStatistics>> getDailyStatisticsRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final startStr = DailyStatistics.formatDate(startDate);
    final endStr = DailyStatistics.formatDate(endDate);

    final results = await _database.query(
      dailyStatisticsTable,
      where: '${DailyStatisticsColumns.date} >= ? AND ${DailyStatisticsColumns.date} <= ?',
      whereArgs: [startStr, endStr],
      orderBy: '${DailyStatisticsColumns.date} ASC',
    );

    return results.map(DailyStatistics.fromMap).toList();
  }

  @override
  Future<List<DailyStatistics>> getRecentDailyStatistics(int days) async {
    final endDate = DateTime.now();
    final startDate = endDate.subtract(Duration(days: days - 1));

    return getDailyStatisticsRange(startDate, endDate);
  }

  @override
  Future<void> updateDailyStatisticsForSession(QuizSession session) async {
    final dateStr = DailyStatistics.formatDate(session.startTime);
    final id = 'daily_$dateStr';
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch ~/ 1000;

    final isCompleted = session.completionStatus == CompletionStatus.completed;
    final isCancelled = session.completionStatus == CompletionStatus.cancelled;
    final isPerfect = session.scorePercentage >= 100.0;

    await _database.execute('''
      INSERT INTO $dailyStatisticsTable (
        ${DailyStatisticsColumns.id},
        ${DailyStatisticsColumns.date},
        ${DailyStatisticsColumns.sessionsPlayed},
        ${DailyStatisticsColumns.sessionsCompleted},
        ${DailyStatisticsColumns.sessionsCancelled},
        ${DailyStatisticsColumns.questionsAnswered},
        ${DailyStatisticsColumns.correctAnswers},
        ${DailyStatisticsColumns.incorrectAnswers},
        ${DailyStatisticsColumns.skippedAnswers},
        ${DailyStatisticsColumns.timePlayedSeconds},
        ${DailyStatisticsColumns.averageScorePercentage},
        ${DailyStatisticsColumns.bestScorePercentage},
        ${DailyStatisticsColumns.perfectScores},
        ${DailyStatisticsColumns.hints5050Used},
        ${DailyStatisticsColumns.hintsSkipUsed},
        ${DailyStatisticsColumns.livesUsed},
        ${DailyStatisticsColumns.createdAt},
        ${DailyStatisticsColumns.updatedAt}
      ) VALUES (?, ?, 1, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
      ON CONFLICT(${DailyStatisticsColumns.date}) DO UPDATE SET
        ${DailyStatisticsColumns.sessionsPlayed} = ${DailyStatisticsColumns.sessionsPlayed} + 1,
        ${DailyStatisticsColumns.sessionsCompleted} = ${DailyStatisticsColumns.sessionsCompleted} + ?,
        ${DailyStatisticsColumns.sessionsCancelled} = ${DailyStatisticsColumns.sessionsCancelled} + ?,
        ${DailyStatisticsColumns.questionsAnswered} = ${DailyStatisticsColumns.questionsAnswered} + ?,
        ${DailyStatisticsColumns.correctAnswers} = ${DailyStatisticsColumns.correctAnswers} + ?,
        ${DailyStatisticsColumns.incorrectAnswers} = ${DailyStatisticsColumns.incorrectAnswers} + ?,
        ${DailyStatisticsColumns.skippedAnswers} = ${DailyStatisticsColumns.skippedAnswers} + ?,
        ${DailyStatisticsColumns.timePlayedSeconds} = ${DailyStatisticsColumns.timePlayedSeconds} + ?,
        ${DailyStatisticsColumns.averageScorePercentage} = (
          (${DailyStatisticsColumns.averageScorePercentage} * (${DailyStatisticsColumns.sessionsPlayed} - 1) + ?)
          / ${DailyStatisticsColumns.sessionsPlayed}
        ),
        ${DailyStatisticsColumns.bestScorePercentage} = MAX(${DailyStatisticsColumns.bestScorePercentage}, ?),
        ${DailyStatisticsColumns.perfectScores} = ${DailyStatisticsColumns.perfectScores} + ?,
        ${DailyStatisticsColumns.hints5050Used} = ${DailyStatisticsColumns.hints5050Used} + ?,
        ${DailyStatisticsColumns.hintsSkipUsed} = ${DailyStatisticsColumns.hintsSkipUsed} + ?,
        ${DailyStatisticsColumns.livesUsed} = ${DailyStatisticsColumns.livesUsed} + ?,
        ${DailyStatisticsColumns.updatedAt} = ?
    ''', [
      // INSERT values
      id,
      dateStr,
      isCompleted ? 1 : 0,
      isCancelled ? 1 : 0,
      session.totalAnswered,
      session.totalCorrect,
      session.totalFailed,
      session.totalSkipped,
      session.durationSeconds ?? 0,
      session.scorePercentage,
      session.scorePercentage,
      isPerfect ? 1 : 0,
      session.hintsUsed5050,
      session.hintsUsedSkip,
      session.livesUsed,
      timestamp,
      timestamp,
      // UPDATE values
      isCompleted ? 1 : 0,
      isCancelled ? 1 : 0,
      session.totalAnswered,
      session.totalCorrect,
      session.totalFailed,
      session.totalSkipped,
      session.durationSeconds ?? 0,
      session.scorePercentage,
      session.scorePercentage,
      isPerfect ? 1 : 0,
      session.hintsUsed5050,
      session.hintsUsedSkip,
      session.livesUsed,
      timestamp,
    ]);
  }

  // ==========================================================================
  // Aggregation helpers
  // ==========================================================================

  @override
  Future<void> recalculateAllStatistics() async {
    // This would recalculate all statistics from session data
    // Useful for data recovery or after imports
    // For now, reset and let the next session updates rebuild
    await resetGlobalStatistics();

    // Clear quiz type stats
    await _database.delete(quizTypeStatisticsTable);

    // Clear daily stats
    await _database.delete(dailyStatisticsTable);
  }
}
