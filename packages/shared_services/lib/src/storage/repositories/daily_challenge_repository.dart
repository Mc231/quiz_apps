/// Repository for daily challenge operations.
///
/// Provides a unified interface for managing daily challenges with
/// caching and reactive updates via Streams.
library;

import 'dart:async';

import '../data_sources/daily_challenge_data_source.dart';
import '../models/daily_challenge.dart';
import '../models/daily_challenge_result.dart';

/// Abstract interface for daily challenge repository operations.
abstract class DailyChallengeRepository {
  // ===========================================================================
  // Challenge Operations
  // ===========================================================================

  /// Gets the challenge for today, creating it if needed.
  ///
  /// [categoryProvider] is called to determine the category if a new
  /// challenge needs to be created.
  Future<DailyChallenge> getTodaysChallenge({
    required Future<String> Function() categoryProvider,
    int questionCount,
    int? timeLimitSeconds,
  });

  /// Gets a challenge by ID.
  Future<DailyChallenge?> getChallengeById(String id);

  /// Gets the challenge for a specific date.
  Future<DailyChallenge?> getChallengeByDate(DateTime date);

  // ===========================================================================
  // Result Operations
  // ===========================================================================

  /// Checks if today's challenge has been completed.
  Future<bool> hasCompletedToday();

  /// Gets the result for today's challenge, if any.
  Future<DailyChallengeResult?> getTodaysResult();

  /// Gets a result by challenge ID.
  Future<DailyChallengeResult?> getResultByChallengeId(String challengeId);

  /// Submits a result for a challenge.
  Future<void> submitResult(DailyChallengeResult result);

  /// Gets challenge history (past results).
  Future<List<DailyChallengeResult>> getHistory({int days});

  /// Gets all results paginated.
  Future<List<DailyChallengeResult>> getAllResults({
    int? limit,
    int? offset,
  });

  // ===========================================================================
  // Statistics
  // ===========================================================================

  /// Gets the count of completed challenges.
  Future<int> getCompletedCount();

  /// Gets the total score across all challenges.
  Future<int> getTotalScore();

  /// Gets the best single-challenge score.
  Future<int> getBestScore();

  /// Gets the average score percentage.
  Future<double> getAverageScorePercentage();

  /// Gets the current daily challenge streak.
  Future<int> getCurrentStreak();

  // ===========================================================================
  // Reactive Updates
  // ===========================================================================

  /// Watches today's challenge status.
  Stream<DailyChallengeStatus> watchTodayStatus();

  // ===========================================================================
  // Cache & Lifecycle
  // ===========================================================================

  /// Clears the cache.
  void clearCache();

  /// Disposes of resources.
  void dispose();
}

/// Status of today's daily challenge.
class DailyChallengeStatus {
  const DailyChallengeStatus({
    required this.challenge,
    this.result,
    required this.isCompleted,
    required this.timeUntilNextChallenge,
  });

  /// Today's challenge.
  final DailyChallenge challenge;

  /// The result if completed.
  final DailyChallengeResult? result;

  /// Whether the challenge has been completed.
  final bool isCompleted;

  /// Time until the next challenge becomes available.
  final Duration timeUntilNextChallenge;
}

/// Implementation of [DailyChallengeRepository].
class DailyChallengeRepositoryImpl implements DailyChallengeRepository {
  /// Creates a [DailyChallengeRepositoryImpl].
  DailyChallengeRepositoryImpl({
    required DailyChallengeDataSource dataSource,
    Duration cacheDuration = const Duration(minutes: 5),
  })  : _dataSource = dataSource,
        _cacheDuration = cacheDuration;

  final DailyChallengeDataSource _dataSource;
  final Duration _cacheDuration;

  // Cache
  _CacheEntry<DailyChallenge>? _todaysChallengeCache;
  _CacheEntry<DailyChallengeResult?>? _todaysResultCache;

  // Stream controller
  final _statusController = StreamController<DailyChallengeStatus>.broadcast();

  // ===========================================================================
  // Challenge Operations
  // ===========================================================================

  @override
  Future<DailyChallenge> getTodaysChallenge({
    required Future<String> Function() categoryProvider,
    int questionCount = 10,
    int? timeLimitSeconds,
  }) async {
    // Check cache first
    if (_todaysChallengeCache != null && !_todaysChallengeCache!.isExpired) {
      final cached = _todaysChallengeCache!.value;
      if (cached.isToday) {
        return cached;
      }
    }

    // Try to get from database
    final today = _normalizeDate(DateTime.now());
    var challenge = await _dataSource.getChallengeByDate(today);

    // Create new challenge if none exists for today
    if (challenge == null) {
      final categoryId = await categoryProvider();
      challenge = DailyChallenge.forToday(
        categoryId: categoryId,
        questionCount: questionCount,
        timeLimitSeconds: timeLimitSeconds,
      );
      await _dataSource.saveChallenge(challenge);
    }

    // Cache and return
    _todaysChallengeCache = _CacheEntry(challenge, _cacheDuration);
    return challenge;
  }

