/// Evaluates achievement triggers against context data.
library;

import '../../storage/models/global_statistics.dart';
import '../../storage/models/quiz_session.dart';
import '../models/achievement_trigger.dart';
import '../models/stat_field.dart';
import 'achievement_context.dart';

/// Evaluates achievement triggers to determine if they are satisfied.
///
/// This class contains the core logic for checking each trigger type
/// against the provided context data.
class TriggerEvaluator {
  /// Creates a [TriggerEvaluator].
  const TriggerEvaluator();

  /// Evaluates whether a trigger is satisfied.
  ///
  /// Returns `true` if the trigger conditions are met.
  bool evaluate(AchievementTrigger trigger, AchievementContext context) {
    return switch (trigger) {
      CumulativeTrigger t => _evaluateCumulative(t, context),
      ThresholdTrigger t => _evaluateThreshold(t, context),
      StreakTrigger t => _evaluateStreak(t, context),
      CategoryTrigger t => _evaluateCategory(t, context),
      ChallengeTrigger t => _evaluateChallenge(t, context),
      CompositeTrigger t => _evaluateComposite(t, context),
      CustomTrigger t => _evaluateCustom(t, context),
    };
  }

  /// Gets the current progress value for a trigger.
  ///
  /// Returns the current value that can be compared against the target.
  int getProgress(AchievementTrigger trigger, AchievementContext context) {
    return switch (trigger) {
      CumulativeTrigger t => _getCumulativeProgress(t, context),
      ThresholdTrigger t => _getThresholdProgress(t, context),
      StreakTrigger t => _getStreakProgress(t, context),
      CategoryTrigger t => _getCategoryProgress(t, context),
      ChallengeTrigger t => _getChallengeProgress(t, context),
      CompositeTrigger t => _getCompositeProgress(t, context),
      CustomTrigger t => _getCustomProgress(t, context),
    };
  }

  /// Gets the target value for a trigger.
  ///
  /// Returns the value that must be reached to unlock the achievement.
  int getTarget(AchievementTrigger trigger) {
    return switch (trigger) {
      CumulativeTrigger t => t.target,
      ThresholdTrigger t => t.value.toInt(),
      StreakTrigger t => t.target,
      CategoryTrigger t => t.requiredCount,
      ChallengeTrigger _ => 1,
      CompositeTrigger t => t.triggers.length,
      CustomTrigger t => t.target ?? 1,
    };
  }

  // ===========================================================================
  // Cumulative Trigger
  // ===========================================================================

  bool _evaluateCumulative(CumulativeTrigger trigger, AchievementContext ctx) {
    final value = _getStatValue(trigger.field, ctx.globalStats, ctx.session);
    return value >= trigger.target;
  }

  int _getCumulativeProgress(CumulativeTrigger trigger, AchievementContext ctx) {
    return _getStatValue(trigger.field, ctx.globalStats, ctx.session).toInt();
  }

  // ===========================================================================
  // Threshold Trigger
  // ===========================================================================

  bool _evaluateThreshold(ThresholdTrigger trigger, AchievementContext ctx) {
    // Threshold triggers typically require a session
    if (!ctx.hasSession) return false;

    final value = _getStatValue(trigger.field, ctx.globalStats, ctx.session);
    return _compareWithOperator(value, trigger.value, trigger.operator);
  }

  int _getThresholdProgress(ThresholdTrigger trigger, AchievementContext ctx) {
    final value = _getStatValue(trigger.field, ctx.globalStats, ctx.session);
    return value.toInt();
  }

  bool _compareWithOperator(num value, num target, ThresholdOperator op) {
    return switch (op) {
      ThresholdOperator.greaterOrEqual => value >= target,
      ThresholdOperator.lessOrEqual => value <= target,
      ThresholdOperator.greaterThan => value > target,
      ThresholdOperator.lessThan => value < target,
      ThresholdOperator.equal => value == target,
    };
  }

  // ===========================================================================
  // Streak Trigger
  // ===========================================================================

  bool _evaluateStreak(StreakTrigger trigger, AchievementContext ctx) {
    final streak = trigger.useBestStreak
        ? ctx.globalStats.bestStreak
        : ctx.globalStats.currentStreak;
    return streak >= trigger.target;
  }

  int _getStreakProgress(StreakTrigger trigger, AchievementContext ctx) {
    return trigger.useBestStreak
        ? ctx.globalStats.bestStreak
        : ctx.globalStats.currentStreak;
  }

  // ===========================================================================
  // Category Trigger
  // ===========================================================================

  bool _evaluateCategory(CategoryTrigger trigger, AchievementContext ctx) {
    final data = ctx.getCategoryData(trigger.categoryId);
    if (data == null) return false;

    final completions =
        trigger.requirePerfect ? data.perfectCompletions : data.totalCompletions;
    return completions >= trigger.requiredCount;
  }

  int _getCategoryProgress(CategoryTrigger trigger, AchievementContext ctx) {
    final data = ctx.getCategoryData(trigger.categoryId);
    if (data == null) return 0;

    return trigger.requirePerfect
        ? data.perfectCompletions
        : data.totalCompletions;
  }

  // ===========================================================================
  // Challenge Trigger
  // ===========================================================================

