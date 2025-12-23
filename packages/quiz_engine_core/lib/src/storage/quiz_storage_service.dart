/// Quiz storage service for integrating quiz engine with persistence layer.
///
/// This service bridges the quiz engine BLoC with the storage system,
/// handling conversion between quiz engine models and storage models.
library;

import 'dart:async';

import 'package:uuid/uuid.dart';

import '../model/config/quiz_config.dart';
import '../model/config/quiz_mode_config.dart';
import '../model/config/hint_config.dart';
import '../model/question.dart';
import '../model/question_entry.dart';

/// Callback type for storage operations.
typedef StorageCallback<T> = Future<T> Function();

/// Interface for quiz storage operations.
///
/// This abstract class defines the contract for quiz storage operations.
/// Implementations connect to the actual storage backend (e.g., shared_services).
abstract class QuizStorageService {
  /// Creates a new quiz session.
  ///
  /// Returns the session ID.
  Future<String> createSession({
    required QuizConfig config,
    required int totalQuestions,
  });

  /// Saves an answer for the current session.
  Future<void> saveAnswer({
    required String sessionId,
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
    required Set<QuestionEntry> disabledOptions,
  });

  /// Updates session progress.
  Future<void> updateSessionProgress({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
  });

  /// Completes a session.
  Future<void> completeSession({
    required String sessionId,
    required SessionCompletionStatus status,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
  });

  /// Checks if there's a recoverable session for the quiz.
  Future<bool> hasRecoverableSession(String quizId);

  /// Gets the recoverable session data.
  Future<RecoverableSession?> getRecoverableSession(String quizId);

  /// Marks a session as no longer recoverable (e.g., after recovery or timeout).
  Future<void> clearRecoverableSession(String sessionId);

  /// Deletes a session completely (e.g., when cancelled with no answers).
  Future<void> deleteSession(String sessionId);

  /// Disposes of resources.
  void dispose();
}

/// Status of a saved answer.
enum AnswerStatus {
  /// User answered correctly.
  correct,

  /// User answered incorrectly.
  incorrect,

  /// User skipped the question.
  skipped,

  /// Question timed out.
  timeout,
}

/// Status of session completion.
enum SessionCompletionStatus {
  /// Quiz completed normally (all questions answered).
  completed,

  /// User cancelled/exited early.
  cancelled,

  /// Quiz ended due to time running out.
  timeout,

  /// Quiz failed (e.g., ran out of lives).
  failed,
}

/// Data for a recoverable quiz session.
class RecoverableSession {
  /// Creates a [RecoverableSession].
  const RecoverableSession({
    required this.sessionId,
    required this.quizId,
    required this.currentQuestionNumber,
    required this.answeredQuestions,
    required this.correctCount,
    required this.failedCount,
    required this.skippedCount,
    required this.remainingLives,
    required this.elapsedSeconds,
    required this.startTime,
  });

  /// The session ID.
  final String sessionId;

  /// The quiz ID.
  final String quizId;

  /// The question number to resume from (1-indexed).
  final int currentQuestionNumber;

  /// IDs of questions already answered.
  final Set<String> answeredQuestions;

  /// Number of correct answers so far.
  final int correctCount;

  /// Number of failed answers so far.
  final int failedCount;

  /// Number of skipped questions so far.
  final int skippedCount;

  /// Remaining lives (null if not applicable).
  final int? remainingLives;

  /// Elapsed time in seconds.
  final int elapsedSeconds;

  /// When the session started.
  final DateTime startTime;

  /// Total answered questions.
  int get totalAnswered => correctCount + failedCount + skippedCount;
}

/// Default implementation of [QuizStorageService] that uses callbacks.
///
/// This implementation allows the quiz engine to remain decoupled from
/// the actual storage backend. Apps provide callbacks that connect to
/// their storage implementation.
class CallbackQuizStorageService implements QuizStorageService {
  /// Creates a [CallbackQuizStorageService].
  CallbackQuizStorageService({
    required this.onCreateSession,
    required this.onSaveAnswer,
    required this.onUpdateProgress,
    required this.onCompleteSession,
    required this.onHasRecoverableSession,
    required this.onGetRecoverableSession,
    required this.onClearRecoverableSession,
    required this.onDeleteSession,
  });

  /// Callback to create a session.
  final Future<String> Function({
    required QuizConfig config,
    required int totalQuestions,
  }) onCreateSession;

  /// Callback to save an answer.
  final Future<void> Function({
    required String sessionId,
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
    required Set<QuestionEntry> disabledOptions,
  }) onSaveAnswer;

