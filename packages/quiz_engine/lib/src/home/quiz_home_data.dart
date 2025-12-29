import '../achievements/screens/achievements_screen_data.dart';
import '../screens/statistics_data.dart';
import '../widgets/session_card.dart';

/// Data provider for the History tab.
class HistoryTabData {
  /// Session history data.
  final List<SessionCardData> sessions;

  /// Whether data is loading.
  final bool isLoading;

  /// Creates [HistoryTabData].
  const HistoryTabData({
    this.sessions = const [],
    this.isLoading = false,
  });
}

/// Data provider for the Statistics tab.
class StatisticsTabData {
  /// Global statistics.
  final GlobalStatisticsData statistics;

  /// Recent sessions for the statistics screen.
  final List<SessionCardData> recentSessions;

  /// Whether data is loading.
  final bool isLoading;

  /// Creates [StatisticsTabData].
  const StatisticsTabData({
    required this.statistics,
    this.recentSessions = const [],
    this.isLoading = false,
  });

  /// Creates empty statistics data.
  factory StatisticsTabData.empty() {
    return const StatisticsTabData(
      statistics: GlobalStatisticsData(
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
}

/// Data provider for the Achievements tab.
class AchievementsTabData {
  /// Achievements data for the screen.
  final AchievementsScreenData screenData;

  /// Whether data is loading.
  final bool isLoading;

  /// Creates [AchievementsTabData].
  const AchievementsTabData({
    required this.screenData,
    this.isLoading = false,
  });

  /// Creates empty achievements data.
  factory AchievementsTabData.empty() {
    return const AchievementsTabData(
      screenData: AchievementsScreenData.empty(),
    );
  }
}
