/// Repository for statistics operations.
///
/// Provides access to aggregated statistics, trends, and insights
/// with caching and reactive updates via Streams.
library;

import 'dart:async';

import '../data_sources/statistics_data_source.dart';
import '../models/daily_statistics.dart';
import '../models/global_statistics.dart';
import '../models/quiz_session.dart';
import '../models/quiz_type_statistics.dart';

/// Statistics trend data for a period.
class StatisticsTrend {
  /// Creates a [StatisticsTrend].
  const StatisticsTrend({
    required this.period,
    required this.dailyStats,
    required this.averageScore,
    required this.totalSessions,
    required this.totalQuestions,
    required this.accuracyRate,
    required this.trend,
  });

  /// The period label (e.g., "Last 7 days").
  final String period;

  /// Daily statistics for the period.
  final List<DailyStatistics> dailyStats;

  /// Average score for the period.
  final double averageScore;

  /// Total sessions played in the period.
  final int totalSessions;

  /// Total questions answered in the period.
  final int totalQuestions;

  /// Accuracy rate (correct / total) as percentage.
  final double accuracyRate;

  /// Trend indicator: positive = improving, negative = declining, 0 = stable.
  final double trend;

  /// Whether the trend is improving.
  bool get isImproving => trend > 0;

  /// Whether the trend is declining.
  bool get isDeclining => trend < 0;

  /// Whether the trend is stable.
  bool get isStable => trend == 0;

  @override
  String toString() =>
      'StatisticsTrend(period: $period, avgScore: $averageScore, trend: $trend)';
}

/// Improvement insight based on performance data.
class ImprovementInsight {
  /// Creates an [ImprovementInsight].
  const ImprovementInsight({
    required this.type,
    required this.title,
    required this.description,
    this.metric,
    this.suggestion,
  });

  /// The type of insight.
  final InsightType type;

  /// Short title for the insight.
  final String title;

  /// Detailed description.
  final String description;

  /// Associated metric value.
  final double? metric;

  /// Suggestion for improvement.
  final String? suggestion;

  @override
  String toString() => 'ImprovementInsight(type: $type, title: $title)';
}

/// Types of improvement insights.
enum InsightType {
  /// Achievement or milestone.
  achievement,

  /// Improvement in performance.
  improvement,

  /// Area that needs work.
  needsWork,

  /// Streak-related insight.
  streak,

  /// Consistency insight.
  consistency,

  /// Time-based insight.
  timeManagement,
}

/// Abstract interface for statistics repository operations.
abstract class StatisticsRepository {
  // ===========================================================================
  // Global Statistics
  // ===========================================================================

  /// Gets the global statistics.
  Future<GlobalStatistics> getGlobalStatistics();

  /// Updates statistics after a session completes.
  Future<void> updateStatisticsForSession(QuizSession session);

  /// Resets all statistics.
  Future<void> resetAllStatistics();

  /// Updates statistics after a daily challenge completion.
  ///
  /// [isPerfect] - Whether the challenge was completed with 100% score.
  /// [currentStreak] - The current daily challenge streak.
  Future<void> updateDailyChallengeStats({
    required bool isPerfect,
    required int currentStreak,
  });

  // ===========================================================================
  // Quiz Type Statistics
  // ===========================================================================

  /// Gets statistics for a specific quiz type.
  Future<QuizTypeStatistics?> getQuizTypeStatistics(
    String quizType, {
    String? category,
  });

  /// Gets all quiz type statistics.
  Future<List<QuizTypeStatistics>> getAllQuizTypeStatistics();

  /// Gets the top quiz types by score.
  Future<List<QuizTypeStatistics>> getTopQuizTypes(int limit);

  /// Gets quiz types that need improvement (low scores).
  Future<List<QuizTypeStatistics>> getQuizTypesNeedingImprovement(int limit);

  // ===========================================================================
  // Daily Statistics & Trends
  // ===========================================================================

  /// Gets daily statistics for a specific date.
  Future<DailyStatistics?> getDailyStatistics(DateTime date);

  /// Gets statistics for today.
  Future<DailyStatistics?> getTodayStatistics();

  /// Gets daily statistics for a date range.
  Future<List<DailyStatistics>> getDailyStatisticsRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Gets statistics trend for the last N days.
  Future<StatisticsTrend> getTrend(int days);

  /// Gets weekly trend (last 7 days).
  Future<StatisticsTrend> getWeeklyTrend();

  /// Gets monthly trend (last 30 days).
  Future<StatisticsTrend> getMonthlyTrend();

  // ===========================================================================
  // Insights & Reports
  // ===========================================================================

