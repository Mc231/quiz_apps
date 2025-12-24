/// High-level service for achievement management.
library;

import 'dart:async';

import '../../storage/data_sources/statistics_data_source.dart';
import '../../storage/models/global_statistics.dart';
import '../../storage/models/quiz_session.dart';
import '../engine/achievement_context.dart';
import '../engine/achievement_engine.dart';
import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../models/achievement_tier.dart';
import '../models/unlocked_achievement.dart';
import '../repositories/achievement_repository.dart';

/// Callback type for providing category completion data.
typedef CategoryDataProvider = Map<String, CategoryCompletionData> Function();

/// Callback type for providing challenge completion data.
typedef ChallengeDataProvider = Map<String, ChallengeCompletionData> Function();

/// High-level service for managing achievements.
///
/// This service provides a simplified API for apps to:
/// - Check achievements after quiz completion
/// - Get achievement progress for UI
/// - Handle achievement notifications
/// - Manage achievement lifecycle
class AchievementService {
  /// Creates an [AchievementService].
  AchievementService({
    required AchievementRepository repository,
    required StatisticsDataSource statisticsDataSource,
    required AchievementEngine engine,
    this.categoryDataProvider,
    this.challengeDataProvider,
  })  : _repository = repository,
        _statisticsDataSource = statisticsDataSource,
        _engine = engine;

  final AchievementRepository _repository;
  final StatisticsDataSource _statisticsDataSource;
  final AchievementEngine _engine;

  /// Optional provider for category completion data.
  CategoryDataProvider? categoryDataProvider;

  /// Optional provider for challenge completion data.
  ChallengeDataProvider? challengeDataProvider;

  /// The list of achievement definitions.
  List<Achievement> _achievements = [];

  /// Stream controller for newly unlocked achievements.
  final _unlockController = StreamController<List<Achievement>>.broadcast();

  /// Stream of newly unlocked achievements.
  ///
  /// Emits a list of achievements each time achievements are unlocked.
  Stream<List<Achievement>> get onAchievementsUnlocked =>
      _unlockController.stream;

  /// Stream of individual unlock events from the repository.
  Stream<UnlockedAchievement> get onUnlockEvent => _repository.unlockEvents;

  /// Initializes the service with achievement definitions.
  ///
  /// Call this once at app startup with all achievement definitions.
  void initialize(List<Achievement> achievements) {
    _achievements = List.unmodifiable(achievements);
    _engine.clearCache();
  }

  /// Checks achievements after a quiz session completes.
  ///
  /// Returns the list of newly unlocked achievements.
  Future<List<Achievement>> checkAfterSession(QuizSession session) async {
    if (_achievements.isEmpty) {
      return [];
    }

    final stats = await _statisticsDataSource.getGlobalStatistics();
    final context = _buildContext(stats, session: session);

    final result = await _engine.checkAfterSession(
      achievements: _achievements,
      context: context,
    );

    if (result.hasNewUnlocks) {
      _unlockController.add(result.newlyUnlocked);
    }

    return result.newlyUnlocked;
  }

  /// Checks all achievements (both session and cumulative).
  ///
  /// Use this for periodic checks or when stats change outside of sessions.
  Future<List<Achievement>> checkAll() async {
    if (_achievements.isEmpty) {
      return [];
    }

    final stats = await _statisticsDataSource.getGlobalStatistics();
    final context = _buildContext(stats);

    final result = await _engine.checkAll(
      achievements: _achievements,
      context: context,
    );

    if (result.hasNewUnlocks) {
      _unlockController.add(result.newlyUnlocked);
    }

    return result.newlyUnlocked;
  }

  /// Gets progress for all achievements.
  Future<List<AchievementProgress>> getAllProgress() async {
    if (_achievements.isEmpty) {
      return [];
    }

    final stats = await _statisticsDataSource.getGlobalStatistics();
    final context = _buildContext(stats);

    return _engine.getAllProgress(
      achievements: _achievements,
      context: context,
    );
  }

  /// Gets progress for a specific achievement.
  Future<AchievementProgress> getProgress(String achievementId) async {
    final achievement = _achievements.firstWhere(
      (a) => a.id == achievementId,
      orElse: () => throw ArgumentError('Achievement not found: $achievementId'),
    );

    final stats = await _statisticsDataSource.getGlobalStatistics();
    final context = _buildContext(stats);

    final unlockedList = await _repository.getUnlockedAchievements();
    final unlockedRecord = unlockedList.where(
      (u) => u.achievementId == achievementId,
    ).firstOrNull;

    return _engine.getProgress(
      achievement: achievement,
      context: context,
      unlockedAt: unlockedRecord?.unlockedAt,
    );
  }

