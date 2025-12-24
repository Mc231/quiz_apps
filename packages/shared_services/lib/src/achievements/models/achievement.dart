import 'package:flutter/widgets.dart';

import 'achievement_tier.dart';
import 'achievement_trigger.dart';

/// A function that returns a localized string given a BuildContext.
typedef LocalizedString = String Function(BuildContext context);

/// Represents an achievement definition.
///
/// Achievements are defined statically in code (not stored in database).
/// Only the unlock status is persisted via [UnlockedAchievement].
///
/// Example:
/// ```dart
/// Achievement(
///   id: 'first_quiz',
///   name: (context) => l10n.achievementFirstQuiz,
///   description: (context) => l10n.achievementFirstQuizDesc,
///   icon: '🎯',
///   tier: AchievementTier.common,
///   trigger: AchievementTrigger.cumulative(
///     field: StatField.totalCompletedSessions,
///     target: 1,
///   ),
/// )
/// ```
class Achievement {
  /// Unique identifier for this achievement.
  final String id;

  /// Localized name of the achievement.
  final LocalizedString name;

  /// Localized description of the achievement.
  final LocalizedString description;

  /// Icon for the achievement (emoji or asset path).
  final String icon;

  /// Rarity tier of the achievement.
  final AchievementTier tier;

  /// The trigger condition for unlocking this achievement.
  final AchievementTrigger trigger;

  /// Optional category for grouping achievements.
  final String? category;

  /// Target value for progressive achievements (e.g., 100 for "Complete 100 quizzes").
  /// If null, defaults to 1 (single unlock).
  final int? target;

  /// Creates an [Achievement].
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.tier,
    required this.trigger,
    this.category,
    this.target,
  });

  /// Points awarded for unlocking this achievement.
  int get points => tier.points;

  /// Whether this achievement is hidden until unlocked.
  bool get isHidden => tier.isHidden;

  /// The target value for progress tracking.
  /// Returns [target] if set, otherwise extracts from trigger if possible.
  int get progressTarget {
    if (target != null) return target!;

    return switch (trigger) {
      CumulativeTrigger(:final target) => target,
      StreakTrigger(:final target) => target,
      CategoryTrigger(:final requiredCount) => requiredCount,
      CustomTrigger(:final target) => target ?? 1,
      _ => 1,
    };
  }

  /// Creates a copy of this achievement with the given fields replaced.
  Achievement copyWith({
    String? id,
    LocalizedString? name,
    LocalizedString? description,
    String? icon,
    AchievementTier? tier,
    AchievementTrigger? trigger,
    String? category,
    int? target,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      tier: tier ?? this.tier,
      trigger: trigger ?? this.trigger,
      category: category ?? this.category,
      target: target ?? this.target,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Achievement && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Achievement(id: $id, tier: ${tier.name})';
}
