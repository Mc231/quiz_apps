import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../widgets/category_statistics_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/leaderboard_widget.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/progress_chart_widget.dart';
import '../widgets/session_card.dart';
import '../widgets/statistics_card.dart';
import '../widgets/trends_widget.dart';
import 'statistics_screen.dart';

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

/// Enhanced statistics dashboard screen with tabbed interface.
class StatisticsDashboardScreen extends StatefulWidget {
  /// Creates a [StatisticsDashboardScreen].
  const StatisticsDashboardScreen({
    super.key,
    required this.data,
    required this.analyticsService,
    this.initialTab = StatisticsDashboardTab.overview,
    this.onSessionTap,
    this.onCategoryTap,
    this.onLeaderboardEntryTap,
    this.onViewAllSessions,
    this.isLoading = false,
    this.showTabs = true,
  });

  /// Dashboard data.
  final StatisticsDashboardData data;

  /// Analytics service for tracking events.
  final AnalyticsService analyticsService;

  /// Initial tab to display.
  final StatisticsDashboardTab initialTab;

  /// Callback when a session is tapped.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback when a category is tapped.
  final void Function(CategoryStatisticsData category)? onCategoryTap;

  /// Callback when a leaderboard entry is tapped.
  final void Function(LeaderboardEntry entry)? onLeaderboardEntryTap;

  /// Callback to view all sessions.
  final VoidCallback? onViewAllSessions;

  /// Whether data is loading.
  final bool isLoading;

  /// Whether to show tab navigation.
  final bool showTabs;

  @override
  State<StatisticsDashboardScreen> createState() =>
      _StatisticsDashboardScreenState();
}