  /// Generates improvement insights based on performance data.
  Future<List<ImprovementInsight>> getImprovementInsights();

  /// Gets a summary of today's performance.
  Future<Map<String, dynamic>> getTodaySummary();

  // ===========================================================================
  // Caching & Reactive Updates
  // ===========================================================================

  /// Clears the statistics cache.
  void clearCache();

  /// Watches global statistics for changes.
  Stream<GlobalStatistics> watchGlobalStatistics();

  /// Watches daily statistics for changes.
  Stream<List<DailyStatistics>> watchRecentDailyStatistics(int days);

  /// Disposes of resources.
  void dispose();
}

/// Implementation of [StatisticsRepository].
class StatisticsRepositoryImpl implements StatisticsRepository {
  /// Creates a [StatisticsRepositoryImpl].
  StatisticsRepositoryImpl({
    required StatisticsDataSource dataSource,
    Duration cacheDuration = const Duration(minutes: 2),
  })  : _dataSource = dataSource,
        _cacheDuration = cacheDuration;

  final StatisticsDataSource _dataSource;
  final Duration _cacheDuration;

  // Cache
  _CacheEntry<GlobalStatistics>? _globalStatsCache;
  _CacheEntry<List<QuizTypeStatistics>>? _quizTypeStatsCache;
  final Map<String, _CacheEntry<DailyStatistics>> _dailyStatsCache = {};

  // Stream controllers
  final _globalStatsController =
      StreamController<GlobalStatistics>.broadcast();
  final _dailyStatsController =
      StreamController<List<DailyStatistics>>.broadcast();

  // ===========================================================================
  // Global Statistics
  // ===========================================================================

  @override
  Future<GlobalStatistics> getGlobalStatistics() async {
    if (_globalStatsCache != null && !_globalStatsCache!.isExpired) {
      return _globalStatsCache!.value;
    }

    final stats = await _dataSource.getGlobalStatistics();
    _globalStatsCache = _CacheEntry(stats, _cacheDuration);

    return stats;
  }

  @override
  Future<void> updateStatisticsForSession(QuizSession session) async {
    await _dataSource.updateGlobalStatisticsForSession(session);
    await _dataSource.updateQuizTypeStatisticsForSession(session);
    await _dataSource.updateDailyStatisticsForSession(session);

    // Invalidate cache
    _invalidateCache();

    // Notify listeners
    _notifyGlobalStatsChanged();
    _notifyDailyStatsChanged();
  }

  @override
  Future<void> resetAllStatistics() async {
    await _dataSource.recalculateAllStatistics();

    // Invalidate cache
    _invalidateCache();

    // Notify listeners
    _notifyGlobalStatsChanged();
    _notifyDailyStatsChanged();
  }

  @override
  Future<void> updateDailyChallengeStats({
    required bool isPerfect,
    required int currentStreak,
  }) async {
    await _dataSource.updateDailyChallengeStats(
      isPerfect: isPerfect,
      currentStreak: currentStreak,
    );

    // Invalidate cache
    _invalidateCache();

    // Notify listeners
    _notifyGlobalStatsChanged();
  }

  // ===========================================================================
  // Quiz Type Statistics
  // ===========================================================================

  @override
  Future<QuizTypeStatistics?> getQuizTypeStatistics(
    String quizType, {
    String? category,
  }) async {
    return _dataSource.getQuizTypeStatistics(quizType, category: category);
  }

  @override
  Future<List<QuizTypeStatistics>> getAllQuizTypeStatistics() async {
    if (_quizTypeStatsCache != null && !_quizTypeStatsCache!.isExpired) {
      return _quizTypeStatsCache!.value;
    }

    final stats = await _dataSource.getAllQuizTypeStatistics();
    _quizTypeStatsCache = _CacheEntry(stats, _cacheDuration);

    return stats;
  }

  @override
  Future<List<QuizTypeStatistics>> getTopQuizTypes(int limit) async {
    final allStats = await getAllQuizTypeStatistics();

    // Sort by average score descending
    final sorted = List<QuizTypeStatistics>.from(allStats)
      ..sort((a, b) => b.averageScorePercentage.compareTo(a.averageScorePercentage));

    return sorted.take(limit).toList();
  }

  @override
  Future<List<QuizTypeStatistics>> getQuizTypesNeedingImprovement(
    int limit,
  ) async {
    final allStats = await getAllQuizTypeStatistics();

    // Filter to only those with at least one session, then sort by score ascending
    final withSessions =
        allStats.where((s) => s.totalSessions > 0).toList()
          ..sort((a, b) =>
              a.averageScorePercentage.compareTo(b.averageScorePercentage));

    return withSessions.take(limit).toList();
  }

