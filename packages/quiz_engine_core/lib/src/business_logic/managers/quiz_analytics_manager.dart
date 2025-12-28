import '../../analytics/quiz_analytics_service.dart';
import '../../model/config/quiz_config.dart';
import '../../model/question.dart';
import '../../model/question_entry.dart';
import '../../model/quiz_results.dart';
import '../../storage/quiz_storage_service.dart';

/// Manages quiz analytics tracking.
///
/// This manager is responsible for:
/// - Tracking quiz lifecycle events (start, complete, cancel, etc.)
/// - Tracking question events (displayed, answered, skipped, timeout)
/// - Tracking hint usage events
/// - Tracking resource events (lives lost, depleted)
/// - Handling analytics errors gracefully (analytics should never block quiz)
class QuizAnalyticsManager {
  /// The analytics service (optional - may be null).
  final QuizAnalyticsService _analyticsService;

  /// The quiz configuration.
  QuizConfig? _config;

  /// The category ID.
  String? _categoryId;

  /// The category name.
  String? _categoryName;

  /// Timestamp when quiz was paused (for calculating pause duration).
  DateTime? _pausedAt;

  /// Creates a new analytics manager.
  ///
  /// [analyticsService] - Optional analytics service for tracking events
  QuizAnalyticsManager({
    required QuizAnalyticsService analyticsService,
  }) : _analyticsService = analyticsService;

  // ============ Getters ============

  /// Whether analytics is enabled.
  bool get isEnabled => true;

  /// The current quiz ID.
  String? get quizId => _config?.quizId;

  // ============ Initialization ============

  /// Initializes the analytics manager with the quiz configuration.
  void initialize({
    required QuizConfig config,
    required String categoryId,
    required String categoryName,
  }) {
    _config = config;
    _categoryId = categoryId;
    _categoryName = categoryName;
  }

  // ============ Quiz Lifecycle Events ============

  /// Tracks when a quiz is started.
  Future<void> trackQuizStarted({
    required String quizName,
    required int totalQuestions,
    int? initialLives,
    int? initialHints,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuizStarted(
        quizId: _config!.quizId,
        quizName: quizName,
        categoryId: _categoryId!,
        categoryName: _categoryName!,
        modeConfig: _config!.modeConfig,
        totalQuestions: totalQuestions,
        initialLives: initialLives,
        initialHints: initialHints,
      );
    } catch (e) {
      // Analytics failure should not block quiz
    }
  }

  /// Tracks when a quiz is completed.
  Future<void> trackQuizCompleted({
    required QuizResults results,
  }) async {
    if (!isEnabled) return;

    try {
      await _analyticsService.trackQuizCompleted(results: results);
    } catch (e) {
      // Analytics failure should not block game over flow
    }
  }

  /// Tracks when a quiz is cancelled.
  Future<void> trackQuizCancelled({
    required String quizName,
    required int questionsAnswered,
    required int totalQuestions,
    required Duration timeSpent,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuizCancelled(
        quizId: _config!.quizId,
        quizName: quizName,
        categoryId: _categoryId!,
        mode: _config!.modeConfig.modeString,
        questionsAnswered: questionsAnswered,
        totalQuestions: totalQuestions,
        timeSpent: timeSpent,
      );
    } catch (e) {
      // Analytics failure should not block cancellation
    }
  }

  /// Tracks when a quiz fails (lives depleted).
  Future<void> trackQuizFailed({
    required String quizName,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required Duration duration,
    required String reason,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      final scorePercentage = totalQuestions > 0
          ? (correctAnswers / totalQuestions * 100)
          : 0.0;

      await _analyticsService.trackQuizFailed(
        quizId: _config!.quizId,
        quizName: quizName,
        categoryId: _categoryId!,
        mode: _config!.modeConfig.modeString,
        questionsAnswered: questionsAnswered,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        scorePercentage: scorePercentage,
        duration: duration,
        reason: reason,
      );
    } catch (e) {
      // Analytics failure should not block game over flow
    }
  }

  /// Tracks when a quiz times out.
  Future<void> trackQuizTimeout({
    required String quizName,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      final scorePercentage = totalQuestions > 0
          ? (correctAnswers / totalQuestions * 100)
          : 0.0;

      await _analyticsService.trackQuizTimeout(
        quizId: _config!.quizId,
        quizName: quizName,
        categoryId: _categoryId!,
        mode: _config!.modeConfig.modeString,
        questionsAnswered: questionsAnswered,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        scorePercentage: scorePercentage,
      );
    } catch (e) {
      // Analytics failure should not block game over flow
    }
  }

