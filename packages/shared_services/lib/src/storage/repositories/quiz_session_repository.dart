/// Repository for quiz session operations.
///
/// Provides a unified interface for managing quiz sessions, including
/// CRUD operations, filtering, and reactive updates via Streams.
library;

import 'dart:async';

import '../data_sources/question_answer_data_source.dart';
import '../data_sources/quiz_session_data_source.dart';
import '../data_sources/statistics_data_source.dart';
import '../models/question_answer.dart';
import '../models/quiz_session.dart';

/// A session with its associated answers.
class SessionWithAnswers {
  /// Creates a [SessionWithAnswers].
  const SessionWithAnswers({
    required this.session,
    required this.answers,
  });

  /// The quiz session.
  final QuizSession session;

  /// The answers for this session, ordered by question number.
  final List<QuestionAnswer> answers;

  /// Gets only the wrong answers.
  List<QuestionAnswer> get wrongAnswers =>
      answers.where((a) => !a.isCorrect).toList();

  /// Gets only the correct answers.
  List<QuestionAnswer> get correctAnswers =>
      answers.where((a) => a.isCorrect).toList();

  /// Gets the number of questions.
  int get questionCount => answers.length;

  @override
  String toString() =>
      'SessionWithAnswers(session: ${session.id}, answers: ${answers.length})';
}

/// Abstract interface for quiz session repository operations.
abstract class QuizSessionRepository {
  // ===========================================================================
  // Session Management
  // ===========================================================================

  /// Saves a new quiz session and returns its ID.
  Future<String> saveSession(QuizSession session);

  /// Saves a session along with its answers in a single transaction.
  Future<void> saveSessionWithAnswers({
    required QuizSession session,
    required List<QuestionAnswer> answers,
  });

  /// Gets a session by its ID.
  Future<QuizSession?> getSession(String id);

  /// Gets sessions with optional filtering and pagination.
  Future<List<QuizSession>> getSessions({
    QuizSessionFilter? filter,
    int? limit,
    int? offset,
  });

  // ===========================================================================
  // Session with Answers
  // ===========================================================================

  /// Gets a session with all its answers.
  Future<SessionWithAnswers?> getSessionWithAnswers(String sessionId);

  /// Gets only the wrong answers for a session.
  Future<List<QuestionAnswer>> getWrongAnswers(String sessionId);

  /// Saves a single question answer during a quiz.
  Future<void> saveQuestionAnswer(QuestionAnswer answer);

  // ===========================================================================
  // Review & Replay
  // ===========================================================================

  /// Gets sessions that are suitable for review (completed with wrong answers).
  Future<List<QuizSession>> getSessionsForReview({int limit = 20});

  /// Gets frequently missed questions across all sessions.
  ///
  /// Returns a map of questionId to the list of wrong answers for that question.
  Future<Map<String, List<QuestionAnswer>>> getFrequentlyMissedQuestions(
    int limit,
  );

  /// Gets recent sessions for display.
  Future<List<QuizSession>> getRecentSessions(int limit);

  /// Gets the best session for a quiz type.
  Future<QuizSession?> getBestSession(String quizType);

  // ===========================================================================
  // Session Completion
  // ===========================================================================

  /// Marks a session as completed with the given status.
  Future<void> completeSession(String sessionId, CompletionStatus status);

  /// Updates a session's score after all questions are answered.
  Future<void> updateSessionScore({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required double scorePercentage,
  });

  // ===========================================================================
  // Cleanup
  // ===========================================================================

  /// Deletes a session and its associated answers.
  Future<void> deleteSession(String id);

  /// Archives (deletes) sessions older than the specified number of days.
  Future<int> archiveOldSessions(int daysOld);

  /// Clears the cache.
  void clearCache();

  // ===========================================================================
  // Reactive Streams
  // ===========================================================================

  /// Watches recent sessions and emits updates when data changes.
  Stream<List<QuizSession>> watchRecentSessions(int limit);

  /// Watches a specific session and emits updates when it changes.
  Stream<QuizSession?> watchSession(String id);

  /// Disposes of resources.
  void dispose();
}

/// Implementation of [QuizSessionRepository].
class QuizSessionRepositoryImpl implements QuizSessionRepository {
  /// Creates a [QuizSessionRepositoryImpl].
  QuizSessionRepositoryImpl({
    required QuizSessionDataSource sessionDataSource,
    required QuestionAnswerDataSource answerDataSource,
    required StatisticsDataSource statsDataSource,
    Duration cacheDuration = const Duration(minutes: 5),
  })  : _sessionDataSource = sessionDataSource,
        _answerDataSource = answerDataSource,
        _statsDataSource = statsDataSource,
        _cacheDuration = cacheDuration;