class _StatisticsDashboardScreenState extends State<StatisticsDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  ProgressTimeRange _progressTimeRange = ProgressTimeRange.week;
  LeaderboardType _leaderboardType = LeaderboardType.bestScores;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
    _tabController.addListener(_handleTabChange);
    _logScreenView();
  }

  void _logScreenView() {
    widget.analyticsService.logEvent(
      ScreenViewEvent.statistics(
        totalSessions: widget.data.globalStatistics.totalSessions,
        averageScore: widget.data.globalStatistics.averageScore,
      ),
    );
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      final tab = StatisticsDashboardTab.values[_tabController.index];
      widget.analyticsService.logEvent(
        InteractionEvent.tabSelected(
          tabId: tab.name,
          tabName: tab.name,
          tabIndex: _tabController.index,
        ),
      );
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    if (widget.isLoading) {
      return LoadingIndicator(message: l10n.loadingData);
    }

    if (!widget.data.hasData) {
      return EmptyStateWidget(
        icon: Icons.analytics_outlined,
        title: l10n.noStatisticsYet,
        message: l10n.playQuizzesToSee,
      );
    }

    if (!widget.showTabs) {
      return _buildOverviewContent(context, l10n);
    }

    return Column(
      children: [
        // Tab bar
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.overview),
              Tab(text: l10n.progress),
              Tab(text: l10n.categories),
              Tab(text: l10n.leaderboard),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, l10n),
              _buildProgressTab(context, l10n),
              _buildCategoriesTab(context, l10n),
              _buildLeaderboardTab(context, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, QuizLocalizations l10n) {
    return SingleChildScrollView(
      child: _buildOverviewContent(context, l10n),
    );
  }

  Widget _buildOverviewContent(BuildContext context, QuizLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview grid
        _buildSectionHeader(context, l10n.overview),
        _buildOverviewGrid(context, l10n),

        // Weekly trend
        if (widget.data.weeklyTrend != null &&
            widget.data.weeklyTrend!.isNotEmpty) ...[
          const SizedBox(height: 8),
          TrendsWidget(
            title: l10n.weeklyTrend,
            dataPoints: widget.data.weeklyTrend!,
            trend: widget.data.trendDirection,
            trendLabel: _getTrendLabel(widget.data.trendDirection, l10n),
          ),
        ],

        // Insights
        _buildSectionHeader(context, l10n.insights),
        _buildInsightsGrid(context, l10n),

        // Recent sessions
        if (widget.data.recentSessions.isNotEmpty) ...[
          _buildRecentSessionsHeader(context, l10n),
          _buildRecentSessions(context, l10n),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProgressTab(BuildContext context, QuizLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: ProgressTimeRangeSelector(
              selectedRange: _progressTimeRange,
              onRangeChanged: (range) {
                setState(() {
                  _progressTimeRange = range;
                });
              },
            ),
          ),

          // Progress chart
          ProgressChartWidget(
            dataPoints: widget.data.progressDataPoints,
            title: l10n.scoreOverTime,
            subtitle: _getTimeRangeSubtitle(_progressTimeRange, l10n),
            improvement: widget.data.progressImprovement,
          ),

          // Summary stats
          if (widget.data.progressDataPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildProgressStats(context, l10n),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context, QuizLocalizations l10n) {
    if (widget.data.categoryStatistics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noCategoryData,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category grid
          CategoryStatisticsGrid(
            categories: widget.data.categoryStatistics,
            onCategoryTap: widget.onCategoryTap,
          ),

          const SizedBox(height: 16),

          // Category list (detailed)
          CategoryStatisticsWidget(
            categories: widget.data.categoryStatistics,
            onCategoryTap: widget.onCategoryTap,
            sortBy: CategorySortBy.averageScore,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, QuizLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: LeaderboardTypeSelector(
              selectedType: _leaderboardType,
              onTypeChanged: (type) {
                setState(() {
                  _leaderboardType = type;
                });
              },
            ),
          ),

          // Leaderboard
          LeaderboardWidget(
            entries: widget.data.leaderboardEntries,
            type: _leaderboardType,
            onEntryTap: widget.onLeaderboardEntryTap,
          ),

          // Coming Soon: Global Leaderboard
          _buildGlobalLeaderboardComingSoon(context, l10n),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboardComingSoon(
      BuildContext context, QuizLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.public,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.globalLeaderboard,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.globalLeaderboardComingSoon,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.comingSoon,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  Widget _buildOverviewGrid(BuildContext context, QuizLocalizations l10n) {
    final stats = widget.data.globalStatistics;

    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: l10n.totalSessions,
          value: stats.totalSessions.toString(),
          icon: Icons.quiz,
          iconColor: Colors.blue,
        ),
        StatisticsCard(
          title: l10n.totalQuestions,
          value: stats.totalQuestions.toString(),
          icon: Icons.help_outline,
          iconColor: Colors.purple,
        ),
        StatisticsCard(
          title: l10n.averageScore,
          value: '${stats.averageScore.round()}%',
          icon: Icons.score,
          iconColor: Colors.orange,
          trend: _getTrendDirection(widget.data.trendDirection),
        ),
        StatisticsCard(
          title: l10n.bestScore,
          value: '${stats.bestScore.round()}%',
          icon: Icons.emoji_events,
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildInsightsGrid(BuildContext context, QuizLocalizations l10n) {
    final stats = widget.data.globalStatistics;

    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: l10n.accuracy,
          value: '${stats.accuracy.round()}%',
          icon: Icons.adjust,
          iconColor: Colors.teal,
        ),
        StatisticsCard(
          title: l10n.timePlayed,
          value: _formatDuration(stats.totalTimePlayed, l10n),
          icon: Icons.timer,
          iconColor: Colors.indigo,
        ),
        StatisticsCard(
          title: l10n.perfectScores,
          value: stats.perfectScores.toString(),
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        StatisticsCard(
          title: l10n.currentStreak,
          value: '${stats.currentStreak}',
          subtitle: '${l10n.bestStreak}: ${stats.bestStreak}',
          icon: Icons.local_fire_department,
          iconColor: Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildProgressStats(BuildContext context, QuizLocalizations l10n) {
    final dataPoints = widget.data.progressDataPoints;
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final values = dataPoints.map((p) => p.value).toList();
    final avgValue = values.reduce((a, b) => a + b) / values.length;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final totalSessions =
        dataPoints.map((p) => p.sessions).reduce((a, b) => a + b);

    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: l10n.averageScore,
          value: '${avgValue.round()}%',
          icon: Icons.score,
          iconColor: Colors.blue,
        ),
        StatisticsCard(
          title: l10n.highestScore,
          value: '${maxValue.round()}%',
          icon: Icons.arrow_upward,
          iconColor: Colors.green,
        ),
        StatisticsCard(
          title: l10n.lowestScore,
          value: '${minValue.round()}%',
          icon: Icons.arrow_downward,
          iconColor: Colors.red,
        ),
        StatisticsCard(
          title: l10n.totalSessions,
          value: totalSessions.toString(),
          icon: Icons.quiz,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRecentSessionsHeader(
      BuildContext context, QuizLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.recentSessions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (widget.onViewAllSessions != null)
            TextButton(
              onPressed: widget.onViewAllSessions,
              child: Text(l10n.viewAll),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context, QuizLocalizations l10n) {
    return Column(
      children: widget.data.recentSessions.take(3).map((session) {
        return SessionCard(
          data: session,
          questionsLabel: l10n.questions,
          formatDate: (date) => _formatSessionDate(date, l10n),
          formatStatus: (status, isPerfect) =>
              _formatStatus(status, isPerfect, l10n),
          onTap: widget.onSessionTap != null
              ? () => widget.onSessionTap!(session)
              : null,
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

  String? _getTrendLabel(TrendType? type, QuizLocalizations l10n) {
    switch (type) {
      case TrendType.improving:
        return l10n.improving;
      case TrendType.declining:
        return l10n.declining;
      case TrendType.stable:
        return l10n.stable;
      case null:
        return null;
    }
  }

  String _getTimeRangeSubtitle(
      ProgressTimeRange range, QuizLocalizations l10n) {
    switch (range) {
      case ProgressTimeRange.week:
        return l10n.last7Days;
      case ProgressTimeRange.month:
        return l10n.last30Days;
      case ProgressTimeRange.quarter:
        return l10n.last90Days;
      case ProgressTimeRange.year:
        return l10n.last365Days;
      case ProgressTimeRange.allTime:
        return l10n.allTimeData;
    }
  }

  String _formatDuration(int seconds, QuizLocalizations l10n) {
    if (seconds < 60) {
      return '$seconds${l10n.seconds}';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '$minutes${l10n.minutes}';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours${l10n.hours} $minutes${l10n.minutes}';
    }
  }

  String _formatSessionDate(DateTime date, QuizLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }

  (String, Color) _formatStatus(
      String status, bool isPerfect, QuizLocalizations l10n) {
    if (isPerfect) {
      return (l10n.perfectScore, Colors.amber);
    }

    switch (status.toLowerCase()) {
      case 'completed':
        return (l10n.sessionCompleted, Colors.green);
      case 'cancelled':
        return (l10n.sessionCancelled, Colors.grey);
      case 'timeout':
        return (l10n.sessionTimeout, Colors.orange);
      case 'failed':
        return (l10n.sessionFailed, Colors.red);
      default:
        return (status, Colors.grey);
    }
  }
}

/// BLoC-compatible content widget for the statistics dashboard.
///
/// This widget receives all state and callbacks externally, making it
/// suitable for use with [StatisticsBloc] via [StatisticsDashboardBuilder].
class StatisticsDashboardContent extends StatefulWidget {
  /// Creates a [StatisticsDashboardContent].
  const StatisticsDashboardContent({
    super.key,
    required this.data,
    required this.selectedTab,
    required this.progressTimeRange,
    required this.leaderboardType,
    required this.onTabChanged,
    required this.onTimeRangeChanged,
    required this.onLeaderboardTypeChanged,
    required this.analyticsService,
    this.onSessionTap,
    this.onCategoryTap,
    this.onLeaderboardEntryTap,
    this.onViewAllSessions,
    this.showTabs = true,
    this.isRefreshing = false,
  });

  /// Dashboard data.
  final StatisticsDashboardData data;

  /// Currently selected tab.
  final StatisticsDashboardTab selectedTab;

  /// Currently selected progress time range.
  final ProgressTimeRange progressTimeRange;

  /// Currently selected leaderboard type.
  final LeaderboardType leaderboardType;

  /// Callback when tab changes.
  final void Function(StatisticsDashboardTab tab) onTabChanged;

  /// Callback when time range changes.
  final void Function(ProgressTimeRange range) onTimeRangeChanged;

  /// Callback when leaderboard type changes.
  final void Function(LeaderboardType type) onLeaderboardTypeChanged;

  /// Analytics service for tracking events.
  final AnalyticsService analyticsService;

  /// Callback when a session is tapped.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback when a category is tapped.
  final void Function(CategoryStatisticsData category)? onCategoryTap;

  /// Callback when a leaderboard entry is tapped.
  final void Function(LeaderboardEntry entry)? onLeaderboardEntryTap;

  /// Callback to view all sessions.
  final VoidCallback? onViewAllSessions;

  /// Whether to show tab navigation.
  final bool showTabs;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  @override
  State<StatisticsDashboardContent> createState() =>
      _StatisticsDashboardContentState();
}

class _StatisticsDashboardContentState extends State<StatisticsDashboardContent>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: widget.selectedTab.index,
    );
    _tabController.addListener(_handleTabControllerChange);
  }

  @override
  void didUpdateWidget(StatisticsDashboardContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync tab controller with external state
    if (widget.selectedTab != oldWidget.selectedTab &&
        _tabController.index != widget.selectedTab.index) {
      _tabController.animateTo(widget.selectedTab.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabControllerChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabControllerChange() {
    if (!_tabController.indexIsChanging) {
      final newTab = StatisticsDashboardTab.values[_tabController.index];
      if (newTab != widget.selectedTab) {
        // Log tab change event
        widget.analyticsService.logEvent(
          InteractionEvent.tabSelected(
            tabId: newTab.name,
            tabName: newTab.name,
            tabIndex: _tabController.index,
          ),
        );
        widget.onTabChanged(newTab);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    if (!widget.showTabs) {
      return SingleChildScrollView(
        child: _buildOverviewContent(context, l10n),
      );
    }

    return Column(
      children: [
        // Tab bar
        Material(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: [
              Tab(text: l10n.overview),
              Tab(text: l10n.progress),
              Tab(text: l10n.categories),
              Tab(text: l10n.leaderboard),
            ],
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(context, l10n),
              _buildProgressTab(context, l10n),
              _buildCategoriesTab(context, l10n),
              _buildLeaderboardTab(context, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, QuizLocalizations l10n) {
    return SingleChildScrollView(
      child: _buildOverviewContent(context, l10n),
    );
  }

  Widget _buildOverviewContent(BuildContext context, QuizLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview grid
        _buildSectionHeader(context, l10n.overview),
        _buildOverviewGrid(context, l10n),

        // Weekly trend
        if (widget.data.weeklyTrend != null &&
            widget.data.weeklyTrend!.isNotEmpty) ...[
          const SizedBox(height: 8),
          TrendsWidget(
            title: l10n.weeklyTrend,
            dataPoints: widget.data.weeklyTrend!,
            trend: widget.data.trendDirection,
            trendLabel: _getTrendLabel(widget.data.trendDirection, l10n),
          ),
        ],

        // Insights
        _buildSectionHeader(context, l10n.insights),
        _buildInsightsGrid(context, l10n),

        // Recent sessions
        if (widget.data.recentSessions.isNotEmpty) ...[
          _buildRecentSessionsHeader(context, l10n),
          _buildRecentSessions(context, l10n),
        ],

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProgressTab(BuildContext context, QuizLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: ProgressTimeRangeSelector(
              selectedRange: widget.progressTimeRange,
              onRangeChanged: widget.onTimeRangeChanged,
            ),
          ),

          // Progress chart
          ProgressChartWidget(
            dataPoints: widget.data.progressDataPoints,
            title: l10n.scoreOverTime,
            subtitle: _getTimeRangeSubtitle(widget.progressTimeRange, l10n),
            improvement: widget.data.progressImprovement,
          ),

          // Summary stats
          if (widget.data.progressDataPoints.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildProgressStats(context, l10n),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab(BuildContext context, QuizLocalizations l10n) {
    if (widget.data.categoryStatistics.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.category_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noCategoryData,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Category grid
          CategoryStatisticsGrid(
            categories: widget.data.categoryStatistics,
            onCategoryTap: widget.onCategoryTap,
          ),

          const SizedBox(height: 16),

          // Category list (detailed)
          CategoryStatisticsWidget(
            categories: widget.data.categoryStatistics,
            onCategoryTap: widget.onCategoryTap,
            sortBy: CategorySortBy.averageScore,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildLeaderboardTab(BuildContext context, QuizLocalizations l10n) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: LeaderboardTypeSelector(
              selectedType: widget.leaderboardType,
              onTypeChanged: widget.onLeaderboardTypeChanged,
            ),
          ),

          // Leaderboard
          LeaderboardWidget(
            entries: widget.data.leaderboardEntries,
            type: widget.leaderboardType,
            onEntryTap: widget.onLeaderboardEntryTap,
          ),

          // Coming Soon: Global Leaderboard
          _buildGlobalLeaderboardComingSoon(context, l10n),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboardComingSoon(
      BuildContext context, QuizLocalizations l10n) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.public,
                color: theme.colorScheme.primary.withValues(alpha: 0.7),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.globalLeaderboard,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.globalLeaderboardComingSoon,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.comingSoon,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
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

  Widget _buildOverviewGrid(BuildContext context, QuizLocalizations l10n) {
    final stats = widget.data.globalStatistics;

    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: l10n.totalSessions,
          value: stats.totalSessions.toString(),
          icon: Icons.quiz,
          iconColor: Colors.blue,
        ),
        StatisticsCard(
          title: l10n.totalQuestions,
          value: stats.totalQuestions.toString(),
          icon: Icons.help_outline,
          iconColor: Colors.purple,
        ),
        StatisticsCard(
          title: l10n.averageScore,
          value: '${stats.averageScore.round()}%',
          icon: Icons.score,
          iconColor: Colors.orange,
          trend: _getTrendDirection(widget.data.trendDirection),
        ),
        StatisticsCard(
          title: l10n.bestScore,
          value: '${stats.bestScore.round()}%',
          icon: Icons.emoji_events,
          iconColor: Colors.amber,
        ),
      ],
    );
  }

  Widget _buildInsightsGrid(BuildContext context, QuizLocalizations l10n) {
    final stats = widget.data.globalStatistics;

    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: l10n.accuracy,
          value: '${stats.accuracy.round()}%',
          icon: Icons.adjust,
          iconColor: Colors.teal,
        ),
        StatisticsCard(
          title: l10n.timePlayed,
          value: _formatDuration(stats.totalTimePlayed, l10n),
          icon: Icons.timer,
          iconColor: Colors.indigo,
        ),
        StatisticsCard(
          title: l10n.perfectScores,
          value: stats.perfectScores.toString(),
          icon: Icons.star,
          iconColor: Colors.amber,
        ),
        StatisticsCard(
          title: l10n.currentStreak,
          value: '${stats.currentStreak}',
          subtitle: '${l10n.bestStreak}: ${stats.bestStreak}',
          icon: Icons.local_fire_department,
          iconColor: Colors.deepOrange,
        ),
      ],
    );
  }

  Widget _buildProgressStats(BuildContext context, QuizLocalizations l10n) {
    final dataPoints = widget.data.progressDataPoints;
    if (dataPoints.isEmpty) return const SizedBox.shrink();

    final values = dataPoints.map((p) => p.value).toList();
    final avgValue = values.reduce((a, b) => a + b) / values.length;
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final totalSessions =
        dataPoints.map((p) => p.sessions).reduce((a, b) => a + b);

    return StatisticsGrid(
      children: [
        StatisticsCard(
          title: l10n.averageScore,
          value: '${avgValue.round()}%',
          icon: Icons.score,
          iconColor: Colors.blue,
        ),
        StatisticsCard(
          title: l10n.highestScore,
          value: '${maxValue.round()}%',
          icon: Icons.arrow_upward,
          iconColor: Colors.green,
        ),
        StatisticsCard(
          title: l10n.lowestScore,
          value: '${minValue.round()}%',
          icon: Icons.arrow_downward,
          iconColor: Colors.red,
        ),
        StatisticsCard(
          title: l10n.totalSessions,
          value: totalSessions.toString(),
          icon: Icons.quiz,
          iconColor: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildRecentSessionsHeader(
      BuildContext context, QuizLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l10n.recentSessions,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          if (widget.onViewAllSessions != null)
            TextButton(
              onPressed: widget.onViewAllSessions,
              child: Text(l10n.viewAll),
            ),
        ],
      ),
    );
  }

  Widget _buildRecentSessions(BuildContext context, QuizLocalizations l10n) {
    return Column(
      children: widget.data.recentSessions.take(3).map((session) {
        return SessionCard(
          data: session,
          questionsLabel: l10n.questions,
          formatDate: (date) => _formatSessionDate(date, l10n),
          formatStatus: (status, isPerfect) =>
              _formatStatus(status, isPerfect, l10n),
          onTap: widget.onSessionTap != null
              ? () => widget.onSessionTap!(session)
              : null,
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

  String? _getTrendLabel(TrendType? type, QuizLocalizations l10n) {
    switch (type) {
      case TrendType.improving:
        return l10n.improving;
      case TrendType.declining:
        return l10n.declining;
      case TrendType.stable:
        return l10n.stable;
      case null:
        return null;
    }
  }

  String _getTimeRangeSubtitle(
      ProgressTimeRange range, QuizLocalizations l10n) {
    switch (range) {
      case ProgressTimeRange.week:
        return l10n.last7Days;
      case ProgressTimeRange.month:
        return l10n.last30Days;
      case ProgressTimeRange.quarter:
        return l10n.last90Days;
      case ProgressTimeRange.year:
        return l10n.last365Days;
      case ProgressTimeRange.allTime:
        return l10n.allTimeData;
    }
  }

  String _formatDuration(int seconds, QuizLocalizations l10n) {
    if (seconds < 60) {
      return '$seconds${l10n.seconds}';
    } else if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '$minutes${l10n.minutes}';
    } else {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return '$hours${l10n.hours} $minutes${l10n.minutes}';
    }
  }

  String _formatSessionDate(DateTime date, QuizLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }

  (String, Color) _formatStatus(
      String status, bool isPerfect, QuizLocalizations l10n) {
    if (isPerfect) {
      return (l10n.perfectScore, Colors.amber);
    }

    switch (status.toLowerCase()) {
      case 'completed':
        return (l10n.sessionCompleted, Colors.green);
      case 'cancelled':
        return (l10n.sessionCancelled, Colors.grey);
      case 'timeout':
        return (l10n.sessionTimeout, Colors.orange);
      case 'failed':
        return (l10n.sessionFailed, Colors.red);
      default:
        return (status, Colors.grey);
    }
  }
}