  // ===========================================================================
  // Daily Statistics & Trends
  // ===========================================================================

  @override
  Future<DailyStatistics?> getDailyStatistics(DateTime date) async {
    final dateKey = DailyStatistics.formatDate(date);

    if (_dailyStatsCache.containsKey(dateKey) &&
        !_dailyStatsCache[dateKey]!.isExpired) {
      return _dailyStatsCache[dateKey]!.value;
    }

    final stats = await _dataSource.getDailyStatistics(date);
    if (stats != null) {
      _dailyStatsCache[dateKey] = _CacheEntry(stats, _cacheDuration);
    }

    return stats;
  }

  @override
  Future<DailyStatistics?> getTodayStatistics() async {
    return getDailyStatistics(DateTime.now());
  }

  @override
  Future<List<DailyStatistics>> getDailyStatisticsRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _dataSource.getDailyStatisticsRange(startDate, endDate);
  }

  @override
  Future<StatisticsTrend> getTrend(int days) async {
    final dailyStats = await _dataSource.getRecentDailyStatistics(days);

    if (dailyStats.isEmpty) {
      return StatisticsTrend(
        period: 'Last $days days',
        dailyStats: [],
        averageScore: 0,
        totalSessions: 0,
        totalQuestions: 0,
        accuracyRate: 0,
        trend: 0,
      );
    }

    // Calculate aggregates
    final totalSessions =
        dailyStats.fold<int>(0, (sum, d) => sum + d.sessionsPlayed);
    final totalQuestions =
        dailyStats.fold<int>(0, (sum, d) => sum + d.questionsAnswered);
    final totalCorrect =
        dailyStats.fold<int>(0, (sum, d) => sum + d.correctAnswers);

    final avgScore = dailyStats.isEmpty
        ? 0.0
        : dailyStats.fold<double>(0, (sum, d) => sum + d.averageScorePercentage) /
            dailyStats.length;
    final accuracyRate =
        totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0.0;

    // Calculate trend by comparing first half vs second half
    final trend = _calculateTrend(dailyStats);

    return StatisticsTrend(
      period: 'Last $days days',
      dailyStats: dailyStats,
      averageScore: avgScore,
      totalSessions: totalSessions,
      totalQuestions: totalQuestions,
      accuracyRate: accuracyRate,
      trend: trend,
    );
  }

  @override
  Future<StatisticsTrend> getWeeklyTrend() => getTrend(7);

  @override
  Future<StatisticsTrend> getMonthlyTrend() => getTrend(30);

  double _calculateTrend(List<DailyStatistics> dailyStats) {
    if (dailyStats.length < 2) return 0;

    final midpoint = dailyStats.length ~/ 2;
    final firstHalf = dailyStats.take(midpoint).toList();
    final secondHalf = dailyStats.skip(midpoint).toList();

    double firstHalfAvg = 0;
    double secondHalfAvg = 0;

    if (firstHalf.isNotEmpty) {
      firstHalfAvg = firstHalf.fold<double>(
              0, (sum, d) => sum + d.averageScorePercentage) /
          firstHalf.length;
    }

    if (secondHalf.isNotEmpty) {
      secondHalfAvg = secondHalf.fold<double>(
              0, (sum, d) => sum + d.averageScorePercentage) /
          secondHalf.length;
    }

    // Return the difference (positive = improving, negative = declining)
    return secondHalfAvg - firstHalfAvg;
  }

  // ===========================================================================
  // Insights & Reports
  // ===========================================================================

  @override
  Future<List<ImprovementInsight>> getImprovementInsights() async {
    final insights = <ImprovementInsight>[];
    final globalStats = await getGlobalStatistics();
    final weeklyTrend = await getWeeklyTrend();

    // Achievement: First session
    if (globalStats.totalSessions == 1) {
      insights.add(const ImprovementInsight(
        type: InsightType.achievement,
        title: 'Welcome!',
        description: 'You\'ve completed your first quiz session!',
        suggestion: 'Keep playing to track your progress.',
      ));
    }

    // Achievement: High accuracy
    if (globalStats.overallAccuracy >= 90) {
      insights.add(ImprovementInsight(
        type: InsightType.achievement,
        title: 'Expert Level!',
        description:
            'Your overall accuracy is ${globalStats.overallAccuracy.toStringAsFixed(1)}%',
        metric: globalStats.overallAccuracy,
      ));
    }

    // Achievement: Perfect scores
    if (globalStats.totalPerfectScores > 0) {
      insights.add(ImprovementInsight(
        type: InsightType.achievement,
        title: 'Perfect Scores',
        description:
            'You\'ve achieved ${globalStats.totalPerfectScores} perfect scores!',
        metric: globalStats.totalPerfectScores.toDouble(),
      ));
    }

    // Trend: Improving
    if (weeklyTrend.isImproving && weeklyTrend.trend > 5) {
      insights.add(ImprovementInsight(
        type: InsightType.improvement,
        title: 'Great Progress!',
        description:
            'Your scores improved by ${weeklyTrend.trend.toStringAsFixed(1)}% this week.',
        metric: weeklyTrend.trend,
      ));
    }

    // Trend: Declining
    if (weeklyTrend.isDeclining && weeklyTrend.trend < -5) {
      insights.add(ImprovementInsight(
        type: InsightType.needsWork,
        title: 'Keep Practicing',
        description: 'Your scores dipped this week. Let\'s get back on track!',
        metric: weeklyTrend.trend,
        suggestion: 'Try reviewing questions you\'ve missed.',
      ));
    }

    // Low accuracy areas
    final lowScoreTypes = await getQuizTypesNeedingImprovement(3);
    for (final quizType in lowScoreTypes) {
      if (quizType.averageScorePercentage < 60 && quizType.totalSessions >= 3) {
        insights.add(ImprovementInsight(
          type: InsightType.needsWork,
          title: 'Focus Area: ${quizType.displayName}',
          description:
              'Average score: ${quizType.averageScorePercentage.toStringAsFixed(1)}%',
          metric: quizType.averageScorePercentage,
          suggestion: 'Practice more in this category to improve.',
        ));
      }
    }

    // Consistency: Playing streak
    if (weeklyTrend.totalSessions >= 7) {
      insights.add(ImprovementInsight(
        type: InsightType.consistency,
        title: 'Consistent Player!',
        description:
            'You\'ve played ${weeklyTrend.totalSessions} sessions this week.',
        metric: weeklyTrend.totalSessions.toDouble(),
      ));
    }

    // Time management
    if (globalStats.totalTimePlayedSeconds > 3600) {
      final hours = globalStats.totalTimePlayedSeconds / 3600;
      insights.add(ImprovementInsight(
        type: InsightType.timeManagement,
        title: 'Dedicated Learner',
        description:
            'You\'ve spent ${hours.toStringAsFixed(1)} hours learning!',
        metric: hours,
      ));
    }

    return insights;
  }

  @override
  Future<Map<String, dynamic>> getTodaySummary() async {
    final todayStats = await getTodayStatistics();

    if (todayStats == null) {
      return {
        'sessionsPlayed': 0,
        'questionsAnswered': 0,
        'correctAnswers': 0,
        'accuracy': 0.0,
        'averageScore': 0.0,
        'timePlayed': Duration.zero,
        'perfectScores': 0,
      };
    }

    return {
      'sessionsPlayed': todayStats.sessionsPlayed,
      'questionsAnswered': todayStats.questionsAnswered,
      'correctAnswers': todayStats.correctAnswers,
      'accuracy': todayStats.accuracy,
      'averageScore': todayStats.averageScorePercentage,
      'timePlayed': todayStats.timePlayed,
      'perfectScores': todayStats.perfectScores,
    };
  }

  // ===========================================================================
  // Caching & Reactive Updates
  // ===========================================================================

  @override
  void clearCache() {
    _invalidateCache();
  }

  @override
  Stream<GlobalStatistics> watchGlobalStatistics() {
    // Emit initial value
    getGlobalStatistics().then((stats) {
      if (!_globalStatsController.isClosed) {
        _globalStatsController.add(stats);
      }
    });

    return _globalStatsController.stream;
  }

  @override
  Stream<List<DailyStatistics>> watchRecentDailyStatistics(int days) {
    // Emit initial value
    _dataSource.getRecentDailyStatistics(days).then((stats) {
      if (!_dailyStatsController.isClosed) {
        _dailyStatsController.add(stats);
      }
    });

    return _dailyStatsController.stream;
  }

  @override
  void dispose() {
    _globalStatsController.close();
    _dailyStatsController.close();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  void _invalidateCache() {
    _globalStatsCache = null;
    _quizTypeStatsCache = null;
    _dailyStatsCache.clear();
  }

  void _notifyGlobalStatsChanged() {
    if (_globalStatsController.hasListener) {
      getGlobalStatistics().then((stats) {
        if (!_globalStatsController.isClosed) {
          _globalStatsController.add(stats);
        }
      });
    }
  }

  void _notifyDailyStatsChanged() {
    if (_dailyStatsController.hasListener) {
      _dataSource.getRecentDailyStatistics(7).then((stats) {
        if (!_dailyStatsController.isClosed) {
          _dailyStatsController.add(stats);
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
