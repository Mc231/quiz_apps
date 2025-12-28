import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../services/quiz_services_context.dart';
import '../widgets/statistics_card.dart';
import '../widgets/trends_widget.dart';
import '../widgets/session_card.dart';

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

/// Localization texts for StatisticsScreen.
class StatisticsTexts {
  /// Creates [StatisticsTexts].
  const StatisticsTexts({
    required this.title,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.overviewLabel,
    required this.insightsLabel,
    required this.recentSessionsLabel,
    required this.viewAllLabel,
    required this.totalSessionsLabel,
    required this.totalQuestionsLabel,
    required this.averageScoreLabel,
    required this.bestScoreLabel,
    required this.accuracyLabel,
    required this.timePlayedLabel,
    required this.perfectScoresLabel,
    required this.currentStreakLabel,
    required this.bestStreakLabel,
    required this.weeklyTrendLabel,
    required this.improvingLabel,
    required this.decliningLabel,
    required this.stableLabel,
    required this.questionsLabel,
    required this.daysLabel,
    required this.formatDate,
    required this.formatStatus,
    required this.formatDuration,
  });

  /// Screen title.
  final String title;

  /// Empty state title.
  final String emptyTitle;

  /// Empty state subtitle.
  final String emptySubtitle;

  /// Overview section label.
  final String overviewLabel;

  /// Insights section label.
  final String insightsLabel;

  /// Recent sessions section label.
  final String recentSessionsLabel;

  /// View all button label.
  final String viewAllLabel;

  /// Total sessions label.
  final String totalSessionsLabel;

  /// Total questions label.
  final String totalQuestionsLabel;

  /// Average score label.
  final String averageScoreLabel;

  /// Best score label.
  final String bestScoreLabel;

  /// Accuracy label.
  final String accuracyLabel;

  /// Time played label.
  final String timePlayedLabel;

  /// Perfect scores label.
  final String perfectScoresLabel;

  /// Current streak label.
  final String currentStreakLabel;

  /// Best streak label.
  final String bestStreakLabel;

  /// Weekly trend label.
  final String weeklyTrendLabel;

  /// Improving trend label.
  final String improvingLabel;

  /// Declining trend label.
  final String decliningLabel;

  /// Stable trend label.
  final String stableLabel;

  /// Questions label.
  final String questionsLabel;

  /// Days label.
  final String daysLabel;

  /// Date formatter.
  final DateFormatter formatDate;

  /// Status formatter.
  final StatusFormatter formatStatus;

  /// Duration formatter.
  final String Function(int seconds) formatDuration;
}

/// Screen displaying global statistics and trends.
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class StatisticsScreen extends StatefulWidget {
  /// Creates a [StatisticsScreen].
  const StatisticsScreen({
    super.key,
    required this.statistics,
    required this.texts,
    this.recentSessions = const [],
    this.onSessionTap,
    this.onViewAllSessions,
    this.isLoading = false,
  });

  /// Global statistics data.
  final GlobalStatisticsData statistics;

  /// Localization texts.
  final StatisticsTexts texts;

  /// Recent sessions for quick access.
  final List<SessionCardData> recentSessions;

  /// Callback when a session is tapped.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback to view all sessions.
  final VoidCallback? onViewAllSessions;

  /// Whether data is loading.
  final bool isLoading;

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  // Service accessor via context
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  bool _screenViewLogged = false;

  void _logScreenView() {
    _analyticsService.logEvent(
      ScreenViewEvent.statistics(
        totalSessions: widget.statistics.totalSessions,
        averageScore: widget.statistics.averageScore,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Log screen view on first build (deferred from initState for context access)
    if (!_screenViewLogged) {
      _screenViewLogged = true;
      _logScreenView();
    }

    if (widget.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!widget.statistics.hasData) {
      return _buildEmptyState(context);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(context, widget.texts.overviewLabel),
          _buildOverviewGrid(context),
          if (widget.statistics.weeklyTrend != null &&
              widget.statistics.weeklyTrend!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildTrendChart(context),
          ],
          _buildSectionHeader(context, widget.texts.insightsLabel),
          _buildInsightsGrid(context),
          if (widget.recentSessions.isNotEmpty) ...[
            _buildRecentSessionsHeader(context),
            _buildRecentSessions(context),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              widget.texts.emptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.texts.emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildOverviewGrid(BuildContext context) {
    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: widget.texts.totalSessionsLabel,
          value: widget.statistics.totalSessions.toString(),
          icon: Icons.quiz,
          iconColor: Colors.blue,
        ),
        StatisticsCard(
          title: widget.texts.totalQuestionsLabel,
          value: widget.statistics.totalQuestions.toString(),
          icon: Icons.help_outline,
          iconColor: Colors.purple,
        ),
        StatisticsCard(
          title: widget.texts.averageScoreLabel,
          value: '${widget.statistics.averageScore.round()}%',
          icon: Icons.score,
          iconColor: Colors.orange,
          trend: _getTrendDirection(widget.statistics.trendDirection),
        ),
        StatisticsCard(
          title: widget.texts.bestScoreLabel,
          value: '${widget.statistics.bestScore.round()}%',
          icon: Icons.emoji_events,
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildTrendChart(BuildContext context) {
    final trendLabel = _getTrendLabel(widget.statistics.trendDirection);

    return TrendsWidget(
      title: widget.texts.weeklyTrendLabel,
      dataPoints: widget.statistics.weeklyTrend!,
      trend: widget.statistics.trendDirection,
      trendLabel: trendLabel,
    );
  }

  Widget _buildInsightsGrid(BuildContext context) {
    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: widget.texts.accuracyLabel,
          value: '${widget.statistics.accuracy.round()}%',
          icon: Icons.adjust,
          iconColor: Colors.teal,
        ),
        StatisticsCard(
          title: widget.texts.timePlayedLabel,
          value: widget.texts.formatDuration(widget.statistics.totalTimePlayed),
          icon: Icons.timer,
          iconColor: Colors.indigo,
        ),
        StatisticsCard(
          title: widget.texts.perfectScoresLabel,
          value: widget.statistics.perfectScores.toString(),
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        StatisticsCard(
          title: widget.texts.currentStreakLabel,
          value: '${widget.statistics.currentStreak}',
          subtitle: '${widget.texts.bestStreakLabel}: ${widget.statistics.bestStreak}',
          icon: Icons.local_fire_department,
          iconColor: Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildRecentSessionsHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              widget.texts.recentSessionsLabel,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (widget.onViewAllSessions != null)
            TextButton(
              onPressed: widget.onViewAllSessions,
              child: Text(widget.texts.viewAllLabel),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context) {
    return Column(
      children: widget.recentSessions.take(3).map((session) {
        return SessionCard(
          data: session,
          questionsLabel: widget.texts.questionsLabel,
          formatDate: widget.texts.formatDate,
          formatStatus: widget.texts.formatStatus,
          onTap: widget.onSessionTap != null ? () => widget.onSessionTap!(session) : null,
        );
      }).toList(),
    );
  }

  TrendDirection? _getTrendDirection(TrendType? type) {
    switch (type) {
      case TrendType.improving:
        return TrendDirection.up;
      case TrendType.declining:
        return TrendDirection.down;
      case TrendType.stable:
        return TrendDirection.neutral;
      case null:
        return null;
    }
  }

  String? _getTrendLabel(TrendType? type) {
    switch (type) {
      case TrendType.improving:
        return widget.texts.improvingLabel;
      case TrendType.declining:
        return widget.texts.decliningLabel;
      case TrendType.stable:
        return widget.texts.stableLabel;
      case null:
        return null;
    }
  }
}
