import 'package:shared_services/shared_services.dart';

import '../home/quiz_home_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/session_card.dart';
import '../widgets/trends_widget.dart';

/// Default data loader for quiz history and statistics.
///
/// Handles conversion between storage models and display models,
/// providing sensible defaults for QuizHomeScreen data providers.
class DefaultDataLoader {
  /// Creates a [DefaultDataLoader].
  const DefaultDataLoader(this._storageService);

  final StorageService _storageService;

  /// Loads history data from storage.
  ///
  /// Returns [HistoryTabData] with session cards sorted by date.
  Future<HistoryTabData> loadHistoryData({int limit = 100}) async {
    try {
      final result = await _storageService.getRecentSessions(limit: limit);
      List<SessionCardData> sessions = [];

      result.ifSuccess((sessionList) {
        sessions = sessionList.map(_convertSessionToCardData).toList();
      });

      return HistoryTabData(sessions: sessions);
    } catch (e) {
      return const HistoryTabData();
    }
  }

  /// Loads statistics data from storage.
  ///
  /// Returns [StatisticsTabData] with global statistics and recent sessions.
  Future<StatisticsTabData> loadStatisticsData({
    int recentSessionsLimit = 3,
    int trendDays = 7,
  }) async {
    try {
      final statsResult = await _storageService.getGlobalStatistics();
      final sessionsResult =
          await _storageService.getRecentSessions(limit: recentSessionsLimit);
      final trendResult = await _storageService.getStatisticsTrend(trendDays);

      GlobalStatistics? statistics;
      List<QuizSession> recentSessions = [];
      StatisticsTrend? trend;

      statsResult.ifSuccess((stats) => statistics = stats);
      sessionsResult.ifSuccess((sessions) => recentSessions = sessions);
      trendResult.ifSuccess((t) => trend = t);

      return StatisticsTabData(
        statistics: _convertStatistics(statistics, trend),
        recentSessions:
            recentSessions.map(_convertSessionToCardData).toList(),
      );
    } catch (e) {
      return StatisticsTabData.empty();
    }
  }

  /// Gets session detail data for a given session ID.
  Future<QuizSession?> getSessionById(String sessionId) async {
    try {
      final result = await _storageService.getRecentSessions(limit: 100);
      QuizSession? foundSession;

      result.ifSuccess((sessions) {
        foundSession = sessions.firstWhere(
          (s) => s.id == sessionId,
          orElse: () => sessions.first,
        );
      });

      return foundSession;
    } catch (e) {
      return null;
    }
  }

  /// Gets session with all its answers for a given session ID.
  ///
  /// Returns [SessionWithAnswers] containing both the session and its answers.
  Future<SessionWithAnswers?> getSessionWithAnswers(String sessionId) async {
    try {
      final result = await _storageService.getSessionWithAnswers(sessionId);
      SessionWithAnswers? sessionWithAnswers;

      result.ifSuccess((data) {
        sessionWithAnswers = data;
      });

      return sessionWithAnswers;
    } catch (e) {
      return null;
    }
  }

  /// Converts a [QuizSession] to [SessionCardData].
  SessionCardData _convertSessionToCardData(QuizSession session) {
    return SessionCardData(
      id: session.id,
      quizName: session.quizName,
      totalQuestions: session.totalQuestions,
      totalCorrect: session.totalCorrect,
      scorePercentage: session.scorePercentage,
      completionStatus: session.completionStatus.name,
      startTime: session.startTime,
      durationSeconds: session.durationSeconds,
      quizCategory: session.quizCategory,
    );
  }

  /// Converts storage statistics to display statistics.
  GlobalStatisticsData _convertStatistics(
    GlobalStatistics? statistics,
    StatisticsTrend? trend,
  ) {
    if (statistics == null) {
      return const GlobalStatisticsData(
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
      );
    }

    return GlobalStatisticsData(
      totalSessions: statistics.totalSessions,
      totalQuestions: statistics.totalQuestionsAnswered,
      totalCorrect: statistics.totalCorrectAnswers,
      totalIncorrect: statistics.totalIncorrectAnswers,
      averageScore: statistics.averageScorePercentage,
      bestScore: statistics.bestScorePercentage,
      totalTimePlayed: statistics.totalTimePlayedSeconds,
      perfectScores: statistics.totalPerfectScores,
      currentStreak: statistics.currentStreak,
      bestStreak: statistics.bestStreak,
      weeklyTrend: _buildWeeklyTrend(trend),
      trendDirection: _calculateTrendDirection(trend),
    );
  }

  /// Builds weekly trend data points.
  List<TrendDataPoint> _buildWeeklyTrend(StatisticsTrend? trend) {
    if (trend == null || trend.dailyStats.isEmpty) {
      return [];
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dateStr = DailyStatistics.formatDate(date);

      final dayStats = trend.dailyStats.where((s) => s.date == dateStr);

      double avgScore = 0;
      if (dayStats.isNotEmpty) {
        avgScore = dayStats.first.averageScorePercentage;
      }

      return TrendDataPoint(
        label: weekdays[date.weekday - 1],
        value: avgScore,
        date: date,
      );
    });
  }

  /// Calculates trend direction from statistics.
  TrendType? _calculateTrendDirection(StatisticsTrend? trend) {
    if (trend == null) return null;

    if (trend.isImproving) {
      return TrendType.improving;
    } else if (trend.isDeclining) {
      return TrendType.declining;
    } else {
      return TrendType.stable;
    }
  }
}
