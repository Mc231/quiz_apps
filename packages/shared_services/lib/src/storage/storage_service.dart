/// Storage service facade for simplified storage operations.
///
/// Provides a unified, high-level API for all storage operations,
/// abstracting away the complexity of repositories and data sources.
library;

import 'dart:async';

import 'data_sources/quiz_session_data_source.dart';
import 'models/daily_statistics.dart';
import 'models/global_statistics.dart';
import 'models/question_answer.dart';
import 'models/quiz_session.dart';
import 'models/quiz_type_statistics.dart';
import 'repositories/quiz_session_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/statistics_repository.dart';

/// Result of a storage operation.
class StorageResult<T> {
  /// Creates a successful result.
  const StorageResult.success(this._value)
      : _error = null,
        _isSuccess = true;

  /// Creates a failed result.
  const StorageResult.failure(this._error)
      : _value = null,
        _isSuccess = false;

  final T? _value;
  final StorageError? _error;
  final bool _isSuccess;

  /// Whether the operation was successful.
  bool get isSuccess => _isSuccess;

  /// Whether the operation failed.
  bool get isFailure => !_isSuccess;

  /// Gets the value if successful, throws if failed.
  T get value {
    if (_isSuccess && _value != null) {
      return _value;
    }
    throw StateError('Cannot access value of failed result: $_error');
  }

  /// Gets the value or null.
  T? get valueOrNull => _value;

  /// Gets the error if failed, null if successful.
  StorageError? get error => _error;

  /// Maps the value if successful.
  StorageResult<R> map<R>(R Function(T value) mapper) {
    if (_isSuccess && _value != null) {
      return StorageResult.success(mapper(_value));
    }
    return StorageResult.failure(_error!);
  }

  /// Executes callback if successful.
  void ifSuccess(void Function(T value) callback) {
    if (_isSuccess && _value != null) {
      callback(_value);
    }
  }

  /// Executes callback if failed.
  void ifFailure(void Function(StorageError error) callback) {
    if (!_isSuccess && _error != null) {
      callback(_error);
    }
  }

  @override
  String toString() {
    if (_isSuccess) {
      return 'StorageResult.success($_value)';
    }
    return 'StorageResult.failure($_error)';
  }
}

/// Types of storage errors.
enum StorageErrorType {
  /// Database error (connection, query failure, etc.).
  database,

  /// Record not found.
  notFound,

  /// Validation error (invalid data).
  validation,

  /// Conflict error (duplicate key, constraint violation).
  conflict,

  /// Unknown/unexpected error.
  unknown,
}

/// Represents a storage error.
class StorageError {
  /// Creates a [StorageError].
  const StorageError({
    required this.type,
    required this.message,
    this.originalError,
    this.stackTrace,
  });

  /// The type of error.
  final StorageErrorType type;

  /// Human-readable error message.
  final String message;

  /// The original exception if available.
  final Object? originalError;

  /// Stack trace if available.
  final StackTrace? stackTrace;

  @override
  String toString() => 'StorageError($type): $message';
}

/// High-level storage service facade.
///
/// Provides a simplified API for common storage operations with
/// built-in error handling and retry logic.
///
/// Example:
/// ```dart
/// final storageService = sl.get<StorageService>();
///
/// // Save a session
/// final result = await storageService.saveQuizSession(session);
/// result.ifSuccess((id) => print('Saved session: $id'));
/// result.ifFailure((error) => print('Failed: ${error.message}'));
///
/// // Get statistics
/// final stats = await storageService.getGlobalStatistics();
/// ```
abstract class StorageService {
  // ===========================================================================
  // Quiz Sessions
  // ===========================================================================

  /// Saves a quiz session.
  ///
  /// Returns the session ID on success.
  Future<StorageResult<String>> saveQuizSession(QuizSession session);

  /// Saves a session with all its answers in a single transaction.
  Future<StorageResult<void>> saveQuizSessionWithAnswers({
    required QuizSession session,
    required List<QuestionAnswer> answers,
  });

