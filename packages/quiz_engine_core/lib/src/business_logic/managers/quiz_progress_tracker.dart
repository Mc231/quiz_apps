import '../../model/answer.dart';

/// Tracks quiz progress and statistics during a session.
///
/// This manager is responsible for:
/// - Recording answers and tracking progress
/// - Tracking consecutive answer streaks
/// - Managing lives in lives-based modes
/// - Providing statistics about the quiz session
class QuizProgressTracker {
  /// List of all answers given during the session.
  final List<Answer> _answers = [];

  /// Current progress (number of questions answered).
  int _currentProgress = 0;

  /// Total number of questions in the quiz.
  int _totalCount = 0;

  /// Current streak of consecutive correct answers.
  int _currentStreak = 0;

  /// Best streak achieved during this session.
  int _bestStreak = 0;

  /// Remaining lives (null if lives mode is not active).
  int? _remainingLives;

  /// Whether the tracker has been initialized.
  bool _isInitialized = false;

  /// Creates a new progress tracker.
  QuizProgressTracker();

  // ============ Getters ============

  /// Returns an unmodifiable view of all answers.
  List<Answer> get answers => List.unmodifiable(_answers);

  /// Current progress (questions answered).
  int get currentProgress => _currentProgress;

  /// Total number of questions.
  int get totalCount => _totalCount;

  /// Current streak of consecutive correct answers.
  int get currentStreak => _currentStreak;

  /// Best streak achieved in this session.
  int get bestStreak => _bestStreak;

  /// Remaining lives (null if lives mode is not active).
  int? get remainingLives => _remainingLives;

  /// Whether the tracker has been initialized.
  bool get isInitialized => _isInitialized;

  /// Number of correct answers.
  int get correctAnswers => _answers.where((a) => a.isCorrect).length;

  /// Number of incorrect answers (excludes skipped and timed out).
  int get incorrectAnswers =>
      _answers.where((a) => !a.isCorrect && !a.isSkipped && !a.isTimeout).length;

  /// Number of skipped answers.
  int get skippedAnswers => _answers.where((a) => a.isSkipped).length;

  /// Number of timed out answers.
  int get timedOutAnswers => _answers.where((a) => a.isTimeout).length;

  /// Total number of failed answers (incorrect + timed out).
  int get totalFailedAnswers => incorrectAnswers + timedOutAnswers;

  /// Whether the player is out of lives.
  bool get isOutOfLives => _remainingLives != null && _remainingLives! <= 0;

  /// Progress as a percentage (0.0 to 1.0).
  double get progressPercentage =>
      _totalCount > 0 ? _currentProgress / _totalCount : 0.0;

  // ============ Methods ============

  /// Initializes the tracker for a new quiz.
  ///
  /// [totalCount] is the total number of questions in the quiz.
  /// [initialLives] is the starting number of lives (null for non-lives modes).
  void initialize({
    required int totalCount,
    int? initialLives,
  }) {
    _totalCount = totalCount;
    _remainingLives = initialLives;
    _isInitialized = true;
  }

  /// Records an answer and updates progress.
  ///
  /// This method:
  /// - Adds the answer to the answers list
  /// - Updates streak based on correctness
  /// - Deducts a life if the answer is wrong and lives mode is active
  /// - Increments progress counter
  void recordAnswer(Answer answer) {
    _answers.add(answer);
    _updateStreak(answer.isCorrect);

    // Deduct life for wrong answers (not skipped, not timed out)
    // Timeout life deduction is handled separately via deductLife()
    if (!answer.isCorrect && !answer.isSkipped && !answer.isTimeout && _remainingLives != null) {
      _remainingLives = _remainingLives! - 1;
    }

    _currentProgress++;
  }

  /// Updates streak based on whether the answer was correct.
  void _updateStreak(bool isCorrect) {
    if (isCorrect) {
      _currentStreak++;
      if (_currentStreak > _bestStreak) {
        _bestStreak = _currentStreak;
      }
    } else {
      _currentStreak = 0;
    }
  }

  /// Manually deducts a life (e.g., for timeout scenarios).
  ///
  /// Does nothing if lives mode is not active.
  void deductLife() {
    if (_remainingLives != null && _remainingLives! > 0) {
      _remainingLives = _remainingLives! - 1;
    }
  }

  /// Resets the tracker for a new quiz.
  ///
  /// Clears all answers, resets progress and streaks, but preserves
  /// the total count and initial lives configuration.
  void reset() {
    _answers.clear();
    _currentProgress = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    // Note: _totalCount and _remainingLives are not reset
    // Call initialize() again for a completely fresh start
  }

  /// Completely resets the tracker to its initial state.
  void resetAll() {
    _answers.clear();
    _currentProgress = 0;
    _totalCount = 0;
    _currentStreak = 0;
    _bestStreak = 0;
    _remainingLives = null;
    _isInitialized = false;
  }
}
