import '../widgets/trends_widget.dart';

/// Data model for global statistics.
class GlobalStatisticsData {
  /// Creates a [GlobalStatisticsData].
  const GlobalStatisticsData({
    required this.totalSessions,
    required this.totalQuestions,
    required this.totalCorrect,
    required this.totalIncorrect,
    required this.averageScore,
    required this.bestScore,
    required this.totalTimePlayed,
    required this.perfectScores,
    required this.currentStreak,
    required this.bestStreak,
    this.weeklyTrend,
    this.trendDirection,
  });

  /// Total number of quiz sessions.
  final int totalSessions;

  /// Total questions answered.
  final int totalQuestions;

  /// Total correct answers.
  final int totalCorrect;

  /// Total incorrect answers.
  final int totalIncorrect;

  /// Average score percentage.
  final double averageScore;

  /// Best score percentage.
  final double bestScore;

  /// Total time played in seconds.
  final int totalTimePlayed;

  /// Number of perfect scores.
  final int perfectScores;

  /// Current daily streak.
  final int currentStreak;

  /// Best daily streak.
  final int bestStreak;

  /// Weekly trend data points.
  final List<TrendDataPoint>? weeklyTrend;

  /// Overall trend direction.
  final TrendType? trendDirection;

  /// Accuracy percentage.
  double get accuracy =>
      totalQuestions > 0 ? (totalCorrect / totalQuestions) * 100 : 0;

  /// Whether there's any data.
  bool get hasData => totalSessions > 0;
}
