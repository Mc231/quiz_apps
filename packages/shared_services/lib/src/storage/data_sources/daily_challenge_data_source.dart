/// Data source for daily challenge database operations.
library;

import '../database/app_database.dart';
import '../database/tables/daily_challenge_table.dart';
import '../models/daily_challenge.dart';
import '../models/daily_challenge_result.dart';

/// Abstract interface for daily challenge data operations.
abstract class DailyChallengeDataSource {
  // ===========================================================================
  // Challenge Operations
  // ===========================================================================

  /// Gets a challenge by ID.
  Future<DailyChallenge?> getChallengeById(String id);

  /// Gets the challenge for a specific date.
  Future<DailyChallenge?> getChallengeByDate(DateTime date);

  /// Saves a new challenge.
  Future<void> saveChallenge(DailyChallenge challenge);

  /// Gets challenges within a date range.
  Future<List<DailyChallenge>> getChallengesInRange(
    DateTime start,
    DateTime end,
  );

  // ===========================================================================
  // Result Operations
  // ===========================================================================

  /// Gets a result by challenge ID.
  Future<DailyChallengeResult?> getResultByChallengeId(String challengeId);

  /// Saves a challenge result.
  Future<void> saveResult(DailyChallengeResult result);

  /// Gets all results, ordered by completion date (newest first).
  Future<List<DailyChallengeResult>> getAllResults({
    int? limit,
    int? offset,
  });

  /// Gets results within a date range.
  Future<List<DailyChallengeResult>> getResultsInRange(
    DateTime start,
    DateTime end,
  );

  /// Gets the count of completed challenges.
  Future<int> getCompletedCount();

  /// Gets the total score across all challenges.
  Future<int> getTotalScore();

  /// Gets the best single-challenge score.
  Future<int> getBestScore();

  /// Gets the average score percentage.
  Future<double> getAverageScorePercentage();

  /// Deletes all results (for testing/reset).
  Future<void> deleteAllResults();
}

/// SQLite implementation of [DailyChallengeDataSource].
class DailyChallengeDataSourceImpl implements DailyChallengeDataSource {
  /// Creates a new [DailyChallengeDataSourceImpl].
  DailyChallengeDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  // ===========================================================================
  // Challenge Operations
  // ===========================================================================

  @override
  Future<DailyChallenge?> getChallengeById(String id) async {
    final results = await _database.query(
      dailyChallengesTable,
      where: '${DailyChallengesColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DailyChallenge.fromMap(results.first);
  }

  @override
  Future<DailyChallenge?> getChallengeByDate(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    final timestamp = normalizedDate.millisecondsSinceEpoch ~/ 1000;

    final results = await _database.query(
      dailyChallengesTable,
      where: '${DailyChallengesColumns.date} = ?',
      whereArgs: [timestamp],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DailyChallenge.fromMap(results.first);
  }

  @override
  Future<void> saveChallenge(DailyChallenge challenge) async {
    await _database.insert(
      dailyChallengesTable,
      challenge.toMap(),
    );
  }

  @override
  Future<List<DailyChallenge>> getChallengesInRange(
    DateTime start,
    DateTime end,
  ) async {
    final startTimestamp = _normalizeDate(start).millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = _normalizeDate(end).millisecondsSinceEpoch ~/ 1000;

    final results = await _database.query(
      dailyChallengesTable,
      where: '${DailyChallengesColumns.date} >= ? AND '
          '${DailyChallengesColumns.date} <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: '${DailyChallengesColumns.date} DESC',
    );

    return results.map(DailyChallenge.fromMap).toList();
  }

  // ===========================================================================
  // Result Operations
  // ===========================================================================

  @override
  Future<DailyChallengeResult?> getResultByChallengeId(
    String challengeId,
  ) async {
    final results = await _database.query(
      dailyChallengeResultsTable,
      where: '${DailyChallengeResultsColumns.challengeId} = ?',
      whereArgs: [challengeId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return DailyChallengeResult.fromMap(results.first);
  }

  @override
  Future<void> saveResult(DailyChallengeResult result) async {
    await _database.insert(
      dailyChallengeResultsTable,
      result.toMap(),
    );
  }

  @override
  Future<List<DailyChallengeResult>> getAllResults({
    int? limit,
    int? offset,
  }) async {
    final results = await _database.query(
      dailyChallengeResultsTable,
      orderBy: '${DailyChallengeResultsColumns.completedAt} DESC',
      limit: limit,
      offset: offset,
    );

    return results.map(DailyChallengeResult.fromMap).toList();
  }

  @override
  Future<List<DailyChallengeResult>> getResultsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final startTimestamp = start.millisecondsSinceEpoch ~/ 1000;
    final endTimestamp = end.millisecondsSinceEpoch ~/ 1000;

    final results = await _database.query(
      dailyChallengeResultsTable,
      where: '${DailyChallengeResultsColumns.completedAt} >= ? AND '
          '${DailyChallengeResultsColumns.completedAt} <= ?',
      whereArgs: [startTimestamp, endTimestamp],
      orderBy: '${DailyChallengeResultsColumns.completedAt} DESC',
    );

    return results.map(DailyChallengeResult.fromMap).toList();
  }

  @override
  Future<int> getCompletedCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $dailyChallengeResultsTable',
    );
    return results.first['count'] as int;
  }

  @override
  Future<int> getTotalScore() async {
    final results = await _database.rawQuery(
      'SELECT COALESCE(SUM(${DailyChallengeResultsColumns.score}), 0) as total '
      'FROM $dailyChallengeResultsTable',
    );
    return results.first['total'] as int;
  }

  @override
  Future<int> getBestScore() async {
    final results = await _database.rawQuery(
      'SELECT COALESCE(MAX(${DailyChallengeResultsColumns.score}), 0) as best '
      'FROM $dailyChallengeResultsTable',
    );
    return results.first['best'] as int;
  }

  @override
  Future<double> getAverageScorePercentage() async {
    final results = await _database.rawQuery(
      'SELECT AVG(CAST(${DailyChallengeResultsColumns.correctCount} AS REAL) / '
      '${DailyChallengeResultsColumns.totalQuestions} * 100) as average '
      'FROM $dailyChallengeResultsTable',
    );
    final average = results.first['average'];
    if (average == null) return 0.0;
    return (average as num).toDouble();
  }

  @override
  Future<void> deleteAllResults() async {
    await _database.delete(dailyChallengeResultsTable);
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Normalizes a date to midnight UTC.
  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }
}
