/// Adapter that bridges QuizAnalyticsService to AnalyticsService.
///
/// This adapter implements [QuizAnalyticsService] from quiz_engine_core
/// and translates all quiz-specific tracking calls to [AnalyticsService]
/// events from shared_services.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

/// Adapts [AnalyticsService] to implement [QuizAnalyticsService].
///
/// This allows the quiz engine to use any analytics backend
/// (Console, Firebase, Composite, etc.) through a unified interface.
///
/// Example:
/// ```dart
/// // Create with console analytics for debugging
/// final analytics = ConsoleAnalyticsService();
/// await analytics.initialize();
/// final quizAnalytics = QuizAnalyticsAdapter(analytics);
///
/// // Create with Firebase for production
/// final analytics = FirebaseAnalyticsService();
/// await analytics.initialize();
/// final quizAnalytics = QuizAnalyticsAdapter(analytics);
/// ```
class QuizAnalyticsAdapter implements QuizAnalyticsService {
  /// Creates a [QuizAnalyticsAdapter] with the given [AnalyticsService].
  QuizAnalyticsAdapter(this._analytics);

  final AnalyticsService _analytics;

  // ============ Quiz Lifecycle Events ============

  @override
  Future<void> trackQuizStarted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String categoryName,
    required QuizModeConfig modeConfig,
    required int totalQuestions,
    int? initialLives,
    int? initialHints,
  }) async {
    await _analytics.logEvent(QuizEvent.started(
      quizId: quizId,
      quizName: quizName,
      categoryId: categoryId,
      categoryName: categoryName,
      mode: modeConfig.modeString,
      totalQuestions: totalQuestions,
      initialLives: initialLives,
      initialHints: initialHints,
    ));
  }

  @override
  Future<void> trackQuizCompleted({required QuizResults results}) async {
    await _analytics.logEvent(QuizEvent.completed(
      quizId: results.quizId,
      quizName: results.quizName,
      categoryId: results.quizId, // Using quizId as categoryId fallback
      mode: results.modeConfig.modeString,
      totalQuestions: results.totalQuestions,
      correctAnswers: results.correctAnswers,
      incorrectAnswers: results.incorrectAnswers,
      skippedQuestions: results.skippedAnswers,
      scorePercentage: results.scorePercentage,
      duration: Duration(seconds: results.durationSeconds),
      hintsUsed: results.totalHintsUsed,
      finalScore: results.score,
      starRating: results.starRating,
      isPerfectScore: results.isPerfectScore,
    ));
  }

  @override
  Future<void> trackQuizCancelled({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required Duration timeSpent,
  }) async {
    await _analytics.logEvent(QuizEvent.cancelled(
      quizId: quizId,
      quizName: quizName,
      categoryId: categoryId,
      mode: mode,
      questionsAnswered: questionsAnswered,
      totalQuestions: totalQuestions,
      timeSpent: timeSpent,
    ));
  }

  @override
  Future<void> trackQuizFailed({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
    required String reason,
  }) async {
    await _analytics.logEvent(QuizEvent.failed(
      quizId: quizId,
      quizName: quizName,
      categoryId: categoryId,
      mode: mode,
      questionsAnswered: questionsAnswered,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      scorePercentage: scorePercentage,
      duration: duration,
      reason: reason,
    ));
  }

  @override
  Future<void> trackQuizTimeout({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
  }) async {
    await _analytics.logEvent(QuizEvent.timeout(
      quizId: quizId,
      quizName: quizName,
      categoryId: categoryId,
      mode: mode,
      questionsAnswered: questionsAnswered,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      scorePercentage: scorePercentage,
    ));
  }

  @override
  Future<void> trackQuizPaused({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
  }) async {
    await _analytics.logEvent(QuizEvent.paused(
      quizId: quizId,
      quizName: quizName,
      currentQuestion: currentQuestion,
      totalQuestions: totalQuestions,
    ));
  }

  @override
  Future<void> trackQuizResumed({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
    required Duration pauseDuration,
  }) async {
    await _analytics.logEvent(QuizEvent.resumed(
      quizId: quizId,
      quizName: quizName,
      currentQuestion: currentQuestion,
      totalQuestions: totalQuestions,
      pauseDuration: pauseDuration,
    ));
  }

  // ============ Question Events ============

  @override
  Future<void> trackQuestionDisplayed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int totalQuestions,
    int? timeLimit,
  }) async {
    await _analytics.logEvent(QuestionEvent.displayed(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      totalQuestions: totalQuestions,
      questionType: question.answer.type.toString(),
      optionCount: question.options.length,
      timeLimit: timeLimit,
    ));
  }

  @override
  Future<void> trackQuestionAnswered({
    required String quizId,
    required Question question,
    required int questionIndex,
    required bool isCorrect,
    required Duration responseTime,
    required QuestionEntry selectedAnswer,
    int? currentStreak,
    int? livesRemaining,
  }) async {
    final questionId = _getQuestionId(question, questionIndex);
    final correctAnswerStr = _getEntryIdentifier(question.answer);
    final selectedAnswerStr = _getEntryIdentifier(selectedAnswer);

    if (isCorrect) {
      await _analytics.logEvent(QuestionEvent.correct(
        quizId: quizId,
        questionId: questionId,
        questionIndex: questionIndex,
        responseTime: responseTime,
        currentStreak: currentStreak ?? 0,
      ));
    } else {
      await _analytics.logEvent(QuestionEvent.incorrect(
        quizId: quizId,
        questionId: questionId,
        questionIndex: questionIndex,
        responseTime: responseTime,
        correctAnswer: correctAnswerStr,
        selectedAnswer: selectedAnswerStr,
        livesRemaining: livesRemaining,
      ));
    }
  }

  @override
  Future<void> trackQuestionSkipped({
    required String quizId,
    required Question question,
    required int questionIndex,
    required Duration timeBeforeSkip,
    required bool usedHint,
    int? hintsRemaining,
  }) async {
    await _analytics.logEvent(QuestionEvent.skipped(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      timeBeforeSkip: timeBeforeSkip,
      usedHint: usedHint,
      hintsRemaining: hintsRemaining,
    ));
  }

  @override
  Future<void> trackQuestionTimeout({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int timeLimit,
    int? livesRemaining,
  }) async {
    await _analytics.logEvent(QuestionEvent.timeout(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      timeLimit: timeLimit,
      correctAnswer: _getEntryIdentifier(question.answer),
      livesRemaining: livesRemaining,
    ));
  }

  @override
  Future<void> trackOptionSelected({
    required String quizId,
    required Question question,
    required int questionIndex,
    required QuestionEntry selectedOption,
    required int optionIndex,
    required Duration timeSinceDisplayed,
  }) async {
    await _analytics.logEvent(QuestionEvent.optionSelected(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      selectedOption: _getEntryIdentifier(selectedOption),
      optionIndex: optionIndex,
      timeSinceDisplayed: timeSinceDisplayed,
      isFirstSelection: true, // Always true since we submit immediately
    ));
  }

  @override
  Future<void> trackFeedbackShown({
    required String quizId,
    required Question question,
    required int questionIndex,
    required bool wasCorrect,
    required Duration feedbackDuration,
  }) async {
    await _analytics.logEvent(QuestionEvent.feedbackShown(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      wasCorrect: wasCorrect,
      feedbackDuration: feedbackDuration,
    ));
  }

  // ============ Hint Events ============

  @override
  Future<void> trackHintFiftyFiftyUsed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required List<QuestionEntry> eliminatedOptions,
  }) async {
    await _analytics.logEvent(HintEvent.fiftyFiftyUsed(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      hintsRemaining: hintsRemaining,
      eliminatedOptions:
          eliminatedOptions.map(_getEntryIdentifier).toList(),
    ));
  }

  @override
  Future<void> trackHintSkipUsed({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int hintsRemaining,
    required Duration timeBeforeSkip,
  }) async {
    await _analytics.logEvent(HintEvent.skipUsed(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      hintsRemaining: hintsRemaining,
      timeBeforeSkip: timeBeforeSkip,
    ));
  }

  // ============ Resource Events ============

  @override
  Future<void> trackLifeLost({
    required String quizId,
    required Question question,
    required int questionIndex,
    required int livesRemaining,
    required int livesTotal,
    required String reason,
  }) async {
    await _analytics.logEvent(ResourceEvent.lifeLost(
      quizId: quizId,
      questionId: _getQuestionId(question, questionIndex),
      questionIndex: questionIndex,
      livesRemaining: livesRemaining,
      livesTotal: livesTotal,
      reason: reason,
    ));
  }

  @override
  Future<void> trackLivesDepleted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
  }) async {
    await _analytics.logEvent(ResourceEvent.livesDepleted(
      quizId: quizId,
      quizName: quizName,
      categoryId: categoryId,
      questionsAnswered: questionsAnswered,
      totalQuestions: totalQuestions,
      correctAnswers: correctAnswers,
      scorePercentage: scorePercentage,
      duration: duration,
    ));
  }

  @override
  void dispose() {
    // AnalyticsService is managed externally, don't dispose it here
  }

  // ============ Private Helpers ============

  /// Generates a unique identifier for a question.
  ///
  /// Since [Question] doesn't have an ID field, we generate one
  /// based on the question index and answer hash.
  String _getQuestionId(Question question, int questionIndex) {
    return 'q_${questionIndex}_${question.answer.hashCode}';
  }

  /// Gets a string identifier for a [QuestionEntry].
  ///
  /// Uses the type name and any available metadata to create
  /// a meaningful identifier for analytics.
  String _getEntryIdentifier(QuestionEntry entry) {
    // Try to get a meaningful identifier from otherOptions
    final name = entry.otherOptions['name'] ??
        entry.otherOptions['text'] ??
        entry.otherOptions['id'] ??
        entry.type.toString();
    return name.toString();
  }
}
