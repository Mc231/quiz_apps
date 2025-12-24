/// Data source for achievement database operations.
library;

import '../../storage/database/app_database.dart';
import '../../storage/database/tables/achievements_table.dart';
import '../models/unlocked_achievement.dart';

/// Abstract interface for achievement data operations.
abstract class AchievementDataSource {
  /// Gets all unlocked achievements.
  Future<List<UnlockedAchievement>> getAllUnlocked();

  /// Gets a specific unlocked achievement by ID.
  Future<UnlockedAchievement?> getById(String id);

  /// Gets an unlocked achievement by achievement ID.
  Future<UnlockedAchievement?> getByAchievementId(String achievementId);

  /// Checks if an achievement is unlocked.
  Future<bool> isUnlocked(String achievementId);

  /// Unlocks an achievement.
  Future<void> unlock(UnlockedAchievement achievement);

  /// Marks an achievement as notified.
  Future<void> markAsNotified(String achievementId);

  /// Gets all unnotified achievements.
  Future<List<UnlockedAchievement>> getUnnotified();

  /// Gets the count of unlocked achievements.
  Future<int> getUnlockedCount();

  /// Deletes an unlocked achievement.
  Future<void> delete(String achievementId);

  /// Deletes all unlocked achievements.
  Future<void> deleteAll();
}

/// SQLite implementation of [AchievementDataSource].
class AchievementDataSourceImpl implements AchievementDataSource {
  /// Creates a new [AchievementDataSourceImpl].
  AchievementDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<List<UnlockedAchievement>> getAllUnlocked() async {
    final results = await _database.query(
      unlockedAchievementsTable,
      orderBy: '${UnlockedAchievementsColumns.unlockedAt} DESC',
    );

    return results.map(UnlockedAchievement.fromMap).toList();
  }

  @override
  Future<UnlockedAchievement?> getById(String id) async {
    final results = await _database.query(
      unlockedAchievementsTable,
      where: '${UnlockedAchievementsColumns.id} = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UnlockedAchievement.fromMap(results.first);
  }

  @override
  Future<UnlockedAchievement?> getByAchievementId(String achievementId) async {
    final results = await _database.query(
      unlockedAchievementsTable,
      where: '${UnlockedAchievementsColumns.achievementId} = ?',
      whereArgs: [achievementId],
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UnlockedAchievement.fromMap(results.first);
  }

  @override
  Future<bool> isUnlocked(String achievementId) async {
    final result = await getByAchievementId(achievementId);
    return result != null;
  }

  @override
  Future<void> unlock(UnlockedAchievement achievement) async {
    // Check if already unlocked
    final existing = await getByAchievementId(achievement.achievementId);
    if (existing != null) {
      // Already unlocked, don't insert again
      return;
    }

    await _database.insert(
      unlockedAchievementsTable,
      achievement.toMap(),
    );
  }

  @override
  Future<void> markAsNotified(String achievementId) async {
    await _database.update(
      unlockedAchievementsTable,
      {UnlockedAchievementsColumns.notified: 1},
      where: '${UnlockedAchievementsColumns.achievementId} = ?',
      whereArgs: [achievementId],
    );
  }

  @override
  Future<List<UnlockedAchievement>> getUnnotified() async {
    final results = await _database.query(
      unlockedAchievementsTable,
      where: '${UnlockedAchievementsColumns.notified} = 0',
      orderBy: '${UnlockedAchievementsColumns.unlockedAt} ASC',
    );

    return results.map(UnlockedAchievement.fromMap).toList();
  }

  @override
  Future<int> getUnlockedCount() async {
    final results = await _database.rawQuery(
      'SELECT COUNT(*) as count FROM $unlockedAchievementsTable',
    );

    return results.first['count'] as int;
  }

  @override
  Future<void> delete(String achievementId) async {
    await _database.delete(
      unlockedAchievementsTable,
      where: '${UnlockedAchievementsColumns.achievementId} = ?',
      whereArgs: [achievementId],
    );
  }

  @override
  Future<void> deleteAll() async {
    await _database.delete(unlockedAchievementsTable);
  }
}
