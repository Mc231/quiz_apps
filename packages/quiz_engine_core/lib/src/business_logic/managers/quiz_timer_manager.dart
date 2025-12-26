import 'dart:async';

import '../../model/config/quiz_mode_config.dart';

/// Callback signature for timer tick events.
typedef OnTimerTick = void Function({
  int? questionTimeRemaining,
  int? totalTimeRemaining,
});

/// Callback signature for question timeout events.
typedef OnQuestionTimeout = void Function(int timeSpentSeconds);

/// Callback signature for total time expired events.
typedef OnTotalTimeExpired = void Function();

/// Manages quiz timers including question timers, total timers, and stopwatches.
///
/// This manager is responsible for:
/// - Per-question countdown timers
/// - Total quiz countdown timers
/// - Session duration tracking via stopwatch
/// - Individual question duration tracking via stopwatch
/// - Pause/resume functionality
class QuizTimerManager {
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

  /// Stopwatch for tracking quiz duration.
  final Stopwatch _sessionStopwatch = Stopwatch();

  /// Stopwatch for tracking individual question duration.
  final Stopwatch _questionStopwatch = Stopwatch();

  /// The configured time per question (null if no limit).
  int? _timePerQuestion;

  /// Callback invoked on each timer tick.
  final OnTimerTick? onTick;

  /// Callback invoked when question time expires.
  final OnQuestionTimeout? onQuestionTimeout;

  /// Callback invoked when total quiz time expires.
  final OnTotalTimeExpired? onTotalTimeExpired;

  /// Creates a new timer manager.
  ///
  /// [onTick] - Called on each timer tick with remaining times
  /// [onQuestionTimeout] - Called when question time expires
  /// [onTotalTimeExpired] - Called when total quiz time expires
  QuizTimerManager({
    this.onTick,
    this.onQuestionTimeout,
    this.onTotalTimeExpired,
  });

  // ============ Getters ============

  /// Remaining time for the current question in seconds.
  int? get questionTimeRemaining => _questionTimeRemaining;

  /// Remaining total time for the entire quiz in seconds.
  int? get totalTimeRemaining => _totalTimeRemaining;

  /// Whether the timers are currently paused.
  bool get isPaused => _timersPaused;

  /// The elapsed session duration in seconds.
  int get sessionDurationSeconds => _sessionStopwatch.elapsed.inSeconds;

  /// The elapsed time for the current question in seconds.
  int get questionTimeSpentSeconds => _questionStopwatch.elapsed.inSeconds;

  /// Whether a question timer is configured.
  bool get hasQuestionTimer => _timePerQuestion != null;

  /// Whether a total timer is configured.
  bool get hasTotalTimer => _totalTimeRemaining != null;

  // ============ Initialization ============

  /// Initializes timer settings from mode configuration.
  ///
  /// [modeConfig] - The quiz mode configuration
  void initialize(QuizModeConfig modeConfig) {
    // Extract time per question from mode config
    if (modeConfig is TimedMode) {
      _timePerQuestion = modeConfig.timePerQuestion;
      if (modeConfig.totalTimeLimit != null) {
        _totalTimeRemaining = modeConfig.totalTimeLimit;
      }
    } else if (modeConfig is SurvivalMode) {
      _timePerQuestion = modeConfig.timePerQuestion;
      if (modeConfig.totalTimeLimit != null) {
        _totalTimeRemaining = modeConfig.totalTimeLimit;
      }
    }
  }

  // ============ Session Stopwatch ============

  /// Starts the session stopwatch.
  void startSession() {
    _sessionStopwatch.start();
  }

  /// Stops the session stopwatch.
  void stopSession() {
    _sessionStopwatch.stop();
  }

  /// Resets the session stopwatch.
  void resetSession() {
    _sessionStopwatch.reset();
  }

  // ============ Question Stopwatch ============

  /// Starts the question stopwatch for tracking time spent on a question.
  void startQuestionStopwatch() {
    _questionStopwatch.reset();
    _questionStopwatch.start();
  }

  /// Stops the question stopwatch.
  ///
  /// Returns the time spent on the question in seconds.
  int stopQuestionStopwatch() {
    _questionStopwatch.stop();
    return _questionStopwatch.elapsed.inSeconds;
  }

  // ============ Total Timer ============

  /// Starts the total quiz timer.
  ///
  /// Does nothing if no total time limit is configured or if paused.
  void startTotalTimer() {
    if (_timersPaused) return;
    if (_totalTimeRemaining == null) return;

    _totalTimer?.cancel();
    _totalTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalTimeRemaining != null && _totalTimeRemaining! > 0) {
        _totalTimeRemaining = _totalTimeRemaining! - 1;
        // Total timer updates are reflected via onTick callback
      } else {
        _handleTotalTimeExpired();
      }
    });
  }

  /// Cancels the total timer.
  void cancelTotalTimer() {
    _totalTimer?.cancel();
    _totalTimer = null;
  }

  void _handleTotalTimeExpired() {
    cancelQuestionTimer();
    cancelTotalTimer();
    _totalTimeRemaining = 0;
    onTotalTimeExpired?.call();
  }

  // ============ Question Timer ============

  /// Starts the question timer for a new question.
  ///
  /// If paused, sets the remaining time but doesn't start the timer.
  /// If [resetTime] is true (default), resets the remaining time.
  void startQuestionTimer({bool resetTime = true}) {
    if (_timePerQuestion == null) return;

    // Reset time if this is a fresh question
    if (resetTime || _questionTimeRemaining == null || _questionTimeRemaining! <= 0) {
      _questionTimeRemaining = _timePerQuestion;
    }

    // Don't start actual timer if paused
    if (_timersPaused) return;

    _questionTimer?.cancel();
    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_questionTimeRemaining != null && _questionTimeRemaining! > 0) {
        _questionTimeRemaining = _questionTimeRemaining! - 1;
        _notifyTick();
      } else {
        _handleQuestionTimeExpired();
      }
    });
  }

  /// Cancels the question timer.
  void cancelQuestionTimer() {
    _questionTimer?.cancel();
    _questionTimer = null;
  }

  void _handleQuestionTimeExpired() {
    cancelQuestionTimer();
    _questionStopwatch.stop();
    final timeSpent = _questionStopwatch.elapsed.inSeconds;
    onQuestionTimeout?.call(timeSpent);
  }

  /// Resets the question time remaining (for starting a new question).
  void resetQuestionTime() {
    _questionTimeRemaining = _timePerQuestion;
  }

  // ============ Pause/Resume ============

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
      startQuestionTimer(resetTime: false);
    }

    // Restart total timer if there's remaining time
    if (_totalTimeRemaining != null && _totalTimeRemaining! > 0) {
      startTotalTimer();
    }
  }

  // ============ Helper Methods ============

  void _notifyTick() {
    onTick?.call(
      questionTimeRemaining: _questionTimeRemaining,
      totalTimeRemaining: _totalTimeRemaining,
    );
  }

  // ============ Cleanup ============

  /// Disposes all timers and stops all stopwatches.
  void dispose() {
    _timersPaused = false;
    cancelQuestionTimer();
    cancelTotalTimer();
    _sessionStopwatch.stop();
    _questionStopwatch.stop();
  }

  /// Resets all state to initial values.
  void reset() {
    cancelQuestionTimer();
    cancelTotalTimer();
    _questionTimeRemaining = null;
    _totalTimeRemaining = null;
    _timersPaused = false;
    _timePerQuestion = null;
    _sessionStopwatch.reset();
    _questionStopwatch.reset();
  }
}
