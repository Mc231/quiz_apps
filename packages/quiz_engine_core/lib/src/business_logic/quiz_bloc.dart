import 'dart:async';

import 'package:quiz_engine_core/src/business_logic/quiz_state/quiz_state.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';

import '../analytics/quiz_analytics_service.dart';
import '../bloc/single_subscription_bloc.dart';
import '../model/question.dart';
import '../model/quiz_results.dart';
import '../random_item_picker.dart';
import '../model/config/quiz_config.dart';
import '../model/config/quiz_mode_config.dart';
import '../model/config/hint_config.dart';
import '../storage/quiz_storage_service.dart';
import 'config_manager/config_manager.dart';
import 'config_manager/config_source.dart';
import 'managers/managers.dart';

/// A business logic component (BLoC) that manages the state of a quiz game.
///
/// The `QuizBloc` class orchestrates various managers to handle different
/// aspects of quiz functionality:
/// - [QuizProgressTracker] - Tracks answers, progress, streaks, lives
/// - [QuizTimerManager] - Manages question and total timers
/// - [QuizHintManager] - Handles hint state and 50/50 logic
/// - [QuizSessionManager] - Manages storage integration
/// - [QuizAnswerProcessor] - Creates answer objects
/// - [QuizGameFlowManager] - Manages question picking and game flow
/// - [QuizAnalyticsManager] - Handles analytics event tracking
class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  /// Function to fetch quiz data.
  final Future<List<QuestionEntry>> Function() dataProvider;

  /// The random item picker used to select random items for questions.
  final RandomItemPicker randomItemPicker;

  /// A filter function to apply when loading data (optional).
  final bool Function(QuestionEntry)? filter;

  /// Callback invoked when the quiz is completed with detailed results.
  final void Function(QuizResults results)? onQuizCompleted;

  /// Configuration manager for loading quiz configuration.
  final ConfigManager configManager;

  /// Human-readable name of the quiz (for display in results).
  final String quizName;

  /// Category ID for analytics tracking.
  final String categoryId;

  /// Category name for analytics tracking.
  final String categoryName;

  /// The loaded configuration.
  late final QuizConfig _config;

  // ============ Managers ============

  /// Tracks quiz progress and statistics.
  final QuizProgressTracker _progressTracker = QuizProgressTracker();

  /// Manages timers and stopwatches.
  late final QuizTimerManager _timerManager;

  /// Manages hint state and usage.
  final QuizHintManager _hintManager = QuizHintManager();

  /// Manages storage session lifecycle.
  final QuizSessionManager _sessionManager;

  /// Manages analytics event tracking.
  final QuizAnalyticsManager _analyticsManager;

  /// Processes answers.
  final QuizAnswerProcessor _answerProcessor = QuizAnswerProcessor();

  /// Manages game flow and question picking.
  late final QuizGameFlowManager _gameFlowManager;

  /// Creates a `QuizBloc` with a provided data fetch function.
  ///
  /// [dataProvider] - Function to fetch quiz data
  /// [randomItemPicker] - Random item picker for selecting questions
  /// [filter] - Optional filter function for quiz data
  /// [onQuizCompleted] - Callback with detailed results for achievement integration
  /// [configManager] - Configuration manager with default config
  /// [storageService] - Optional storage service for persisting quiz sessions
  /// [analyticsService] - Optional analytics service for event tracking
  /// [quizName] - Human-readable name of the quiz (for display in results)
  /// [categoryId] - Category ID for analytics tracking
  /// [categoryName] - Category name for analytics tracking
  QuizBloc(
    this.dataProvider,
    this.randomItemPicker, {
    this.filter,
    this.onQuizCompleted,
    required this.configManager,
    QuizStorageService? storageService,
    required QuizAnalyticsService analyticsService,
    this.quizName = 'Quiz',
    this.categoryId = '',
    this.categoryName = '',
  })  : _sessionManager = QuizSessionManager(storageService: storageService),
        _analyticsManager = QuizAnalyticsManager(analyticsService: analyticsService) {
    // Initialize timer manager with callbacks
    _timerManager = QuizTimerManager(
      onTick: _handleTimerTick,
      onQuestionTimeout: _handleQuestionTimeout,
      onTotalTimeExpired: _handleTotalTimeExpired,
    );

    // Initialize game flow manager with callbacks
    _gameFlowManager = QuizGameFlowManager(
      randomItemPicker: randomItemPicker,
      onNewQuestion: _handleNewQuestion,
      onGameOver: _handleGameOver,
    );
  }

  /// The initial state of the game, set to loading.
  @override
  QuizState get initialState => QuizState.loading();

  /// Getter for the loaded configuration.
  QuizConfig get config => _config;

  /// Gets the current session ID (for external use if needed).
  String? get currentSessionId => _sessionManager.currentSessionId;

  /// The current question being asked to the player.
  Question get currentQuestion => _gameFlowManager.currentQuestion!;

  /// Setter for current question (needed for tests).
  set currentQuestion(Question question) {
    // This is only used in tests - the game flow manager handles this internally
    _gameFlowManager.currentQuestion = question;
  }

  // ============ Initialization ============

  /// Performs the initial data load when the screen is loaded.
  Future<void> performInitialLoad() async {
    // Load configuration first
    _config = await configManager.getConfig(source: const DefaultSource());

    // Initialize managers
    _progressTracker.initialize(
      totalCount: 0, // Will be set after loading items
      initialLives: _config.modeConfig.lives,
    );

    _timerManager.initialize(_config.modeConfig);
    _hintManager.initialize(_config.hintConfig);

    // Load quiz data
    var items = await dataProvider();
    final filteredItems = filter != null ? items.where(filter!).toList() : items;

    // Update progress tracker with actual count
    _progressTracker.resetAll();
    _progressTracker.initialize(
      totalCount: filteredItems.length,
      initialLives: _config.modeConfig.lives,
    );

    // Initialize game flow
    _gameFlowManager.initialize(
      items: filteredItems,
      modeConfig: _config.modeConfig,
    );

    // Create storage session
    await _sessionManager.initializeSession(
      config: _config,
      totalQuestions: filteredItems.length,
    );

    // Initialize analytics manager
    _analyticsManager.initialize(
      config: _config,
      categoryId: categoryId,
      categoryName: categoryName,
    );

    // Track quiz started
    await _analyticsManager.trackQuizStarted(
      quizName: quizName,
      totalQuestions: filteredItems.length,
      initialLives: _config.modeConfig.lives,
      initialHints: _hintManager.hintState?.remainingHints[HintType.fiftyFifty],
    );

    // Start tracking session duration
    _timerManager.startSession();

    // Start total timer if configured
    _timerManager.startTotalTimer();

    // Pick the first question
    _pickQuestion();
  }

  // ============ Answer Processing ============

  /// Processes the player's answer to the current question.
  Future<void> processAnswer(QuestionEntry selectedItem) async {
    _timerManager.cancelQuestionTimer();
    final timeSpentSeconds = _timerManager.stopQuestionStopwatch();

    // Track option selected
    final optionIndex = currentQuestion.options.indexOf(selectedItem);
    await _analyticsManager.trackOptionSelected(
      question: currentQuestion,
      questionIndex: _progressTracker.currentProgress,
      selectedOption: selectedItem,
      optionIndex: optionIndex,
      timeSinceDisplayed: Duration(seconds: timeSpentSeconds),
    );

    // Process the answer
    final result = _answerProcessor.processUserAnswer(selectedItem, currentQuestion);

    // Track life lost before recording (to get accurate remaining count)
    final livesBeforeAnswer = _progressTracker.remainingLives;
    final initialLives = _config.modeConfig.lives;

    // Update progress
    _progressTracker.recordAnswer(result.answer);

    // Track answer submitted
    await _analyticsManager.trackQuestionAnswered(
      question: currentQuestion,
      questionIndex: _progressTracker.currentProgress - 1,
      isCorrect: result.isCorrect,
      responseTime: Duration(seconds: timeSpentSeconds),
      selectedAnswer: selectedItem,
      currentStreak: result.isCorrect ? _progressTracker.currentStreak : 0,
      livesRemaining: _progressTracker.remainingLives,
    );

    // Track life lost if incorrect and lives mode is active
    if (!result.isCorrect &&
        initialLives != null &&
        _progressTracker.remainingLives != null &&
        _progressTracker.remainingLives! < livesBeforeAnswer!) {
      await _analyticsManager.trackLifeLost(
        question: currentQuestion,
        questionIndex: _progressTracker.currentProgress - 1,
        livesRemaining: _progressTracker.remainingLives!,
        livesTotal: initialLives,
        reason: 'incorrect_answer',
      );
    }

    // Save to storage
    await _sessionManager.saveAnswer(
      questionNumber: _progressTracker.currentProgress,
      question: currentQuestion,
      selectedAnswer: selectedItem,
      isCorrect: result.isCorrect,
      status: result.status,
      timeSpentSeconds: timeSpentSeconds,
      hintUsed: null,
      disabledOptions: _hintManager.disabledOptions,
    );

    // Show feedback if enabled
    if (_config.modeConfig.showAnswerFeedback) {
      final feedbackDuration = Duration(
        milliseconds: _config.uiBehaviorConfig.answerFeedbackDuration,
      );
      _emitFeedbackState(selectedItem, result.isCorrect);

      // Track feedback shown
      await _analyticsManager.trackFeedbackShown(
        question: currentQuestion,
        questionIndex: _progressTracker.currentProgress - 1,
        wasCorrect: result.isCorrect,
        feedbackDuration: feedbackDuration,
      );

      await Future.delayed(feedbackDuration);
    }

    _pickQuestion();
  }

  // ============ Hints ============

  /// Uses the 50/50 hint to disable 2 incorrect options.
  void use50_50Hint() {
    final disabled = _hintManager.use5050Hint(currentQuestion);
    if (disabled.isNotEmpty) {
      // Track hint usage
      _analyticsManager.trackHintFiftyFiftyUsed(
        question: currentQuestion,
        questionIndex: _progressTracker.currentProgress,
        hintsRemaining: _hintManager.hintState?.remainingHints[HintType.fiftyFifty] ?? 0,
        eliminatedOptions: disabled.toList(),
      );

      _emitQuestionState();
    }
  }

  /// Skips the current question.
  Future<void> skipQuestion() async {
    if (!_hintManager.useSkipHint()) return;

    _timerManager.cancelQuestionTimer();
    final timeSpentSeconds = _timerManager.stopQuestionStopwatch();

    // Track hint skip used
    await _analyticsManager.trackHintSkipUsed(
      question: currentQuestion,
      questionIndex: _progressTracker.currentProgress,
      hintsRemaining: _hintManager.hintState?.remainingHints[HintType.skip] ?? 0,
      timeBeforeSkip: Duration(seconds: timeSpentSeconds),
    );

    // Process the skip
    final result = _answerProcessor.processSkip(currentQuestion);

    // Record without deducting life (skipped answers don't deduct lives)
    _progressTracker.recordAnswer(result.answer);

    // Track question skipped
    await _analyticsManager.trackQuestionSkipped(
      question: currentQuestion,
      questionIndex: _progressTracker.currentProgress - 1,
      timeBeforeSkip: Duration(seconds: timeSpentSeconds),
      usedHint: true,
      hintsRemaining: _hintManager.hintState?.remainingHints[HintType.skip],
    );

    // Save to storage
    await _sessionManager.saveAnswer(
      questionNumber: _progressTracker.currentProgress,
      question: currentQuestion,
      selectedAnswer: null,
      isCorrect: false,
      status: result.status,
      timeSpentSeconds: timeSpentSeconds,
      hintUsed: HintType.skip,
      disabledOptions: _hintManager.disabledOptions,
    );

    _pickQuestion();
  }

  // ============ Timer Control ============

  /// Pauses both question and total timers.
  void pauseTimers() {
    _timerManager.pauseTimers();

    // Track quiz paused
    _analyticsManager.trackQuizPaused(
      quizName: quizName,
      currentQuestion: _progressTracker.currentProgress,
      totalQuestions: _progressTracker.totalCount,
    );
  }

  /// Resumes both question and total timers.
  void resumeTimers() {
    _timerManager.resumeTimers();

    // Track quiz resumed
    _analyticsManager.trackQuizResumed(
      quizName: quizName,
      currentQuestion: _progressTracker.currentProgress,
      totalQuestions: _progressTracker.totalCount,
    );
  }

  // ============ Quiz Cancellation ============

  /// Cancels the current quiz and marks it as cancelled in storage.
  Future<void> cancelQuiz() async {
    _timerManager.cancelQuestionTimer();
    _timerManager.cancelTotalTimer();
    _timerManager.stopSession();

    // Track quiz cancelled
    await _analyticsManager.trackQuizCancelled(
      quizName: quizName,
      questionsAnswered: _progressTracker.answers.length,
      totalQuestions: _progressTracker.totalCount,
      timeSpent: Duration(seconds: _timerManager.sessionDurationSeconds),
    );

    await _sessionManager.cancelSession(
      hasAnswers: _progressTracker.answers.isNotEmpty,
      totalCorrect: _progressTracker.correctAnswers,
      totalFailed: _progressTracker.totalFailedAnswers,
      totalSkipped: _progressTracker.skippedAnswers,
      durationSeconds: _timerManager.sessionDurationSeconds,
      hintsUsed5050: _hintManager.hintsUsed5050,
      hintsUsedSkip: _hintManager.hintsUsedSkip,
      bestStreak: _progressTracker.bestStreak,
    );
  }

  // ============ Private Methods - Question Flow ============

  void _pickQuestion() {
    _hintManager.resetForNewQuestion();

    final question = _gameFlowManager.pickNextQuestion(
      remainingLives: _progressTracker.remainingLives,
      totalTimeRemaining: _timerManager.totalTimeRemaining,
    );

    if (question == null) {
      // Game over is handled by the callback
      return;
    }

    // Start timers for new question
    _timerManager.startQuestionTimer();
    _timerManager.startQuestionStopwatch();

    // Track question displayed
    _analyticsManager.trackQuestionDisplayed(
      question: question,
      questionIndex: _progressTracker.currentProgress,
      totalQuestions: _progressTracker.totalCount,
      timeLimit: _config.modeConfig.questionTimeLimit,
    );

    _emitQuestionState();
  }

  // ============ Private Methods - Timer Callbacks ============

  void _handleTimerTick({int? questionTimeRemaining, int? totalTimeRemaining}) {
    _emitQuestionState();
  }

  void _handleQuestionTimeout(int timeSpentSeconds) {
    final mode = _config.modeConfig;
    if (mode is! TimedMode && mode is! SurvivalMode) return;

    // Get time limit from mode config
    final timeLimit = mode is TimedMode
        ? mode.timePerQuestion
        : (mode as SurvivalMode).timePerQuestion;

    // Track question timeout
    _analyticsManager.trackQuestionTimeout(
      question: currentQuestion,
      questionIndex: _progressTracker.currentProgress,
      timeLimit: timeLimit,
      livesRemaining: _progressTracker.remainingLives,
    );

    // Create timeout answer
    final result = _answerProcessor.processTimeout(currentQuestion);

    // Track life lost before deducting
    final livesBeforeDeduct = _progressTracker.remainingLives;
    final initialLives = _config.modeConfig.lives;

    // Deduct life for timeout
    _progressTracker.deductLife();

    // Track life lost
    if (initialLives != null &&
        _progressTracker.remainingLives != null &&
        livesBeforeDeduct != null &&
        _progressTracker.remainingLives! < livesBeforeDeduct) {
      _analyticsManager.trackLifeLost(
        question: currentQuestion,
        questionIndex: _progressTracker.currentProgress,
        livesRemaining: _progressTracker.remainingLives!,
        livesTotal: initialLives,
        reason: 'timeout',
      );
    }

    // Record the timeout answer
    _progressTracker.recordAnswer(result.answer);

    // Save to storage
    _sessionManager.saveAnswer(
      questionNumber: _progressTracker.currentProgress,
      question: currentQuestion,
      selectedAnswer: null,
      isCorrect: false,
      status: result.status,
      timeSpentSeconds: timeSpentSeconds,
      hintUsed: null,
      disabledOptions: _hintManager.disabledOptions,
    );

    _pickQuestion();
  }

  void _handleTotalTimeExpired() {
    _emitQuestionState();
    _notifyGameOver();
  }

  // ============ Private Methods - Game Flow Callbacks ============

  void _handleNewQuestion(Question question) {
    // Question is already set in the manager
  }

  void _handleGameOver() {
    // Emit final state and notify
    _emitQuestionState();
    _notifyGameOver();
  }

  // ============ Private Methods - Game Over ============

  Future<void> _notifyGameOver() async {
    _timerManager.cancelQuestionTimer();
    _timerManager.cancelTotalTimer();
    _timerManager.stopSession();

    // Determine completion status
    final completionStatus = _determineCompletionStatus();
    final duration = Duration(seconds: _timerManager.sessionDurationSeconds);

    // Track analytics based on completion status
    switch (completionStatus) {
      case SessionCompletionStatus.completed:
        // Track completed - happens after results are created (below)
        break;
      case SessionCompletionStatus.failed:
        // Track lives depleted first
        await _analyticsManager.trackLivesDepleted(
          quizName: quizName,
          questionsAnswered: _progressTracker.answers.length,
          totalQuestions: _progressTracker.totalCount,
          correctAnswers: _progressTracker.correctAnswers,
          duration: duration,
        );
        // Then track quiz failed
        await _analyticsManager.trackQuizFailed(
          quizName: quizName,
          questionsAnswered: _progressTracker.answers.length,
          totalQuestions: _progressTracker.totalCount,
          correctAnswers: _progressTracker.correctAnswers,
          duration: duration,
          reason: 'lives_depleted',
        );
        break;
      case SessionCompletionStatus.timeout:
        await _analyticsManager.trackQuizTimeout(
          quizName: quizName,
          questionsAnswered: _progressTracker.answers.length,
          totalQuestions: _progressTracker.totalCount,
          correctAnswers: _progressTracker.correctAnswers,
        );
        break;
      case SessionCompletionStatus.cancelled:
        // Cancelled is handled by cancelQuiz() method
        break;
    }

    // Calculate score
    final scoreBreakdown = _config.scoringStrategy.calculateScore(
      correctAnswers: _progressTracker.correctAnswers,
      totalQuestions: _progressTracker.totalCount,
      durationSeconds: _timerManager.sessionDurationSeconds,
      streaks: _progressTracker.bestStreak > 0 ? [_progressTracker.bestStreak] : null,
    );

    // Complete storage session
    await _sessionManager.completeSession(
      status: completionStatus,
      totalAnswered: _progressTracker.answers.length,
      totalCorrect: _progressTracker.correctAnswers,
      totalFailed: _progressTracker.totalFailedAnswers,
      totalSkipped: _progressTracker.skippedAnswers,
      durationSeconds: _timerManager.sessionDurationSeconds,
      hintsUsed5050: _hintManager.hintsUsed5050,
      hintsUsedSkip: _hintManager.hintsUsedSkip,
      bestStreak: _progressTracker.bestStreak,
      score: scoreBreakdown.totalScore,
    );

    // Create quiz results
    final results = QuizResults(
      sessionId: _sessionManager.currentSessionId,
      quizId: _config.quizId,
      quizName: quizName,
      completedAt: DateTime.now(),
      totalQuestions: _progressTracker.totalCount,
      correctAnswers: _progressTracker.correctAnswers,
      incorrectAnswers: _progressTracker.incorrectAnswers,
      skippedAnswers: _progressTracker.skippedAnswers,
      timedOutAnswers: _progressTracker.timedOutAnswers,
      durationSeconds: _timerManager.sessionDurationSeconds,
      modeConfig: _config.modeConfig,
      answers: _progressTracker.answers,
      hintsUsed5050: _hintManager.hintsUsed5050,
      hintsUsedSkip: _hintManager.hintsUsedSkip,
      score: scoreBreakdown.totalScore,
      scoreBreakdown: scoreBreakdown,
    );

    // Track quiz completed (for successful completion)
    if (completionStatus == SessionCompletionStatus.completed) {
      await _analyticsManager.trackQuizCompleted(results: results);
    }

    dispatchState(QuizState.completed(results));
    onQuizCompleted?.call(results);
  }

  SessionCompletionStatus _determineCompletionStatus() {
    if (_timerManager.totalTimeRemaining != null &&
        _timerManager.totalTimeRemaining! <= 0) {
      return SessionCompletionStatus.timeout;
    }

    if (_progressTracker.isOutOfLives) {
      return SessionCompletionStatus.failed;
    }

    return SessionCompletionStatus.completed;
  }

  // ============ Private Methods - State Emission ============

  void _emitQuestionState() {
    final state = QuizState.question(
      currentQuestion,
      _progressTracker.currentProgress,
      _progressTracker.totalCount,
      remainingLives: _progressTracker.remainingLives,
      questionTimeRemaining: _timerManager.questionTimeRemaining,
      totalTimeRemaining: _timerManager.totalTimeRemaining,
      hintState: _hintManager.hintState,
      disabledOptions: _hintManager.disabledOptions,
    );
    dispatchState(state);
  }

  void _emitFeedbackState(QuestionEntry selectedItem, bool isCorrect) {
    final state = QuizState.answerFeedback(
      currentQuestion,
      selectedItem,
      isCorrect,
      _progressTracker.currentProgress - 1, // Progress was already incremented
      _progressTracker.totalCount,
      remainingLives: _progressTracker.remainingLives,
      questionTimeRemaining: _timerManager.questionTimeRemaining,
      totalTimeRemaining: _timerManager.totalTimeRemaining,
      hintState: _hintManager.hintState,
    );
    dispatchState(state);
  }

  // ============ Cleanup ============

  @override
  void dispose() {
    _timerManager.dispose();
    _sessionManager.dispose();
    _analyticsManager.dispose();
    _gameFlowManager.reset();
    _progressTracker.resetAll();
    _hintManager.reset();
    super.dispose();
  }
}