  /// Gets a session by ID.
  Future<StorageResult<QuizSession?>> getQuizSession(String id);

  /// Gets a session with all its answers.
  Future<StorageResult<SessionWithAnswers?>> getSessionWithAnswers(
    String sessionId,
  );

  /// Gets recent sessions.
  Future<StorageResult<List<QuizSession>>> getRecentSessions({int limit = 20});

  /// Completes a session with the given status.
  Future<StorageResult<void>> completeSession(
    String sessionId,
    CompletionStatus status,
  );

  /// Updates session score after completion.
  Future<StorageResult<void>> updateSessionScore({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required double scorePercentage,
  });

  /// Deletes a session and its answers.
  Future<StorageResult<void>> deleteSession(String id);

  // ===========================================================================
  // Question Answers
  // ===========================================================================

  /// Saves a single question answer.
  Future<StorageResult<void>> saveQuestionAnswer(QuestionAnswer answer);

  /// Gets wrong answers for a session.
  Future<StorageResult<List<QuestionAnswer>>> getWrongAnswers(String sessionId);

  // ===========================================================================
  // Statistics
  // ===========================================================================

  /// Gets global statistics.
  Future<StorageResult<GlobalStatistics>> getGlobalStatistics();

  /// Gets statistics for a specific quiz type.
  Future<StorageResult<QuizTypeStatistics?>> getQuizTypeStatistics(
    String quizType, {
    String? category,
  });

  /// Gets all quiz type statistics.
  Future<StorageResult<List<QuizTypeStatistics>>> getAllQuizTypeStatistics();

  /// Gets today's statistics.
  Future<StorageResult<DailyStatistics?>> getTodayStatistics();

  /// Gets statistics trend for the last N days.
  Future<StorageResult<StatisticsTrend>> getStatisticsTrend(int days);

  /// Gets improvement insights.
  Future<StorageResult<List<ImprovementInsight>>> getImprovementInsights();

  // ===========================================================================
  // Session Recovery
  // ===========================================================================

  /// Gets an interrupted (incomplete) session that can be resumed.
  ///
  /// Returns the most recent session with status 'in_progress' for the
  /// given quiz ID, or null if no recoverable session exists.
  Future<StorageResult<SessionWithAnswers?>> getRecoverableSession(
    String quizId,
  );

  /// Checks if there's a recoverable session for the given quiz.
  Future<bool> hasRecoverableSession(String quizId);

  // ===========================================================================
  // Reactive Streams
  // ===========================================================================

  /// Watches global statistics for changes.
  Stream<GlobalStatistics> watchGlobalStatistics();

  /// Watches recent sessions for changes.
  Stream<List<QuizSession>> watchRecentSessions({int limit = 20});

  /// Watches a specific session for changes.
  Stream<QuizSession?> watchSession(String id);

  // ===========================================================================
  // Cache Management
  // ===========================================================================

  /// Clears all caches.
  void clearCache();

  /// Disposes of resources.
  void dispose();
}

/// Default implementation of [StorageService].
class StorageServiceImpl implements StorageService {
  /// Creates a [StorageServiceImpl].
  StorageServiceImpl({
    required QuizSessionRepository sessionRepository,
    required StatisticsRepository statisticsRepository,
    required SettingsRepository settingsRepository,
    this.maxRetries = 3,
    this.retryDelay = const Duration(milliseconds: 100),
  })  : _sessionRepository = sessionRepository,
        _statisticsRepository = statisticsRepository,
        _settingsRepository = settingsRepository;

  final QuizSessionRepository _sessionRepository;
  final StatisticsRepository _statisticsRepository;
  final SettingsRepository _settingsRepository;

  /// Maximum number of retries for failed operations.
  final int maxRetries;

  /// Delay between retries.
  final Duration retryDelay;

  // ===========================================================================
  // Quiz Sessions
  // ===========================================================================

  @override
  Future<StorageResult<String>> saveQuizSession(QuizSession session) async {
    return _executeWithRetry(() async {
      final id = await _sessionRepository.saveSession(session);
      return StorageResult.success(id);
    });
  }