  /// Tracks when a quiz is paused.
  Future<void> trackQuizPaused({
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
  }) async {
    _pausedAt = DateTime.now();

    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuizPaused(
        quizId: _config!.quizId,
        quizName: quizName,
        currentQuestion: currentQuestion,
        totalQuestions: totalQuestions,
      );
    } catch (e) {
      // Analytics failure should not block pause
    }
  }

  /// Tracks when a quiz is resumed.
  Future<void> trackQuizResumed({
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
  }) async {
    if (!isEnabled || _config == null) return;

    final pauseDuration = _pausedAt != null
        ? DateTime.now().difference(_pausedAt!)
        : Duration.zero;
    _pausedAt = null;

    try {
      await _analyticsService.trackQuizResumed(
        quizId: _config!.quizId,
        quizName: quizName,
        currentQuestion: currentQuestion,
        totalQuestions: totalQuestions,
        pauseDuration: pauseDuration,
      );
    } catch (e) {
      // Analytics failure should not block resume
    }
  }

  // ============ Question Events ============

  /// Tracks when a question is displayed.
  Future<void> trackQuestionDisplayed({
    required Question question,
    required int questionIndex,
    required int totalQuestions,
    int? timeLimit,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuestionDisplayed(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        totalQuestions: totalQuestions,
        timeLimit: timeLimit,
      );
    } catch (e) {
      // Analytics failure should not block question display
    }
  }

  /// Tracks when a question is answered.
  Future<void> trackQuestionAnswered({
    required Question question,
    required int questionIndex,
    required bool isCorrect,
    required Duration responseTime,
    required QuestionEntry selectedAnswer,
    int? currentStreak,
    int? livesRemaining,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuestionAnswered(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        isCorrect: isCorrect,
        responseTime: responseTime,
        selectedAnswer: selectedAnswer,
        currentStreak: currentStreak,
        livesRemaining: livesRemaining,
      );
    } catch (e) {
      // Analytics failure should not block answer processing
    }
  }

  /// Tracks when a question is skipped.
  Future<void> trackQuestionSkipped({
    required Question question,
    required int questionIndex,
    required Duration timeBeforeSkip,
    required bool usedHint,
    int? hintsRemaining,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuestionSkipped(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        timeBeforeSkip: timeBeforeSkip,
        usedHint: usedHint,
        hintsRemaining: hintsRemaining,
      );
    } catch (e) {
      // Analytics failure should not block skip
    }
  }

  /// Tracks when a question times out.
  Future<void> trackQuestionTimeout({
    required Question question,
    required int questionIndex,
    required int timeLimit,
    int? livesRemaining,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackQuestionTimeout(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        timeLimit: timeLimit,
        livesRemaining: livesRemaining,
      );
    } catch (e) {
      // Analytics failure should not block timeout handling
    }
  }

  /// Tracks when a user selects an answer option.
  Future<void> trackOptionSelected({
    required Question question,
    required int questionIndex,
    required QuestionEntry selectedOption,
    required int optionIndex,
    required Duration timeSinceDisplayed,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackOptionSelected(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        selectedOption: selectedOption,
        optionIndex: optionIndex,
        timeSinceDisplayed: timeSinceDisplayed,
      );
    } catch (e) {
      // Analytics failure should not block option selection
    }
  }

  /// Tracks when answer feedback is shown to the user.
  Future<void> trackFeedbackShown({
    required Question question,
    required int questionIndex,
    required bool wasCorrect,
    required Duration feedbackDuration,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackFeedbackShown(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        wasCorrect: wasCorrect,
        feedbackDuration: feedbackDuration,
      );
    } catch (e) {
      // Analytics failure should not block feedback display
    }
  }

  // ============ Hint Events ============

  /// Tracks when a 50/50 hint is used.
  Future<void> trackHintFiftyFiftyUsed({
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required List<QuestionEntry> eliminatedOptions,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackHintFiftyFiftyUsed(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        hintsRemaining: hintsRemaining,
        eliminatedOptions: eliminatedOptions,
      );
    } catch (e) {
      // Analytics failure should not block hint usage
    }
  }

  /// Tracks when a skip hint is used.
  Future<void> trackHintSkipUsed({
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required Duration timeBeforeSkip,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackHintSkipUsed(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        hintsRemaining: hintsRemaining,
        timeBeforeSkip: timeBeforeSkip,
      );
    } catch (e) {
      // Analytics failure should not block hint usage
    }
  }

  // ============ Resource Events ============

  /// Tracks when a life is lost.
  Future<void> trackLifeLost({
    required Question question,
    required int questionIndex,
    required int livesRemaining,
    required int livesTotal,
    required String reason,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackLifeLost(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        livesRemaining: livesRemaining,
        livesTotal: livesTotal,
        reason: reason,
      );
    } catch (e) {
      // Analytics failure should not block life deduction
    }
  }

  /// Tracks when all lives are depleted.
  Future<void> trackLivesDepleted({
    required String quizName,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required Duration duration,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      final scorePercentage = totalQuestions > 0
          ? (correctAnswers / totalQuestions * 100)
          : 0.0;

      await _analyticsService.trackLivesDepleted(
        quizId: _config!.quizId,
        quizName: quizName,
        categoryId: _categoryId!,
        questionsAnswered: questionsAnswered,
        totalQuestions: totalQuestions,
        correctAnswers: correctAnswers,
        scorePercentage: scorePercentage,
        duration: duration,
      );
    } catch (e) {
      // Analytics failure should not block game over
    }
  }

  // ============ Timer Events ============

  /// Tracks when timer reaches warning threshold.
  Future<void> trackTimerWarning({
    required Question question,
    required int questionIndex,
    required int secondsRemaining,
    required String warningLevel,
  }) async {
    if (!isEnabled || _config == null) return;

    try {
      await _analyticsService.trackTimerWarning(
        quizId: _config!.quizId,
        question: question,
        questionIndex: questionIndex,
        secondsRemaining: secondsRemaining,
        warningLevel: warningLevel,
      );
    } catch (e) {
      // Analytics failure should not block quiz
    }
  }

  // ============ Reset & Dispose ============

  /// Resets the manager state.
  void reset() {
    _config = null;
    _categoryId = null;
    _categoryName = null;
    _pausedAt = null;
  }

  /// Disposes the analytics service.
  void dispose() {
    _analyticsService.dispose();
    reset();
  }
}