  /// Gets all visible achievements for display.
  ///
  /// Hidden achievements (Epic, Legendary) are filtered based on
  /// visibility rules.
  Future<List<Achievement>> getVisibleAchievements() async {
    if (_achievements.isEmpty) {
      return [];
    }

    final stats = await _statisticsDataSource.getGlobalStatistics();
    final context = _buildContext(stats);
    final unlockedIds = await _repository.getUnlockedAchievementIds();

    return _engine.filterByVisibility(
      achievements: _achievements,
      context: context,
      unlockedIds: unlockedIds,
    );
  }

  /// Gets achievements sorted for display.
  Future<List<Achievement>> getSortedAchievements() async {
    if (_achievements.isEmpty) {
      return [];
    }

    final stats = await _statisticsDataSource.getGlobalStatistics();
    final context = _buildContext(stats);
    final unlockedIds = await _repository.getUnlockedAchievementIds();

    final visible = _engine.filterByVisibility(
      achievements: _achievements,
      context: context,
      unlockedIds: unlockedIds,
    );

    return _engine.sortForDisplay(
      achievements: visible,
      context: context,
      unlockedIds: unlockedIds,
    );
  }

  /// Gets achievements grouped by tier.
  Map<AchievementTier, List<Achievement>> getAchievementsByTier() {
    return _engine.groupByTier(_achievements);
  }

  /// Gets pending achievement notifications.
  ///
  /// Returns achievements that were unlocked but not yet shown to the user.
  Future<List<Achievement>> getPendingNotifications() async {
    final pending = await _repository.getPendingNotifications();

    return pending
        .map((unlocked) => _achievements.firstWhere(
              (a) => a.id == unlocked.achievementId,
              orElse: () => throw StateError(
                  'Achievement definition not found: ${unlocked.achievementId}'),
            ))
        .toList();
  }

  /// Marks an achievement notification as shown.
  Future<void> markNotificationShown(String achievementId) async {
    await _repository.markAsNotified(achievementId);
  }

  /// Marks multiple achievement notifications as shown.
  Future<void> markAllNotificationsShown(List<String> achievementIds) async {
    for (final id in achievementIds) {
      await _repository.markAsNotified(id);
    }
  }

  /// Gets summary statistics for achievements.
  Future<AchievementSummary> getSummary() async {
    final unlockedCount = await _repository.getUnlockedCount();
    final totalPoints = await _repository.getTotalPoints(_achievements);

    return AchievementSummary(
      totalAchievements: _achievements.length,
      unlockedAchievements: unlockedCount,
      totalPoints: totalPoints,
      maxPoints: _achievements.fold(0, (sum, a) => sum + a.points),
    );
  }

  /// Checks if a specific achievement is unlocked.
  Future<bool> isUnlocked(String achievementId) async {
    return _repository.isUnlocked(achievementId);
  }

  /// Gets the count of unlocked achievements.
  Future<int> getUnlockedCount() async {
    return _repository.getUnlockedCount();
  }

  /// Gets total points from unlocked achievements.
  Future<int> getTotalPoints() async {
    return _repository.getTotalPoints(_achievements);
  }

  /// Resets all achievement progress.
  ///
  /// This deletes all unlocked achievements.
  Future<void> resetAll() async {
    await _repository.resetAll();
    _engine.clearCache();
  }

  /// Builds an achievement context from current state.
  AchievementContext _buildContext(
    GlobalStatistics stats, {
    QuizSession? session,
  }) {
    final categoryData = categoryDataProvider?.call() ?? {};
    final challengeData = challengeDataProvider?.call() ?? {};

    if (session != null) {
      return AchievementContext.afterSession(
        globalStats: stats,
        session: session,
        categoryData: categoryData,
        challengeData: challengeData,
      );
    }

    return AchievementContext.forProgress(
      globalStats: stats,
      categoryData: categoryData,
      challengeData: challengeData,
    );
  }

  /// Disposes of resources.
  void dispose() {
    _unlockController.close();
  }
}

/// Summary of achievement progress.
class AchievementSummary {
  /// Creates an [AchievementSummary].
  const AchievementSummary({
    required this.totalAchievements,
    required this.unlockedAchievements,
    required this.totalPoints,
    required this.maxPoints,
  });

  /// Total number of achievement definitions.
  final int totalAchievements;

  /// Number of unlocked achievements.
  final int unlockedAchievements;

  /// Total points earned from unlocked achievements.
  final int totalPoints;

  /// Maximum possible points from all achievements.
  final int maxPoints;

  /// Percentage of achievements unlocked (0.0 to 1.0).
  double get completionPercentage =>
      totalAchievements > 0 ? unlockedAchievements / totalAchievements : 0.0;

  /// Percentage of points earned (0.0 to 1.0).
  double get pointsPercentage =>
      maxPoints > 0 ? totalPoints / maxPoints : 0.0;

  @override
  String toString() => 'AchievementSummary('
      'unlocked: $unlockedAchievements/$totalAchievements, '
      'points: $totalPoints/$maxPoints)';
}
