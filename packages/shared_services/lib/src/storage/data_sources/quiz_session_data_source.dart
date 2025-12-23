/// Data source for quiz session database operations.
library;

import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/tables/quiz_sessions_table.dart';
import '../models/quiz_session.dart';

/// Filter options for querying quiz sessions.
class QuizSessionFilter {
  /// Creates a new [QuizSessionFilter].
  const QuizSessionFilter({
    this.quizType,
    this.quizCategory,
    this.completionStatus,
    this.mode,
    this.startDateFrom,
    this.startDateTo,
    this.minScore,
    this.maxScore,
  });

  /// Filter by quiz type.
  final String? quizType;

  /// Filter by quiz category.
  final String? quizCategory;

  /// Filter by completion status.
  final CompletionStatus? completionStatus;

  /// Filter by quiz mode.
  final QuizMode? mode;

  /// Filter sessions started on or after this date.
  final DateTime? startDateFrom;

  /// Filter sessions started on or before this date.
  final DateTime? startDateTo;

  /// Filter sessions with score >= this value.
  final double? minScore;

  /// Filter sessions with score <= this value.
  final double? maxScore;

  /// Whether this filter has any conditions.
  bool get hasConditions =>
      quizType != null ||
      quizCategory != null ||
      completionStatus != null ||
      mode != null ||
      startDateFrom != null ||
      startDateTo != null ||
      minScore != null ||
      maxScore != null;

  /// Builds the WHERE clause and arguments for this filter.
  ({String where, List<dynamic> args}) buildWhereClause() {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (quizType != null) {
      conditions.add('${QuizSessionsColumns.quizType} = ?');
      args.add(quizType);
    }

    if (quizCategory != null) {
      conditions.add('${QuizSessionsColumns.quizCategory} = ?');
      args.add(quizCategory);
    }

    if (completionStatus != null) {
      conditions.add('${QuizSessionsColumns.completionStatus} = ?');
      args.add(completionStatus!.value);
    }

    if (mode != null) {
      conditions.add('${QuizSessionsColumns.mode} = ?');
      args.add(mode!.value);
    }

    if (startDateFrom != null) {
      conditions.add('${QuizSessionsColumns.startTime} >= ?');
      args.add(startDateFrom!.millisecondsSinceEpoch ~/ 1000);
    }

    if (startDateTo != null) {
      conditions.add('${QuizSessionsColumns.startTime} <= ?');
      args.add(startDateTo!.millisecondsSinceEpoch ~/ 1000);
    }

    if (minScore != null) {
      conditions.add('${QuizSessionsColumns.scorePercentage} >= ?');
      args.add(minScore);
    }

    if (maxScore != null) {
      conditions.add('${QuizSessionsColumns.scorePercentage} <= ?');
      args.add(maxScore);
    }

    return (
      where: conditions.isEmpty ? '' : conditions.join(' AND '),
      args: args,
    );
  }
}

/// Abstract interface for quiz session data operations.
abstract class QuizSessionDataSource {
  // Create
  /// Inserts a new quiz session.
  Future<void> insertSession(QuizSession session);

  // Read
  /// Gets a session by its ID.
  Future<QuizSession?> getSessionById(String id);

  /// Gets all sessions with optional pagination and filtering.
  Future<List<QuizSession>> getAllSessions({
    int? limit,
    int? offset,
    QuizSessionFilter? filter,
  });

  /// Gets the most recent sessions.
  Future<List<QuizSession>> getRecentSessions(int limit);

  /// Gets sessions of a specific quiz type.
  Future<List<QuizSession>> getSessionsByType(String quizType);

  /// Gets the best session for a quiz type (highest score).
  Future<QuizSession?> getBestSession(String quizType);

  // Update
  /// Updates an existing session.
  Future<void> updateSession(QuizSession session);

  /// Marks a session as completed with the given status.
  Future<void> completeSession(String sessionId, CompletionStatus status);

  // Delete
  /// Deletes a session by ID.
  Future<void> deleteSession(String id);

  /// Deletes all sessions.
  Future<void> deleteAllSessions();

  /// Deletes sessions older than the given date.
  Future<int> deleteOldSessions(DateTime before);

  // Statistics
  /// Gets the total number of sessions.
  Future<int> getTotalSessionsCount();

  /// Gets the number of completed sessions.
  Future<int> getCompletedSessionsCount();

  /// Gets the average score across all completed sessions.
  Future<double> getAverageScore();
}

