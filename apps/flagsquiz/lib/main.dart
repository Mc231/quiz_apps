import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'data/flags_categories.dart';
import 'data/flags_data_provider.dart';
import 'l10n/app_localizations.dart';
import 'ui/history/session_detail_page.dart';
import 'ui/settings/settings_screen.dart';

/// The entry point of the Flags Quiz application.
///
/// Uses [QuizApp] from quiz_engine for the main app structure with
/// [FlagsDataProvider] for loading country quiz data.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize settings service
  final settingsService = SettingsService();
  await settingsService.initialize();

  // Initialize shared services (including storage)
  await SharedServicesInitializer.initialize();

  runApp(
    FlagsQuizRoot(settingsService: settingsService),
  );
}

/// Root widget for the Flags Quiz app.
///
/// Wraps [QuizApp] and handles quiz navigation when a category is selected.
class FlagsQuizRoot extends StatelessWidget {
  /// Creates a [FlagsQuizRoot].
  const FlagsQuizRoot({
    super.key,
    required this.settingsService,
  });

  /// Settings service for app preferences.
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    final storageService = sl.get<StorageService>();
    final dataProvider = const FlagsDataProvider();

    return QuizApp(
      settingsService: settingsService,
      categories: createFlagsCategories(),
      config: QuizAppConfig(
        title: 'Flags Quiz',
        appLocalizationDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: _resolveLocale,
        useMaterial3: false,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      homeConfig: QuizHomeScreenConfig(
        tabConfig: QuizTabConfig.defaultConfig(),
        showSettingsInAppBar: true,
      ),
      callbacks: QuizAppCallbacks(
        onCategorySelected: (category) {
          // Navigation is handled by _FlagsQuizNavigator
        },
        onSettingsPressed: () {
          // Settings navigation handled via settingsBuilder
        },
      ),
      historyDataProvider: () => _loadHistoryData(storageService),
      statisticsDataProvider: () => _loadStatisticsData(storageService),
      settingsBuilder: (context) => SettingsScreen(
        settingsService: settingsService,
      ),
      homeBuilder: (context) => _FlagsQuizNavigator(
        settingsService: settingsService,
        storageService: storageService,
        dataProvider: dataProvider,
      ),
    );
  }

  Locale _resolveLocale(Locale? locale, Iterable<Locale> supportedLocales) {
    if (locale != null && supportedLocales.contains(locale)) {
      return locale;
    }
    return const Locale('en');
  }

  Future<HistoryTabData> _loadHistoryData(StorageService storageService) async {
    try {
      final result = await storageService.getRecentSessions(limit: 100);
      List<SessionCardData> sessions = [];

      result.ifSuccess((sessionList) {
        sessions = sessionList.map(_convertSessionToCardData).toList();
      });

      return HistoryTabData(sessions: sessions);
    } catch (e) {
      return const HistoryTabData();
    }
  }

  Future<StatisticsTabData> _loadStatisticsData(
    StorageService storageService,
  ) async {
    try {
      final statsResult = await storageService.getGlobalStatistics();
      final sessionsResult = await storageService.getRecentSessions(limit: 3);
      final trendResult = await storageService.getStatisticsTrend(7);

      GlobalStatistics? statistics;
      List<QuizSession> recentSessions = [];
      StatisticsTrend? trend;

      statsResult.ifSuccess((stats) => statistics = stats);
      sessionsResult.ifSuccess((sessions) => recentSessions = sessions);
      trendResult.ifSuccess((t) => trend = t);

      return StatisticsTabData(
        statistics: _convertStatistics(statistics, trend),
        recentSessions: recentSessions.map(_convertSessionToCardData).toList(),
      );
    } catch (e) {
      return StatisticsTabData.empty();
    }
  }

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

/// Navigator widget that handles quiz navigation.
///
/// This widget wraps QuizHomeScreen and handles navigation to
/// the quiz screen when a category is selected.
class _FlagsQuizNavigator extends StatefulWidget {
  const _FlagsQuizNavigator({
    required this.settingsService,
    required this.storageService,
    required this.dataProvider,
  });

  final SettingsService settingsService;
  final StorageService storageService;
  final FlagsDataProvider dataProvider;

  @override
  State<_FlagsQuizNavigator> createState() => _FlagsQuizNavigatorState();
}

class _FlagsQuizNavigatorState extends State<_FlagsQuizNavigator> {
  @override
  Widget build(BuildContext context) {
    return QuizHomeScreen(
      categories: createFlagsCategories(),
      config: QuizHomeScreenConfig(
        tabConfig: QuizTabConfig.defaultConfig(),
        showSettingsInAppBar: true,
      ),
      onCategorySelected: (category) => _startQuiz(context, category),
      onSettingsPressed: () => _openSettings(context),
      onSessionTap: (session) => _openSessionDetail(context, session),
      historyDataProvider: _loadHistoryData,
      statisticsDataProvider: _loadStatisticsData,
      formatDate: (date) => _formatDate(context, date),
      formatStatus: (status, isPerfect) => _formatStatus(context, status, isPerfect),
      formatDuration: (seconds) => _formatDuration(context, seconds),
    );
  }

