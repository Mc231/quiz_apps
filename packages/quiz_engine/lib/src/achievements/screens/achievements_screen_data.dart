import '../widgets/achievement_card.dart';
import '../widgets/achievements_list.dart';

/// Data model for achievements screen.
class AchievementsScreenData {
  /// Creates an [AchievementsScreenData].
  const AchievementsScreenData({
    required this.achievements,
    required this.totalPoints,
  });

  /// Creates empty data for loading states.
  const AchievementsScreenData.empty()
      : achievements = const [],
        totalPoints = 0;

  /// All achievements with their progress.
  final List<AchievementDisplayData> achievements;

  /// Total points earned from unlocked achievements.
  final int totalPoints;

  /// Number of unlocked achievements.
  int get unlockedCount => achievements.where((a) => a.isUnlocked).length;

  /// Total number of achievements.
  int get totalCount => achievements.length;

  /// Points that can still be earned.
  int get remainingPoints {
    return achievements
        .where((a) => !a.isUnlocked)
        .fold(0, (sum, a) => sum + a.achievement.points);
  }

  /// Creates filter counts map.
  Map<AchievementFilter, int> get filterCounts => {
        AchievementFilter.all: achievements.length,
        AchievementFilter.unlocked:
            achievements.where((a) => a.isUnlocked).length,
        AchievementFilter.inProgress: achievements
            .where((a) => !a.isUnlocked && a.progress.hasProgress)
            .length,
        AchievementFilter.locked: achievements
            .where((a) => !a.isUnlocked && !a.progress.hasProgress)
            .length,
      };
}
