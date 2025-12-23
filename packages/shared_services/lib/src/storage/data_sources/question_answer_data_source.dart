/// Data source for question answer database operations.
library;

import 'package:sqflite/sqflite.dart';

import '../database/app_database.dart';
import '../database/tables/question_answers_table.dart';
import '../models/question_answer.dart';

/// Filter options for querying question answers.
class QuestionAnswerFilter {
  /// Creates a new [QuestionAnswerFilter].
  const QuestionAnswerFilter({
    this.sessionId,
    this.questionId,
    this.isCorrect,
    this.answerStatus,
    this.hintUsed,
  });

  /// Filter by session ID.
  final String? sessionId;

  /// Filter by question ID.
  final String? questionId;

  /// Filter by correct/incorrect answers.
  final bool? isCorrect;

  /// Filter by answer status.
  final AnswerStatus? answerStatus;

  /// Filter by hint used.
  final HintUsed? hintUsed;

  /// Whether this filter has any conditions.
  bool get hasConditions =>
      sessionId != null ||
      questionId != null ||
      isCorrect != null ||
      answerStatus != null ||
      hintUsed != null;

  /// Builds the WHERE clause and arguments for this filter.
  ({String where, List<dynamic> args}) buildWhereClause() {
    final conditions = <String>[];
    final args = <dynamic>[];

    if (sessionId != null) {
      conditions.add('${QuestionAnswersColumns.sessionId} = ?');
      args.add(sessionId);
    }

    if (questionId != null) {
      conditions.add('${QuestionAnswersColumns.questionId} = ?');
      args.add(questionId);
    }

    if (isCorrect != null) {
      conditions.add('${QuestionAnswersColumns.isCorrect} = ?');
      args.add(isCorrect! ? 1 : 0);
    }

    if (answerStatus != null) {
      conditions.add('${QuestionAnswersColumns.answerStatus} = ?');
      args.add(answerStatus!.value);
    }

    if (hintUsed != null) {
      conditions.add('${QuestionAnswersColumns.hintUsed} = ?');
      args.add(hintUsed!.value);
    }

    return (
      where: conditions.isEmpty ? '' : conditions.join(' AND '),
      args: args,
    );
  }
}

/// Abstract interface for question answer data operations.
abstract class QuestionAnswerDataSource {
  // Create
  /// Inserts a new question answer.
  Future<void> insertAnswer(QuestionAnswer answer);

  /// Inserts multiple answers in a batch.
  Future<void> insertAnswers(List<QuestionAnswer> answers);

  // Read
  /// Gets an answer by its ID.
  Future<QuestionAnswer?> getAnswerById(String id);

  /// Gets all answers for a session.
  Future<List<QuestionAnswer>> getAnswersBySessionId(String sessionId);

  /// Gets all answers with optional filtering.
  Future<List<QuestionAnswer>> getAnswers({
    int? limit,
    int? offset,
    QuestionAnswerFilter? filter,
  });

  /// Gets incorrect answers for a session.
  Future<List<QuestionAnswer>> getIncorrectAnswers(String sessionId);

  /// Gets the most frequently missed questions across all sessions.
  Future<List<({String questionId, int missCount})>> getFrequentlyMissedQuestions(
    int limit,
  );

  /// Gets answers for a specific question ID across all sessions.
  Future<List<QuestionAnswer>> getAnswersByQuestionId(String questionId);

  // Update
  /// Updates an existing answer.
  Future<void> updateAnswer(QuestionAnswer answer);

  // Delete
  /// Deletes an answer by ID.
  Future<void> deleteAnswer(String id);

  /// Deletes all answers for a session.
  Future<void> deleteAnswersBySessionId(String sessionId);

  /// Deletes all answers.
  Future<void> deleteAllAnswers();

  // Statistics
  /// Gets the total number of answers.
  Future<int> getTotalAnswersCount();

  /// Gets the count of correct answers.
  Future<int> getCorrectAnswersCount();

  /// Gets the count of incorrect answers.
  Future<int> getIncorrectAnswersCount();

  /// Gets accuracy rate (correct / total).
  Future<double> getAccuracyRate();
}

