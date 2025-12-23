import 'dart:async';
import 'dart:math';

import 'package:quiz_engine_core/src/business_logic/quiz_state/quiz_state.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';

import '../bloc/single_subscription_bloc.dart';
import '../model/answer.dart';
import '../model/question.dart';
import '../model/random_pick_result.dart';
import '../random_item_picker.dart';
import '../model/config/quiz_config.dart';
import '../model/config/quiz_mode_config.dart';
import '../model/config/hint_config.dart';
import '../storage/quiz_storage_service.dart';
import 'config_manager/config_manager.dart';
import 'config_manager/config_source.dart';

/// A business logic component (BLoC) that manages the state of a quiz game.
///
/// The `QuizBloc` class no longer depends on a specific `QuizDataProvider`.
/// Instead, the user must provide a function that supplies quiz data.
class QuizBloc extends SingleSubscriptionBloc<QuizState> {
  /// Function to fetch quiz data.
  ///
  /// This function should return a `Future<List<QuestionEntry>>`.
  final Future<List<QuestionEntry>> Function() dataProvider;

  /// The random item picker used to select random items for questions.
  final RandomItemPicker randomItemPicker;

  /// A filter function to apply when loading data (optional).
  final bool Function(QuestionEntry)? filter;

  /// Callback function to be invoked when the game is over.
  Function(String result)? gameOverCallback;

  /// Configuration manager for loading quiz configuration.
  final ConfigManager configManager;

  /// Optional storage service for persisting quiz sessions.
  final QuizStorageService? storageService;

  /// The loaded configuration (initialized with default, can be updated from configManager).
  late final QuizConfig _config;

  /// The current session ID (null if storage is disabled).
  String? _currentSessionId;

  /// Stopwatch for tracking quiz duration.
  final Stopwatch _sessionStopwatch = Stopwatch();

  /// Stopwatch for tracking individual question duration.
  final Stopwatch _questionStopwatch = Stopwatch();

  /// Count of 50/50 hints used.
  int _hintsUsed5050 = 0;

  /// Count of skip hints used.
  int _hintsUsedSkip = 0;

  /// The list of quiz data items available for the game.
  List<QuestionEntry> _items = [];

  /// The current progress indicating how many questions have been answered.
  int _currentProgress = 0;

  /// The total number of questions in the game.
  int _totalCount = 0;

  /// The current question being asked to the player.
  late Question currentQuestion;

  /// The list of answers provided by the player.
  final List<Answer> _answers = [];

  /// The number of remaining lives (only used in lives/survival modes).
  int? _remainingLives;

  /// Timer for tracking question time limit.
  Timer? _questionTimer;

  /// Timer for tracking total quiz time limit.
  Timer? _totalTimer;

  /// Remaining time for the current question in seconds.
  int? _questionTimeRemaining;

  /// Remaining total time for the entire quiz in seconds.
  int? _totalTimeRemaining;

  /// Whether the timers are currently paused.
  bool _timersPaused = false;

  /// The current hint state tracking which hints have been used.
  late HintState _hintState;

  /// Options disabled for the current question (e.g., from 50/50 hint).
  Set<QuestionEntry> _disabledOptions = {};

  /// Creates a `QuizBloc` with a provided data fetch function.
  ///
  /// [dataProvider] - Function to fetch quiz data
  /// [randomItemPicker] - Random item picker for selecting questions
  /// [filter] - Optional filter function for quiz data
  /// [gameOverCallback] - Optional callback when quiz ends
  /// [configManager] - Configuration manager with default config
  /// [storageService] - Optional storage service for persisting quiz sessions
  QuizBloc(
    this.dataProvider,
    this.randomItemPicker, {
    this.filter,
    this.gameOverCallback,
    required this.configManager,
    this.storageService,
  });

  /// The initial state of the game, set to loading.
  @override
  QuizState get initialState => QuizState.loading();

  /// Getter for the loaded configuration.
  QuizConfig get config => _config;