/// SQLite implementation of [QuizSessionDataSource].
class QuizSessionDataSourceImpl implements QuizSessionDataSource {
  /// Creates a new [QuizSessionDataSourceImpl].
  QuizSessionDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<void> insertSession(QuizSession session) async {
    await _database.insert(
      quizSessionsTable,
      session.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<QuizSession?> getSessionById(String id) async {
    final results = await _database.query(
      quizSessionsTable,
      where: '${QuizSessionsColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return QuizSession.fromMap(results.first);
  }

  @override
  Future<List<QuizSession>> getAllSessions({
    int? limit,
    int? offset,
    QuizSessionFilter? filter,
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (filter != null && filter.hasConditions) {
      final clause = filter.buildWhereClause();
      where = clause.where;
      whereArgs = clause.args;
    }

    final results = await _database.query(
      quizSessionsTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${QuizSessionsColumns.startTime} DESC',
      limit: limit,
      offset: offset,
    );

    return results.map(QuizSession.fromMap).toList();
  }

  @override
  Future<List<QuizSession>> getRecentSessions(int limit) async {
    final results = await _database.query(
      quizSessionsTable,
      orderBy: '${QuizSessionsColumns.startTime} DESC',
      limit: limit,
    );

    return results.map(QuizSession.fromMap).toList();
  }

  @override
  Future<List<QuizSession>> getSessionsByType(String quizType) async {
    final results = await _database.query(
      quizSessionsTable,
      where: '${QuizSessionsColumns.quizType} = ?',
      whereArgs: [quizType],
      orderBy: '${QuizSessionsColumns.startTime} DESC',
    );

    return results.map(QuizSession.fromMap).toList();
  }

  @override
  Future<QuizSession?> getBestSession(String quizType) async {
    final results = await _database.query(
      quizSessionsTable,
      where: '${QuizSessionsColumns.quizType} = ? AND '
          '${QuizSessionsColumns.completionStatus} = ?',
      whereArgs: [quizType, CompletionStatus.completed.value],
      orderBy: '${QuizSessionsColumns.scorePercentage} DESC',
      limit: 1,
    );

    if (results.isEmpty) return null;
    return QuizSession.fromMap(results.first);
  }

  @override
  Future<void> updateSession(QuizSession session) async {
    await _database.update(
      quizSessionsTable,
      session.toMap(),
      where: '${QuizSessionsColumns.id} = ?',
      whereArgs: [session.id],
    );
  }

  @override
  Future<void> completeSession(
    String sessionId,
    CompletionStatus status,
  ) async {
    final now = DateTime.now();
    final session = await getSessionById(sessionId);

    if (session == null) return;

    final duration = now.difference(session.startTime).inSeconds;

    await _database.update(
      quizSessionsTable,
      {
        QuizSessionsColumns.completionStatus: status.value,
        QuizSessionsColumns.endTime: now.millisecondsSinceEpoch ~/ 1000,
        QuizSessionsColumns.durationSeconds: duration,
        QuizSessionsColumns.updatedAt: now.millisecondsSinceEpoch ~/ 1000,
      },
      where: '${QuizSessionsColumns.id} = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<void> deleteSession(String id) async {
    await _database.delete(
      quizSessionsTable,
      where: '${QuizSessionsColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAllSessions() async {
    await _database.delete(quizSessionsTable);
  }

  @override
  Future<int> deleteOldSessions(DateTime before) async {
    return await _database.delete(
      quizSessionsTable,
      where: '${QuizSessionsColumns.startTime} < ?',
      whereArgs: [before.millisecondsSinceEpoch ~/ 1000],
    );
  }

  @override
  Future<int> getTotalSessionsCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $quizSessionsTable',
    );
    return results.first['count'] as int;
  }

  @override
  Future<int> getCompletedSessionsCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $quizSessionsTable '
      'WHERE ${QuizSessionsColumns.completionStatus} = ?',
      [CompletionStatus.completed.value],
    );
    return results.first['count'] as int;
  }

  @override
  Future<double> getAverageScore() async {
    final results = await _database.rawQuery(
      'SELECT AVG(${QuizSessionsColumns.scorePercentage}) as avg_score '
      'FROM $quizSessionsTable '
      'WHERE ${QuizSessionsColumns.completionStatus} = ?',
      [CompletionStatus.completed.value],
    );

    final avgScore = results.first['avg_score'];
    if (avgScore == null) return 0.0;
    return (avgScore as num).toDouble();
  }
}
