import '../analytics_event.dart';

/// Sealed class for quiz lifecycle events.
///
/// Tracks the start, completion, and various end states of a quiz session.
/// Total: 8 events.
sealed class QuizEvent extends AnalyticsEvent {
  const QuizEvent();

  /// The quiz ID associated with the event.
  String get quizId;

  // ============ Lifecycle Events ============

  /// Quiz started event.
  factory QuizEvent.started({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String categoryName,
    required String mode,
    required int totalQuestions,
    int? initialLives,
    int? initialHints,
    int? timeLimit,
  }) = QuizStartedEvent;

  /// Quiz completed event (all questions answered).
  factory QuizEvent.completed({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int totalQuestions,
    required int correctAnswers,
    required int incorrectAnswers,
    required int skippedQuestions,
    required double scorePercentage,
    required Duration duration,
    required int hintsUsed,
    int? finalScore,
    int? starRating,
    bool isPerfectScore,
  }) = QuizCompletedEvent;

  /// Quiz cancelled event (user quit manually).
  factory QuizEvent.cancelled({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required Duration timeSpent,
  }) = QuizCancelledEvent;

  /// Quiz timeout event (total time expired).
  factory QuizEvent.timeout({
    required String quizId,
    required String quizName,
    required String categoryId,
    required String mode,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
  }) = QuizTimeoutEvent;

  /// Quiz failed event (lives depleted).
  factory QuizEvent.failed({
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
  }) = QuizFailedEvent;

  /// Quiz paused event (app went to background).
  factory QuizEvent.paused({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
  }) = QuizPausedEvent;

  /// Quiz resumed event (app returned to foreground).
  factory QuizEvent.resumed({
    required String quizId,
    required String quizName,
    required int currentQuestion,
    required int totalQuestions,
    required Duration pauseDuration,
  }) = QuizResumedEvent;

  /// Challenge started event (special challenge mode).
  factory QuizEvent.challengeStarted({
    required String quizId,
    required String quizName,
    required String challengeId,
    required String challengeName,
    required String difficulty,
    required int targetScore,
  }) = QuizChallengeStartedEvent;
}

// ============ Lifecycle Event Implementations ============

/// Quiz started event.
final class QuizStartedEvent extends QuizEvent {
  const QuizStartedEvent({
    required this.quizId,
    required this.quizName,
    required this.categoryId,
    required this.categoryName,
    required this.mode,
    required this.totalQuestions,
    this.initialLives,
    this.initialHints,
    this.timeLimit,
  });

  @override
  final String quizId;
  final String quizName;
  final String categoryId;
  final String categoryName;
  final String mode;
  final int totalQuestions;
  final int? initialLives;
  final int? initialHints;
  final int? timeLimit;

  @override
  String get eventName => 'quiz_started';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'category_id': categoryId,
        'category_name': categoryName,
        'mode': mode,
        'total_questions': totalQuestions,
        if (initialLives != null) 'initial_lives': initialLives,
        if (initialHints != null) 'initial_hints': initialHints,
        if (timeLimit != null) 'time_limit': timeLimit,
      };
}

/// Quiz completed event.
final class QuizCompletedEvent extends QuizEvent {
  const QuizCompletedEvent({
    required this.quizId,
    required this.quizName,
    required this.categoryId,
    required this.mode,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.skippedQuestions,
    required this.scorePercentage,
    required this.duration,
    required this.hintsUsed,
    this.finalScore,
    this.starRating,
    this.isPerfectScore = false,
  });

  @override
  final String quizId;
  final String quizName;
  final String categoryId;
  final String mode;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int skippedQuestions;
  final double scorePercentage;
  final Duration duration;
  final int hintsUsed;
  final int? finalScore;
  final int? starRating;
  final bool isPerfectScore;

