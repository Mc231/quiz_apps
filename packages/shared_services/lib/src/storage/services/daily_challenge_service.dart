/// Service for managing daily challenges.
///
/// Provides a high-level API for the UI to interact with daily challenges,
/// handling challenge generation, result submission, and statistics.
library;

import 'dart:async';
import 'dart:math';

import '../models/daily_challenge.dart';
import '../models/daily_challenge_result.dart';
import '../repositories/daily_challenge_repository.dart';

/// Configuration for daily challenge bonuses.
class DailyChallengeConfig {
  const DailyChallengeConfig({
    this.basePointsPerQuestion = 100,
    this.streakBonusPerDay = 10,
    this.maxStreakBonus = 100,
    this.timeBonusThresholdSeconds = 60,
    this.timeBonusPerSecond = 2,
    this.maxTimeBonus = 50,
    this.perfectScoreMultiplier = 1.5,
  });

  /// Base points awarded per correct answer.
  final int basePointsPerQuestion;

  /// Bonus points per day of streak.
  final int streakBonusPerDay;

  /// Maximum streak bonus.
  final int maxStreakBonus;

  /// Time threshold (seconds) under which time bonus is awarded.
  final int timeBonusThresholdSeconds;

  /// Bonus points per second under threshold.
  final int timeBonusPerSecond;

  /// Maximum time bonus.
  final int maxTimeBonus;

  /// Score multiplier for perfect scores.
  final double perfectScoreMultiplier;
}

/// Category rotation strategy for daily challenges.
abstract class CategoryRotationStrategy {
  /// Returns the category ID for a given date.
  String getCategoryForDate(DateTime date, List<String> availableCategories);
}

/// Random category selection based on date seed.
class RandomCategoryRotation implements CategoryRotationStrategy {
  @override
  String getCategoryForDate(DateTime date, List<String> availableCategories) {
    if (availableCategories.isEmpty) {
      throw ArgumentError('availableCategories cannot be empty');
    }
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final random = Random(seed);
    return availableCategories[random.nextInt(availableCategories.length)];
  }
}

/// Sequential category rotation (cycles through categories).
class SequentialCategoryRotation implements CategoryRotationStrategy {
  @override
  String getCategoryForDate(DateTime date, List<String> availableCategories) {
    if (availableCategories.isEmpty) {
      throw ArgumentError('availableCategories cannot be empty');
    }
    // Days since epoch
    final daysSinceEpoch = date.millisecondsSinceEpoch ~/ 86400000;
    return availableCategories[daysSinceEpoch % availableCategories.length];
  }
}

/// Service for managing daily challenges.
abstract class DailyChallengeService {
  /// Gets today's challenge.
  Future<DailyChallenge> getTodaysChallenge();

  /// Checks if today's challenge has been completed.
  Future<bool> hasCompletedToday();

  /// Gets the result for today's challenge.
  Future<DailyChallengeResult?> getTodaysResult();

  /// Submits a result for a challenge.
  ///
  /// Returns the result with calculated bonuses.
  Future<DailyChallengeResult> submitResult({
    required String challengeId,
    required int correctCount,
    required int totalQuestions,
    required int completionTimeSeconds,
  });

  /// Gets the challenge history.
  Future<List<DailyChallengeResult>> getHistory({int days});

  /// Gets daily challenge statistics.
  Future<DailyChallengeStats> getStats();

  /// Watches today's challenge status.
  Stream<DailyChallengeStatus> watchTodayStatus();

  /// Gets time until next challenge.
  Duration getTimeUntilNextChallenge();

  /// Disposes of resources.
  void dispose();
}

/// Statistics for daily challenges.
class DailyChallengeStats {
  const DailyChallengeStats({
    required this.completedCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalScore,
    required this.bestScore,
    required this.averageScorePercentage,
    required this.perfectCount,
  });

  /// Total completed challenges.
  final int completedCount;

  /// Current daily streak.
  final int currentStreak;

  /// Longest daily streak achieved.
  final int longestStreak;

  /// Total score across all challenges.
  final int totalScore;

  /// Best single-challenge score.
  final int bestScore;

  /// Average score percentage.
  final double averageScorePercentage;

  /// Number of perfect scores.
  final int perfectCount;
}

/// Implementation of [DailyChallengeService].
class DailyChallengeServiceImpl implements DailyChallengeService {
  /// Creates a [DailyChallengeServiceImpl].
  DailyChallengeServiceImpl({
    required DailyChallengeRepository repository,
    required List<String> availableCategories,
    CategoryRotationStrategy? rotationStrategy,
    DailyChallengeConfig config = const DailyChallengeConfig(),
    int questionCount = 10,
    int? timeLimitSeconds,
  })  : _repository = repository,
        _availableCategories = availableCategories,
        _rotationStrategy = rotationStrategy ?? RandomCategoryRotation(),
        _config = config,
        _questionCount = questionCount,
        _timeLimitSeconds = timeLimitSeconds;