  bool _evaluateChallenge(ChallengeTrigger trigger, AchievementContext ctx) {
    final data = ctx.getChallengeData(trigger.challengeId);
    if (data == null) return false;

    // Check basic completion
    if (data.totalCompletions == 0) return false;

    // Check perfect requirement
    if (trigger.requirePerfect && data.perfectCompletions == 0) {
      return false;
    }

    // Check no lives lost requirement
    if (trigger.requireNoLivesLost && data.noLivesLostCompletions == 0) {
      return false;
    }

    return true;
  }

  int _getChallengeProgress(ChallengeTrigger trigger, AchievementContext ctx) {
    final data = ctx.getChallengeData(trigger.challengeId);
    if (data == null) return 0;

    if (trigger.requirePerfect) {
      return data.perfectCompletions > 0 ? 1 : 0;
    }
    if (trigger.requireNoLivesLost) {
      return data.noLivesLostCompletions > 0 ? 1 : 0;
    }
    return data.totalCompletions > 0 ? 1 : 0;
  }

  // ===========================================================================
  // Composite Trigger
  // ===========================================================================

  bool _evaluateComposite(CompositeTrigger trigger, AchievementContext ctx) {
    // All triggers must be satisfied (AND logic)
    for (final subTrigger in trigger.triggers) {
      if (!evaluate(subTrigger, ctx)) {
        return false;
      }
    }
    return trigger.triggers.isNotEmpty;
  }

  int _getCompositeProgress(CompositeTrigger trigger, AchievementContext ctx) {
    // Count how many sub-triggers are satisfied
    var satisfied = 0;
    for (final subTrigger in trigger.triggers) {
      if (evaluate(subTrigger, ctx)) {
        satisfied++;
      }
    }
    return satisfied;
  }

  // ===========================================================================
  // Custom Trigger
  // ===========================================================================

  bool _evaluateCustom(CustomTrigger trigger, AchievementContext ctx) {
    return trigger.evaluate(ctx.globalStats, ctx.session);
  }

  int _getCustomProgress(CustomTrigger trigger, AchievementContext ctx) {
    if (trigger.getProgress != null) {
      return trigger.getProgress!(ctx.globalStats);
    }
    // If no progress function, return 1 if satisfied, 0 otherwise
    return trigger.evaluate(ctx.globalStats, ctx.session) ? 1 : 0;
  }

  // ===========================================================================
  // Stat Value Extraction
  // ===========================================================================

  /// Gets a statistic value from the appropriate source.
  num _getStatValue(
    StatField field,
    GlobalStatistics stats,
    QuizSession? session,
  ) {
    return switch (field) {
      // Global Statistics - Session Counts
      StatField.totalSessions => stats.totalSessions,
      StatField.totalCompletedSessions => stats.totalCompletedSessions,
      StatField.totalCancelledSessions => stats.totalCancelledSessions,

      // Global Statistics - Question Counts
      StatField.totalQuestionsAnswered => stats.totalQuestionsAnswered,
      StatField.totalCorrectAnswers => stats.totalCorrectAnswers,
      StatField.totalIncorrectAnswers => stats.totalIncorrectAnswers,
      StatField.totalSkippedQuestions => stats.totalSkippedQuestions,

      // Global Statistics - Time
      StatField.totalTimePlayedSeconds => stats.totalTimePlayedSeconds,

      // Global Statistics - Hints
      StatField.totalHints5050Used => stats.totalHints5050Used,
      StatField.totalHintsSkipUsed => stats.totalHintsSkipUsed,

      // Global Statistics - Scores
      StatField.averageScorePercentage => stats.averageScorePercentage,
      StatField.bestScorePercentage => stats.bestScorePercentage,
      StatField.totalPerfectScores => stats.totalPerfectScores,

      // Global Statistics - Streaks
      StatField.currentStreak => stats.currentStreak,
      StatField.bestStreak => stats.bestStreak,
      StatField.consecutiveDaysPlayed => stats.consecutiveDaysPlayed,

      // V2 Statistics
      StatField.sessionsWithScore90Plus => stats.highScore90Count,
      StatField.sessionsWithScore95Plus => stats.highScore95Count,
      StatField.sessionsWithoutHints => stats.sessionsNoHints,
      StatField.quickAnswersCount => stats.quickAnswersCount,
      StatField.consecutivePerfectScores => _getConsecutivePerfectScores(stats),

      // Session-specific fields (require session)
      StatField.sessionScorePercentage =>
        session?.scorePercentage ?? 0,
      StatField.sessionDurationSeconds =>
        session?.durationSeconds ?? 0,
      StatField.sessionLivesUsed =>
        _getSessionLivesUsed(session),
      StatField.sessionHintsUsed =>
        (session?.hintsUsed5050 ?? 0) + (session?.hintsUsedSkip ?? 0),
      StatField.sessionSkippedQuestions =>
        session?.totalSkipped ?? 0,
      StatField.sessionIsPerfect =>
        (session?.scorePercentage ?? 0) >= 100.0 ? 1 : 0,

      // Daily Challenge fields (from GlobalStatistics)
      StatField.totalDailyChallengesCompleted =>
        stats.totalDailyChallengesCompleted,
      StatField.dailyChallengeStreak => stats.dailyChallengeStreak,
      StatField.perfectDailyChallenges => stats.perfectDailyChallenges,
    };
  }

  int _getSessionLivesUsed(QuizSession? session) {
    if (session == null) return 0;
    // Lives used = total incorrect + skipped (depending on mode)
    return session.totalFailed;
  }

  int _getConsecutivePerfectScores(GlobalStatistics stats) {
    return stats.consecutivePerfectScores;
  }
}