  /// Performs the initial data load when the screen is loaded.
  ///
  /// This method loads the configuration, retrieves quiz data using the
  /// provided `dataProvider` function, applies the optional filter,
  /// and initializes the random picker.
  Future<void> performInitialLoad() async {
    // Load configuration first
    _config = await configManager.getConfig(source: const DefaultSource());

    // Initialize lives from mode config
    _remainingLives = _config.modeConfig.lives;

    // Initialize hint state from config
    _hintState = HintState.fromConfig(_config.hintConfig);

    // Initialize timers from mode config
    _initializeTimers();

    var items = await dataProvider();

    // Apply filter if provided, otherwise keep all items
    _items = filter != null ? items.where(filter!).toList() : items;

    _totalCount = _items.length;
    randomItemPicker.replaceItems(_items);

    // Create storage session if storage is enabled
    await _initializeStorageSession();

    // Start tracking session duration
    _sessionStopwatch.start();

    _pickQuestion();
  }

  /// Initializes the storage session if storage is enabled.
  Future<void> _initializeStorageSession() async {
    if (!_isStorageEnabled) return;

    try {
      _currentSessionId = await storageService!.createSession(
        config: _config,
        totalQuestions: _totalCount,
      );
    } catch (e) {
      // Storage failure should not block quiz from starting
      _currentSessionId = null;
    }
  }

  /// Whether storage is enabled for this quiz.
  bool get _isStorageEnabled =>
      storageService != null && _config.storageConfig.enabled;

  /// Processes the player's answer to the current question.
  ///
  /// If answer feedback is enabled in configuration, this will emit an
  /// [AnswerFeedbackState] showing whether the answer was correct/incorrect
  /// before moving to the next question.
  Future<void> processAnswer(QuestionEntry selectedItem) async {
    // Cancel question timer when answer is submitted
    _cancelQuestionTimer();

    // Stop question timer and get elapsed time
    _questionStopwatch.stop();
    final timeSpentSeconds = _questionStopwatch.elapsed.inSeconds;

    var answer = Answer(selectedItem, currentQuestion);
    final isCorrect = answer.isCorrect;

    // Deduct life if answer is wrong and lives are tracked
    if (!isCorrect && _remainingLives != null) {
      _remainingLives = _remainingLives! - 1;
    }

    // Save answer to storage if enabled
    await _saveAnswerToStorage(
      questionNumber: _currentProgress + 1,
      question: currentQuestion,
      selectedAnswer: selectedItem,
      isCorrect: isCorrect,
      status: isCorrect ? AnswerStatus.correct : AnswerStatus.incorrect,
      timeSpentSeconds: timeSpentSeconds,
      hintUsed: null,
    );

    // Show feedback if enabled in configuration
    if (_config.uiBehaviorConfig.showAnswerFeedback) {
      // Emit feedback state with updated lives and timer info
      var feedbackState = QuizState.answerFeedback(
        currentQuestion,
        selectedItem,
        isCorrect,
        _currentProgress,
        _totalCount,
        remainingLives: _remainingLives,
        questionTimeRemaining: _questionTimeRemaining,
        totalTimeRemaining: _totalTimeRemaining,
      );
      dispatchState(feedbackState);

      // Wait for feedback duration before proceeding
      await Future.delayed(
        Duration(milliseconds: _config.uiBehaviorConfig.answerFeedbackDuration),
      );
    }

    // Record the answer and move to next question
    _answers.add(answer);
    _currentProgress++;
    _pickQuestion();
  }

  /// Saves an answer to storage if enabled.
  Future<void> _saveAnswerToStorage({
    required int questionNumber,
    required Question question,
    required QuestionEntry? selectedAnswer,
    required bool isCorrect,
    required AnswerStatus status,
    required int? timeSpentSeconds,
    required HintType? hintUsed,
  }) async {
    if (!_isStorageEnabled ||
        _currentSessionId == null ||
        !_config.storageConfig.saveAnswersDuringQuiz) {
      return;
    }

    try {
      await storageService!.saveAnswer(
        sessionId: _currentSessionId!,
        questionNumber: questionNumber,
        question: question,
        selectedAnswer: selectedAnswer,
        isCorrect: isCorrect,
        status: status,
        timeSpentSeconds: timeSpentSeconds,
        hintUsed: hintUsed,
        disabledOptions: _disabledOptions,
      );
    } catch (e) {
      // Storage failure should not block quiz progression
    }
  }