  @override
  Future<StorageResult<void>> saveQuizSessionWithAnswers({
    required QuizSession session,
    required List<QuestionAnswer> answers,
  }) async {
    return _executeWithRetry(() async {
      await _sessionRepository.saveSessionWithAnswers(
        session: session,
        answers: answers,
      );
      return const StorageResult.success(null);
    });
  }

  @override
  Future<StorageResult<QuizSession?>> getQuizSession(String id) async {
    return _executeWithRetry(() async {
      final session = await _sessionRepository.getSession(id);
      return StorageResult.success(session);
    });
  }

  @override
  Future<StorageResult<SessionWithAnswers?>> getSessionWithAnswers(
    String sessionId,
  ) async {
    return _executeWithRetry(() async {
      final result = await _sessionRepository.getSessionWithAnswers(sessionId);
      return StorageResult.success(result);
    });
  }

  @override
  Future<StorageResult<List<QuizSession>>> getRecentSessions({
    int limit = 20,
  }) async {
    return _executeWithRetry(() async {
      final sessions = await _sessionRepository.getRecentSessions(limit);
      return StorageResult.success(sessions);
    });
  }

  @override
  Future<StorageResult<void>> completeSession(
    String sessionId,
    CompletionStatus status,
  ) async {
    return _executeWithRetry(() async {
      await _sessionRepository.completeSession(sessionId, status);
      return const StorageResult.success(null);
    });
  }

  @override
  Future<StorageResult<void>> updateSessionScore({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required double scorePercentage,
  }) async {
    return _executeWithRetry(() async {
      await _sessionRepository.updateSessionScore(
        sessionId: sessionId,
        totalAnswered: totalAnswered,
        totalCorrect: totalCorrect,
        totalFailed: totalFailed,
        totalSkipped: totalSkipped,
        scorePercentage: scorePercentage,
      );
      return const StorageResult.success(null);
    });
  }

  @override
  Future<StorageResult<void>> deleteSession(String id) async {
    return _executeWithRetry(() async {
      await _sessionRepository.deleteSession(id);
      return const StorageResult.success(null);
    });
  }

  // ===========================================================================
  // Question Answers
  // ===========================================================================

  @override
  Future<StorageResult<void>> saveQuestionAnswer(QuestionAnswer answer) async {
    return _executeWithRetry(() async {
      await _sessionRepository.saveQuestionAnswer(answer);
      return const StorageResult.success(null);
    });
  }