  final QuizSessionDataSource _sessionDataSource;
  final QuestionAnswerDataSource _answerDataSource;
  final StatisticsDataSource _statsDataSource;
  final Duration _cacheDuration;

  // Cache for sessions
  final Map<String, _CacheEntry<QuizSession>> _sessionCache = {};
  _CacheEntry<List<QuizSession>>? _recentSessionsCache;

  // Stream controllers for reactive updates
  final _recentSessionsController =
      StreamController<List<QuizSession>>.broadcast();
  final Map<String, StreamController<QuizSession?>> _sessionControllers = {};

  // ===========================================================================
  // Session Management
  // ===========================================================================

  @override
  Future<String> saveSession(QuizSession session) async {
    await _sessionDataSource.insertSession(session);

    // Update statistics
    await _statsDataSource.updateGlobalStatisticsForSession(session);
    await _statsDataSource.updateQuizTypeStatisticsForSession(session);
    await _statsDataSource.updateDailyStatisticsForSession(session);

    // Invalidate cache
    _invalidateCache();

    // Notify listeners
    _notifyRecentSessionsChanged();

    return session.id;
  }

  @override
  Future<void> saveSessionWithAnswers({
    required QuizSession session,
    required List<QuestionAnswer> answers,
  }) async {
    // Save session
    await _sessionDataSource.insertSession(session);

    // Save all answers
    await _answerDataSource.insertAnswers(answers);

    // Update statistics
    await _statsDataSource.updateGlobalStatisticsForSession(session);
    await _statsDataSource.updateQuizTypeStatisticsForSession(session);
    await _statsDataSource.updateDailyStatisticsForSession(session);

    // Invalidate cache
    _invalidateCache();

    // Notify listeners
    _notifyRecentSessionsChanged();
    _notifySessionChanged(session.id, session);
  }

  @override
  Future<QuizSession?> getSession(String id) async {
    // Check cache first
    final cached = _sessionCache[id];
    if (cached != null && !cached.isExpired) {
      return cached.value;
    }

    final session = await _sessionDataSource.getSessionById(id);

    // Update cache
    if (session != null) {
      _sessionCache[id] = _CacheEntry(session, _cacheDuration);
    }

    return session;
  }

  @override
  Future<List<QuizSession>> getSessions({
    QuizSessionFilter? filter,
    int? limit,
    int? offset,
  }) async {
    return _sessionDataSource.getAllSessions(
      filter: filter,
      limit: limit,
      offset: offset,
    );
  }

  // ===========================================================================
  // Session with Answers
  // ===========================================================================

  @override
  Future<SessionWithAnswers?> getSessionWithAnswers(String sessionId) async {
    final session = await getSession(sessionId);
    if (session == null) return null;

    final answers = await _answerDataSource.getAnswersBySessionId(sessionId);

    return SessionWithAnswers(session: session, answers: answers);
  }

  @override
  Future<List<QuestionAnswer>> getWrongAnswers(String sessionId) async {
    return _answerDataSource.getIncorrectAnswers(sessionId);
  }

  @override
  Future<void> saveQuestionAnswer(QuestionAnswer answer) async {
    await _answerDataSource.insertAnswer(answer);
  }

  // ===========================================================================
  // Review & Replay
  // ===========================================================================

  @override
  Future<List<QuizSession>> getSessionsForReview({int limit = 20}) async {
    // Get completed sessions with scores less than 100%
    final filter = const QuizSessionFilter(
      completionStatus: CompletionStatus.completed,
      maxScore: 99.9,
    );

    return _sessionDataSource.getAllSessions(filter: filter, limit: limit);
  }

  @override
  Future<Map<String, List<QuestionAnswer>>> getFrequentlyMissedQuestions(
    int limit,
  ) async {
    final frequentlyMissed =
        await _answerDataSource.getFrequentlyMissedQuestions(limit);

    final result = <String, List<QuestionAnswer>>{};

    for (final item in frequentlyMissed) {
      final answers =
          await _answerDataSource.getAnswersByQuestionId(item.questionId);
      // Only include wrong answers
      result[item.questionId] = answers.where((a) => !a.isCorrect).toList();
    }

    return result;
  }

  @override
  Future<List<QuizSession>> getRecentSessions(int limit) async {
    // Check cache
    if (_recentSessionsCache != null &&
        !_recentSessionsCache!.isExpired &&
        _recentSessionsCache!.value.length >= limit) {
      return _recentSessionsCache!.value.take(limit).toList();
    }

    final sessions = await _sessionDataSource.getRecentSessions(limit);

    // Update cache
    _recentSessionsCache = _CacheEntry(sessions, _cacheDuration);

    return sessions;
  }