  /// Picks the next question or ends the game if no more items are available.
  void _pickQuestion() {
    // For endless mode, replenish questions from answered items when exhausted
    if (_config.modeConfig is EndlessMode && randomItemPicker.items.isEmpty) {
      randomItemPicker.replenishFromAnswered();
    }

    var randomResult = randomItemPicker.pick();
    if (_isGameOver(randomResult)) {
      _cancelQuestionTimer();
      _cancelTotalTimer();
      var state = QuizState.question(
        currentQuestion,
        _currentProgress,
        _totalCount,
        remainingLives: _remainingLives,
        questionTimeRemaining: _questionTimeRemaining,
        totalTimeRemaining: _totalTimeRemaining,
        hintState: _hintState,
        disabledOptions: _disabledOptions,
      );
      dispatchState(state);
      _notifyGameOver();
    } else {
      var question = Question.fromRandomResult(randomResult!);
      currentQuestion = question;

      // Reset disabled options for new question
      _disabledOptions = {};

      // Reset question timer for new question (unless paused)
      if (!_timersPaused) {
        _questionTimeRemaining = null;
      }

      // Start question timer for new question
      _startQuestionTimer();

      // Reset and start question stopwatch for tracking time spent
      _questionStopwatch.reset();
      _questionStopwatch.start();

      var state = QuizState.question(
        question,
        _currentProgress,
        _totalCount,
        remainingLives: _remainingLives,
        questionTimeRemaining: _questionTimeRemaining,
        totalTimeRemaining: _totalTimeRemaining,
        hintState: _hintState,
        disabledOptions: _disabledOptions,
      );
      dispatchState(state);
    }
  }

  /// Determines if the game is over based on the random picker result, lives, or time.
  bool _isGameOver(RandomPickResult? result) {
    // Game over if no more questions
    if (result == null) return true;

    // Game over if lives reach 0
    if (_remainingLives != null && _remainingLives! <= 0) return true;

    // Game over if total time has expired
    if (_totalTimeRemaining != null && _totalTimeRemaining! <= 0) return true;

    return false;
  }

  /// Notifies the game-over state and invokes the callback with the final result.
  void _notifyGameOver() {
    _cancelQuestionTimer();
    _cancelTotalTimer();

    // Stop tracking session duration
    _sessionStopwatch.stop();

    var correctAnswers = _answers.where((answer) => answer.isCorrect).length;
    var failedAnswers = _answers.where((answer) => !answer.isCorrect && !answer.isSkipped && !answer.isTimeout).length;
    var skippedAnswers = _answers.where((answer) => answer.isSkipped).length;
    var timedOutAnswers = _answers.where((answer) => answer.isTimeout).length;
    var result = '$correctAnswers / $_totalCount';

    // Complete the session in storage
    _completeStorageSession(
      status: _determineCompletionStatus(),
      totalCorrect: correctAnswers,
      totalFailed: failedAnswers + timedOutAnswers,
      totalSkipped: skippedAnswers,
    );

    gameOverCallback?.call(result);
  }

  /// Determines the completion status based on how the quiz ended.
  SessionCompletionStatus _determineCompletionStatus() {
    // Check if game ended due to time
    if (_totalTimeRemaining != null && _totalTimeRemaining! <= 0) {
      return SessionCompletionStatus.timeout;
    }

    // Check if game ended due to running out of lives
    if (_remainingLives != null && _remainingLives! <= 0) {
      return SessionCompletionStatus.failed;
    }

    // Normal completion
    return SessionCompletionStatus.completed;
  }

  /// Completes the session in storage.
  Future<void> _completeStorageSession({
    required SessionCompletionStatus status,
    required int totalCorrect,
    required int totalFailed,
    required int totalSkipped,
  }) async {
    if (!_isStorageEnabled || _currentSessionId == null) return;

    try {
      await storageService!.completeSession(
        sessionId: _currentSessionId!,
        status: status,
        totalAnswered: _answers.length,
        totalCorrect: totalCorrect,
        totalFailed: totalFailed,
        totalSkipped: totalSkipped,
        durationSeconds: _sessionStopwatch.elapsed.inSeconds,
        hintsUsed5050: _hintsUsed5050,
        hintsUsedSkip: _hintsUsedSkip,
      );
    } catch (e) {
      // Storage failure should not affect game over flow
    }
  }

  /// Initializes timer settings from mode configuration.
  void _initializeTimers() {
    final mode = _config.modeConfig;

    // Initialize total timer if the mode has a total time limit
    if (mode is TimedMode && mode.totalTimeLimit != null) {
      _totalTimeRemaining = mode.totalTimeLimit;
      _startTotalTimer();
    } else if (mode is SurvivalMode && mode.totalTimeLimit != null) {
      _totalTimeRemaining = mode.totalTimeLimit;
      _startTotalTimer();
    }
  }

