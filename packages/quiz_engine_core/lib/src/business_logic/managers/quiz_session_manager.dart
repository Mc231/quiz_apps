import '../../model/config/hint_config.dart';
import '../../model/config/quiz_config.dart';
import '../../model/question.dart';
import '../../model/question_entry.dart';
import '../../storage/quiz_storage_service.dart';

/// Manages quiz session lifecycle and storage integration.
///
/// This manager is responsible for:
/// - Creating and managing quiz sessions
/// - Saving answers to storage
/// - Completing or cancelling sessions
/// - Handling storage errors gracefully
class QuizSessionManager {
  /// The storage service (optional - may be null).
  final QuizStorageService? _storageService;

  /// The current session ID.
  String? _currentSessionId;

  /// The quiz configuration.
  QuizConfig? _config;

  /// Creates a new session manager.
  ///
  /// [storageService] - Optional storage service for persistence
  QuizSessionManager({
    QuizStorageService? storageService,
  }) : _storageService = storageService;

  // ============ Getters ============

  /// The current session ID (null if no session or storage disabled).
  String? get currentSessionId => _currentSessionId;

  /// Whether storage is enabled for this session.
  bool get isStorageEnabled =>
      _storageService != null &&
      _config != null &&
      _config!.storageConfig.enabled;

  /// Whether answers should be saved during the quiz.
  bool get shouldSaveAnswersDuringQuiz =>
      isStorageEnabled && (_config?.storageConfig.saveAnswersDuringQuiz ?? false);

  // ============ Session Lifecycle ============

  /// Initializes a new quiz session.
  ///
  /// [config] - The quiz configuration
  /// [totalQuestions] - Total number of questions in the quiz
  ///
  /// Returns the session ID if storage is enabled, null otherwise.
  Future<String?> initializeSession({
    required QuizConfig config,
    required int totalQuestions,
  }) async {
    _config = config;

    if (!isStorageEnabled) {
      _currentSessionId = null;
      return null;
    }

    try {
      _currentSessionId = await _storageService!.createSession(
        config: config,
        totalQuestions: totalQuestions,
      );
      return _currentSessionId;
    } catch (e) {
      // Storage failure should not block quiz from starting
      _currentSessionId = null;
      return null;
    }
  }

  // ============ Answer Saving ============

  /// Saves an answer to storage.
  ///
  /// Silently fails if storage is disabled or encounters an error.
  Future<void> saveAnswer({
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
    required Set<QuestionEntry> disabledOptions,
  }) async {
    if (!shouldSaveAnswersDuringQuiz || _currentSessionId == null) {
      return;
    }

    try {
      await _storageService!.saveAnswer(
        sessionId: _currentSessionId!,
        questionNumber: questionNumber,
        question: question,
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
        status: status,
        timeSpentSeconds: timeSpentSeconds,
        hintUsed: hintUsed,
        disabledOptions: disabledOptions,
      );
    } catch (e) {
      // Storage failure should not block quiz progression
    }
  }

  // ============ Session Completion ============

  /// Completes the current session.
  ///
  /// [status] - How the session ended
  /// [totalAnswered] - Total number of questions answered
  /// [totalCorrect] - Number of correct answers
  /// [totalFailed] - Number of failed answers (incorrect + timeout)
  /// [totalSkipped] - Number of skipped questions
  /// [durationSeconds] - Session duration in seconds
  /// [hintsUsed5050] - Number of 50/50 hints used
  /// [hintsUsedSkip] - Number of skip hints used
  /// [bestStreak] - Best streak achieved
  /// [score] - Final score
  Future<void> completeSession({
    required SessionCompletionStatus status,
    required int totalAnswered,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
    int bestStreak = 0,
    int score = 0,
  }) async {
    if (!isStorageEnabled || _currentSessionId == null) {
      return;
    }

    try {
      await _storageService!.completeSession(
        sessionId: _currentSessionId!,
        status: status,
        totalAnswered: totalAnswered,
        totalCorrect: totalCorrect,
        totalFailed: totalFailed,
        totalSkipped: totalSkipped,
        durationSeconds: durationSeconds,
        hintsUsed5050: hintsUsed5050,
        hintsUsedSkip: hintsUsedSkip,
        bestStreak: bestStreak,
        score: score,
      );
    } catch (e) {
      // Storage failure should not affect game over flow
    }
  }

  // ============ Session Cancellation ============

  /// Cancels the current session.
  ///
  /// If no answers were given, the session is deleted entirely.
  /// Otherwise, it is marked as cancelled with the current progress.
  ///
  /// [hasAnswers] - Whether any answers were given
  /// [totalCorrect] - Number of correct answers
  /// [totalFailed] - Number of failed answers
  /// [totalSkipped] - Number of skipped answers
  /// [durationSeconds] - Session duration in seconds
  /// [hintsUsed5050] - Number of 50/50 hints used
  /// [hintsUsedSkip] - Number of skip hints used
  /// [bestStreak] - Best streak achieved
  Future<void> cancelSession({
    required bool hasAnswers,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
    required int durationSeconds,
    required int hintsUsed5050,
    required int hintsUsedSkip,
    int bestStreak = 0,
  }) async {
    if (!isStorageEnabled || _currentSessionId == null) {
      return;
    }

    try {
      if (!hasAnswers) {
        // Delete the session entirely if no answers
        await _storageService!.deleteSession(_currentSessionId!);
      } else {
        // Complete as cancelled with progress
        await _storageService!.completeSession(
          sessionId: _currentSessionId!,
          status: SessionCompletionStatus.cancelled,
          totalAnswered: totalCorrect + totalFailed + totalSkipped,
          totalCorrect: totalCorrect,
          totalFailed: totalFailed,
          totalSkipped: totalSkipped,
          durationSeconds: durationSeconds,
          hintsUsed5050: hintsUsed5050,
          hintsUsedSkip: hintsUsedSkip,
          bestStreak: bestStreak,
        );
      }
    } catch (e) {
      // Storage failure should not block cancellation
    }
  }

  // ============ Session Recovery ============

  /// Checks if there's a recoverable session for the quiz.
  Future<bool> hasRecoverableSession(String quizId) async {
    if (_storageService == null) return false;

    try {
      return await _storageService!.hasRecoverableSession(quizId);
    } catch (e) {
      return false;
    }
  }

  /// Gets the recoverable session data.
  Future<RecoverableSession?> getRecoverableSession(String quizId) async {
    if (_storageService == null) return null;

    try {
      return await _storageService!.getRecoverableSession(quizId);
    } catch (e) {
      return null;
    }
  }

  /// Clears the recoverable session.
  Future<void> clearRecoverableSession() async {
    if (_storageService == null || _currentSessionId == null) return;

    try {
      await _storageService!.clearRecoverableSession(_currentSessionId!);
    } catch (e) {
      // Ignore errors
    }
  }

  // ============ Reset ============

  /// Resets the manager state.
  void reset() {
    _currentSessionId = null;
    _config = null;
  }

  /// Disposes the storage service.
  void dispose() {
    _storageService?.dispose();
    reset();
  }
}
