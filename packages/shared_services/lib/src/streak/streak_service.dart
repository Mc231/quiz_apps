/// Service for managing user streaks.
///
/// Provides high-level streak operations including status checking,
/// activity recording, and milestone tracking.
library;

import 'dart:async';

import '../storage/models/streak_data.dart';
import '../storage/repositories/streak_repository.dart';
import 'streak_config.dart';
import 'streak_status.dart';

/// Result of recording activity for streak tracking.
class StreakActivityResult {
  /// Creates a [StreakActivityResult].
  const StreakActivityResult({
    required this.previousStreak,
    required this.newStreak,
    required this.isNewDay,
    required this.milestoneReached,
    required this.isNewRecord,
  });

  /// The streak count before recording activity.
  final int previousStreak;

  /// The streak count after recording activity.
  final int newStreak;

  /// Whether this was activity on a new day (not already played today).
  final bool isNewDay;

  /// The milestone reached, if any (e.g., 7, 30, 100).
  final int? milestoneReached;

  /// Whether this creates a new personal best streak.
  final bool isNewRecord;

  /// Whether any streak change occurred.
  bool get hasChange => previousStreak != newStreak;

  /// The change in streak count.
  int get streakChange => newStreak - previousStreak;
}

/// Service for managing daily play streaks.
///
/// Handles streak calculation, status updates, and milestone tracking.
/// Uses timezone-aware date calculations to properly handle day boundaries.
abstract class StreakService {
  /// Gets the current streak count.
  Future<int> getCurrentStreak();

  /// Gets the longest streak ever achieved.
  Future<int> getLongestStreak();

  /// Gets the total days played.
  Future<int> getTotalDaysPlayed();

  /// Gets the complete streak data.
  Future<StreakData> getStreakData();

  /// Records that the user completed a quiz.
  ///
  /// This should be called whenever a quiz is completed.
  /// The service handles determining if this affects the streak.
  ///
  /// Returns a [StreakActivityResult] with details about the update.
  Future<StreakActivityResult> recordActivity();

  /// Gets the current streak status.
  ///
  /// Returns [StreakStatus.active] if played today,
  /// [StreakStatus.atRisk] if not played today but streak is valid,
  /// [StreakStatus.broken] if streak was lost,
  /// [StreakStatus.none] if no streak has been started.
  Future<StreakStatus> getStreakStatus();

  /// Checks if the streak is currently active.
  ///
  /// A streak is active if the user has played today or
  /// if they played yesterday (at risk but not broken).
  Future<bool> isStreakActive();

  /// Gets the number of days until the streak is lost.
  ///
  /// Returns 0 if the user has already played today.
  /// Returns 1 if the user needs to play today to maintain the streak.
  /// Returns null if there is no active streak.
  Future<int?> getDaysUntilStreakLost();

  /// Gets the next milestone to reach.
  ///
  /// Returns null if all milestones have been reached.
  Future<int?> getNextMilestone();

  /// Gets the progress to the next milestone (0.0 to 1.0).
  Future<double> getMilestoneProgress();

  /// Watches streak data for changes.
  Stream<StreakData> watchStreakData();

  /// Resets the current streak (for testing or admin purposes).
  Future<void> resetStreak();

  /// Disposes of resources.
  void dispose();
}

/// Default implementation of [StreakService].
class StreakServiceImpl implements StreakService {
  /// Creates a [StreakServiceImpl].
  ///
  /// [repository] - The streak repository for persistence.
  /// [config] - Configuration for streak behavior.
  /// [clock] - Optional clock function for testing (defaults to DateTime.now).
  StreakServiceImpl({
    required StreakRepository repository,
    StreakConfig config = const StreakConfig(),
    DateTime Function()? clock,
  })  : _repository = repository,
        _config = config,
        _clock = clock ?? DateTime.now;

  final StreakRepository _repository;
  final StreakConfig _config;
  final DateTime Function() _clock;

  @override
  Future<int> getCurrentStreak() async {
    final data = await _repository.getStreakData();
    return _calculateCurrentStreak(data);
  }

  @override
  Future<int> getLongestStreak() async {
    return await _repository.getLongestStreak();
  }

  @override
  Future<int> getTotalDaysPlayed() async {
    return await _repository.getTotalDaysPlayed();
  }

  @override
  Future<StreakData> getStreakData() async {
    return await _repository.getStreakData();
  }

