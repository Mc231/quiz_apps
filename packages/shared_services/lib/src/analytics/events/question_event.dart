import '../analytics_event.dart';

/// Sealed class for question-related events.
///
/// Tracks question display, user answers, and feedback.
/// Total: 8 events.
sealed class QuestionEvent extends AnalyticsEvent {
  const QuestionEvent();

  /// The quiz ID associated with the event.
  String get quizId;

  // ============ Question Events ============

  /// Question displayed event.
  factory QuestionEvent.displayed({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required int totalQuestions,
    required String questionType,
    required int optionCount,
    int? timeLimit,
  }) = QuestionDisplayedEvent;

  /// Answer submitted event.
  factory QuestionEvent.answered({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required bool isCorrect,
    required Duration responseTime,
    required String selectedAnswer,
    required String correctAnswer,
  }) = QuestionAnsweredEvent;

  /// Correct answer event.
  factory QuestionEvent.correct({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required Duration responseTime,
    required int currentStreak,
    int? pointsEarned,
    int? bonusPoints,
  }) = QuestionCorrectEvent;

  /// Incorrect answer event.
  factory QuestionEvent.incorrect({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required Duration responseTime,
    required String selectedAnswer,
    required String correctAnswer,
    int? livesRemaining,
  }) = QuestionIncorrectEvent;

  /// Question skipped event.
  factory QuestionEvent.skipped({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required Duration timeBeforeSkip,
    required bool usedHint,
    int? hintsRemaining,
  }) = QuestionSkippedEvent;

  /// Question timeout event.
  factory QuestionEvent.timeout({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required int timeLimit,
    required String correctAnswer,
    int? livesRemaining,
  }) = QuestionTimeoutEvent;

  /// Feedback shown event.
  factory QuestionEvent.feedbackShown({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required bool wasCorrect,
    required Duration feedbackDuration,
  }) = QuestionFeedbackShownEvent;

  /// Option selected event (before confirming answer).
  factory QuestionEvent.optionSelected({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required String selectedOption,
    required int optionIndex,
    required Duration timeSinceDisplayed,
    required bool isFirstSelection,
    int? changeCount,
  }) = QuestionOptionSelectedEvent;
}

// ============ Question Event Implementations ============

/// Question displayed event.
final class QuestionDisplayedEvent extends QuestionEvent {
  const QuestionDisplayedEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.totalQuestions,
    required this.questionType,
    required this.optionCount,
    this.timeLimit,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final int totalQuestions;
  final String questionType;
  final int optionCount;
  final int? timeLimit;

  @override
  String get eventName => 'question_displayed';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'total_questions': totalQuestions,
        'question_type': questionType,
        'option_count': optionCount,
        if (timeLimit != null) 'time_limit': timeLimit,
      };
}

/// Question answered event.
final class QuestionAnsweredEvent extends QuestionEvent {
  const QuestionAnsweredEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.isCorrect,
    required this.responseTime,
    required this.selectedAnswer,
    required this.correctAnswer,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final bool isCorrect;
  final Duration responseTime;
  final String selectedAnswer;
  final String correctAnswer;

  @override
  String get eventName => 'question_answered';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'is_correct': isCorrect ? 1 : 0,
        'response_time_ms': responseTime.inMilliseconds,
        'selected_answer': selectedAnswer,
        'correct_answer': correctAnswer,
      };
}

/// Correct answer event.
final class QuestionCorrectEvent extends QuestionEvent {
  const QuestionCorrectEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.responseTime,
    required this.currentStreak,
    this.pointsEarned,
    this.bonusPoints,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final Duration responseTime;
  final int currentStreak;
  final int? pointsEarned;
  final int? bonusPoints;

  @override
  String get eventName => 'question_correct';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'response_time_ms': responseTime.inMilliseconds,
        'current_streak': currentStreak,
        if (pointsEarned != null) 'points_earned': pointsEarned,
        if (bonusPoints != null) 'bonus_points': bonusPoints,
      };
}

/// Incorrect answer event.
final class QuestionIncorrectEvent extends QuestionEvent {
  const QuestionIncorrectEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.responseTime,
    required this.selectedAnswer,
    required this.correctAnswer,
    this.livesRemaining,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final Duration responseTime;
  final String selectedAnswer;
  final String correctAnswer;
  final int? livesRemaining;

  @override
  String get eventName => 'question_incorrect';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'response_time_ms': responseTime.inMilliseconds,
        'selected_answer': selectedAnswer,
        'correct_answer': correctAnswer,
        if (livesRemaining != null) 'lives_remaining': livesRemaining,
      };
}

/// Question skipped event.
final class QuestionSkippedEvent extends QuestionEvent {
  const QuestionSkippedEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.timeBeforeSkip,
    required this.usedHint,
    this.hintsRemaining,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final Duration timeBeforeSkip;
  final bool usedHint;
  final int? hintsRemaining;

  @override
  String get eventName => 'question_skipped';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'time_before_skip_ms': timeBeforeSkip.inMilliseconds,
        'used_hint': usedHint ? 1 : 0,
        if (hintsRemaining != null) 'hints_remaining': hintsRemaining,
      };
}

/// Question timeout event.
final class QuestionTimeoutEvent extends QuestionEvent {
  const QuestionTimeoutEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.timeLimit,
    required this.correctAnswer,
    this.livesRemaining,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final int timeLimit;
  final String correctAnswer;
  final int? livesRemaining;

  @override
  String get eventName => 'question_timeout';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'time_limit': timeLimit,
        'correct_answer': correctAnswer,
        if (livesRemaining != null) 'lives_remaining': livesRemaining,
      };
}

/// Feedback shown event.
final class QuestionFeedbackShownEvent extends QuestionEvent {
  const QuestionFeedbackShownEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.wasCorrect,
    required this.feedbackDuration,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final bool wasCorrect;
  final Duration feedbackDuration;

  @override
  String get eventName => 'question_feedback_shown';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'was_correct': wasCorrect ? 1 : 0,
        'feedback_duration_ms': feedbackDuration.inMilliseconds,
      };
}

/// Option selected event.
final class QuestionOptionSelectedEvent extends QuestionEvent {
  const QuestionOptionSelectedEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.selectedOption,
    required this.optionIndex,
    required this.timeSinceDisplayed,
    required this.isFirstSelection,
    this.changeCount,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final String selectedOption;
  final int optionIndex;
  final Duration timeSinceDisplayed;
  final bool isFirstSelection;
  final int? changeCount;

  @override
  String get eventName => 'question_option_selected';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'selected_option': selectedOption,
        'option_index': optionIndex,
        'time_since_displayed_ms': timeSinceDisplayed.inMilliseconds,
        'is_first_selection': isFirstSelection ? 1 : 0,
        if (changeCount != null) 'change_count': changeCount,
      };
}
