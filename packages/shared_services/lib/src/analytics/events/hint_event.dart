import '../analytics_event.dart';

/// Sealed class for hint-related events.
///
/// Tracks hint usage and availability during quizzes.
/// Total: 4 events.
sealed class HintEvent extends AnalyticsEvent {
  const HintEvent();

  /// The quiz ID associated with the event.
  String get quizId;

  // ============ Hint Events ============

  /// Fifty-fifty hint used event.
  factory HintEvent.fiftyFiftyUsed({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required int hintsRemaining,
    required List<String> eliminatedOptions,
  }) = FiftyFiftyUsedEvent;

  /// Skip hint used event.
  factory HintEvent.skipUsed({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required int hintsRemaining,
    required Duration timeBeforeSkip,
  }) = SkipUsedEvent;

  /// Hint unavailable tapped event (user tried to use depleted hint).
  factory HintEvent.unavailableTapped({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required String hintType,
    int? totalHintsUsed,
  }) = HintUnavailableTappedEvent;

  /// Timer warning event (shown when time is running low).
  factory HintEvent.timerWarning({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required int secondsRemaining,
    required String warningLevel,
  }) = HintTimerWarningEvent;
}

// ============ Hint Event Implementations ============

/// Fifty-fifty hint used event.
final class FiftyFiftyUsedEvent extends HintEvent {
  const FiftyFiftyUsedEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.hintsRemaining,
    required this.eliminatedOptions,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final int hintsRemaining;
  final List<String> eliminatedOptions;

  @override
  String get eventName => 'hint_fifty_fifty_used';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'hints_remaining': hintsRemaining,
        'eliminated_options': eliminatedOptions.join(','),
        'eliminated_count': eliminatedOptions.length,
      };
}

/// Skip hint used event.
final class SkipUsedEvent extends HintEvent {
  const SkipUsedEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.hintsRemaining,
    required this.timeBeforeSkip,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final int hintsRemaining;
  final Duration timeBeforeSkip;

  @override
  String get eventName => 'hint_skip_used';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'hints_remaining': hintsRemaining,
        'time_before_skip_ms': timeBeforeSkip.inMilliseconds,
      };
}

/// Hint unavailable tapped event.
final class HintUnavailableTappedEvent extends HintEvent {
  const HintUnavailableTappedEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.hintType,
    this.totalHintsUsed,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final String hintType;
  final int? totalHintsUsed;

  @override
  String get eventName => 'hint_unavailable_tapped';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'hint_type': hintType,
        if (totalHintsUsed != null) 'total_hints_used': totalHintsUsed,
      };
}

/// Timer warning event.
final class HintTimerWarningEvent extends HintEvent {
  const HintTimerWarningEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.secondsRemaining,
    required this.warningLevel,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final int secondsRemaining;
  final String warningLevel;

  @override
  String get eventName => 'hint_timer_warning';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'seconds_remaining': secondsRemaining,
        'warning_level': warningLevel,
      };
}
