import 'package:flutter/material.dart';

import '../app/quiz_tab.dart';
import '../l10n/quiz_localizations.dart';
import '../models/quiz_category.dart';
import '../screens/session_history_screen.dart';
import '../screens/statistics_screen.dart';
import '../widgets/session_card.dart';
import 'category_card.dart';
import 'play_screen.dart';

/// Default empty tab config for const initialization.
const _emptyTabConfig = QuizTabConfig(tabs: []);

/// Configuration for the QuizHomeScreen.
class QuizHomeScreenConfig {
  /// Tab configuration.
  final QuizTabConfig tabConfig;

  /// Configuration for the PlayScreen.
  final PlayScreenConfig playScreenConfig;

  /// Whether to show settings button in app bar.
  final bool showSettingsInAppBar;

  /// Custom app bar actions.
  final List<Widget>? appBarActions;

  /// Creates a [QuizHomeScreenConfig].
  const QuizHomeScreenConfig({
    this.tabConfig = _emptyTabConfig,
    this.playScreenConfig = const PlayScreenConfig(),
    this.showSettingsInAppBar = false,
    this.appBarActions,
  });

  /// Default configuration with Play, History, and Statistics tabs.
  factory QuizHomeScreenConfig.defaultConfig() {
    return QuizHomeScreenConfig(
      tabConfig: QuizTabConfig.defaultConfig(),
    );
  }
}

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

/// A home screen widget with bottom navigation for quiz apps.
///
/// Integrates PlayScreen, SessionHistoryScreen, and StatisticsScreen
/// with configurable tabs and navigation.
///
/// Example:
/// ```dart
/// QuizHomeScreen(
///   categories: myCategories,
///   config: QuizHomeScreenConfig.defaultConfig(),
///   onCategorySelected: (category) => navigateToQuiz(category),
///   historyDataProvider: () => loadHistoryData(),
///   statisticsDataProvider: () => loadStatisticsData(),
/// )
/// ```
class QuizHomeScreen extends StatefulWidget {
  /// Categories to display in the Play tab.
  final List<QuizCategory> categories;

  /// Configuration for the home screen.
  final QuizHomeScreenConfig config;

  /// Callback when a category is selected in the Play tab.
  final void Function(QuizCategory category)? onCategorySelected;

  /// Callback when settings is pressed.
  final VoidCallback? onSettingsPressed;

  /// Callback when a session is tapped in History/Statistics.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback when "View All Sessions" is tapped in Statistics.
  final VoidCallback? onViewAllSessions;

  /// Data provider for the History tab.
  /// Called when the History tab is selected or refreshed.
  final Future<HistoryTabData> Function()? historyDataProvider;

  /// Data provider for the Statistics tab.
  /// Called when the Statistics tab is selected or refreshed.
  final Future<StatisticsTabData> Function()? statisticsDataProvider;

  /// Builder for the Settings tab content.
  /// If not provided and Settings tab is in tabs, a placeholder is shown.
  final Widget Function(BuildContext context)? settingsBuilder;

  /// Whether the Play tab is loading.
  final bool isPlayLoading;

  /// Date formatter for session cards.
  final DateFormatter? formatDate;

  /// Status formatter for session cards.
  final StatusFormatter? formatStatus;

  /// Duration formatter for statistics.
  final String Function(int seconds)? formatDuration;

  /// Creates a [QuizHomeScreen].
  const QuizHomeScreen({
    super.key,
    required this.categories,
    this.config = const QuizHomeScreenConfig(),
    this.onCategorySelected,
    this.onSettingsPressed,
    this.onSessionTap,
    this.onViewAllSessions,
    this.historyDataProvider,
    this.statisticsDataProvider,
    this.settingsBuilder,
    this.isPlayLoading = false,
    this.formatDate,
    this.formatStatus,
    this.formatDuration,
  });

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen> {
  late int _currentIndex;
  HistoryTabData _historyData = const HistoryTabData();
  StatisticsTabData _statisticsData = StatisticsTabData.empty();

  List<QuizTab> get _tabs {
    final configTabs = widget.config.tabConfig.tabs;
    return configTabs.isNotEmpty ? configTabs : QuizTabConfig.defaultConfig().tabs;
  }

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.config.tabConfig.initialIndex;
    _loadDataForCurrentTab();
  }