  /// Callback to update progress.
  final Future<void> Function({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
  }) onUpdateProgress;

  /// Callback to complete a session.
  final Future<void> Function({
    required String sessionId,
    required SessionCompletionStatus status,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
  }) onCompleteSession;

  /// Callback to check for recoverable session.
  final Future<bool> Function(String quizId) onHasRecoverableSession;

  /// Callback to get recoverable session.
  final Future<RecoverableSession?> Function(String quizId)
      onGetRecoverableSession;

  /// Callback to clear recoverable session.
  final Future<void> Function(String sessionId) onClearRecoverableSession;

  /// Callback to delete session.
  final Future<void> Function(String sessionId) onDeleteSession;

  @override
  Future<String> createSession({
    required QuizConfig config,
    required int totalQuestions,
  }) {
    return onCreateSession(config: config, totalQuestions: totalQuestions);
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
    required Set<QuestionEntry> disabledOptions,
  }) {
    return onSaveAnswer(
      sessionId: sessionId,
      questionNumber: questionNumber,
      question: question,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      status: status,
      timeSpentSeconds: timeSpentSeconds,
      hintUsed: hintUsed,
      disabledOptions: disabledOptions,
    );
  }

  @override
  Future<void> updateSessionProgress({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
  }) {
    return onUpdateProgress(
      sessionId: sessionId,
      totalAnswered: totalAnswered,
      totalCorrect: totalCorrect,
      totalFailed: totalFailed,
      totalSkipped: totalSkipped,
    );
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required SessionCompletionStatus status,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
  }) {
    return onCompleteSession(
      sessionId: sessionId,
      status: status,
      totalAnswered: totalAnswered,
      totalCorrect: totalCorrect,
      totalFailed: totalFailed,
      totalSkipped: totalSkipped,
      durationSeconds: durationSeconds,
      hintsUsed5050: hintsUsed5050,
      hintsUsedSkip: hintsUsedSkip,
    );
  }

  @override
  Future<bool> hasRecoverableSession(String quizId) {
    return onHasRecoverableSession(quizId);
  }

  @override
  Future<RecoverableSession?> getRecoverableSession(String quizId) {
    return onGetRecoverableSession(quizId);
  }

  @override
  Future<void> clearRecoverableSession(String sessionId) {
    return onClearRecoverableSession(sessionId);
  }

  @override
  Future<void> deleteSession(String sessionId) {
    return onDeleteSession(sessionId);
  }

  @override
  void dispose() {
    // Nothing to dispose in callback implementation
  }
}

/// A no-op implementation of [QuizStorageService].
///
/// Use this when storage is disabled or for testing.
class NoOpQuizStorageService implements QuizStorageService {
  /// UUID generator for session IDs.
  static const _uuid = Uuid();

  @override
  Future<String> createSession({
    required QuizConfig config,
    required int totalQuestions,
  }) async {
    return _uuid.v4();
  }

  @override
  Future<void> saveAnswer({
    required String sessionId,
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
    required Set<QuestionEntry> disabledOptions,
  }) async {
    // No-op
  }

  @override
  Future<void> updateSessionProgress({
    required String sessionId,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
  }) async {
    // No-op
  }

  @override
  Future<void> completeSession({
    required String sessionId,
    required SessionCompletionStatus status,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
  }) async {
    // No-op
  }

  @override
  Future<bool> hasRecoverableSession(String quizId) async => false;

  @override
  Future<RecoverableSession?> getRecoverableSession(String quizId) async =>
      null;

  @override
  Future<void> clearRecoverableSession(String sessionId) async {
    // No-op
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    // No-op
  }

  @override
  void dispose() {
    // Nothing to dispose
  }
}

/// Helper to convert quiz mode to string representation.
extension QuizModeToString on QuizModeConfig {
  /// Gets the string representation of the quiz mode.
  String get modeString {
    return switch (this) {
      StandardMode() => 'normal',
      TimedMode() => 'timed',
      LivesMode() => 'survival',
      EndlessMode() => 'endless',
      SurvivalMode() => 'survival',
    };
  }

  /// Gets the time limit per question if applicable.
  int? get questionTimeLimit {
    return switch (this) {
      TimedMode(:final timePerQuestion) => timePerQuestion,
      SurvivalMode(:final timePerQuestion) => timePerQuestion,
      _ => null,
    };
  }

  /// Gets the total time limit if applicable.
  int? get totalTimeLimit {
    return switch (this) {
      TimedMode(:final totalTimeLimit) => totalTimeLimit,
      SurvivalMode(:final totalTimeLimit) => totalTimeLimit,
      _ => null,
    };
  }
}