  final DailyChallengeRepository _repository;
  final List<String> _availableCategories;
  final CategoryRotationStrategy _rotationStrategy;
  final DailyChallengeConfig _config;
  final int _questionCount;
  final int? _timeLimitSeconds;

  // Track longest streak locally (could also be stored in repository)
  int _longestStreak = 0;
  int _perfectCount = 0;
  bool _statsLoaded = false;

  @override
  Future<DailyChallenge> getTodaysChallenge() async {
    return _repository.getTodaysChallenge(
      categoryProvider: () async {
        final today = DateTime.now();
        return _rotationStrategy.getCategoryForDate(
          today,
          _availableCategories,
        );
      },
      questionCount: _questionCount,
      timeLimitSeconds: _timeLimitSeconds,
    );
  }

  @override
  Future<bool> hasCompletedToday() async {
    return _repository.hasCompletedToday();
  }

  @override
  Future<DailyChallengeResult?> getTodaysResult() async {
    return _repository.getTodaysResult();
  }

  @override
  Future<DailyChallengeResult> submitResult({
    required String challengeId,
    required int correctCount,
    required int totalQuestions,
    required int completionTimeSeconds,
  }) async {
    // Calculate bonuses
    final currentStreak = await _repository.getCurrentStreak();
    final streakBonus = _calculateStreakBonus(currentStreak);
    final timeBonus = _calculateTimeBonus(completionTimeSeconds);

    // Calculate base score
    var baseScore = correctCount * _config.basePointsPerQuestion;

    // Apply perfect score multiplier
    if (correctCount == totalQuestions) {
      baseScore = (baseScore * _config.perfectScoreMultiplier).round();
    }

    final totalScore = baseScore + streakBonus + timeBonus;

    // Create and save result
    final result = DailyChallengeResult.create(
      challengeId: challengeId,
      score: totalScore,
      correctCount: correctCount,
      totalQuestions: totalQuestions,
      completionTimeSeconds: completionTimeSeconds,
      streakBonus: streakBonus,
      timeBonus: timeBonus,
    );

    await _repository.submitResult(result);

    // Update local stats
    if (result.isPerfectScore) {
      _perfectCount++;
    }
    final newStreak = currentStreak + 1;
    if (newStreak > _longestStreak) {
      _longestStreak = newStreak;
    }

    return result;
  }

  @override
  Future<List<DailyChallengeResult>> getHistory({int days = 30}) async {
    return _repository.getHistory(days: days);
  }

  @override
  Future<DailyChallengeStats> getStats() async {
    if (!_statsLoaded) {
      await _loadStats();
    }

    final completedCount = await _repository.getCompletedCount();
    final currentStreak = await _repository.getCurrentStreak();
    final totalScore = await _repository.getTotalScore();
    final bestScore = await _repository.getBestScore();
    final averageScore = await _repository.getAverageScorePercentage();

    return DailyChallengeStats(
      completedCount: completedCount,
      currentStreak: currentStreak,
      longestStreak: _longestStreak,
      totalScore: totalScore,
      bestScore: bestScore,
      averageScorePercentage: averageScore,
      perfectCount: _perfectCount,
    );
  }

  @override
  Stream<DailyChallengeStatus> watchTodayStatus() {
    return _repository.watchTodayStatus();
  }

  @override
  Duration getTimeUntilNextChallenge() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow.difference(now);
  }

  @override
  void dispose() {
    _repository.dispose();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  int _calculateStreakBonus(int streak) {
    final bonus = streak * _config.streakBonusPerDay;
    return bonus.clamp(0, _config.maxStreakBonus);
  }

  int _calculateTimeBonus(int completionTimeSeconds) {
    if (completionTimeSeconds >= _config.timeBonusThresholdSeconds) {
      return 0;
    }
    final secondsUnderThreshold =
        _config.timeBonusThresholdSeconds - completionTimeSeconds;
    final bonus = secondsUnderThreshold * _config.timeBonusPerSecond;
    return bonus.clamp(0, _config.maxTimeBonus);
  }

  Future<void> _loadStats() async {
    // Calculate longest streak from history
    final results = await _repository.getAllResults();
    _perfectCount = results.where((r) => r.isPerfectScore).length;

    // Calculate longest streak
    int currentStreak = 0;
    int longestStreak = 0;
    DateTime? expectedDate;

    for (final result in results) {
      final resultDate = DateTime.utc(
        result.completedAt.year,
        result.completedAt.month,
        result.completedAt.day,
      );

      if (expectedDate == null) {
        currentStreak = 1;
        expectedDate = resultDate.subtract(const Duration(days: 1));
      } else if (resultDate == expectedDate) {
        currentStreak++;
        expectedDate = resultDate.subtract(const Duration(days: 1));
      } else if (resultDate.isBefore(expectedDate)) {
        if (currentStreak > longestStreak) {
          longestStreak = currentStreak;
        }
        currentStreak = 1;
        expectedDate = resultDate.subtract(const Duration(days: 1));
      }
    }

    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    _longestStreak = longestStreak;
    _statsLoaded = true;
  }
}
