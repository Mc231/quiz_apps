import '../analytics_event.dart';

/// Sealed class for daily challenge analytics events.
///
/// Tracks daily challenge lifecycle, completion, and ranking.
/// Total: 4 events.
sealed class DailyChallengeEvent extends AnalyticsEvent {
  const DailyChallengeEvent();

  // ============ Daily Challenge Events ============

  /// Daily challenge started event.
  factory DailyChallengeEvent.started({
    required String challengeId,
    required String categoryId,
    required int totalQuestions,
    int? timeLimitSeconds,
    required int currentStreak,
  }) = DailyChallengeStartedEvent;

  /// Daily challenge completed event.
  factory DailyChallengeEvent.completed({
    required String challengeId,
    required String categoryId,
    required int score,
    required int correctCount,
    required int totalQuestions,
    required int completionTimeSeconds,
    required int streakBonus,
    required int timeBonus,
    required bool isPerfect,
    required int currentStreak,
    required bool isEarlyBird,
  }) = DailyChallengeCompletedEvent;

  /// Daily challenge ranked event (when position on leaderboard is calculated).
  factory DailyChallengeEvent.ranked({
    required String challengeId,
    required int rank,
    required int totalParticipants,
    required int score,
    required bool isTopTen,
    required bool isTopThree,
    required bool isFirst,
  }) = DailyChallengeRankedEvent;

  /// Daily challenge skipped event.
  factory DailyChallengeEvent.skipped({
    required String challengeId,
    required String categoryId,
    required int currentStreak,
  }) = DailyChallengeSkippedEvent;
}

// ============ Daily Challenge Event Implementations ============

/// Daily challenge started event.
///
/// Fired when the user starts today's daily challenge.
final class DailyChallengeStartedEvent extends DailyChallengeEvent {
  const DailyChallengeStartedEvent({
    required this.challengeId,
    required this.categoryId,
    required this.totalQuestions,
    this.timeLimitSeconds,
    required this.currentStreak,
  });

  /// Unique ID for this daily challenge.
  final String challengeId;

  /// Category of the challenge (e.g., 'eu', 'as', 'all').
  final String categoryId;

  /// Total number of questions in the challenge.
  final int totalQuestions;

  /// Time limit in seconds, if applicable.
  final int? timeLimitSeconds;

  /// User's current daily challenge streak.
  final int currentStreak;

  @override
  String get eventName => 'daily_challenge_started';

  @override
  Map<String, dynamic> get parameters => {
        'challenge_id': challengeId,
        'category_id': categoryId,
        'total_questions': totalQuestions,
        if (timeLimitSeconds != null) 'time_limit_seconds': timeLimitSeconds,
        'current_streak': currentStreak,
        'has_time_limit': timeLimitSeconds != null ? 1 : 0,
      };
}

/// Daily challenge completed event.
///
/// Fired when the user completes today's daily challenge.
final class DailyChallengeCompletedEvent extends DailyChallengeEvent {
  const DailyChallengeCompletedEvent({
    required this.challengeId,
    required this.categoryId,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.completionTimeSeconds,
    required this.streakBonus,
    required this.timeBonus,
    required this.isPerfect,
    required this.currentStreak,
    required this.isEarlyBird,
  });

  /// Unique ID for this daily challenge.
  final String challengeId;

  /// Category of the challenge.
  final String categoryId;

  /// Total score earned (including bonuses).
  final int score;

  /// Number of correct answers.
  final int correctCount;

  /// Total questions in the challenge.
  final int totalQuestions;

  /// Time taken to complete in seconds.
  final int completionTimeSeconds;

  /// Bonus points from streak.
  final int streakBonus;

  /// Bonus points from fast completion.
  final int timeBonus;

  /// Whether the user achieved a perfect score.
  final bool isPerfect;

  /// User's streak after completing (incremented).
  final int currentStreak;

  /// Whether completed within the first hour of the day.
  final bool isEarlyBird;

  @override
  String get eventName => 'daily_challenge_completed';

  @override
  Map<String, dynamic> get parameters => {
        'challenge_id': challengeId,
        'category_id': categoryId,
        'score': score,
        'correct_count': correctCount,
        'total_questions': totalQuestions,
        'score_percentage':
            totalQuestions > 0 ? (correctCount / totalQuestions * 100) : 0,
        'completion_time_seconds': completionTimeSeconds,
        'streak_bonus': streakBonus,
        'time_bonus': timeBonus,
        'is_perfect': isPerfect ? 1 : 0,
        'current_streak': currentStreak,
        'is_early_bird': isEarlyBird ? 1 : 0,
      };
}

/// Daily challenge ranked event.
///
/// Fired when the user's rank on the leaderboard is calculated.
final class DailyChallengeRankedEvent extends DailyChallengeEvent {
  const DailyChallengeRankedEvent({
    required this.challengeId,
    required this.rank,
    required this.totalParticipants,
    required this.score,
    required this.isTopTen,
    required this.isTopThree,
    required this.isFirst,
  });

  /// Unique ID for this daily challenge.
  final String challengeId;

  /// User's rank (1 = first place).
  final int rank;

  /// Total number of participants.
  final int totalParticipants;

  /// User's score.
  final int score;

  /// Whether user is in top 10.
  final bool isTopTen;

  /// Whether user is in top 3.
  final bool isTopThree;

  /// Whether user is first place.
  final bool isFirst;

  @override
  String get eventName => 'daily_challenge_ranked';

  @override
  Map<String, dynamic> get parameters => {
        'challenge_id': challengeId,
        'rank': rank,
        'total_participants': totalParticipants,
        'score': score,
        'percentile': totalParticipants > 0
            ? ((totalParticipants - rank + 1) / totalParticipants * 100).round()
            : 0,
        'is_top_ten': isTopTen ? 1 : 0,
        'is_top_three': isTopThree ? 1 : 0,
        'is_first': isFirst ? 1 : 0,
      };
}

/// Daily challenge skipped event.
///
/// Fired when the user skips today's challenge (day ends without completion).
final class DailyChallengeSkippedEvent extends DailyChallengeEvent {
  const DailyChallengeSkippedEvent({
    required this.challengeId,
    required this.categoryId,
    required this.currentStreak,
  });

  /// Unique ID for this daily challenge.
  final String challengeId;

  /// Category of the challenge.
  final String categoryId;

  /// User's current streak (before being broken).
  final int currentStreak;

  @override
  String get eventName => 'daily_challenge_skipped';

  @override
  Map<String, dynamic> get parameters => {
        'challenge_id': challengeId,
        'category_id': categoryId,
        'current_streak': currentStreak,
        'streak_lost': currentStreak > 0 ? 1 : 0,
      };
}