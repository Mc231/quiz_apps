import '../analytics_event.dart';

/// Sealed class for achievement-related events.
///
/// Tracks achievement unlocks, notifications, and user interactions.
/// Total: 5 events.
sealed class AchievementEvent extends AnalyticsEvent {
  const AchievementEvent();

  // ============ Achievement Events ============

  /// Achievement unlocked event.
  factory AchievementEvent.unlocked({
    required String achievementId,
    required String achievementName,
    required String achievementCategory,
    required int pointsAwarded,
    required int totalPoints,
    required int unlockedCount,
    required int totalAchievements,
    String? triggerQuizId,
  }) = AchievementUnlockedEvent;

  /// Achievement notification shown event.
  factory AchievementEvent.notificationShown({
    required String achievementId,
    required String achievementName,
    required int pointsAwarded,
    required Duration displayDuration,
  }) = AchievementNotificationShownEvent;

  /// Achievement notification tapped event.
  factory AchievementEvent.notificationTapped({
    required String achievementId,
    required String achievementName,
    required Duration timeToTap,
  }) = AchievementNotificationTappedEvent;

  /// Achievement detail viewed event.
  factory AchievementEvent.detailViewed({
    required String achievementId,
    required String achievementName,
    required String achievementCategory,
    required bool isUnlocked,
    double? progress,
  }) = AchievementDetailViewedEvent;

  /// Achievement list filtered event.
  factory AchievementEvent.filtered({
    required String filterType,
    required String filterValue,
    required int resultCount,
    required int totalCount,
  }) = AchievementFilteredEvent;
}

// ============ Achievement Event Implementations ============

/// Achievement unlocked event.
final class AchievementUnlockedEvent extends AchievementEvent {
  const AchievementUnlockedEvent({
    required this.achievementId,
    required this.achievementName,
    required this.achievementCategory,
    required this.pointsAwarded,
    required this.totalPoints,
    required this.unlockedCount,
    required this.totalAchievements,
    this.triggerQuizId,
  });

  final String achievementId;
  final String achievementName;
  final String achievementCategory;
  final int pointsAwarded;
  final int totalPoints;
  final int unlockedCount;
  final int totalAchievements;
  final String? triggerQuizId;

  @override
  String get eventName => 'achievement_unlocked';

  @override
  Map<String, dynamic> get parameters => {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'achievement_category': achievementCategory,
        'points_awarded': pointsAwarded,
        'total_points': totalPoints,
        'unlocked_count': unlockedCount,
        'total_achievements': totalAchievements,
        'unlock_percentage': totalAchievements > 0
            ? (unlockedCount / totalAchievements * 100).toStringAsFixed(1)
            : '0.0',
        if (triggerQuizId != null) 'trigger_quiz_id': triggerQuizId,
      };
}

/// Achievement notification shown event.
final class AchievementNotificationShownEvent extends AchievementEvent {
  const AchievementNotificationShownEvent({
    required this.achievementId,
    required this.achievementName,
    required this.pointsAwarded,
    required this.displayDuration,
  });

  final String achievementId;
  final String achievementName;
  final int pointsAwarded;
  final Duration displayDuration;

  @override
  String get eventName => 'achievement_notification_shown';

  @override
  Map<String, dynamic> get parameters => {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'points_awarded': pointsAwarded,
        'display_duration_ms': displayDuration.inMilliseconds,
      };
}

/// Achievement notification tapped event.
final class AchievementNotificationTappedEvent extends AchievementEvent {
  const AchievementNotificationTappedEvent({
    required this.achievementId,
    required this.achievementName,
    required this.timeToTap,
  });

  final String achievementId;
  final String achievementName;
  final Duration timeToTap;

  @override
  String get eventName => 'achievement_notification_tapped';

  @override
  Map<String, dynamic> get parameters => {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'time_to_tap_ms': timeToTap.inMilliseconds,
      };
}

/// Achievement detail viewed event.
final class AchievementDetailViewedEvent extends AchievementEvent {
  const AchievementDetailViewedEvent({
    required this.achievementId,
    required this.achievementName,
    required this.achievementCategory,
    required this.isUnlocked,
    this.progress,
  });

  final String achievementId;
  final String achievementName;
  final String achievementCategory;
  final bool isUnlocked;
  final double? progress;

  @override
  String get eventName => 'achievement_detail_viewed';

  @override
  Map<String, dynamic> get parameters => {
        'achievement_id': achievementId,
        'achievement_name': achievementName,
        'achievement_category': achievementCategory,
        'is_unlocked': isUnlocked,
        if (progress != null) 'progress': progress,
      };
}

/// Achievement list filtered event.
final class AchievementFilteredEvent extends AchievementEvent {
  const AchievementFilteredEvent({
    required this.filterType,
    required this.filterValue,
    required this.resultCount,
    required this.totalCount,
  });

  final String filterType;
  final String filterValue;
  final int resultCount;
  final int totalCount;

  @override
  String get eventName => 'achievement_filtered';

  @override
  Map<String, dynamic> get parameters => {
        'filter_type': filterType,
        'filter_value': filterValue,
        'result_count': resultCount,
        'total_count': totalCount,
      };
}
