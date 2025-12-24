import 'package:flutter/material.dart';

/// Achievement tier/rarity levels.
///
/// Each tier has an associated color, icon, points value, and visibility rule.
/// Higher tiers are more difficult to unlock and award more points.
enum AchievementTier {
  /// Bronze tier - easy achievements, always visible.
  common,

  /// Silver tier - moderate effort, always visible.
  uncommon,

  /// Gold tier - significant progress, always visible.
  rare,

  /// Purple tier - major milestone, hidden until unlocked.
  epic,

  /// Diamond tier - exceptional achievement, hidden until unlocked.
  legendary,
}

/// Extension providing tier properties.
extension AchievementTierExtension on AchievementTier {
  /// The display color for this tier.
  Color get color => switch (this) {
        AchievementTier.common => const Color(0xFFCD7F32), // Bronze
        AchievementTier.uncommon => const Color(0xFFC0C0C0), // Silver
        AchievementTier.rare => const Color(0xFFFFD700), // Gold
        AchievementTier.epic => const Color(0xFF9B59B6), // Purple
        AchievementTier.legendary => const Color(0xFF00D9FF), // Diamond
      };

  /// The icon/emoji for this tier.
  String get icon => switch (this) {
        AchievementTier.common => '🥉',
        AchievementTier.uncommon => '🥈',
        AchievementTier.rare => '🥇',
        AchievementTier.epic => '💜',
        AchievementTier.legendary => '💎',
      };

  /// The display label for this tier.
  String get label => switch (this) {
        AchievementTier.common => 'Common',
        AchievementTier.uncommon => 'Uncommon',
        AchievementTier.rare => 'Rare',
        AchievementTier.epic => 'Epic',
        AchievementTier.legendary => 'Legendary',
      };

  /// Points awarded for unlocking an achievement of this tier.
  int get points => switch (this) {
        AchievementTier.common => 10,
        AchievementTier.uncommon => 25,
        AchievementTier.rare => 50,
        AchievementTier.epic => 100,
        AchievementTier.legendary => 250,
      };

  /// Whether achievements of this tier are hidden until unlocked.
  bool get isHidden => switch (this) {
        AchievementTier.common => false,
        AchievementTier.uncommon => false,
        AchievementTier.rare => false,
        AchievementTier.epic => true,
        AchievementTier.legendary => true,
      };

  /// The tier index for sorting (0 = common, 4 = legendary).
  int get sortIndex => index;
}