/// SQLite implementation of [QuestionAnswerDataSource].
class QuestionAnswerDataSourceImpl implements QuestionAnswerDataSource {
  /// Creates a new [QuestionAnswerDataSourceImpl].
  QuestionAnswerDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<void> insertAnswer(QuestionAnswer answer) async {
    await _database.insert(
      questionAnswersTable,
      answer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> insertAnswers(List<QuestionAnswer> answers) async {
    if (answers.isEmpty) return;

    await _database.batch((batch) {
      for (final answer in answers) {
        batch.insert(
          questionAnswersTable,
          answer.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  @override
  Future<QuestionAnswer?> getAnswerById(String id) async {
    final results = await _database.query(
      questionAnswersTable,
      where: '${QuestionAnswersColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return QuestionAnswer.fromMap(results.first);
  }

  @override
  Future<List<QuestionAnswer>> getAnswersBySessionId(String sessionId) async {
    final results = await _database.query(
      questionAnswersTable,
      where: '${QuestionAnswersColumns.sessionId} = ?',
      whereArgs: [sessionId],
      orderBy: '${QuestionAnswersColumns.questionNumber} ASC',
    );

    return results.map(QuestionAnswer.fromMap).toList();
  }

  @override
  Future<List<QuestionAnswer>> getAnswers({
    int? limit,
    int? offset,
    QuestionAnswerFilter? filter,
  }) async {
    String? where;
    List<dynamic>? whereArgs;

    if (filter != null && filter.hasConditions) {
      final clause = filter.buildWhereClause();
      where = clause.where;
      whereArgs = clause.args;
    }

    final results = await _database.query(
      questionAnswersTable,
      where: where,
      whereArgs: whereArgs,
      orderBy: '${QuestionAnswersColumns.createdAt} DESC',
      limit: limit,
      offset: offset,
    );

    return results.map(QuestionAnswer.fromMap).toList();
  }

  @override
  Future<List<QuestionAnswer>> getIncorrectAnswers(String sessionId) async {
    final results = await _database.query(
      questionAnswersTable,
      where: '${QuestionAnswersColumns.sessionId} = ? AND '
          '${QuestionAnswersColumns.isCorrect} = ?',
      whereArgs: [sessionId, 0],
      orderBy: '${QuestionAnswersColumns.questionNumber} ASC',
    );

    return results.map(QuestionAnswer.fromMap).toList();
  }

  @override
  Future<List<({String questionId, int missCount})>>
      getFrequentlyMissedQuestions(int limit) async {
    final results = await _database.rawQuery(
      '''
      SELECT ${QuestionAnswersColumns.questionId}, COUNT(*) as miss_count
      FROM $questionAnswersTable
      WHERE ${QuestionAnswersColumns.isCorrect} = 0
      GROUP BY ${QuestionAnswersColumns.questionId}
      ORDER BY miss_count DESC
      LIMIT ?
      ''',
      [limit],
    );

    return results.map((row) {
      return (
        questionId: row[QuestionAnswersColumns.questionId] as String,
        missCount: row['miss_count'] as int,
      );
    }).toList();
  }

  @override
  Future<List<QuestionAnswer>> getAnswersByQuestionId(String questionId) async {
    final results = await _database.query(
      questionAnswersTable,
      where: '${QuestionAnswersColumns.questionId} = ?',
      whereArgs: [questionId],
      orderBy: '${QuestionAnswersColumns.createdAt} DESC',
    );

    return results.map(QuestionAnswer.fromMap).toList();
  }

  @override
  Future<void> updateAnswer(QuestionAnswer answer) async {
    await _database.update(
      questionAnswersTable,
      answer.toMap(),
      where: '${QuestionAnswersColumns.id} = ?',
      whereArgs: [answer.id],
    );
  }

  @override
  Future<void> deleteAnswer(String id) async {
    await _database.delete(
      questionAnswersTable,
      where: '${QuestionAnswersColumns.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAnswersBySessionId(String sessionId) async {
    await _database.delete(
      questionAnswersTable,
      where: '${QuestionAnswersColumns.sessionId} = ?',
      whereArgs: [sessionId],
    );
  }

  @override
  Future<void> deleteAllAnswers() async {
    await _database.delete(questionAnswersTable);
  }

  @override
  Future<int> getTotalAnswersCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $questionAnswersTable',
    );
    return results.first['count'] as int;
  }

  @override
  Future<int> getCorrectAnswersCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $questionAnswersTable '
      'WHERE ${QuestionAnswersColumns.isCorrect} = 1',
    );
    return results.first['count'] as int;
  }

  @override
  Future<int> getIncorrectAnswersCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $questionAnswersTable '
      'WHERE ${QuestionAnswersColumns.isCorrect} = 0',
    );
    return results.first['count'] as int;
  }

  @override
  Future<double> getAccuracyRate() async {
    final total = await getTotalAnswersCount();
    if (total == 0) return 0.0;

    final correct = await getCorrectAnswersCount();
    return (correct / total) * 100;
  }
}