  void _loadDataForCurrentTab() {
    if (_currentIndex >= 0 && _currentIndex < _tabs.length) {
      final tab = _tabs[_currentIndex];
      if (tab is HistoryTab) {
        _loadHistoryData();
      } else if (tab is StatisticsTab) {
        _loadStatisticsData();
      }
    }
  }

  Future<void> _loadHistoryData() async {
    if (widget.historyDataProvider == null) return;

    setState(() {
      _historyData = const HistoryTabData(isLoading: true);
    });

    try {
      final data = await widget.historyDataProvider!();
      if (mounted) {
        setState(() {
          _historyData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _historyData = const HistoryTabData();
        });
      }
    }
  }

  Future<void> _loadStatisticsData() async {
    if (widget.statisticsDataProvider == null) return;

    setState(() {
      _statisticsData = StatisticsTabData(
        statistics: _statisticsData.statistics,
        recentSessions: _statisticsData.recentSessions,
        isLoading: true,
      );
    });

    try {
      final data = await widget.statisticsDataProvider!();
      if (mounted) {
        setState(() {
          _statisticsData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _statisticsData = StatisticsTabData.empty();
        });
      }
    }
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    // Notify callback
    widget.config.tabConfig.onTabSelected?.call(_tabs[index], index);

    // Load data for the new tab
    _loadDataForCurrentTab();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final l10n = QuizLocalizations.of(context);
    final currentTab = _tabs[_currentIndex];
    final title = _getTabTitle(context, currentTab, l10n);

    return AppBar(
      title: Text(title),
      actions: _buildAppBarActions(context),
    );
  }

  String _getTabTitle(
    BuildContext context,
    QuizTab tab,
    QuizLocalizations l10n,
  ) {
    // Use custom config title for Play tab if provided
    if (tab is PlayTab && widget.config.playScreenConfig.title != null) {
      return widget.config.playScreenConfig.title!;
    }

    // Use tab's label builder
    return tab.labelBuilder(context);
  }

  List<Widget>? _buildAppBarActions(BuildContext context) {
    final actions = <Widget>[];

    // Add custom actions
    if (widget.config.appBarActions != null) {
      actions.addAll(widget.config.appBarActions!);
    }

    // Add settings action if configured
    if (widget.config.showSettingsInAppBar && widget.onSettingsPressed != null) {
      actions.add(
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: widget.onSettingsPressed,
          tooltip: QuizLocalizations.of(context).settings,
        ),
      );
    }