  @override
  Future<QuizSession?> getBestSession(String quizType) async {
    return _sessionDataSource.getBestSession(quizType);
  }

  // ===========================================================================
  // Session Completion
  // ===========================================================================

  @override
  Future<void> completeSession(
    String sessionId,
    CompletionStatus status,
  ) async {
    await _sessionDataSource.completeSession(sessionId, status);

    // Invalidate cache for this session
    _sessionCache.remove(sessionId);
    _recentSessionsCache = null;

    // Notify listeners
    _notifyRecentSessionsChanged();

    final updatedSession = await getSession(sessionId);
    _notifySessionChanged(sessionId, updatedSession);
  }

  @override
  Future<void> updateSessionScore({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required double scorePercentage,
  }) async {
    final session = await getSession(sessionId);
    if (session == null) return;

    final updatedSession = session.copyWith(
      totalAnswered: totalAnswered,
      totalCorrect: totalCorrect,
      totalFailed: totalFailed,
      totalSkipped: totalSkipped,
      scorePercentage: scorePercentage,
      updatedAt: DateTime.now(),
    );

    await _sessionDataSource.updateSession(updatedSession);

    // Invalidate cache
    _sessionCache.remove(sessionId);
    _recentSessionsCache = null;

    // Notify listeners
    _notifyRecentSessionsChanged();
    _notifySessionChanged(sessionId, updatedSession);
  }

  // ===========================================================================
  // Cleanup
  // ===========================================================================

  @override
  Future<void> deleteSession(String id) async {
    // Delete answers first (due to foreign key)
    await _answerDataSource.deleteAnswersBySessionId(id);

    // Delete session
    await _sessionDataSource.deleteSession(id);

    // Invalidate cache
    _sessionCache.remove(id);
    _recentSessionsCache = null;

    // Notify listeners
    _notifyRecentSessionsChanged();
    _notifySessionChanged(id, null);
  }

  @override
  Future<int> archiveOldSessions(int daysOld) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));

    // Get sessions to delete
    final sessionsToDelete = await _sessionDataSource.getAllSessions(
      filter: QuizSessionFilter(startDateTo: cutoffDate),
    );

    // Delete answers for each session
    for (final session in sessionsToDelete) {
      await _answerDataSource.deleteAnswersBySessionId(session.id);
    }

    // Delete sessions
    final deletedCount = await _sessionDataSource.deleteOldSessions(cutoffDate);

    // Invalidate all cache
    _invalidateCache();

    // Notify listeners
    _notifyRecentSessionsChanged();

    return deletedCount;
  }

  @override
  void clearCache() {
    _invalidateCache();
  }

  // ===========================================================================
  // Reactive Streams
  // ===========================================================================

  @override
  Stream<List<QuizSession>> watchRecentSessions(int limit) {
    // Emit initial value
    getRecentSessions(limit).then((sessions) {
      if (!_recentSessionsController.isClosed) {
        _recentSessionsController.add(sessions);
      }
    });

    return _recentSessionsController.stream;
  }

  @override
  Stream<QuizSession?> watchSession(String id) {
    // Create controller if doesn't exist
    if (!_sessionControllers.containsKey(id)) {
      _sessionControllers[id] = StreamController<QuizSession?>.broadcast();
    }

    // Emit initial value
    getSession(id).then((session) {
      if (_sessionControllers[id] != null &&
          !_sessionControllers[id]!.isClosed) {
        _sessionControllers[id]!.add(session);
      }
    });

    return _sessionControllers[id]!.stream;
  }

  @override
  void dispose() {
    _recentSessionsController.close();
    for (final controller in _sessionControllers.values) {
      controller.close();
    }
    _sessionControllers.clear();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  void _invalidateCache() {
    _sessionCache.clear();
    _recentSessionsCache = null;
  }

  void _notifyRecentSessionsChanged() {
    if (_recentSessionsController.hasListener) {
      getRecentSessions(10).then((sessions) {
        if (!_recentSessionsController.isClosed) {
          _recentSessionsController.add(sessions);
        }
      });
    }
  }

  void _notifySessionChanged(String id, QuizSession? session) {
    if (_sessionControllers.containsKey(id) &&
        !_sessionControllers[id]!.isClosed) {
      _sessionControllers[id]!.add(session);
    }
  }
}

/// Cache entry with expiration.
class _CacheEntry<T> {
  _CacheEntry(this.value, Duration duration)
      : _expiresAt = DateTime.now().add(duration);

  final T value;
  final DateTime _expiresAt;

  bool get isExpired => DateTime.now().isAfter(_expiresAt);
}
