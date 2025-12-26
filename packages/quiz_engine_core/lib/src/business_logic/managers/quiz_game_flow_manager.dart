import '../../model/config/quiz_mode_config.dart';
import '../../model/question.dart';
import '../../model/question_entry.dart';
import '../../model/random_pick_result.dart';
import '../../random_item_picker.dart';

/// Callback signature for when the game ends.
typedef OnGameOver = void Function();

/// Callback signature for when a new question is ready.
typedef OnNewQuestion = void Function(Question question);

/// Manages game flow including question picking and game over detection.
///
/// This manager is responsible for:
/// - Managing the question items pool
/// - Picking random questions using RandomItemPicker
/// - Detecting game over conditions
/// - Handling endless mode replenishment
class QuizGameFlowManager {
  /// The random item picker for selecting questions.
  final RandomItemPicker _randomItemPicker;

  /// The quiz mode configuration.
  QuizModeConfig? _modeConfig;

  /// The current question.
  Question? _currentQuestion;

  /// Total number of questions.
  int _totalCount = 0;

  /// Callback when game is over.
  final OnGameOver? onGameOver;

  /// Callback when new question is ready.
  final OnNewQuestion? onNewQuestion;

  /// Creates a new game flow manager.
  ///
  /// [randomItemPicker] - The picker for random question selection
  /// [onGameOver] - Called when game over is detected
  /// [onNewQuestion] - Called when a new question is picked
  QuizGameFlowManager({
    required RandomItemPicker randomItemPicker,
    this.onGameOver,
    this.onNewQuestion,
  }) : _randomItemPicker = randomItemPicker;

  // ============ Getters ============

  /// The current question.
  Question? get currentQuestion => _currentQuestion;

  /// Sets the current question (used for tests).
  set currentQuestion(Question? question) {
    _currentQuestion = question;
  }

  /// Total number of questions.
  int get totalCount => _totalCount;

  /// Whether there are more questions available.
  bool get hasMoreQuestions => _randomItemPicker.items.isNotEmpty;

  /// Whether the manager has been initialized.
  bool get isInitialized => _modeConfig != null;

  // ============ Initialization ============

  /// Initializes the game flow with items and configuration.
  ///
  /// [items] - The question entries to use
  /// [modeConfig] - The quiz mode configuration
  /// [filter] - Optional filter function for items
  void initialize({
    required List<QuestionEntry> items,
    required QuizModeConfig modeConfig,
    bool Function(QuestionEntry)? filter,
  }) {
    _modeConfig = modeConfig;

    // Apply filter if provided
    final filteredItems = filter != null ? items.where(filter).toList() : items;

    _totalCount = filteredItems.length;
    _randomItemPicker.replaceItems(filteredItems);
  }

  // ============ Question Picking ============

  /// Picks the next question.
  ///
  /// [remainingLives] - Current remaining lives (for game over check)
  /// [totalTimeRemaining] - Remaining total time (for game over check)
  ///
  /// Returns the picked question, or null if game is over.
  Question? pickNextQuestion({
    int? remainingLives,
    int? totalTimeRemaining,
  }) {
    // For endless mode, replenish questions from answered items when exhausted
    if (_modeConfig is EndlessMode && _randomItemPicker.items.isEmpty) {
      _randomItemPicker.replenishFromAnswered();
    }

    final randomResult = _randomItemPicker.pick();

    // Check if game is over
    if (_isGameOver(
      result: randomResult,
      remainingLives: remainingLives,
      totalTimeRemaining: totalTimeRemaining,
    )) {
      onGameOver?.call();
      return null;
    }

    // Create the question from the pick result
    final question = Question.fromRandomResult(randomResult!);
    _currentQuestion = question;

    onNewQuestion?.call(question);
    return question;
  }

  /// Checks if the game is over based on various conditions.
  bool _isGameOver({
    RandomPickResult? result,
    int? remainingLives,
    int? totalTimeRemaining,
  }) {
    // Game over if no more questions
    if (result == null) return true;

    // Game over if lives reach 0
    if (remainingLives != null && remainingLives <= 0) return true;

    // Game over if total time has expired
    if (totalTimeRemaining != null && totalTimeRemaining <= 0) return true;

    return false;
  }

  /// Checks if game would be over with current state (without picking).
  ///
  /// Useful for checking before actually picking the next question.
  bool wouldBeGameOver({
    int? remainingLives,
    int? totalTimeRemaining,
  }) {
    // For endless mode, we never run out of questions
    if (_modeConfig is EndlessMode) {
      // Only game over if lives depleted or time expired
      if (remainingLives != null && remainingLives <= 0) return true;
      if (totalTimeRemaining != null && totalTimeRemaining <= 0) return true;
      return false;
    }

    // Check if items are exhausted
    if (_randomItemPicker.items.isEmpty) return true;

    // Check lives
    if (remainingLives != null && remainingLives <= 0) return true;

    // Check time
    if (totalTimeRemaining != null && totalTimeRemaining <= 0) return true;

    return false;
  }

  // ============ Reset ============

  /// Resets the game flow for a new game.
  void reset() {
    _currentQuestion = null;
    _totalCount = 0;
    _modeConfig = null;
    // Clear items by replacing with empty list
    _randomItemPicker.replaceItems([]);
  }
}