  @override
  Future<StorageResult<List<QuestionAnswer>>> getWrongAnswers(
    String sessionId,
  ) async {
    return _executeWithRetry(() async {
      final answers = await _sessionRepository.getWrongAnswers(sessionId);
      return StorageResult.success(answers);
    });
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  @override
  Future<StorageResult<GlobalStatistics>> getGlobalStatistics() async {
    return _executeWithRetry(() async {
      final stats = await _statisticsRepository.getGlobalStatistics();
      return StorageResult.success(stats);
    });
  }

  @override
  Future<StorageResult<QuizTypeStatistics?>> getQuizTypeStatistics(
    String quizType, {
    String? category,
  }) async {
    return _executeWithRetry(() async {
      final stats = await _statisticsRepository.getQuizTypeStatistics(
        quizType,
        category: category,
      );
      return StorageResult.success(stats);
    });
  }

  @override
  Future<StorageResult<List<QuizTypeStatistics>>>
      getAllQuizTypeStatistics() async {
    return _executeWithRetry(() async {
      final stats = await _statisticsRepository.getAllQuizTypeStatistics();
      return StorageResult.success(stats);
    });
  }

  @override
  Future<StorageResult<DailyStatistics?>> getTodayStatistics() async {
    return _executeWithRetry(() async {
      final stats = await _statisticsRepository.getTodayStatistics();
      return StorageResult.success(stats);
    });
  }

  @override
  Future<StorageResult<StatisticsTrend>> getStatisticsTrend(int days) async {
    return _executeWithRetry(() async {
      final trend = await _statisticsRepository.getTrend(days);
      return StorageResult.success(trend);
    });
  }

  @override
  Future<StorageResult<List<ImprovementInsight>>>
      getImprovementInsights() async {
    return _executeWithRetry(() async {
      final insights = await _statisticsRepository.getImprovementInsights();
      return StorageResult.success(insights);
    });
  }

  // ===========================================================================
  // Session Recovery
  // ===========================================================================

  @override
  Future<StorageResult<SessionWithAnswers?>> getRecoverableSession(
    String quizId,
  ) async {
    return _executeWithRetry(() async {
      // Get recent sessions for the quiz type and filter by quizId
      final sessions = await _sessionRepository.getSessions(
        filter: QuizSessionFilter(
          completionStatus: CompletionStatus.cancelled,
        ),
        limit: 10,
      );

      // Find sessions matching the quizId
      final matchingSessions = sessions.where((s) => s.quizId == quizId).toList();

      if (matchingSessions.isEmpty) {
        return const StorageResult.success(null);
      }

      final session = matchingSessions.first;
      // Only recover sessions from the last 24 hours
      final cutoff = DateTime.now().subtract(const Duration(hours: 24));
      if (session.startTime.isBefore(cutoff)) {
        return const StorageResult.success(null);
      }

      final withAnswers = await _sessionRepository.getSessionWithAnswers(
        session.id,
      );
      return StorageResult.success(withAnswers);
    });
  }

  @override
  Future<bool> hasRecoverableSession(String quizId) async {
    final result = await getRecoverableSession(quizId);
    return result.isSuccess && result.valueOrNull != null;
  }

  // ===========================================================================
  // Reactive Streams
  // ===========================================================================

  @override
  Stream<GlobalStatistics> watchGlobalStatistics() {
    return _statisticsRepository.watchGlobalStatistics();
  }

  @override
  Stream<List<QuizSession>> watchRecentSessions({int limit = 20}) {
    return _sessionRepository.watchRecentSessions(limit);
  }

  @override
  Stream<QuizSession?> watchSession(String id) {
    return _sessionRepository.watchSession(id);
  }

  // ===========================================================================
  // Cache Management
  // ===========================================================================

  @override
  void clearCache() {
    _sessionRepository.clearCache();
    _statisticsRepository.clearCache();
    _settingsRepository.clearCache();
  }

  @override
  void dispose() {
    _sessionRepository.dispose();
    _statisticsRepository.dispose();
    _settingsRepository.dispose();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Executes an operation with automatic retry on failure.
  Future<StorageResult<T>> _executeWithRetry<T>(
    Future<StorageResult<T>> Function() operation,
  ) async {
    int attempts = 0;

    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e, stackTrace) {
        attempts++;

        if (attempts >= maxRetries) {
          return StorageResult.failure(
            StorageError(
              type: _classifyError(e),
              message: e.toString(),
              originalError: e,
              stackTrace: stackTrace,
            ),
          );
        }

        // Wait before retrying
        await Future.delayed(retryDelay * attempts);
      }
    }

    // Should never reach here, but just in case
    return StorageResult.failure(
      const StorageError(
        type: StorageErrorType.unknown,
        message: 'Max retries exceeded',
      ),
    );
  }

  /// Classifies an error into a StorageErrorType.
  StorageErrorType _classifyError(Object error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('not found') ||
        errorString.contains('no such') ||
        errorString.contains('does not exist')) {
      return StorageErrorType.notFound;
    }

    if (errorString.contains('constraint') ||
        errorString.contains('unique') ||
        errorString.contains('duplicate') ||
        errorString.contains('conflict')) {
      return StorageErrorType.conflict;
    }

    if (errorString.contains('database') ||
        errorString.contains('sql') ||
        errorString.contains('sqflite')) {
      return StorageErrorType.database;
    }

    if (errorString.contains('invalid') ||
        errorString.contains('validation') ||
        errorString.contains('required')) {
      return StorageErrorType.validation;
    }

    return StorageErrorType.unknown;
  }
}
