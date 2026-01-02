/// Categories for grouping achievements.
///
/// Achievements are organized into these categories for display
/// and filtering in the achievements screen.
enum AchievementCategory {
  /// First steps achievements (first quiz, first perfect, etc.)
  beginner,

  /// Cumulative progress achievements (complete N quizzes, answer N questions)
  progress,

  /// Score-based achievements (perfect scores, high scores)
  mastery,

  /// Time-based achievements (fast completions, quick answers)
  speed,

  /// Consecutive correct answer achievements
  streak,

  /// Challenge mode achievements (survival, blitz, time attack, etc.)
  challenge,

  /// Time and consistency achievements (play time, daily streaks)
  dedication,

  /// Special gameplay achievements (no hints, flawless, comeback)
  skill,

  /// Daily challenge achievements (devotee, perfect day, early bird)
  dailyChallenge,
}

/// Extension providing category metadata.
extension AchievementCategoryExtension on AchievementCategory {
  /// Display name for the category.
  String get displayName => switch (this) {
        AchievementCategory.beginner => 'Beginner',
        AchievementCategory.progress => 'Progress',
        AchievementCategory.mastery => 'Mastery',
        AchievementCategory.speed => 'Speed',
        AchievementCategory.streak => 'Streak',
        AchievementCategory.challenge => 'Challenge',
        AchievementCategory.dedication => 'Dedication',
        AchievementCategory.skill => 'Skill',
        AchievementCategory.dailyChallenge => 'Daily Challenge',
      };

  /// Icon for the category.
  String get icon => switch (this) {
        AchievementCategory.beginner => '🎯',
        AchievementCategory.progress => '📚',
        AchievementCategory.mastery => '⭐',
        AchievementCategory.speed => '⚡',
        AchievementCategory.streak => '🔥',
        AchievementCategory.challenge => '🏆',
        AchievementCategory.dedication => '📅',
        AchievementCategory.skill => '💎',
        AchievementCategory.dailyChallenge => '📆',
      };

  /// Order for sorting categories in display.
  int get sortOrder => index;
}
