import '../widgets/category_statistics_widget.dart';
import '../widgets/leaderboard_widget.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/session_card.dart';
import '../widgets/trends_widget.dart';
import 'statistics_data.dart';

/// Dashboard tab for statistics.
enum StatisticsDashboardTab {
  /// Overview tab with main statistics.
  overview,

  /// Progress tab with improvement over time.
  progress,

  /// Categories breakdown tab.
  categories,

  /// Leaderboard tab.
  leaderboard,
}

/// Complete data model for the statistics dashboard.
class StatisticsDashboardData {
  /// Creates a [StatisticsDashboardData].
  const StatisticsDashboardData({
    required this.globalStatistics,
    this.categoryStatistics = const [],
    this.progressDataPoints = const [],
    this.leaderboardEntries = const [],
    this.recentSessions = const [],
    this.weeklyTrend,
    this.trendDirection,
    this.progressImprovement,
  });

  /// Global aggregate statistics.
  final GlobalStatisticsData globalStatistics;

  /// Statistics per category.
  final List<CategoryStatisticsData> categoryStatistics;

  /// Progress data points for the chart.
  final List<ProgressDataPoint> progressDataPoints;

  /// Leaderboard entries.
  final List<LeaderboardEntry> leaderboardEntries;

  /// Recent quiz sessions.
  final List<SessionCardData> recentSessions;

  /// Weekly trend data.
  final List<TrendDataPoint>? weeklyTrend;

  /// Overall trend direction.
  final TrendType? trendDirection;

  /// Progress improvement percentage.
  final double? progressImprovement;

  /// Whether there's any data.
  bool get hasData => globalStatistics.hasData;

  /// Creates empty dashboard data.
  static const empty = StatisticsDashboardData(
    globalStatistics: GlobalStatisticsData(
      totalSessions: 0,
      totalQuestions: 0,
      totalCorrect: 0,
      totalIncorrect: 0,
      averageScore: 0,
      bestScore: 0,
      totalTimePlayed: 0,
      perfectScores: 0,
      currentStreak: 0,
      bestStreak: 0,
    ),
  );
}