  @override
  Future<StreakActivityResult> recordActivity() async {
    final now = _clock();
    final data = await _repository.getStreakData();
    final previousStreak = _calculateCurrentStreak(data);

    // Check if already played today
    if (data.lastPlayDate != null && _isSameDay(data.lastPlayDate!, now)) {
      // Already played today, no change
      return StreakActivityResult(
        previousStreak: previousStreak,
        newStreak: previousStreak,
        isNewDay: false,
        milestoneReached: null,
        isNewRecord: false,
      );
    }

    // Record the activity
    await _repository.updateStreak(now);

    // Get updated data
    final newData = await _repository.getStreakData();
    final newStreak = newData.currentStreak;

    // Check for milestone
    int? milestoneReached;
    if (_config.isMilestone(newStreak)) {
      milestoneReached = newStreak;
    }

    // Check for new record
    final isNewRecord = newStreak > data.longestStreak;

    return StreakActivityResult(
      previousStreak: previousStreak,
      newStreak: newStreak,
      isNewDay: true,
      milestoneReached: milestoneReached,
      isNewRecord: isNewRecord,
    );
  }

  @override
  Future<StreakStatus> getStreakStatus() async {
    final data = await _repository.getStreakData();
    return _calculateStatus(data);
  }

  @override
  Future<bool> isStreakActive() async {
    final status = await getStreakStatus();
    return status.isActive;
  }

  @override
  Future<int?> getDaysUntilStreakLost() async {
    final data = await _repository.getStreakData();
    final status = _calculateStatus(data);

    switch (status) {
      case StreakStatus.active:
        // Played today, have until end of tomorrow
        return 1;
      case StreakStatus.atRisk:
        // Haven't played today, need to play today
        return 0;
      case StreakStatus.broken:
      case StreakStatus.none:
        // No active streak
        return null;
    }
  }

  @override
  Future<int?> getNextMilestone() async {
    final streak = await getCurrentStreak();
    return _config.getNextMilestone(streak);
  }

  @override
  Future<double> getMilestoneProgress() async {
    final streak = await getCurrentStreak();
    return _config.getMilestoneProgress(streak);
  }

  @override
  Stream<StreakData> watchStreakData() {
    return _repository.watchStreakData();
  }

  @override
  Future<void> resetStreak() async {
    await _repository.resetStreak();
  }

  @override
  void dispose() {
    _repository.dispose();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  /// Calculates the current streak considering if it's still valid.
  int _calculateCurrentStreak(StreakData data) {
    if (data.lastPlayDate == null) return 0;

    final now = _clock();
    final lastPlay = data.lastPlayDate!;
    final effectiveNow = _getEffectiveDate(now);
    final effectiveLastPlay = _getEffectiveDate(lastPlay);

    final daysDifference = effectiveNow.difference(effectiveLastPlay).inDays;

    if (daysDifference <= 1) {
      // Played today or yesterday, streak is valid
      return data.currentStreak;
    } else {
      // Streak is broken
      return 0;
    }
  }

  /// Calculates the streak status.
  StreakStatus _calculateStatus(StreakData data) {
    if (data.lastPlayDate == null) {
      return StreakStatus.none;
    }

    final now = _clock();
    final lastPlay = data.lastPlayDate!;
    final effectiveNow = _getEffectiveDate(now);
    final effectiveLastPlay = _getEffectiveDate(lastPlay);

    final daysDifference = effectiveNow.difference(effectiveLastPlay).inDays;

    if (daysDifference == 0) {
      // Played today
      return StreakStatus.active;
    } else if (daysDifference == 1) {
      // Played yesterday, at risk today
      return StreakStatus.atRisk;
    } else {
      // Streak is broken
      return data.currentStreak > 0 ? StreakStatus.broken : StreakStatus.none;
    }
  }

  /// Gets the effective date for streak calculations.
  ///
  /// Handles grace period by shifting the day boundary.
  DateTime _getEffectiveDate(DateTime dateTime) {
    // Apply grace period - if it's before the grace period hour,
    // consider it as the previous day
    final adjustedTime =
        dateTime.subtract(Duration(hours: _config.gracePeriodHours));

    // Normalize to start of day (midnight)
    return DateTime(adjustedTime.year, adjustedTime.month, adjustedTime.day);
  }

  /// Checks if two dates are the same day.
  bool _isSameDay(DateTime a, DateTime b) {
    final effectiveA = _getEffectiveDate(a);
    final effectiveB = _getEffectiveDate(b);
    return effectiveA == effectiveB;
  }
}
