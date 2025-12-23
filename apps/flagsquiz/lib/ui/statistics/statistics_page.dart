import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flags_quiz/ui/history/session_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

/// Page displaying quiz statistics.
class StatisticsPage extends StatefulWidget {
  /// Creates a [StatisticsPage].
  const StatisticsPage({
    super.key,
    required this.storageService,
  });

  /// Storage service for loading statistics.
  final StorageService storageService;

  @override
  State<StatisticsPage> createState() => StatisticsPageState();
}

/// State for [StatisticsPage].
class StatisticsPageState extends State<StatisticsPage> {
  GlobalStatistics? _statistics;
  List<QuizSession> _recentSessions = [];
  StatisticsTrend? _trend;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  /// Refreshes the statistics data.
  void refresh() {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final statsResult = await widget.storageService.getGlobalStatistics();
      final sessionsResult =
          await widget.storageService.getRecentSessions(limit: 3);
      final trendResult = await widget.storageService.getStatisticsTrend(7);

      statsResult.ifSuccess((stats) {
        _statistics = stats;
      });

      sessionsResult.ifSuccess((sessions) {
        _recentSessions = sessions;
      });

      trendResult.ifSuccess((trend) {
        _trend = trend;
      });

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.statistics),
      ),
      body: StatisticsScreen(
        statistics: _convertStatistics(),
        texts: _buildTexts(l10n),
        recentSessions: _recentSessions.map(_convertToCardData).toList(),
        onSessionTap: _onSessionTap,
        onViewAllSessions: _onViewAllSessions,
        isLoading: _isLoading,
      ),
    );
  }

  GlobalStatisticsData _convertStatistics() {
    if (_statistics == null) {
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

    final weeklyTrend = _buildWeeklyTrend();
    final trendDirection = _calculateTrendDirection();

    return GlobalStatisticsData(
      totalSessions: _statistics!.totalSessions,
      totalQuestions: _statistics!.totalQuestionsAnswered,
      totalCorrect: _statistics!.totalCorrectAnswers,
      totalIncorrect: _statistics!.totalIncorrectAnswers,
      averageScore: _statistics!.averageScorePercentage,
      bestScore: _statistics!.bestScorePercentage,
      totalTimePlayed: _statistics!.totalTimePlayedSeconds,
      perfectScores: _statistics!.totalPerfectScores,
      currentStreak: _statistics!.currentStreak,
      bestStreak: _statistics!.bestStreak,
      weeklyTrend: weeklyTrend,
      trendDirection: trendDirection,
    );
  }

  List<TrendDataPoint> _buildWeeklyTrend() {
    if (_trend == null || _trend!.dailyStats.isEmpty) {
      return [];
    }

    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final now = DateTime.now();

    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      final dateStr = DailyStatistics.formatDate(date);

      final dayStats = _trend!.dailyStats.where((s) => s.date == dateStr);

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

  TrendType? _calculateTrendDirection() {
    if (_trend == null) return null;

    if (_trend!.isImproving) {
      return TrendType.improving;
    } else if (_trend!.isDeclining) {
      return TrendType.declining;
    } else {
      return TrendType.stable;
    }
  }

  StatisticsTexts _buildTexts(AppLocalizations l10n) {
    return StatisticsTexts(
      title: l10n.statistics,
      emptyTitle: l10n.noStatisticsYet,
      emptySubtitle: l10n.playQuizzesToSee,
      overviewLabel: l10n.overview,
      insightsLabel: l10n.insights,
      recentSessionsLabel: l10n.recentSessions,
      viewAllLabel: l10n.viewAll,
      totalSessionsLabel: l10n.totalSessions,
      totalQuestionsLabel: l10n.totalQuestions,
      averageScoreLabel: l10n.averageScore,
      bestScoreLabel: l10n.bestScore,
      accuracyLabel: l10n.accuracy,
      timePlayedLabel: l10n.timePlayed,
      perfectScoresLabel: l10n.perfectScores,
      currentStreakLabel: l10n.currentStreak,
      bestStreakLabel: l10n.bestStreak,
      weeklyTrendLabel: l10n.weeklyTrend,
      improvingLabel: l10n.improving,
      decliningLabel: l10n.declining,
      stableLabel: l10n.stable,
      questionsLabel: l10n.questions,
      daysLabel: l10n.days,
      formatDate: (date) => _formatDate(date),
      formatStatus: (status, isPerfect) => _formatStatus(status, isPerfect),
      formatDuration: _formatDuration,
    );
  }

  SessionCardData _convertToCardData(QuizSession session) {
    return SessionCardData(
      id: session.id,
      quizName: _getQuizName(session.quizId),
      totalQuestions: session.totalQuestions,
      totalCorrect: session.totalCorrect,
      scorePercentage: session.scorePercentage,
      completionStatus: session.completionStatus.name,
      startTime: session.startTime,
      durationSeconds: session.durationSeconds,
      quizCategory: session.quizCategory,
    );
  }

  String _getQuizName(String? quizId) {
    final l10n = AppLocalizations.of(context)!;
    if (quizId == null) return 'Flags Quiz';

    switch (quizId.toLowerCase()) {
      case 'all':
        return l10n.all;
      case 'europe':
        return l10n.europe;
      case 'asia':
        return l10n.asia;
      case 'africa':
        return l10n.africa;
      case 'north_america':
      case 'northamerica':
        return l10n.northAmerica;
      case 'south_america':
      case 'southamerica':
        return l10n.southAmerica;
      case 'oceania':
        return l10n.oceania;
      default:
        return quizId;
    }
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return '${l10n.today} ${_formatTime(date)}';
    } else if (diff.inDays == 1) {
      return '${l10n.yesterday} ${_formatTime(date)}';
    } else if (diff.inDays < 7) {
      return l10n.daysAgo(diff.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  (String, Color) _formatStatus(String status, bool isPerfect) {
    final l10n = AppLocalizations.of(context)!;

    switch (status.toLowerCase()) {
      case 'completed':
        return isPerfect
            ? (l10n.perfectScore, Colors.amber)
            : (l10n.sessionCompleted, Colors.green);
      case 'cancelled':
        return (l10n.sessionCancelled, Colors.orange);
      case 'timeout':
        return (l10n.sessionTimeout, Colors.red);
      case 'failed':
        return (l10n.sessionFailed, Colors.red);
      default:
        return (status, Colors.grey);
    }
  }

  String _formatDuration(int seconds) {
    final l10n = AppLocalizations.of(context)!;
    if (seconds < 60) {
      return '$seconds ${l10n.seconds}';
    }
    final minutes = seconds ~/ 60;
    if (minutes < 60) {
      return '$minutes ${l10n.minutes}';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours ${l10n.hours} $remainingMinutes ${l10n.minutes}';
  }

  void _onSessionTap(SessionCardData sessionData) {
    final session = _recentSessions.firstWhere(
      (s) => s.id == sessionData.id,
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => SessionDetailPage(
          session: session,
          storageService: widget.storageService,
          onDeleted: _loadStatistics,
        ),
      ),
    );
  }

  void _onViewAllSessions() {
    // Navigate to history tab - handled by parent HomeScreen
  }
}
