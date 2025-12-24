/// Represents the progress toward an achievement.
///
/// Combines the achievement definition with current progress data.
/// Used for displaying achievements in the UI with progress bars.
class AchievementProgress {
  /// The achievement ID.
  final String achievementId;

  /// Current progress value.
  final int currentValue;

  /// Target value to unlock.
  final int targetValue;

  /// Whether the achievement is unlocked.
  final bool isUnlocked;

  /// When the achievement was unlocked (null if not unlocked).
  final DateTime? unlockedAt;

  /// Creates an [AchievementProgress].
  const AchievementProgress({
    required this.achievementId,
    required this.currentValue,
    required this.targetValue,
    required this.isUnlocked,
    this.unlockedAt,
  });

  /// Creates an unlocked [AchievementProgress].
  factory AchievementProgress.unlocked({
    required String achievementId,
    required int targetValue,
    required DateTime unlockedAt,
  }) {
    return AchievementProgress(
      achievementId: achievementId,
      currentValue: targetValue,
      targetValue: targetValue,
      isUnlocked: true,
      unlockedAt: unlockedAt,
    );
  }

  /// Creates a locked [AchievementProgress] with progress.
  factory AchievementProgress.inProgress({
    required String achievementId,
    required int currentValue,
    required int targetValue,
  }) {
    return AchievementProgress(
      achievementId: achievementId,
      currentValue: currentValue,
      targetValue: targetValue,
      isUnlocked: false,
    );
  }

  /// Creates a locked [AchievementProgress] with no progress.
  factory AchievementProgress.locked({
    required String achievementId,
    required int targetValue,
  }) {
    return AchievementProgress(
      achievementId: achievementId,
      currentValue: 0,
      targetValue: targetValue,
      isUnlocked: false,
    );
  }

  /// Progress as a percentage (0.0 to 1.0).
  double get percentage {
    if (targetValue <= 0) return isUnlocked ? 1.0 : 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  /// Progress as a percentage (0 to 100).
  int get percentageInt => (percentage * 100).round();

  /// Whether the achievement has any progress.
  bool get hasProgress => currentValue > 0;

  /// Whether the achievement is close to being unlocked (80%+).
  bool get isCloseToUnlock => percentage >= 0.8 && !isUnlocked;

  /// Creates a copy with the given fields replaced.
  AchievementProgress copyWith({
    String? achievementId,
    int? currentValue,
    int? targetValue,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementProgress && achievementId == other.achievementId;

  @override
  int get hashCode => achievementId.hashCode;

  @override
  String toString() =>
      'AchievementProgress(id: $achievementId, $currentValue/$targetValue, unlocked: $isUnlocked)';
}
