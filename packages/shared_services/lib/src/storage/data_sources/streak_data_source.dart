/// Data source for streak database operations.
library;

import '../database/app_database.dart';
import '../database/tables/streak_table.dart';
import '../models/streak_data.dart';

/// Abstract interface for streak data operations.
abstract class StreakDataSource {
  /// Gets the current streak data.
  Future<StreakData> getStreakData();

  /// Updates the streak data.
  Future<void> updateStreakData(StreakData data);

  /// Updates a single streak field.
  Future<void> updateField(String key, dynamic value);

  /// Resets streak to initial state.
  Future<void> resetStreak();

  // Convenience methods

  /// Gets the current streak count.
  Future<int> getCurrentStreak();

  /// Gets the longest streak count.
  Future<int> getLongestStreak();

  /// Gets the last play date.
  Future<DateTime?> getLastPlayDate();

  /// Gets the streak start date.
  Future<DateTime?> getStreakStartDate();

  /// Gets total days played.
  Future<int> getTotalDaysPlayed();

  /// Updates streak values atomically.
  Future<void> updateStreakValues({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastPlayDate,
    required DateTime? streakStartDate,
    required int totalDaysPlayed,
  });
}

/// SQLite implementation of [StreakDataSource].
class StreakDataSourceImpl implements StreakDataSource {
  /// Creates a new [StreakDataSourceImpl].
  StreakDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<StreakData> getStreakData() async {
    final results = await _database.query(
      streakTable,
      where: '${StreakColumns.id} = 1',
      limit: 1,
    );

    if (results.isEmpty) {
      return StreakData.empty();
    }

    return StreakData.fromMap(results.first);
  }

  @override
  Future<void> updateStreakData(StreakData data) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final map = data.toMap();
    map[StreakColumns.updatedAt] = now;

    await _database.update(
      streakTable,
      map,
      where: '${StreakColumns.id} = 1',
    );
  }

  @override
  Future<void> updateField(String key, dynamic value) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.update(
      streakTable,
      {
        key: value,
        StreakColumns.updatedAt: now,
      },
      where: '${StreakColumns.id} = 1',
    );
  }

  @override
  Future<void> resetStreak() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.update(
      streakTable,
      {
        StreakColumns.currentStreak: 0,
        StreakColumns.lastPlayDate: null,
        StreakColumns.streakStartDate: null,
        // Note: longestStreak and totalDaysPlayed are NOT reset
        StreakColumns.updatedAt: now,
      },
      where: '${StreakColumns.id} = 1',
    );
  }

  // ===========================================================================
  // Convenience Methods
  // ===========================================================================

  @override
  Future<int> getCurrentStreak() async {
    final data = await getStreakData();
    return data.currentStreak;
  }

  @override
  Future<int> getLongestStreak() async {
    final data = await getStreakData();
    return data.longestStreak;
  }

  @override
  Future<DateTime?> getLastPlayDate() async {
    final data = await getStreakData();
    return data.lastPlayDate;
  }

  @override
  Future<DateTime?> getStreakStartDate() async {
    final data = await getStreakData();
    return data.streakStartDate;
  }

  @override
  Future<int> getTotalDaysPlayed() async {
    final data = await getStreakData();
    return data.totalDaysPlayed;
  }

  @override
  Future<void> updateStreakValues({
    required int currentStreak,
    required int longestStreak,
    required DateTime lastPlayDate,
    required DateTime? streakStartDate,
    required int totalDaysPlayed,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.update(
      streakTable,
      {
        StreakColumns.currentStreak: currentStreak,
        StreakColumns.longestStreak: longestStreak,
        StreakColumns.lastPlayDate: lastPlayDate.millisecondsSinceEpoch ~/ 1000,
        StreakColumns.streakStartDate: streakStartDate != null
            ? streakStartDate.millisecondsSinceEpoch ~/ 1000
            : null,
        StreakColumns.totalDaysPlayed: totalDaysPlayed,
        StreakColumns.updatedAt: now,
      },
      where: '${StreakColumns.id} = 1',
    );
  }
}
