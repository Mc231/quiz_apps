/// Core engine for checking and unlocking achievements.
library;

import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../models/achievement_tier.dart';
import '../repositories/achievement_repository.dart';
import 'achievement_context.dart';
import 'trigger_evaluator.dart';

/// Result of checking achievements.
class AchievementCheckResult {
  /// Creates an [AchievementCheckResult].
  const AchievementCheckResult({
    required this.newlyUnlocked,
    required this.alreadyUnlocked,
    required this.stillLocked,
  });

  /// Achievements that were just unlocked.
  final List<Achievement> newlyUnlocked;

  /// Achievements that were already unlocked before this check.
  final List<Achievement> alreadyUnlocked;

  /// Achievements that are still locked after this check.
  final List<Achievement> stillLocked;

  /// Whether any achievements were newly unlocked.
  bool get hasNewUnlocks => newlyUnlocked.isNotEmpty;

  /// Total points earned from newly unlocked achievements.
  int get pointsEarned =>
      newlyUnlocked.fold(0, (sum, a) => sum + a.points);

  @override
  String toString() => 'AchievementCheckResult('
      'newlyUnlocked: ${newlyUnlocked.length}, '
      'alreadyUnlocked: ${alreadyUnlocked.length}, '
      'stillLocked: ${stillLocked.length})';
}

/// Core engine for evaluating and unlocking achievements.
///
/// The engine checks achievement triggers against context data and
/// unlocks achievements when conditions are met.
class AchievementEngine {
  /// Creates an [AchievementEngine].
  AchievementEngine({
    required AchievementRepository repository,
    TriggerEvaluator? evaluator,
  })  : _repository = repository,
        _evaluator = evaluator ?? const TriggerEvaluator();

  final AchievementRepository _repository;
  final TriggerEvaluator _evaluator;

  /// Cache of unlocked achievement IDs.
  Set<String>? _unlockedCache;

  /// Checks all achievements against the given context.
  ///
  /// Returns achievements that were newly unlocked, already unlocked,
  /// and still locked.
  Future<AchievementCheckResult> checkAll({
    required List<Achievement> achievements,
    required AchievementContext context,
  }) async {
    // Refresh cache
    _unlockedCache = await _repository.getUnlockedAchievementIds();

    final newlyUnlocked = <Achievement>[];
    final alreadyUnlocked = <Achievement>[];
    final stillLocked = <Achievement>[];

    for (final achievement in achievements) {
      if (_unlockedCache!.contains(achievement.id)) {
        alreadyUnlocked.add(achievement);
        continue;
      }

      final isSatisfied = _evaluator.evaluate(achievement.trigger, context);
      if (isSatisfied) {
        // Unlock the achievement
        final wasUnlocked = await _repository.unlock(
          achievementId: achievement.id,
          progress: _evaluator.getTarget(achievement.trigger),
          points: achievement.points,
        );

        if (wasUnlocked) {
          newlyUnlocked.add(achievement);
          _unlockedCache!.add(achievement.id);
        } else {
          // Race condition - already unlocked
          alreadyUnlocked.add(achievement);
        }
      } else {
        stillLocked.add(achievement);
      }
    }

    return AchievementCheckResult(
      newlyUnlocked: newlyUnlocked,
      alreadyUnlocked: alreadyUnlocked,
      stillLocked: stillLocked,
    );
  }

  /// Checks only session-related achievements.
  ///
  /// This should be called after a quiz session completes.
  /// It only checks achievements that can be triggered by session data.
  Future<AchievementCheckResult> checkAfterSession({
    required List<Achievement> achievements,
    required AchievementContext context,
  }) async {
    // Session must be present
    if (!context.hasSession) {
      return const AchievementCheckResult(
        newlyUnlocked: [],
        alreadyUnlocked: [],
        stillLocked: [],
      );
    }

    // Check all achievements - the evaluator will handle
    // which triggers need session data
    return checkAll(achievements: achievements, context: context);
  }