  @override
  String get eventName => 'quiz_completed';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'category_id': categoryId,
        'mode': mode,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'incorrect_answers': incorrectAnswers,
        'skipped_questions': skippedQuestions,
        'score_percentage': scorePercentage,
        'duration_seconds': duration.inSeconds,
        'hints_used': hintsUsed,
        'is_perfect_score': isPerfectScore ? 1 : 0,
        if (finalScore != null) 'final_score': finalScore,
        if (starRating != null) 'star_rating': starRating,
      };
}

/// Quiz cancelled event.
final class QuizCancelledEvent extends QuizEvent {
  const QuizCancelledEvent({
    required this.quizId,
    required this.quizName,
    required this.categoryId,
    required this.mode,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.timeSpent,
  });

  @override
  final String quizId;
  final String quizName;
  final String categoryId;
  final String mode;
  final int questionsAnswered;
  final int totalQuestions;
  final Duration timeSpent;

  @override
  String get eventName => 'quiz_cancelled';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'category_id': categoryId,
        'mode': mode,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
        'time_spent_seconds': timeSpent.inSeconds,
        'completion_percentage': totalQuestions > 0
            ? (questionsAnswered / totalQuestions * 100).toStringAsFixed(1)
            : '0.0',
      };
}

/// Quiz timeout event.
final class QuizTimeoutEvent extends QuizEvent {
  const QuizTimeoutEvent({
    required this.quizId,
    required this.quizName,
    required this.categoryId,
    required this.mode,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
  });

  @override
  final String quizId;
  final String quizName;
  final String categoryId;
  final String mode;
  final int questionsAnswered;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;

  @override
  String get eventName => 'quiz_timeout';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'category_id': categoryId,
        'mode': mode,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'score_percentage': scorePercentage,
      };
}

/// Quiz failed event (lives depleted or other failure).
final class QuizFailedEvent extends QuizEvent {
  const QuizFailedEvent({
    required this.quizId,
    required this.quizName,
    required this.categoryId,
    required this.mode,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.duration,
    required this.reason,
  });

  @override
  final String quizId;
  final String quizName;
  final String categoryId;
  final String mode;
  final int questionsAnswered;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final Duration duration;
  final String reason;

  @override
  String get eventName => 'quiz_failed';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'category_id': categoryId,
        'mode': mode,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'score_percentage': scorePercentage,
        'duration_seconds': duration.inSeconds,
        'reason': reason,
      };
}

/// Quiz paused event.
final class QuizPausedEvent extends QuizEvent {
  const QuizPausedEvent({
    required this.quizId,
    required this.quizName,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  final String quizId;
  final String quizName;
  final int currentQuestion;
  final int totalQuestions;

  @override
  String get eventName => 'quiz_paused';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'current_question': currentQuestion,
        'total_questions': totalQuestions,
      };
}

/// Quiz resumed event.
final class QuizResumedEvent extends QuizEvent {
  const QuizResumedEvent({
    required this.quizId,
    required this.quizName,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.pauseDuration,
  });

  @override
  final String quizId;
  final String quizName;
  final int currentQuestion;
  final int totalQuestions;
  final Duration pauseDuration;

  @override
  String get eventName => 'quiz_resumed';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'current_question': currentQuestion,
        'total_questions': totalQuestions,
        'pause_duration_seconds': pauseDuration.inSeconds,
      };
}

/// Quiz challenge started event.
final class QuizChallengeStartedEvent extends QuizEvent {
  const QuizChallengeStartedEvent({
    required this.quizId,
    required this.quizName,
    required this.challengeId,
    required this.challengeName,
    required this.difficulty,
    required this.targetScore,
  });

  @override
  final String quizId;
  final String quizName;
  final String challengeId;
  final String challengeName;
  final String difficulty;
  final int targetScore;

  @override
  String get eventName => 'quiz_challenge_started';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'challenge_id': challengeId,
        'challenge_name': challengeName,
        'difficulty': difficulty,
        'target_score': targetScore,
      };
}