  /// Starts the question timer based on mode configuration.
  void _startQuestionTimer() {
    // Don't start timer if paused
    if (_timersPaused) return;

    final mode = _config.modeConfig;
    int? timePerQuestion;

    // Get time per question from mode config
    if (mode is TimedMode) {
      timePerQuestion = mode.timePerQuestion;
    } else if (mode is SurvivalMode) {
      timePerQuestion = mode.timePerQuestion;
    }

    if (timePerQuestion == null) return;

    // Only reset time if this is a fresh question (not a resume)
    if (_questionTimeRemaining == null || _questionTimeRemaining! <= 0) {
      _questionTimeRemaining = timePerQuestion;
    }

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimeRemaining != null && _questionTimeRemaining! > 0) {
        _questionTimeRemaining = _questionTimeRemaining! - 1;

        // Emit updated state with new timer value
        var state = QuizState.question(
          currentQuestion,
          _currentProgress,
          _totalCount,
          remainingLives: _remainingLives,
          questionTimeRemaining: _questionTimeRemaining,
          totalTimeRemaining: _totalTimeRemaining,
          hintState: _hintState,
          disabledOptions: _disabledOptions,
        );
        dispatchState(state);
      } else {
        _handleQuestionTimeExpired();
      }
    });
  }

  /// Starts the total quiz timer.
  void _startTotalTimer() {
    // Don't start timer if paused
    if (_timersPaused) return;

    if (_totalTimeRemaining == null) return;

    _totalTimer?.cancel();
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeRemaining != null && _totalTimeRemaining! > 0) {
        _totalTimeRemaining = _totalTimeRemaining! - 1;

        // Total timer updates are reflected in the next question state emission
        // We don't need to emit state here as the question timer will handle it
      } else {
        _handleTotalTimeExpired();
      }
    });
  }

  /// Pauses both question and total timers.
  ///
  /// Call this when the app goes to background or becomes inactive.
  /// Timers will stop counting down but preserve their current values.
  void pauseTimers() {
    if (_timersPaused) return;

    _timersPaused = true;
    _questionTimer?.cancel();
    _totalTimer?.cancel();
  }

  /// Resumes both question and total timers.
  ///
  /// Call this when the app returns to foreground.
  /// Timers will continue from where they were paused.
  void resumeTimers() {
    if (!_timersPaused) return;

    _timersPaused = false;

    // Restart question timer if there's remaining time
    if (_questionTimeRemaining != null && _questionTimeRemaining! > 0) {
      _startQuestionTimer();
    }

    // Restart total timer if there's remaining time
    if (_totalTimeRemaining != null && _totalTimeRemaining! > 0) {
      _startTotalTimer();
    }
  }

  /// Cancels the question timer.
  void _cancelQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  /// Cancels the total timer.
  void _cancelTotalTimer() {
    _totalTimer?.cancel();
    _totalTimer = null;
  }

  /// Handles when the question time expires.
  void _handleQuestionTimeExpired() {
    _cancelQuestionTimer();

    // Stop question timer
    _questionStopwatch.stop();
    final timeSpentSeconds = _questionStopwatch.elapsed.inSeconds;

    // Treat time expiration as a wrong answer
    final mode = _config.modeConfig;
    if (mode is TimedMode || mode is SurvivalMode) {
      // For timed modes, time expiration means wrong answer
      if (_remainingLives != null) {
        _remainingLives = _remainingLives! - 1;
      }

      // Create a dummy wrong answer
      final dummyAnswer = Answer(
        currentQuestion.answer,
        currentQuestion,
        isTimeout: true,
      );

      // Save timeout answer to storage
      _saveAnswerToStorage(
        questionNumber: _currentProgress + 1,
        question: currentQuestion,
        selectedAnswer: null,
        isCorrect: false,
        status: AnswerStatus.timeout,
        timeSpentSeconds: timeSpentSeconds,
        hintUsed: null,
      );

      _answers.add(dummyAnswer);
      _currentProgress++;
      _pickQuestion();
    }
  }

  /// Handles when the total quiz time expires.
  void _handleTotalTimeExpired() {
    _cancelQuestionTimer();
    _cancelTotalTimer();
    _totalTimeRemaining = 0;

    // End the game
    var state = QuizState.question(
      currentQuestion,
      _currentProgress,
      _totalCount,
      remainingLives: _remainingLives,
      questionTimeRemaining: _questionTimeRemaining,
      totalTimeRemaining: _totalTimeRemaining,
      hintState: _hintState,
      disabledOptions: _disabledOptions,
    );
    dispatchState(state);
    _notifyGameOver();
  }

  /// Uses the 50/50 hint to disable 2 incorrect options.
  ///
  /// Randomly selects and disables 2 incorrect options from the current question,
  /// making it easier for the player to identify the correct answer.
  void use50_50Hint() {
    // Check if hint is available
    if (!_hintState.canUseHint(HintType.fiftyFifty)) return;

    // Mark hint as used and track for storage
    _hintState.useHint(HintType.fiftyFifty);
    _hintsUsed5050++;

    // Find all incorrect options
    final incorrectOptions =
        currentQuestion.options
            .where((option) => option != currentQuestion.answer)
            .toList();

    // If there are less than 2 incorrect options, can't use this hint
    if (incorrectOptions.length < 2) return;

    // Randomly select 2 incorrect options to disable
    final random = Random();
    incorrectOptions.shuffle(random);
    _disabledOptions = incorrectOptions.take(2).toSet();

    // Emit updated state with disabled options
    var state = QuizState.question(
      currentQuestion,
      _currentProgress,
      _totalCount,
      remainingLives: _remainingLives,
      questionTimeRemaining: _questionTimeRemaining,
      totalTimeRemaining: _totalTimeRemaining,
      hintState: _hintState,
      disabledOptions: _disabledOptions,
    );
    dispatchState(state);
  }

  /// Skips the current question.
  ///
  /// Marks the current question as skipped and moves to the next question.
  Future<void> skipQuestion() async {
    // Check if hint is available
    if (!_hintState.canUseHint(HintType.skip)) return;

    // Cancel question timer
    _cancelQuestionTimer();

    // Stop question timer and get elapsed time
    _questionStopwatch.stop();
    final timeSpentSeconds = _questionStopwatch.elapsed.inSeconds;

    // Mark hint as used and track for storage
    _hintState.useHint(HintType.skip);
    _hintsUsedSkip++;

    // Create a skipped answer
    final skippedAnswer = Answer(
      currentQuestion.answer,
      currentQuestion,
      isSkipped: true,
    );

    // Save skipped answer to storage
    await _saveAnswerToStorage(
      questionNumber: _currentProgress + 1,
      question: currentQuestion,
      selectedAnswer: null,
      isCorrect: false,
      status: AnswerStatus.skipped,
      timeSpentSeconds: timeSpentSeconds,
      hintUsed: HintType.skip,
    );

    // Record the skipped answer and move to next question
    _answers.add(skippedAnswer);
    _currentProgress++;
    _pickQuestion();
  }

  @override
  void dispose() {
    _timersPaused = false;
    _cancelQuestionTimer();
    _cancelTotalTimer();
    _sessionStopwatch.stop();
    _questionStopwatch.stop();
    storageService?.dispose();
    super.dispose();
  }

  /// Gets the current session ID (for external use if needed).
  String? get currentSessionId => _currentSessionId;

  /// Cancels the current quiz and marks it as cancelled in storage.
  ///
  /// If no answers were given, the session is deleted entirely.
  /// Otherwise, it is marked as cancelled with the current progress.
  Future<void> cancelQuiz() async {
    _cancelQuestionTimer();
    _cancelTotalTimer();
    _sessionStopwatch.stop();

    if (_isStorageEnabled && _currentSessionId != null) {
      // If no answers were given, delete the session entirely
      if (_answers.isEmpty) {
        try {
          await storageService!.deleteSession(_currentSessionId!);
        } catch (e) {
          // Storage failure should not block cancellation
        }
        return;
      }

      // Otherwise, complete the session as cancelled with progress
      var correctAnswers = _answers.where((answer) => answer.isCorrect).length;
      var failedAnswers = _answers.where((answer) => !answer.isCorrect && !answer.isSkipped && !answer.isTimeout).length;
      var skippedAnswers = _answers.where((answer) => answer.isSkipped).length;
      var timedOutAnswers = _answers.where((answer) => answer.isTimeout).length;

      await _completeStorageSession(
        status: SessionCompletionStatus.cancelled,
        totalCorrect: correctAnswers,
        totalFailed: failedAnswers + timedOutAnswers,
        totalSkipped: skippedAnswers,
      );
    }
  }
}
