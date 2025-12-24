/// Repository for achievement operations.
library;

import 'dart:async';

import '../../storage/data_sources/statistics_data_source.dart';
import '../data_sources/achievement_data_source.dart';
import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../models/unlocked_achievement.dart';

/// Abstract interface for achievement repository operations.
abstract class AchievementRepository {
  /// Gets all unlocked achievements.
  Future<List<UnlockedAchievement>> getUnlockedAchievements();

  /// Gets unlocked achievement IDs as a Set for quick lookup.
  Future<Set<String>> getUnlockedAchievementIds();

  /// Checks if an achievement is unlocked.
  Future<bool> isUnlocked(String achievementId);

  /// Unlocks an achievement.
  ///
  /// Returns `true` if the achievement was newly unlocked,
  /// `false` if it was already unlocked.
  Future<bool> unlock({
    required String achievementId,
    required int progress,
    required int points,
  });

  /// Marks an achievement notification as shown.
  Future<void> markAsNotified(String achievementId);

  /// Gets all achievements that need notification.
  Future<List<UnlockedAchievement>> getPendingNotifications();

  /// Gets the total count of unlocked achievements.
  Future<int> getUnlockedCount();

  /// Gets the total points from all unlocked achievements.
  ///
  /// Requires the achievement definitions to calculate points.
  Future<int> getTotalPoints(List<Achievement> definitions);

  /// Gets progress for all achievements.
  ///
  /// Combines unlocked status with achievement definitions.
  Future<List<AchievementProgress>> getProgressForAll(
    List<Achievement> definitions,
  );

  /// Stream of achievement unlock events.
  Stream<UnlockedAchievement> get unlockEvents;

  /// Resets all achievement progress (deletes all unlocked achievements).
  Future<void> resetAll();
}

/// Implementation of [AchievementRepository].
class AchievementRepositoryImpl implements AchievementRepository {
  /// Creates a new [AchievementRepositoryImpl].
  AchievementRepositoryImpl({
    required AchievementDataSource dataSource,
    required StatisticsDataSource statisticsDataSource,
  })  : _dataSource = dataSource,
        _statisticsDataSource = statisticsDataSource;

  final AchievementDataSource _dataSource;
  final StatisticsDataSource _statisticsDataSource;

  final _unlockController = StreamController<UnlockedAchievement>.broadcast();

  @override
  Stream<UnlockedAchievement> get unlockEvents => _unlockController.stream;

  @override
  Future<List<UnlockedAchievement>> getUnlockedAchievements() async {
    return _dataSource.getAllUnlocked();
  }

  @override
  Future<Set<String>> getUnlockedAchievementIds() async {
    final unlocked = await _dataSource.getAllUnlocked();
    return unlocked.map((a) => a.achievementId).toSet();
  }

  @override
  Future<bool> isUnlocked(String achievementId) async {
    return _dataSource.isUnlocked(achievementId);
  }

  @override
  Future<bool> unlock({
    required String achievementId,
    required int progress,
    required int points,
  }) async {
    // Check if already unlocked
    final alreadyUnlocked = await _dataSource.isUnlocked(achievementId);
    if (alreadyUnlocked) {
      return false;
    }

    // Create the unlock record
    final unlocked = UnlockedAchievement.create(
      id: _generateId(),
      achievementId: achievementId,
      progress: progress,
    );

    // Save to database
    await _dataSource.unlock(unlocked);

    // Update cached stats in global statistics
    final count = await _dataSource.getUnlockedCount();
    final stats = await _statisticsDataSource.getGlobalStatistics();
    await _statisticsDataSource.updateAchievementStats(
      totalUnlocked: count,
      totalPoints: stats.totalAchievementPoints + points,
    );

    // Emit unlock event
    _unlockController.add(unlocked);

    return true;
  }

  String _generateId() {
    return 'ach_${DateTime.now().millisecondsSinceEpoch}_${_randomSuffix()}';
  }

  String _randomSuffix() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = DateTime.now().microsecond;
    return String.fromCharCodes(
      List.generate(6, (i) => chars.codeUnitAt((random + i * 7) % chars.length)),
    );
  }

  @override
  Future<void> markAsNotified(String achievementId) async {
    await _dataSource.markAsNotified(achievementId);
  }

  @override
  Future<List<UnlockedAchievement>> getPendingNotifications() async {
    return _dataSource.getUnnotified();
  }

  @override
  Future<int> getUnlockedCount() async {
    return _dataSource.getUnlockedCount();
  }

  @override
  Future<int> getTotalPoints(List<Achievement> definitions) async {
    final unlockedIds = await getUnlockedAchievementIds();

    var totalPoints = 0;
    for (final achievement in definitions) {
      if (unlockedIds.contains(achievement.id)) {
        totalPoints += achievement.points;
      }
    }

    return totalPoints;
  }

  @override
  Future<List<AchievementProgress>> getProgressForAll(
    List<Achievement> definitions,
  ) async {
    final unlockedMap = <String, UnlockedAchievement>{};
    final unlocked = await _dataSource.getAllUnlocked();
    for (final u in unlocked) {
      unlockedMap[u.achievementId] = u;
    }

    return definitions.map((achievement) {
      final unlockedRecord = unlockedMap[achievement.id];
      if (unlockedRecord != null) {
        return AchievementProgress.unlocked(
          achievementId: achievement.id,
          targetValue: achievement.progressTarget,
          unlockedAt: unlockedRecord.unlockedAt,
        );
      } else {
        // For locked achievements, progress would need to be computed
        // from statistics. This will be done by the AchievementEngine.
        return AchievementProgress.locked(
          achievementId: achievement.id,
          targetValue: achievement.progressTarget,
        );
      }
    }).toList();
  }

  @override
  Future<void> resetAll() async {
    await _dataSource.deleteAll();

    // Reset cached stats
    await _statisticsDataSource.updateAchievementStats(
      totalUnlocked: 0,
      totalPoints: 0,
    );
  }

  /// Disposes of resources.
  void dispose() {
    _unlockController.close();
  }
}