  /// Gets progress for a specific achievement.
  AchievementProgress getProgress({
    required Achievement achievement,
    required AchievementContext context,
    DateTime? unlockedAt,
  }) {
    final target = _evaluator.getTarget(achievement.trigger);
    final current = _evaluator.getProgress(achievement.trigger, context);

    // Check if unlocked
    final isUnlocked = unlockedAt != null ||
        (_unlockedCache?.contains(achievement.id) ?? false);

    if (isUnlocked) {
      return AchievementProgress.unlocked(
        achievementId: achievement.id,
        targetValue: target,
        unlockedAt: unlockedAt ?? DateTime.now(),
      );
    }

    return AchievementProgress.inProgress(
      achievementId: achievement.id,
      currentValue: current,
      targetValue: target,
    );
  }

  /// Gets progress for all achievements.
  Future<List<AchievementProgress>> getAllProgress({
    required List<Achievement> achievements,
    required AchievementContext context,
  }) async {
    // Get unlocked achievements with their unlock times
    final unlockedList = await _repository.getUnlockedAchievements();
    final unlockedMap = <String, DateTime>{};
    for (final u in unlockedList) {
      unlockedMap[u.achievementId] = u.unlockedAt;
    }

    return achievements.map((achievement) {
      return getProgress(
        achievement: achievement,
        context: context,
        unlockedAt: unlockedMap[achievement.id],
      );
    }).toList();
  }

  /// Filters achievements by visibility rules.
  ///
  /// Hidden achievements (Epic, Legendary) are only shown if:
  /// - They are unlocked, OR
  /// - They have some progress (> 0%)
  List<Achievement> filterByVisibility({
    required List<Achievement> achievements,
    required AchievementContext context,
    Set<String>? unlockedIds,
  }) {
    final unlocked = unlockedIds ?? _unlockedCache ?? {};

    return achievements.where((achievement) {
      // Always show if unlocked
      if (unlocked.contains(achievement.id)) {
        return true;
      }

      // Hidden tiers are only shown if they have progress
      if (achievement.tier.isHidden) {
        final progress = _evaluator.getProgress(achievement.trigger, context);
        return progress > 0;
      }

      // Non-hidden tiers are always shown
      return true;
    }).toList();
  }

  /// Groups achievements by their tier.
  Map<AchievementTier, List<Achievement>> groupByTier(
    List<Achievement> achievements,
  ) {
    final grouped = <AchievementTier, List<Achievement>>{};
    for (final tier in AchievementTier.values) {
      grouped[tier] = [];
    }
    for (final achievement in achievements) {
      grouped[achievement.tier]!.add(achievement);
    }
    return grouped;
  }

  /// Sorts achievements for display.
  ///
  /// Unlocked achievements first, then by progress, then by tier.
  List<Achievement> sortForDisplay({
    required List<Achievement> achievements,
    required AchievementContext context,
    Set<String>? unlockedIds,
  }) {
    final unlocked = unlockedIds ?? _unlockedCache ?? {};

    return List.from(achievements)
      ..sort((a, b) {
        final aUnlocked = unlocked.contains(a.id);
        final bUnlocked = unlocked.contains(b.id);

        // Unlocked first
        if (aUnlocked && !bUnlocked) return -1;
        if (!aUnlocked && bUnlocked) return 1;

        // If both locked, sort by progress (higher first)
        if (!aUnlocked && !bUnlocked) {
          final aProgress = _evaluator.getProgress(a.trigger, context);
          final bProgress = _evaluator.getProgress(b.trigger, context);
          final aTarget = _evaluator.getTarget(a.trigger);
          final bTarget = _evaluator.getTarget(b.trigger);
          final aPercent = aTarget > 0 ? aProgress / aTarget : 0;
          final bPercent = bTarget > 0 ? bProgress / bTarget : 0;

          if (aPercent != bPercent) {
            return bPercent.compareTo(aPercent); // Higher progress first
          }
        }

        // Finally sort by tier (lower tier first = easier achievements first)
        return a.tier.sortIndex.compareTo(b.tier.sortIndex);
      });
  }

  /// Clears the unlocked cache.
  ///
  /// Call this when you need to refresh the cache from the repository.
  void clearCache() {
    _unlockedCache = null;
  }
}
