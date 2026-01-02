import '../analytics_event.dart';

/// Sealed class for streak-related analytics events.
///
/// Tracks streak extensions, breaks, and milestone achievements.
/// Total: 4 events.
sealed class StreakEvent extends AnalyticsEvent {
  const StreakEvent();

  // ============ Streak Events ============

  /// Streak extended event (streak increased by 1).
  factory StreakEvent.extended({
    required int previousStreak,
    required int newStreak,
    required bool isNewRecord,
    int? nextMilestone,
  }) = StreakExtendedEvent;

  /// Streak broken event (streak was lost).
  factory StreakEvent.broken({
    required int lostStreak,
    required int longestStreak,
    required int daysSinceLastPlay,
  }) = StreakBrokenEvent;

  /// Streak milestone reached event.
  factory StreakEvent.milestoneReached({
    required int milestoneDay,
    required int currentStreak,
    required bool isNewRecord,
    int? nextMilestone,
  }) = StreakMilestoneReachedEvent;

  /// Streak restored event (streak recovered via freeze token or similar).
  factory StreakEvent.restored({
    required int restoredStreak,
    required String restoreMethod,
  }) = StreakRestoredEvent;
}

// ============ Streak Event Implementations ============

/// Streak extended event.
///
/// Fired when the user maintains their streak by playing on a new day.
final class StreakExtendedEvent extends StreakEvent {
  const StreakExtendedEvent({
    required this.previousStreak,
    required this.newStreak,
    required this.isNewRecord,
    this.nextMilestone,
  });

  /// The streak count before extending.
  final int previousStreak;

  /// The new streak count after extending.
  final int newStreak;

  /// Whether this creates a new personal best streak.
  final bool isNewRecord;

  /// The next milestone to reach, if any.
  final int? nextMilestone;

  @override
  String get eventName => 'streak_extended';

  @override
  Map<String, dynamic> get parameters => {
        'previous_streak': previousStreak,
        'new_streak': newStreak,
        'streak_change': newStreak - previousStreak,
        'is_new_record': isNewRecord ? 1 : 0,
        if (nextMilestone != null) 'next_milestone': nextMilestone,
        if (nextMilestone != null) 'days_to_milestone': nextMilestone! - newStreak,
      };
}

/// Streak broken event.
///
/// Fired when the user's streak is lost due to missing a day.
final class StreakBrokenEvent extends StreakEvent {
  const StreakBrokenEvent({
    required this.lostStreak,
    required this.longestStreak,
    required this.daysSinceLastPlay,
  });

  /// The streak count that was lost.
  final int lostStreak;

  /// The user's longest streak ever (for comparison).
  final int longestStreak;

  /// How many days since the user last played.
  final int daysSinceLastPlay;

  @override
  String get eventName => 'streak_broken';

  @override
  Map<String, dynamic> get parameters => {
        'lost_streak': lostStreak,
        'longest_streak': longestStreak,
        'days_since_last_play': daysSinceLastPlay,
        'was_personal_best': lostStreak == longestStreak ? 1 : 0,
      };
}

/// Streak milestone reached event.
///
/// Fired when the user reaches a milestone day (7, 30, 100, etc.).
final class StreakMilestoneReachedEvent extends StreakEvent {
  const StreakMilestoneReachedEvent({
    required this.milestoneDay,
    required this.currentStreak,
    required this.isNewRecord,
    this.nextMilestone,
  });

  /// The milestone day reached (e.g., 7, 30, 100).
  final int milestoneDay;

  /// The current streak count.
  final int currentStreak;

  /// Whether this is a new personal best.
  final bool isNewRecord;

  /// The next milestone to reach, if any.
  final int? nextMilestone;

  @override
  String get eventName => 'streak_milestone';

  @override
  Map<String, dynamic> get parameters => {
        'milestone_day': milestoneDay,
        'current_streak': currentStreak,
        'is_new_record': isNewRecord ? 1 : 0,
        if (nextMilestone != null) 'next_milestone': nextMilestone,
      };
}

/// Streak restored event.
///
/// Fired when a streak is restored through a recovery mechanism.
final class StreakRestoredEvent extends StreakEvent {
  const StreakRestoredEvent({
    required this.restoredStreak,
    required this.restoreMethod,
  });

  /// The streak count that was restored.
  final int restoredStreak;

  /// The method used to restore the streak (e.g., 'freeze_token', 'ad_watch').
  final String restoreMethod;

  @override
  String get eventName => 'streak_restored';

  @override
  Map<String, dynamic> get parameters => {
        'restored_streak': restoredStreak,
        'restore_method': restoreMethod,
      };
}