  @override
  Future<DailyChallenge?> getChallengeById(String id) async {
    return _dataSource.getChallengeById(id);
  }

  @override
  Future<DailyChallenge?> getChallengeByDate(DateTime date) async {
    return _dataSource.getChallengeByDate(date);
  }

  // ===========================================================================
  // Result Operations
  // ===========================================================================

  @override
  Future<bool> hasCompletedToday() async {
    final result = await getTodaysResult();
    return result != null;
  }

  @override
  Future<DailyChallengeResult?> getTodaysResult() async {
    // Check cache first
    if (_todaysResultCache != null && !_todaysResultCache!.isExpired) {
      return _todaysResultCache!.value;
    }

    // Get today's challenge ID
    final today = _normalizeDate(DateTime.now());
    final challenge = await _dataSource.getChallengeByDate(today);
    if (challenge == null) {
      _todaysResultCache = _CacheEntry(null, _cacheDuration);
      return null;
    }

    // Get result
    final result = await _dataSource.getResultByChallengeId(challenge.id);
    _todaysResultCache = _CacheEntry(result, _cacheDuration);
    return result;
  }

  @override
  Future<DailyChallengeResult?> getResultByChallengeId(
    String challengeId,
  ) async {
    return _dataSource.getResultByChallengeId(challengeId);
  }

  @override
  Future<void> submitResult(DailyChallengeResult result) async {
    await _dataSource.saveResult(result);

    // Invalidate cache and notify
    _invalidateCacheAndNotify();
  }

  @override
  Future<List<DailyChallengeResult>> getHistory({int days = 30}) async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: days));
    return _dataSource.getResultsInRange(start, end);
  }

  @override
  Future<List<DailyChallengeResult>> getAllResults({
    int? limit,
    int? offset,
  }) async {
    return _dataSource.getAllResults(limit: limit, offset: offset);
  }

  // ===========================================================================
  // Statistics
  // ===========================================================================

  @override
  Future<int> getCompletedCount() async {
    return _dataSource.getCompletedCount();
  }

  @override
  Future<int> getTotalScore() async {
    return _dataSource.getTotalScore();
  }

  @override
  Future<int> getBestScore() async {
    return _dataSource.getBestScore();
  }

  @override
  Future<double> getAverageScorePercentage() async {
    return _dataSource.getAverageScorePercentage();
  }

  @override
  Future<int> getCurrentStreak() async {
    // Get recent results to calculate streak
    final results = await _dataSource.getAllResults(limit: 365);
    if (results.isEmpty) return 0;

    int streak = 0;
    DateTime? expectedDate = _normalizeDate(DateTime.now());

    for (final result in results) {
      final resultDate = _normalizeDate(result.completedAt);

      if (streak == 0) {
        // First result - check if it's today or yesterday
        final difference = expectedDate!.difference(resultDate).inDays;
        if (difference > 1) break; // Gap too large, no streak
        if (difference == 1) {
          // Started streak yesterday
          expectedDate = resultDate;
        }
        streak = 1;
        expectedDate = resultDate.subtract(const Duration(days: 1));
      } else {
        // Check if this result is the expected previous day
        if (resultDate == expectedDate) {
          streak++;
          expectedDate = resultDate.subtract(const Duration(days: 1));
        } else if (resultDate.isBefore(expectedDate!)) {
          // Gap in streak
          break;
        }
        // If result is after expected date, skip (multiple results same day)
      }
    }

    return streak;
  }

  // ===========================================================================
  // Reactive Updates
  // ===========================================================================

  @override
  Stream<DailyChallengeStatus> watchTodayStatus() {
    // Emit initial status
    _emitCurrentStatus();
    return _statusController.stream;
  }

  // ===========================================================================
  // Cache & Lifecycle
  // ===========================================================================

  @override
  void clearCache() {
    _todaysChallengeCache = null;
    _todaysResultCache = null;
  }

  @override
  void dispose() {
    _statusController.close();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Duration _timeUntilMidnight() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  void _invalidateCacheAndNotify() {
    _todaysChallengeCache = null;
    _todaysResultCache = null;

    if (_statusController.hasListener) {
      _emitCurrentStatus();
    }
  }

  Future<void> _emitCurrentStatus() async {
    try {
      final challenge = await _dataSource.getChallengeByDate(
        _normalizeDate(DateTime.now()),
      );
      if (challenge == null) return;

      final result = await _dataSource.getResultByChallengeId(challenge.id);

      if (!_statusController.isClosed) {
        _statusController.add(DailyChallengeStatus(
          challenge: challenge,
          result: result,
          isCompleted: result != null,
          timeUntilNextChallenge: _timeUntilMidnight(),
        ));
      }
    } catch (_) {
      // Ignore errors during status emission
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
