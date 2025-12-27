import '../analytics_event.dart';

/// Sealed class for resource-related events.
///
/// Tracks lives, hints, and other consumable game resources.
/// Total: 4 events.
sealed class ResourceEvent extends AnalyticsEvent {
  const ResourceEvent();

  /// The quiz ID associated with the event.
  String get quizId;

  // ============ Resource Events ============

  /// Life lost event.
  factory ResourceEvent.lifeLost({
    required String quizId,
    required String questionId,
    required int questionIndex,
    required int livesRemaining,
    required int livesTotal,
    required String reason,
  }) = LifeLostEvent;

  /// Lives depleted event (game over due to no lives).
  factory ResourceEvent.livesDepleted({
    required String quizId,
    required String quizName,
    required String categoryId,
    required int questionsAnswered,
    required int totalQuestions,
    required int correctAnswers,
    required double scorePercentage,
    required Duration duration,
  }) = LivesDepletedEvent;

  /// Resource button tapped event (lives or hints button).
  factory ResourceEvent.buttonTapped({
    required String quizId,
    required String resourceType,
    required int currentAmount,
    required bool isAvailable,
    required String context,
  }) = ResourceButtonTappedEvent;

  /// Resource added event (via reward, purchase, or bonus).
  factory ResourceEvent.added({
    required String quizId,
    required String resourceType,
    required int amountAdded,
    required int newTotal,
    required String source,
  }) = ResourceAddedEvent;
}

// ============ Resource Event Implementations ============

/// Life lost event.
final class LifeLostEvent extends ResourceEvent {
  const LifeLostEvent({
    required this.quizId,
    required this.questionId,
    required this.questionIndex,
    required this.livesRemaining,
    required this.livesTotal,
    required this.reason,
  });

  @override
  final String quizId;
  final String questionId;
  final int questionIndex;
  final int livesRemaining;
  final int livesTotal;
  final String reason;

  @override
  String get eventName => 'resource_life_lost';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'question_id': questionId,
        'question_index': questionIndex,
        'lives_remaining': livesRemaining,
        'lives_total': livesTotal,
        'reason': reason,
      };
}

/// Lives depleted event.
final class LivesDepletedEvent extends ResourceEvent {
  const LivesDepletedEvent({
    required this.quizId,
    required this.quizName,
    required this.categoryId,
    required this.questionsAnswered,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.scorePercentage,
    required this.duration,
  });

  @override
  final String quizId;
  final String quizName;
  final String categoryId;
  final int questionsAnswered;
  final int totalQuestions;
  final int correctAnswers;
  final double scorePercentage;
  final Duration duration;

  @override
  String get eventName => 'resource_lives_depleted';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'quiz_name': quizName,
        'category_id': categoryId,
        'questions_answered': questionsAnswered,
        'total_questions': totalQuestions,
        'correct_answers': correctAnswers,
        'score_percentage': scorePercentage,
        'duration_seconds': duration.inSeconds,
        'completion_percentage': totalQuestions > 0
            ? (questionsAnswered / totalQuestions * 100).toStringAsFixed(1)
            : '0.0',
      };
}

/// Resource button tapped event.
final class ResourceButtonTappedEvent extends ResourceEvent {
  const ResourceButtonTappedEvent({
    required this.quizId,
    required this.resourceType,
    required this.currentAmount,
    required this.isAvailable,
    required this.context,
  });

  @override
  final String quizId;
  final String resourceType;
  final int currentAmount;
  final bool isAvailable;
  final String context;

  @override
  String get eventName => 'resource_button_tapped';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'resource_type': resourceType,
        'current_amount': currentAmount,
        'is_available': isAvailable,
        'context': context,
      };
}

/// Resource added event.
final class ResourceAddedEvent extends ResourceEvent {
  const ResourceAddedEvent({
    required this.quizId,
    required this.resourceType,
    required this.amountAdded,
    required this.newTotal,
    required this.source,
  });

  @override
  final String quizId;
  final String resourceType;
  final int amountAdded;
  final int newTotal;
  final String source;

  @override
  String get eventName => 'resource_added';

  @override
  Map<String, dynamic> get parameters => {
        'quiz_id': quizId,
        'resource_type': resourceType,
        'amount_added': amountAdded,
        'new_total': newTotal,
        'source': source,
      };
}
