import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../achievements/screens/achievements_screen.dart';
import '../services/quiz_services_context.dart';
import '../achievements/widgets/achievement_card.dart';
import '../app/quiz_tab.dart';
import '../l10n/quiz_localizations.dart';
import '../models/quiz_category.dart';
import '../screens/session_detail_screen.dart';
import '../screens/session_history_screen.dart';
import '../screens/statistics_dashboard_screen.dart';
import '../screens/statistics_screen.dart';
import '../utils/default_data_loader.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/question_review_widget.dart';
import '../widgets/session_card.dart';
import 'category_card.dart';
import 'play_screen.dart';
import 'play_screen_tab.dart';
import 'tabbed_play_screen.dart';

/// Default empty tab config for const initialization.
const _emptyTabConfig = QuizTabConfig(tabs: []);

/// Configuration for the QuizHomeScreen.
class QuizHomeScreenConfig {
  /// Tab configuration.
  final QuizTabConfig tabConfig;

  /// Configuration for the PlayScreen.
  final PlayScreenConfig playScreenConfig;

  /// Optional tabs for TabbedPlayScreen.
  ///
  /// When provided, uses [TabbedPlayScreen] instead of [PlayScreen].
  /// Each tab can be a [CategoriesTab], [PracticeTab], or [CustomContentTab].
  final List<PlayScreenTab>? playScreenTabs;

  /// Initial tab ID for TabbedPlayScreen.
  ///
  /// Only used when [playScreenTabs] is provided.
  final String? initialPlayTabId;

  /// Configuration for TabbedPlayScreen.
  ///
  /// Only used when [playScreenTabs] is provided.
  final TabbedPlayScreenConfig? tabbedPlayScreenConfig;

  /// Whether to show settings button in app bar.
  final bool showSettingsInAppBar;

  /// Custom app bar actions.
  final List<Widget>? appBarActions;

  /// Creates a [QuizHomeScreenConfig].
  const QuizHomeScreenConfig({
    this.tabConfig = _emptyTabConfig,
    this.playScreenConfig = const PlayScreenConfig(),
    this.playScreenTabs,
    this.initialPlayTabId,
    this.tabbedPlayScreenConfig,
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

/// A home screen widget with bottom navigation for quiz apps.
///
/// Integrates PlayScreen, SessionHistoryScreen, and StatisticsScreen
/// with configurable tabs and navigation.
///
/// Storage service is obtained from [QuizServicesProvider] via context,
/// enabling default data loading and session navigation automatically:
///
/// ```dart
/// // Minimal usage with defaults (services from context)
/// QuizHomeScreen(
///   categories: myCategories,
///   onCategorySelected: (category) => navigateToQuiz(category),
///   onSettingsPressed: () => openSettings(),
/// )
///
/// // Or with custom data providers
/// QuizHomeScreen(
///   categories: myCategories,
///   historyDataProvider: () => loadHistoryData(),
///   statisticsDataProvider: () => loadStatisticsData(),
///   onSessionTap: (session) => openSessionDetail(session),
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
  ///
  /// When storage service is available from context and this is null,
  /// default navigation to [SessionDetailScreen] is used.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback when "View All Sessions" is tapped in Statistics.
  final VoidCallback? onViewAllSessions;

  /// Data provider for the History tab.
  ///
  /// Called when the History tab is selected or refreshed.
  /// If null, default loading is used via storage service from context.
  final Future<HistoryTabData> Function()? historyDataProvider;

  /// Data provider for the Statistics tab.
  ///
  /// Called when the Statistics tab is selected or refreshed.
  /// If null, default loading is used via storage service from context.
  final Future<StatisticsTabData> Function()? statisticsDataProvider;

  /// Data provider for the Achievements tab.
  ///
  /// Called when the Achievements tab is selected or refreshed.
  /// Must be provided if Achievements tab is in tabs.
  final Future<AchievementsTabData> Function()? achievementsDataProvider;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData achievement)? onAchievementTap;

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

  /// Callback when a session is deleted.
  ///
  /// Called after successful deletion from [SessionDetailScreen].
  final VoidCallback? onSessionDeleted;

  /// Creates a [QuizHomeScreen].
  ///
  /// Services (analytics, storage) are obtained from [QuizServicesProvider] via context.
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
    this.achievementsDataProvider,
    this.onAchievementTap,
    this.settingsBuilder,
    this.isPlayLoading = false,
    this.formatDate,
    this.formatStatus,
    this.formatDuration,
    this.onSessionDeleted,
  });

  @override
  State<QuizHomeScreen> createState() => _QuizHomeScreenState();
}

