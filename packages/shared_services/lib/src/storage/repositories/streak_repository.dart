/// Repository for streak tracking operations.
///
/// Provides a unified interface for managing user streaks with
/// caching and reactive updates via Streams.
library;

import 'dart:async';

import '../data_sources/streak_data_source.dart';
import '../models/streak_data.dart';

/// Abstract interface for streak repository operations.
abstract class StreakRepository {
  // ===========================================================================
  // Streak Data Access
  // ===========================================================================

  /// Gets the current streak data.
  Future<StreakData> getStreakData();

  /// Updates streak data after recording activity.
  ///
  /// [playDate] is the date when the user completed a quiz.
  /// This method handles all streak logic internally.
  Future<void> updateStreak(DateTime playDate);

  /// Resets the current streak to zero.
  ///
  /// Note: This only resets [currentStreak] and [streakStartDate].
  /// [longestStreak] and [totalDaysPlayed] are preserved.
  Future<void> resetStreak();

  // ===========================================================================
  // Convenience Getters
  // ===========================================================================

  /// Gets the current streak count.
  Future<int> getCurrentStreak();

  /// Gets the longest streak count.
  Future<int> getLongestStreak();

  /// Gets the last play date.
  Future<DateTime?> getLastPlayDate();

  /// Gets total days played.
  Future<int> getTotalDaysPlayed();

  // ===========================================================================
  // Reactive Updates
  // ===========================================================================

  /// Watches streak data for changes.
  ///
  /// Emits the current value immediately, then emits updates
  /// whenever the streak data changes.
  Stream<StreakData> watchStreakData();

  // ===========================================================================
  // Cache & Lifecycle
  // ===========================================================================

  /// Clears the streak cache.
  void clearCache();

  /// Disposes of resources.
  void dispose();
}

/// Implementation of [StreakRepository].
class StreakRepositoryImpl implements StreakRepository {
  /// Creates a [StreakRepositoryImpl].
  StreakRepositoryImpl({
    required StreakDataSource dataSource,
    Duration cacheDuration = const Duration(minutes: 10),
  })  : _dataSource = dataSource,
        _cacheDuration = cacheDuration;

  final StreakDataSource _dataSource;
  final Duration _cacheDuration;

  // Cache
  _CacheEntry<StreakData>? _streakCache;

  // Stream controller
  final _streakController = StreamController<StreakData>.broadcast();

  // ===========================================================================
  // Streak Data Access
  // ===========================================================================

  @override
  Future<StreakData> getStreakData() async {
    if (_streakCache != null && !_streakCache!.isExpired) {
      return _streakCache!.value;
    }

    final data = await _dataSource.getStreakData();
    _streakCache = _CacheEntry(data, _cacheDuration);

    return data;
  }

  @override
  Future<void> updateStreak(DateTime playDate) async {
    final currentData = await getStreakData();
    final today = _normalizeDate(playDate);
    final lastPlay = currentData.lastPlayDate;

    // Calculate new streak values
    int newStreak;
    DateTime? newStreakStart;
    int newTotalDays;

    if (lastPlay == null) {
      // First time playing
      newStreak = 1;
      newStreakStart = today;
      newTotalDays = 1;
    } else {
      final lastPlayNormalized = _normalizeDate(lastPlay);
      final daysDifference = today.difference(lastPlayNormalized).inDays;

      if (daysDifference == 0) {
        // Same day - no change to streak
        return;
      } else if (daysDifference == 1) {
        // Consecutive day - extend streak
        newStreak = currentData.currentStreak + 1;
        newStreakStart = currentData.streakStartDate;
        newTotalDays = currentData.totalDaysPlayed + 1;
      } else {
        // Gap in days - reset streak
        newStreak = 1;
        newStreakStart = today;
        newTotalDays = currentData.totalDaysPlayed + 1;
      }
    }

    // Update longest streak if current exceeds it
    final newLongest = newStreak > currentData.longestStreak
        ? newStreak
        : currentData.longestStreak;

    // Save updated data
    await _dataSource.updateStreakValues(
      currentStreak: newStreak,
      longestStreak: newLongest,
      lastPlayDate: today,
      streakStartDate: newStreakStart,
      totalDaysPlayed: newTotalDays,
    );

    // Invalidate cache and notify
    _invalidateCacheAndNotify();
  }

  @override
  Future<void> resetStreak() async {
    await _dataSource.resetStreak();
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Convenience Getters
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
  Future<int> getTotalDaysPlayed() async {
    final data = await getStreakData();
    return data.totalDaysPlayed;
  }

  // ===========================================================================
  // Reactive Updates
  // ===========================================================================

  @override
  Stream<StreakData> watchStreakData() {
    // Emit initial value
    getStreakData().then((data) {
      if (!_streakController.isClosed) {
        _streakController.add(data);
      }
    });

    return _streakController.stream;
  }

  // ===========================================================================
  // Cache & Lifecycle
  // ===========================================================================

  @override
  void clearCache() {
    _streakCache = null;
  }

  @override
  void dispose() {
    _streakController.close();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Normalizes a date to midnight (start of day) for comparison.
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  void _invalidateCacheAndNotify() {
    _streakCache = null;

    if (_streakController.hasListener) {
      getStreakData().then((data) {
        if (!_streakController.isClosed) {
          _streakController.add(data);
        }
      });
    }
  }
}

/// Cache entry with expiration.
class _CacheEntry<T> {
  _CacheEntry(this.value, Duration duration)
      : _expiresAt = DateTime.now().add(duration);

  final T value;
  final DateTime _expiresAt;

  bool get isExpired => DateTime.now().isAfter(_expiresAt);
}