    return actions.isEmpty ? null : actions;
  }

  Widget _buildBody(BuildContext context) {
    if (widget.config.tabConfig.preserveState) {
      return IndexedStack(
        index: _currentIndex,
        children: _tabs.map((tab) => _buildTabContent(context, tab)).toList(),
      );
    }

    return _buildTabContent(context, _tabs[_currentIndex]);
  }

  Widget _buildTabContent(BuildContext context, QuizTab tab) {
    return switch (tab) {
      PlayTab() => _buildPlayTab(context),
      HistoryTab() => _buildHistoryTab(context),
      StatisticsTab() => _buildStatisticsTab(context),
      SettingsTab() => _buildSettingsTab(context),
      CustomTab(:final builder) => builder(context),
    };
  }

  Widget _buildPlayTab(BuildContext context) {
    return PlayScreen(
      categories: widget.categories,
      config: widget.config.playScreenConfig.copyWith(showAppBar: false),
      onCategorySelected: widget.onCategorySelected,
      onSettingsPressed: widget.onSettingsPressed,
      isLoading: widget.isPlayLoading,
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final l10n = QuizLocalizations.of(context);
    final texts = _createHistoryTexts(l10n);

    return SessionHistoryScreen(
      sessions: _historyData.sessions,
      texts: texts,
      isLoading: _historyData.isLoading,
      onSessionTap: widget.onSessionTap ?? (_) {},
      onRefresh: widget.historyDataProvider != null ? _loadHistoryData : null,
    );
  }

  Widget _buildStatisticsTab(BuildContext context) {
    final l10n = QuizLocalizations.of(context);
    final texts = _createStatisticsTexts(l10n);

    return StatisticsScreen(
      statistics: _statisticsData.statistics,
      texts: texts,
      recentSessions: _statisticsData.recentSessions,
      isLoading: _statisticsData.isLoading,
      onSessionTap: widget.onSessionTap,
      onViewAllSessions: widget.onViewAllSessions,
    );
  }

  Widget _buildSettingsTab(BuildContext context) {
    if (widget.settingsBuilder != null) {
      return widget.settingsBuilder!(context);
    }

    // Default placeholder
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.settings,
            size: 64,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            QuizLocalizations.of(context).settings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  SessionHistoryTexts _createHistoryTexts(QuizLocalizations l10n) {
    return SessionHistoryTexts(
      title: l10n.history,
      emptyTitle: l10n.noSessionsYet,
      emptySubtitle: l10n.startPlayingToSee,
      questionsLabel: l10n.questions,
      formatDate: widget.formatDate ?? _defaultFormatDate,
      formatStatus: widget.formatStatus ?? _defaultFormatStatus,
    );
  }

  StatisticsTexts _createStatisticsTexts(QuizLocalizations l10n) {
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
      formatDate: widget.formatDate ?? _defaultFormatDate,
      formatStatus: widget.formatStatus ?? _defaultFormatStatus,
      formatDuration: widget.formatDuration ?? _defaultFormatDuration,
    );
  }

  String _defaultFormatDate(DateTime date) {
    final l10n = QuizLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return l10n.daysAgo(difference);
  }

  (String, Color) _defaultFormatStatus(String status, bool isPerfect) {
    final l10n = QuizLocalizations.of(context);

    if (isPerfect) {
      return (l10n.perfectScore, Colors.amber);
    }

    switch (status.toLowerCase()) {
      case 'completed':
        return (l10n.sessionCompleted, Colors.green);
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

  String _defaultFormatDuration(int seconds) {
    final l10n = QuizLocalizations.of(context);
    if (seconds < 60) {
      return '$seconds ${l10n.seconds}';
    }
    if (seconds < 3600) {
      final minutes = seconds ~/ 60;
      return '$minutes ${l10n.minutes}';
    }
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (minutes == 0) {
      return '$hours ${l10n.hours}';
    }
    return '$hours ${l10n.hours} $minutes ${l10n.minutes}';
  }

  Widget _buildBottomNavigation(BuildContext context) {
    final l10n = QuizLocalizations.of(context);

    return NavigationBar(
      selectedIndex: _currentIndex,
      onDestinationSelected: _onTabSelected,
      destinations: _tabs.map((tab) {
        return NavigationDestination(
          icon: Icon(tab.icon),
          selectedIcon: Icon(tab.effectiveSelectedIcon),
          label: _getNavigationLabel(context, tab, l10n),
        );
      }).toList(),
    );
  }

  String _getNavigationLabel(
    BuildContext context,
    QuizTab tab,
    QuizLocalizations l10n,
  ) {
    // Use localized strings for built-in tabs
    return switch (tab) {
      PlayTab() => l10n.play,
      HistoryTab() => l10n.history,
      StatisticsTab() => l10n.statistics,
      SettingsTab() => l10n.settings,
      CustomTab() => tab.labelBuilder(context),
    };
  }
}

/// Extension to add copyWith to PlayScreenConfig.
extension PlayScreenConfigCopyWith on PlayScreenConfig {
  /// Creates a copy with the given fields replaced.
  PlayScreenConfig copyWith({
    String? title,
    PlayScreenLayout? layout,
    int? gridColumnsMobile,
    int? gridColumnsTablet,
    int? gridColumnsDesktop,
    double? gridAspectRatio,
    double? itemSpacing,
    EdgeInsets? padding,
    CategoryCardStyle? cardStyle,
    bool? showSettingsAction,
    List<Widget>? appBarActions,
    bool? showAppBar,
    Widget? emptyStateWidget,
    Widget? loadingWidget,
  }) {
    return PlayScreenConfig(
      title: title ?? this.title,
      layout: layout ?? this.layout,
      gridColumnsMobile: gridColumnsMobile ?? this.gridColumnsMobile,
      gridColumnsTablet: gridColumnsTablet ?? this.gridColumnsTablet,
      gridColumnsDesktop: gridColumnsDesktop ?? this.gridColumnsDesktop,
      gridAspectRatio: gridAspectRatio ?? this.gridAspectRatio,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      padding: padding ?? this.padding,
      cardStyle: cardStyle ?? this.cardStyle,
      showSettingsAction: showSettingsAction ?? this.showSettingsAction,
      appBarActions: appBarActions ?? this.appBarActions,
      showAppBar: showAppBar ?? this.showAppBar,
      emptyStateWidget: emptyStateWidget ?? this.emptyStateWidget,
      loadingWidget: loadingWidget ?? this.loadingWidget,
    );
  }
}