  void _startQuiz(BuildContext context, QuizCategory category) async {
    final l10n = AppLocalizations.of(context)!;

    // Load questions
    final questions = await widget.dataProvider.loadQuestions(context, category);

    // Create quiz texts
    final texts = widget.dataProvider.createQuizTexts(context, category);

    // Create storage config
    final storageConfig = widget.dataProvider.createStorageConfig(context, category) ??
        StorageConfig(
          enabled: true,
          quizType: 'flags',
          quizName: category.title(context),
          quizCategory: category.id,
        );

    // Create base quiz config with storage config
    final baseConfig = QuizConfig(
      quizId: category.id,
      hintConfig: HintConfig.noHints(),
      storageConfig: storageConfig,
    );

    // Create storage adapter
    final storageAdapter = QuizStorageAdapter(widget.storageService);

    // Create config manager that applies user settings
    final configManager = ConfigManager(
      defaultConfig: baseConfig,
      getSettings: () => {
        'soundEnabled': widget.settingsService.currentSettings.soundEnabled,
        'hapticEnabled': widget.settingsService.currentSettings.hapticEnabled,
        'showAnswerFeedback':
            widget.settingsService.currentSettings.showAnswerFeedback,
      },
    );

    // Navigate to quiz
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => QuizWidget(
            quizEntry: QuizWidgetEntry(
              texts: texts ?? QuizTexts(
                title: category.title(context),
                gameOverText: l10n.yourScore,
                exitDialogTitle: l10n.exitDialogTitle,
                exitDialogMessage: l10n.exitDialogMessage,
                exitDialogConfirm: l10n.exitDialogConfirm,
                exitDialogCancel: l10n.exitDialogCancel,
                correctFeedback: l10n.correctFeedback,
                incorrectFeedback: l10n.incorrectFeedback,
                hint5050Label: l10n.hint5050Label,
                hintSkipLabel: l10n.hintSkipLabel,
                timerSecondsSuffix: l10n.timerSecondsSuffix,
                videoLoadError: l10n.videoLoadError,
              ),
              dataProvider: () async => questions,
              configManager: configManager,
              storageService: storageAdapter,
            ),
          ),
        ),
      );
    }
  }

  void _openSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          settingsService: widget.settingsService,
        ),
      ),
    );
  }

  void _openSessionDetail(BuildContext context, SessionCardData sessionData) async {
    final result = await widget.storageService.getRecentSessions(limit: 100);

    result.ifSuccess((sessions) {
      final session = sessions.firstWhere(
        (s) => s.id == sessionData.id,
        orElse: () => sessions.first,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SessionDetailPage(
            session: session,
            storageService: widget.storageService,
            onDeleted: () {
              // Refresh data after deletion
              setState(() {});
            },
          ),
        ),
      );
    });
  }

  Future<HistoryTabData> _loadHistoryData() async {
    try {
      final result = await widget.storageService.getRecentSessions(limit: 100);
      List<SessionCardData> sessions = [];

      result.ifSuccess((sessionList) {
        sessions = sessionList.map(_convertSessionToCardData).toList();
      });

      return HistoryTabData(sessions: sessions);
    } catch (e) {
      return const HistoryTabData();
    }
  }

  Future<StatisticsTabData> _loadStatisticsData() async {
    try {
      final statsResult = await widget.storageService.getGlobalStatistics();
      final sessionsResult = await widget.storageService.getRecentSessions(limit: 3);
      final trendResult = await widget.storageService.getStatisticsTrend(7);

      GlobalStatistics? statistics;
      List<QuizSession> recentSessions = [];
      StatisticsTrend? trend;

      statsResult.ifSuccess((stats) => statistics = stats);
      sessionsResult.ifSuccess((sessions) => recentSessions = sessions);
      trendResult.ifSuccess((t) => trend = t);

      return StatisticsTabData(
        statistics: _convertStatistics(statistics, trend),
        recentSessions: recentSessions.map(_convertSessionToCardData).toList(),
      );
    } catch (e) {
      return StatisticsTabData.empty();
    }
  }

  SessionCardData _convertSessionToCardData(QuizSession session) {
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
      case 'eu':
        return l10n.europe;
      case 'as':
        return l10n.asia;
      case 'af':
        return l10n.africa;
      case 'na':
        return l10n.northAmerica;
      case 'sa':
        return l10n.southAmerica;
      case 'oc':
        return l10n.oceania;
      default:
        return quizId;
    }
  }

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

  String _formatDate(BuildContext context, DateTime date) {
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

  (String, Color) _formatStatus(
    BuildContext context,
    String status,
    bool isPerfect,
  ) {
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

  String _formatDuration(BuildContext context, int seconds) {
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
}
