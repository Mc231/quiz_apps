import '../../storage/models/global_statistics.dart';
import '../../storage/models/quiz_session.dart';
import 'stat_field.dart';

/// Base sealed class for achievement trigger conditions.
///
/// Each trigger type defines how to check if an achievement should be unlocked.
/// Use factory methods to create specific trigger types.
sealed class AchievementTrigger {
  const AchievementTrigger();

  /// Cumulative trigger: total count reaches target.
  /// Example: "Complete 100 quizzes"
  factory AchievementTrigger.cumulative({
    required StatField field,
    required int target,
  }) = CumulativeTrigger;

  /// Threshold trigger: single session meets condition.
  /// Example: "Score 90%+"
  factory AchievementTrigger.threshold({
    required StatField field,
    required num value,
    ThresholdOperator operator,
  }) = ThresholdTrigger;

  /// Streak trigger: consecutive count reaches target.
  /// Example: "10 correct answers in a row"
  factory AchievementTrigger.streak({
    required int target,
    bool useBestStreak,
  }) = StreakTrigger;

  /// Category trigger: complete specific category.
  /// Example: "Complete Europe category"
  factory AchievementTrigger.category({
    required String categoryId,
    bool requirePerfect,
    int requiredCount,
  }) = CategoryTrigger;

  /// Challenge trigger: complete specific challenge mode.
  /// Example: "Complete Survival mode"
  factory AchievementTrigger.challenge({
    required String challengeId,
    bool requirePerfect,
    bool requireNoLivesLost,
  }) = ChallengeTrigger;

  /// Composite trigger: multiple conditions (AND logic).
  /// Example: "Perfect score + no hints"
  factory AchievementTrigger.composite({
    required List<AchievementTrigger> triggers,
  }) = CompositeTrigger;

  /// Custom trigger: app-defined evaluation function.
  /// Example: Complex conditions not covered by other triggers
  factory AchievementTrigger.custom({
    required bool Function(GlobalStatistics stats, QuizSession? session)
        evaluate,
    int Function(GlobalStatistics stats)? getProgress,
    int? target,
  }) = CustomTrigger;
}

/// Operators for threshold comparisons.
enum ThresholdOperator {
  /// Greater than or equal to.
  greaterOrEqual,

  /// Less than or equal to.
  lessOrEqual,

  /// Greater than.
  greaterThan,

  /// Less than.
  lessThan,

  /// Equal to.
  equal,
}

/// Trigger that checks if a cumulative stat reaches a target.
///
/// Used for achievements like "Complete 100 quizzes" or "Answer 1000 questions".
class CumulativeTrigger extends AchievementTrigger {
  /// The statistic field to check.
  final StatField field;

  /// The target value to reach.
  final int target;

  const CumulativeTrigger({
    required this.field,
    required this.target,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CumulativeTrigger &&
          field == other.field &&
          target == other.target;

  @override
  int get hashCode => Object.hash(field, target);

  @override
  String toString() => 'CumulativeTrigger(field: $field, target: $target)';
}

/// Trigger that checks if a value meets a threshold condition.
///
/// Used for achievements like "Score 90%+" or "Complete in under 60 seconds".
class ThresholdTrigger extends AchievementTrigger {
  /// The statistic field to check.
  final StatField field;

  /// The threshold value.
  final num value;

  /// The comparison operator.
  final ThresholdOperator operator;

  const ThresholdTrigger({
    required this.field,
    required this.value,
    this.operator = ThresholdOperator.greaterOrEqual,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThresholdTrigger &&
          field == other.field &&
          value == other.value &&
          operator == other.operator;

  @override
  int get hashCode => Object.hash(field, value, operator);

  @override
  String toString() =>
      'ThresholdTrigger(field: $field, operator: $operator, value: $value)';
}

/// Trigger that checks if a streak reaches a target.
///
/// Used for achievements like "10 correct in a row" or "Best streak of 50".
class StreakTrigger extends AchievementTrigger {
  /// The target streak count.
  final int target;

  /// Whether to use best streak ever (true) or current streak (false).
  final bool useBestStreak;

  const StreakTrigger({
    required this.target,
    this.useBestStreak = true,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StreakTrigger &&
          target == other.target &&
          useBestStreak == other.useBestStreak;

  @override
  int get hashCode => Object.hash(target, useBestStreak);

  @override
  String toString() =>
      'StreakTrigger(target: $target, useBestStreak: $useBestStreak)';
}

/// Trigger that checks if a specific category was completed.
///
/// Used for achievements like "Complete Europe" or "Get 5 perfect scores in Asia".
class CategoryTrigger extends AchievementTrigger {
  /// The category ID to check.
  final String categoryId;

  /// Whether a perfect score is required.
  final bool requirePerfect;

  /// Number of times the category must be completed (default 1).
  final int requiredCount;

  const CategoryTrigger({
    required this.categoryId,
    this.requirePerfect = false,
    this.requiredCount = 1,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryTrigger &&
          categoryId == other.categoryId &&
          requirePerfect == other.requirePerfect &&
          requiredCount == other.requiredCount;

  @override
  int get hashCode => Object.hash(categoryId, requirePerfect, requiredCount);

  @override
  String toString() =>
      'CategoryTrigger(categoryId: $categoryId, requirePerfect: $requirePerfect, requiredCount: $requiredCount)';
}

/// Trigger that checks if a specific challenge mode was completed.
///
/// Used for achievements like "Complete Survival" or "Complete Blitz with perfect".
class ChallengeTrigger extends AchievementTrigger {
  /// The challenge mode ID to check.
  final String challengeId;

  /// Whether a perfect score is required.
  final bool requirePerfect;

  /// Whether completion without losing lives is required.
  final bool requireNoLivesLost;

  const ChallengeTrigger({
    required this.challengeId,
    this.requirePerfect = false,
    this.requireNoLivesLost = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChallengeTrigger &&
          challengeId == other.challengeId &&
          requirePerfect == other.requirePerfect &&
          requireNoLivesLost == other.requireNoLivesLost;

  @override
  int get hashCode =>
      Object.hash(challengeId, requirePerfect, requireNoLivesLost);

  @override
  String toString() =>
      'ChallengeTrigger(challengeId: $challengeId, requirePerfect: $requirePerfect, requireNoLivesLost: $requireNoLivesLost)';
}

/// Trigger that combines multiple triggers with AND logic.
///
/// Used for achievements like "Perfect score + no hints + no lives lost".
class CompositeTrigger extends AchievementTrigger {
  /// The list of triggers that must all be satisfied.
  final List<AchievementTrigger> triggers;

  const CompositeTrigger({
    required this.triggers,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompositeTrigger && _listEquals(triggers, other.triggers);

  @override
  int get hashCode => Object.hashAll(triggers);

  @override
  String toString() => 'CompositeTrigger(triggers: $triggers)';

  bool _listEquals(List<AchievementTrigger> a, List<AchievementTrigger> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Trigger with custom evaluation logic.
///
/// Used for complex achievements that don't fit other trigger types.
class CustomTrigger extends AchievementTrigger {
  /// Function to evaluate if the achievement is unlocked.
  final bool Function(GlobalStatistics stats, QuizSession? session) evaluate;

  /// Optional function to get current progress.
  final int Function(GlobalStatistics stats)? getProgress;

  /// Optional target value for progress display.
  final int? target;

  const CustomTrigger({
    required this.evaluate,
    this.getProgress,
    this.target,
  });

  @override
  String toString() => 'CustomTrigger(target: $target)';
}