class _QuizHomeScreenState extends State<QuizHomeScreen>
    with WidgetsBindingObserver {
  late int _currentIndex;
  HistoryTabData _historyData = const HistoryTabData();
  StatisticsTabData _statisticsData = StatisticsTabData.empty();
  StatisticsDashboardData? _dashboardData;
  bool _dashboardLoading = false;
  AchievementsTabData _achievementsData = AchievementsTabData.empty();
  DefaultDataLoader? _dataLoader;
  bool _dataLoaderInitialized = false;

  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  /// Gets the storage service from context.
  StorageService get _storageService => context.storageService;

  List<QuizTab> get _tabs {
    final configTabs = widget.config.tabConfig.tabs;
    return configTabs.isNotEmpty ? configTabs : QuizTabConfig.defaultConfig().tabs;
  }

  /// Whether default data loading is enabled.
  bool get _useDefaults => _dataLoader != null;

  /// Gets the effective history data provider.
  Future<HistoryTabData> Function()? get _effectiveHistoryProvider {
    if (widget.historyDataProvider != null) {
      return widget.historyDataProvider;
    }
    if (_useDefaults && _dataLoader != null) {
      return () => _dataLoader!.loadHistoryData();
    }
    return null;
  }

  /// Gets the effective statistics data provider.
  Future<StatisticsTabData> Function()? get _effectiveStatisticsProvider {
    if (widget.statisticsDataProvider != null) {
      return widget.statisticsDataProvider;
    }
    if (_useDefaults && _dataLoader != null) {
      return () => _dataLoader!.loadStatisticsData();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.config.tabConfig.initialIndex;

    // Defer data loader initialization and data loading to after first frame
    // when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDataLoader();
      _loadDataForCurrentTab();
      _trackInitialScreenView();
    });
  }

  /// Initializes the data loader using storage service from context.
  void _initializeDataLoader() {
    if (!_dataLoaderInitialized && mounted) {
      _dataLoader = DefaultDataLoader(_storageService);
      _dataLoaderInitialized = true;
    }
  }

  /// Tracks the initial screen view when the home screen loads.
  void _trackInitialScreenView() {
    final currentTab = _tabs[_currentIndex];
    final screenEvent = ScreenViewEvent.home(activeTab: _getTabId(currentTab));
    _analyticsService.logEvent(screenEvent);
    _analyticsService.setCurrentScreen(
      screenName: screenEvent.screenName,
      screenClass: screenEvent.screenClass,
    );
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload data when app is resumed to ensure fresh statistics
    if (state == AppLifecycleState.resumed) {
      _loadDataForCurrentTab();
    }
  }

  void _loadDataForCurrentTab() {
    if (_currentIndex >= 0 && _currentIndex < _tabs.length) {
      final tab = _tabs[_currentIndex];
      if (tab is HistoryTab) {
        _loadHistoryData();
      } else if (tab is StatisticsTab) {
        _loadStatisticsData();
      } else if (tab is AchievementsTab) {
        _loadAchievementsData();
      }
    }
  }

  Future<void> _loadHistoryData() async {
    final provider = _effectiveHistoryProvider;
    if (provider == null) return;

    setState(() {
      _historyData = const HistoryTabData(isLoading: true);
    });

    try {
      final data = await provider();
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
    // Use dashboard data loading when using default data loader
    if (_useDefaults && _dataLoader != null) {
      await _loadDashboardData();
      return;
    }

    // Fall back to legacy statistics provider
    final provider = _effectiveStatisticsProvider;
    if (provider == null) return;

    setState(() {
      _statisticsData = StatisticsTabData(
        statistics: _statisticsData.statistics,
        recentSessions: _statisticsData.recentSessions,
        isLoading: true,
      );
    });

    try {
      final data = await provider();
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

  Future<void> _loadDashboardData() async {
    if (_dataLoader == null) return;

    setState(() {
      _dashboardLoading = true;
    });

    try {
      final data = await _dataLoader!.loadDashboardData();
      if (mounted) {
        setState(() {
          _dashboardData = data;
          _dashboardLoading = false;
          // Also update legacy statistics data for compatibility
          _statisticsData = StatisticsTabData(
            statistics: data.globalStatistics,
            recentSessions: data.recentSessions,
          );
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _dashboardData = StatisticsDashboardData.empty;
          _dashboardLoading = false;
          _statisticsData = StatisticsTabData.empty();
        });
      }
    }
  }

  Future<void> _loadAchievementsData() async {
    final provider = widget.achievementsDataProvider;
    if (provider == null) return;

    setState(() {
      _achievementsData = AchievementsTabData(
        screenData: _achievementsData.screenData,
        isLoading: true,
      );
    });

    try {
      final data = await provider();
      if (mounted) {
        setState(() {
          _achievementsData = data;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _achievementsData = AchievementsTabData.empty();
        });
      }
    }
  }

  /// Handles session tap with default navigation if no callback provided.
  void _handleSessionTap(SessionCardData session) {
    if (widget.onSessionTap != null) {
      widget.onSessionTap!(session);
      return;
    }

    // Use default navigation if storageService is available
    if (_useDefaults && _dataLoader != null) {
      _navigateToSessionDetail(session);
    }
  }

  /// Navigates to the default session detail screen.
  Future<void> _navigateToSessionDetail(SessionCardData sessionData) async {
    final sessionWithAnswers =
        await _dataLoader!.getSessionWithAnswers(sessionData.id);
    if (sessionWithAnswers == null || !mounted) return;

    final l10n = QuizL10n.of(context);
    final texts = _createSessionDetailTexts(l10n);
    final detailData = _convertToSessionDetailData(
      sessionWithAnswers.session,
      sessionWithAnswers.answers,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'session_detail'),
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(texts.title),
          ),
          body: SessionDetailScreen(
            session: detailData,
            texts: texts,
            onDelete: () => _deleteSession(
              sessionWithAnswers.session.id,
              quizName: sessionWithAnswers.session.quizName,
              startTime: sessionWithAnswers.session.startTime,
            ),
            imageBuilder: _buildQuestionImage,
          ),
        ),
      ),
    );
  }

  /// Builds an image widget for question review.
  ///
  /// Handles both local assets and network images.
  Widget _buildQuestionImage(String path) {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        height: 120,
        errorBuilder: (context, error, stackTrace) => const SizedBox(
          height: 120,
          child: Center(child: Icon(Icons.broken_image, size: 48)),
        ),
      );
    }
    return Image.asset(
      path,
      fit: BoxFit.contain,
      height: 120,
      errorBuilder: (context, error, stackTrace) => const SizedBox(
        height: 120,
        child: Center(child: Icon(Icons.broken_image, size: 48)),
      ),
    );
  }

  /// Creates session detail texts from localizations.
  SessionDetailTexts _createSessionDetailTexts(QuizLocalizations l10n) {
    return SessionDetailTexts(
      title: l10n.sessionDetails,
      reviewAnswersLabel: l10n.reviewAnswers,
      practiceWrongAnswersLabel: l10n.practiceWrongAnswers,
      exportLabel: l10n.exportSession,
      deleteLabel: l10n.delete,
      scoreLabel: l10n.score,
      correctLabel: l10n.correct,
      incorrectLabel: l10n.incorrect,
      skippedLabel: l10n.skipped,
      durationLabel: l10n.duration,
      questionLabel: (n) => l10n.questionNumber(n),
      yourAnswerLabel: l10n.yourAnswer,
      correctAnswerLabel: l10n.correctAnswer,
      formatDate: widget.formatDate ?? _defaultFormatDate,
      formatStatus: widget.formatStatus ?? _defaultFormatStatus,
      deleteDialogTitle: l10n.deleteSession,
      deleteDialogMessage: l10n.deleteSessionMessage,
      cancelLabel: l10n.cancel,
    );
  }

  /// Converts a QuizSession to SessionDetailData.
  SessionDetailData _convertToSessionDetailData(
    QuizSession session,
    List<QuestionAnswer> answers,
  ) {
    return SessionDetailData(
      id: session.id,
      quizName: session.quizName,
      totalQuestions: session.totalQuestions,
      totalCorrect: session.totalCorrect,
      totalIncorrect: session.totalFailed,
      totalSkipped: session.totalSkipped,
      scorePercentage: session.scorePercentage,
      completionStatus: session.completionStatus.name,
      startTime: session.startTime,
      durationSeconds: session.durationSeconds,
      quizCategory: session.quizCategory,
      questions: answers.map(_convertToReviewedQuestion).toList(),
    );
  }

  /// Converts a QuestionAnswer to ReviewedQuestion.
  ReviewedQuestion _convertToReviewedQuestion(QuestionAnswer answer) {
    return ReviewedQuestion(
      questionNumber: answer.questionNumber,
      questionText: answer.questionContent ?? '',
      correctAnswer: answer.correctAnswer.text,
      userAnswer: answer.userAnswer?.text,
      isCorrect: answer.isCorrect,
      isSkipped: answer.answerStatus == AnswerStatus.skipped,
      explanation: answer.explanation,
      questionImagePath: answer.questionResourceUrl,
    );
  }

  /// Deletes a session and refreshes data.
  Future<void> _deleteSession(
    String sessionId, {
    String? quizName,
    DateTime? startTime,
  }) async {
    await _storageService.deleteSession(sessionId);

    // Log analytics event
    if (quizName != null && startTime != null) {
      final daysAgo = DateTime.now().difference(startTime).inDays;
      _analyticsService.logEvent(
        InteractionEvent.sessionDeleted(
          sessionId: sessionId,
          quizName: quizName,
          daysAgo: daysAgo,
        ),
      );
    }

    // Refresh data
    _loadHistoryData();
    _loadStatisticsData();

    // Notify callback
    widget.onSessionDeleted?.call();

    // Pop back to home
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _onTabSelected(int index) {
    final isSameTab = index == _currentIndex;
    final previousTabId = isSameTab ? null : _getTabId(_tabs[_currentIndex]);

    if (!isSameTab) {
      setState(() {
        _currentIndex = index;
      });

      // Notify callback
      widget.config.tabConfig.onTabSelected?.call(_tabs[index], index);

      // Track tab selection analytics
      final newTab = _tabs[index];
      _trackTabSelected(newTab, index, previousTabId);
    }

    // Always reload data for the tab (even if already selected)
    // This ensures fresh data when tapping an already-selected tab
    _loadDataForCurrentTab();
  }

  /// Gets a string identifier for a tab.
  String _getTabId(QuizTab tab) {
    return switch (tab) {
      PlayTab() => 'play',
      HistoryTab() => 'history',
      StatisticsTab() => 'statistics',
      SettingsTab() => 'settings',
      AchievementsTab() => 'achievements',
      CustomTab(:final id) => id,
    };
  }

  /// Gets a display name for a tab.
  String _getTabName(QuizTab tab) {
    return switch (tab) {
      PlayTab() => 'Play',
      HistoryTab() => 'History',
      StatisticsTab() => 'Statistics',
      SettingsTab() => 'Settings',
      AchievementsTab() => 'Achievements',
      CustomTab(:final labelBuilder) => labelBuilder(context),
    };
  }

  /// Tracks tab selection analytics event.
  void _trackTabSelected(QuizTab tab, int index, String? previousTabId) {
    final event = InteractionEvent.tabSelected(
      tabId: _getTabId(tab),
      tabName: _getTabName(tab),
      tabIndex: index,
      previousTabId: previousTabId,
    );

    _analyticsService.logEvent(event);
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
    final l10n = QuizL10n.of(context);
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
          tooltip: QuizL10n.of(context).settings,
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
      AchievementsTab() => _buildAchievementsTab(context),
      CustomTab(:final builder) => builder(context),
    };
  }

  Widget _buildPlayTab(BuildContext context) {
    // Show loading indicator if loading
    if (widget.isPlayLoading) {
      return const LoadingIndicator();
    }

    final l10n = QuizL10n.of(context);

    // Build tabs - use configured tabs or create default from categories
    final tabs = widget.config.playScreenTabs ??
        [
          PlayScreenTab.categories(
            id: 'all',
            label: l10n.play,
            categories: widget.categories,
          ),
        ];

    return TabbedPlayScreen(
      tabs: tabs,
      initialTabId: widget.config.initialPlayTabId,
      onCategorySelected: widget.onCategorySelected,
      onSettingsPressed: widget.onSettingsPressed,
      config: widget.config.tabbedPlayScreenConfig ??
          TabbedPlayScreenConfig(
            showAppBar: false,
            playScreenConfig:
                widget.config.playScreenConfig.copyWith(showAppBar: false),
          ),
    );
  }

  Widget _buildHistoryTab(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final texts = _createHistoryTexts(l10n);

    return SessionHistoryScreen(
      sessions: _historyData.sessions,
      texts: texts,
      isLoading: _historyData.isLoading,
      onSessionTap: _handleSessionTap,
      onRefresh: _effectiveHistoryProvider != null ? _loadHistoryData : null,
    );
  }

  Widget _buildStatisticsTab(BuildContext context) {
    // Use full dashboard data when available
    final dashboardData = _dashboardData ??
        StatisticsDashboardData(
          globalStatistics: _statisticsData.statistics,
          recentSessions: _statisticsData.recentSessions,
          weeklyTrend: _statisticsData.statistics.weeklyTrend,
          trendDirection: _statisticsData.statistics.trendDirection,
        );

    return StatisticsDashboardScreen(
      data: dashboardData,
      isLoading: _dashboardLoading || _statisticsData.isLoading,
      onSessionTap: _handleSessionTap,
      onViewAllSessions: widget.onViewAllSessions,
      // Show tabs for enhanced UI - can be disabled with showTabs: false
      showTabs: true,
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
            QuizL10n.of(context).settings,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsTab(BuildContext context) {
    // Show loading indicator while loading
    if (_achievementsData.isLoading &&
        _achievementsData.screenData.achievements.isEmpty) {
      return const LoadingIndicator();
    }

    return AchievementsScreen(
      data: _achievementsData.screenData,
      onAchievementTap: widget.onAchievementTap,
      onRefresh: widget.achievementsDataProvider != null
          ? _loadAchievementsData
          : null,
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

  String _defaultFormatDate(DateTime date) {
    final l10n = QuizL10n.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);

    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return l10n.today;
    if (difference == 1) return l10n.yesterday;
    return l10n.daysAgo(difference);
  }

  (String, Color) _defaultFormatStatus(String status, bool isPerfect) {
    final l10n = QuizL10n.of(context);

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

  Widget _buildBottomNavigation(BuildContext context) {
    final l10n = QuizL10n.of(context);

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
      AchievementsTab() => l10n.achievements,
      CustomTab() => tab.labelBuilder(context),
    };
  }
}

/// BLoC-compatible content widget for home screen tabs.
///
/// This widget receives tab data and callbacks externally, making it
/// suitable for use with [HomeBloc] via [HomeBuilder].
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class HomeTabContent extends StatelessWidget {
  /// Creates a [HomeTabContent].
  const HomeTabContent({
    super.key,
    required this.currentTabIndex,
    required this.historySessions,
    required this.historyTexts,
    this.isHistoryLoading = false,
    this.dashboardData,
    this.isDashboardLoading = false,
    this.achievementsData,
    this.isAchievementsLoading = false,
    this.onSessionTap,
    this.onViewAllSessions,
    this.onAchievementTap,
    this.onRefreshHistory,
    this.onRefreshStatistics,
    this.onRefreshAchievements,
  });

  /// Current tab index.
  final int currentTabIndex;

  /// Sessions for history tab.
  final List<SessionCardData> historySessions;

  /// Texts for history screen.
  final SessionHistoryTexts historyTexts;

  /// Whether history is loading.
  final bool isHistoryLoading;

  /// Dashboard data for statistics tab.
  final StatisticsDashboardData? dashboardData;

  /// Whether dashboard is loading.
  final bool isDashboardLoading;

  /// Achievements data for achievements tab.
  final AchievementsScreenData? achievementsData;

  /// Whether achievements are loading.
  final bool isAchievementsLoading;

  /// Callback when a session is tapped.
  final void Function(SessionCardData session)? onSessionTap;

  /// Callback when view all sessions is tapped.
  final VoidCallback? onViewAllSessions;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData achievement)? onAchievementTap;

  /// Callback to refresh history.
  final Future<void> Function()? onRefreshHistory;

  /// Callback to refresh statistics.
  final Future<void> Function()? onRefreshStatistics;

  /// Callback to refresh achievements.
  final Future<void> Function()? onRefreshAchievements;

  /// Builds the history tab content.
  Widget buildHistoryTab(BuildContext context) {
    return SessionHistoryScreen(
      sessions: historySessions,
      texts: historyTexts,
      isLoading: isHistoryLoading,
      onSessionTap: onSessionTap ?? (_) {},
      onRefresh: onRefreshHistory,
    );
  }

  /// Builds the statistics tab content.
  Widget buildStatisticsTab(BuildContext context) {
    if (dashboardData == null && !isDashboardLoading) {
      return const LoadingIndicator();
    }

    return StatisticsDashboardScreen(
      data: dashboardData ?? StatisticsDashboardData.empty,
      isLoading: isDashboardLoading,
      onSessionTap: onSessionTap,
      onViewAllSessions: onViewAllSessions,
      showTabs: true,
    );
  }

  /// Builds the achievements tab content.
  Widget buildAchievementsTab(BuildContext context) {
    if (achievementsData == null && !isAchievementsLoading) {
      return const LoadingIndicator();
    }

    return AchievementsScreen(
      data: achievementsData ?? const AchievementsScreenData.empty(),
      onAchievementTap: onAchievementTap,
      onRefresh: onRefreshAchievements,
    );
  }

  @override
  Widget build(BuildContext context) {
    // This widget is typically used within a tab-switching context
    // Individual tab builders are provided for flexibility
    return const SizedBox.shrink();
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
