import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;

import '../achievements/achievement_notification_controller.dart';
import '../achievements/widgets/achievement_card.dart';
import '../home/play_screen_tab.dart';
import '../home/quiz_home_screen.dart';
import '../home/quiz_home_config.dart';
import '../home/tabbed_play_screen_config.dart';
import '../home/quiz_home_data.dart';
import '../l10n/quiz_localizations.dart';
import '../l10n/quiz_localizations_delegate.dart';
import '../models/quiz_category.dart';
import '../models/quiz_data_provider.dart';
import '../models/achievements_data_provider.dart';
import '../models/practice_data_provider.dart';
import '../models/challenge_mode.dart';
import '../quiz_widget.dart';
import '../quiz_widget_entry.dart';
import '../screens/challenges_screen.dart';
import '../screens/practice_start_screen.dart';
import '../screens/practice_complete_screen.dart';
import '../services/quiz_services.dart';
import '../services/quiz_services_context.dart';
import '../services/quiz_services_provider.dart';
import '../settings/quiz_settings_screen.dart';
import '../settings/quiz_settings_config.dart';
import '../widgets/layout_mode_selector.dart';
import '../widgets/practice_empty_state.dart';
import '../widgets/restore_resource_dialog.dart';
import '../widgets/session_card.dart';
import '../rate_app/rate_app_config_provider.dart';
import '../share/share_bottom_sheet.dart';
import 'play_tab_type.dart';
import 'quiz_tab.dart';

/// Configuration for rate app prompts in the quiz results screen.
///
/// When configured, the quiz results screen will automatically check
/// conditions and show rate app prompts when appropriate.
class RateAppUiConfig {
  /// The app name to display in the love dialog.
  final String appName;

  /// Optional app icon widget to display in the love dialog.
  final Widget? appIcon;

  /// Optional email address for feedback submissions.
  final String? feedbackEmail;

  /// Delay in seconds before showing rate app dialog after results appear.
  /// Default is 2 seconds to let users see their results first.
  final int delaySeconds;

  /// Creates a [RateAppUiConfig].
  const RateAppUiConfig({
    required this.appName,
    this.appIcon,
    this.feedbackEmail,
    this.delaySeconds = 2,
  });
}

/// Configuration for the QuizApp.
///
/// Provides customization options for theming, localization,
/// navigation, and app behavior.
class QuizAppConfig {
  /// The application title shown in task switcher.
  final String? title;

  /// Custom light theme for the app.
  final ThemeData? lightTheme;

  /// Custom dark theme for the app.
  final ThemeData? darkTheme;

  /// Whether to show the debug banner.
  final bool debugShowCheckedModeBanner;

  /// Whether to use Material 3 design.
  final bool useMaterial3;

  /// Additional localization delegates from the app.
  ///
  /// These are combined with the engine's localization delegate.
  final List<LocalizationsDelegate<dynamic>> appLocalizationDelegates;

  /// Supported locales for the app.
  final List<Locale> supportedLocales;

  /// Custom locale resolution callback.
  final Locale? Function(Locale?, Iterable<Locale>)? localeResolutionCallback;

  /// Navigation observers for analytics, etc.
  final List<NavigatorObserver> navigatorObservers;

  /// Primary color for theming.
  final Color? primaryColor;

  /// Scaffold background color.
  final Color? scaffoldBackgroundColor;

  /// App bar theme configuration.
  final AppBarTheme? appBarTheme;

  /// Configuration for rate app prompts.
  ///
  /// When provided, quiz results screen will automatically show
  /// rate app prompts when conditions are met.
  final RateAppUiConfig? rateAppConfig;

  /// Creates a [QuizAppConfig].
  const QuizAppConfig({
    this.title,
    this.lightTheme,
    this.darkTheme,
    this.debugShowCheckedModeBanner = false,
    this.useMaterial3 = true,
    this.appLocalizationDelegates = const [],
    this.supportedLocales = const [Locale('en')],
    this.localeResolutionCallback,
    this.navigatorObservers = const [],
    this.primaryColor,
    this.scaffoldBackgroundColor,
    this.appBarTheme,
    this.rateAppConfig,
  });

  /// Creates a copy with modified fields.
  QuizAppConfig copyWith({
    String? title,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
    bool? debugShowCheckedModeBanner,
    bool? useMaterial3,
    List<LocalizationsDelegate<dynamic>>? appLocalizationDelegates,
    List<Locale>? supportedLocales,
    Locale? Function(Locale?, Iterable<Locale>)? localeResolutionCallback,
    List<NavigatorObserver>? navigatorObservers,
    Color? primaryColor,
    Color? scaffoldBackgroundColor,
    AppBarTheme? appBarTheme,
    RateAppUiConfig? rateAppConfig,
  }) {
    return QuizAppConfig(
      title: title ?? this.title,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      debugShowCheckedModeBanner:
          debugShowCheckedModeBanner ?? this.debugShowCheckedModeBanner,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      appLocalizationDelegates:
          appLocalizationDelegates ?? this.appLocalizationDelegates,
      supportedLocales: supportedLocales ?? this.supportedLocales,
      localeResolutionCallback:
          localeResolutionCallback ?? this.localeResolutionCallback,
      navigatorObservers: navigatorObservers ?? this.navigatorObservers,
      primaryColor: primaryColor ?? this.primaryColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      appBarTheme: appBarTheme ?? this.appBarTheme,
      rateAppConfig: rateAppConfig ?? this.rateAppConfig,
    );
  }
}

/// Callbacks for QuizApp events.
///
/// Provides hooks for handling various app events like category selection,
/// session taps, and navigation.
class QuizAppCallbacks {
  /// Called when a category is selected in the Play tab.
  final void Function(QuizCategory category)? onCategorySelected;

  /// Called when settings button is pressed.
  final VoidCallback? onSettingsPressed;

  /// Called when a session is tapped in History/Statistics.
  final void Function(SessionCardData session)? onSessionTap;

  /// Called when "View All Sessions" is tapped in Statistics.
  final VoidCallback? onViewAllSessions;

  /// Creates [QuizAppCallbacks].
  const QuizAppCallbacks({
    this.onCategorySelected,
    this.onSettingsPressed,
    this.onSessionTap,
    this.onViewAllSessions,
  });
}

/// The root widget for a quiz application.
///
/// QuizApp provides:
/// - MaterialApp setup with theming
/// - Localization (engine + app delegates)
/// - Settings-based theme mode switching
/// - Navigation observer support
/// - QuizHomeScreen integration
/// - QuizServicesProvider for dependency injection
///
/// ## Basic Usage
///
/// ```dart
/// QuizApp(
///   services: QuizServices(
///     settingsService: settingsService,
///     storageService: storageService,
///     achievementService: achievementService,
///     screenAnalyticsService: analyticsService,
///     quizAnalyticsService: quizAnalyticsService,
///   ),
///   categories: myCategories,
///   callbacks: QuizAppCallbacks(
///     onCategorySelected: (category) => startQuiz(category),
///   ),
/// )
/// ```
///
/// ## With Custom Home Widget
///
/// ```dart
/// QuizApp(
///   services: services,
///   homeBuilder: (context) => MyCustomHomeScreen(),
/// )
/// ```
///
/// ## With Full Configuration
///
/// ```dart
/// QuizApp(
///   services: services,
///   categories: categories,
///   config: QuizAppConfig(
///     title: 'My Quiz App',
///     appLocalizationDelegates: AppLocalizations.localizationsDelegates,
///     supportedLocales: AppLocalizations.supportedLocales,
///     navigatorObservers: [FirebaseAnalyticsObserver()],
///   ),
///   homeConfig: QuizHomeScreenConfig(
///     tabConfig: QuizTabConfig.allTabs(),
///   ),
/// )
/// ```
class QuizApp extends StatefulWidget {
  /// All core services for the quiz app.
  ///
  /// Services are made available to all descendant widgets via
  /// [QuizServicesProvider] and can be accessed using:
  /// - `QuizServicesProvider.of(context)`
  /// - `context.services` (using the extension)
  /// - `context.settingsService`, `context.storageService`, etc.
  final QuizServices services;

  /// Categories to display in the Play tab.
  ///
  /// Required if [homeBuilder] is not provided.
  final List<QuizCategory>? categories;

  /// Data provider for loading quiz questions and configuration.
  ///
  /// When provided, QuizApp handles all navigation automatically:
  /// - Starting a quiz when category is selected
  /// - Opening settings screen
  ///
  /// If not provided, you must handle navigation via [callbacks].
  final QuizDataProvider? dataProvider;

  /// Configuration for the QuizHomeScreen.
  final QuizHomeScreenConfig homeConfig;

  /// Callbacks for app events.
  final QuizAppCallbacks callbacks;

  /// App configuration.
  final QuizAppConfig config;

  /// Custom home widget builder.
  ///
  /// If provided, this is used instead of the default QuizHomeScreen.
  final Widget Function(BuildContext context)? homeBuilder;

  /// Data provider for the History tab.
  final Future<HistoryTabData> Function()? historyDataProvider;

  /// Data provider for the Statistics tab.
  final Future<StatisticsTabData> Function()? statisticsDataProvider;

  /// Data provider for the Achievements tab.
  ///
  /// When provided, [QuizApp] will automatically call [onSessionCompleted]
  /// after a quiz is completed. This integrates achievement checking
  /// without requiring external callback wiring.
  final AchievementsDataProvider? achievementsDataProvider;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData achievement)? onAchievementTap;

  /// Additional callback invoked when a quiz is completed.
  ///
  /// Use this for app-specific processing like analytics or custom logic.
  /// Note: Achievement checking is handled automatically via [achievementsDataProvider].
  final void Function(QuizResults results)? onQuizCompleted;

  /// Types of tabs to show in the Play screen.
  ///
  /// When provided, [QuizApp] internally builds the tabs based on these types:
  /// - [PlayTabType.quiz]: Uses [categories] for category selection
  /// - [PlayTabType.challenges]: Uses [challenges] to build ChallengesScreen
  /// - [PlayTabType.practice]: Uses [practiceDataProvider] for practice mode
  ///
  /// If not provided, falls back to [homeConfig.playScreenTabs].
  final Set<PlayTabType>? playTabTypes;

  /// List of challenge modes to show in the Challenges tab.
  ///
  /// Required when [playTabTypes] contains [PlayTabType.challenges].
  final List<ChallengeMode>? challenges;

  /// Builder for layout mode options in the Challenges screen category picker.
  ///
  /// When provided, users can select a layout mode (e.g., Standard, Reverse)
  /// before starting a challenge. The selected layout is applied to the quiz.
  ///
  /// The builder receives a [BuildContext] to access localization:
  /// ```dart
  /// challengeLayoutModeOptionsBuilder: (context) {
  ///   final l10n = AppLocalizations.of(context)!;
  ///   return [
  ///     LayoutModeOption(id: 'standard', label: l10n.standard, ...),
  ///     LayoutModeOption(id: 'reverse', label: l10n.reverse, ...),
  ///   ];
  /// }
  /// ```
  ///
  /// If not provided, challenges use the default layout from the category.
  final List<LayoutModeOption> Function(BuildContext)? challengeLayoutModeOptionsBuilder;

  /// Title for the layout mode selector in the Challenges category picker.
  ///
  /// Can be a function that receives context for localization.
  final String Function(BuildContext)? challengeLayoutModeSelectorTitleBuilder;

  /// Builder for layout mode options in the Play screen.
  ///
  /// When provided, users can select a layout mode (e.g., Standard, Reverse)
  /// at the top of the Play screen. The selected layout is persisted in settings
  /// and applied to all quizzes started from the Play tab.
  ///
  /// The builder receives a [BuildContext] to access localization:
  /// ```dart
  /// playLayoutModeOptionsBuilder: (context) {
  ///   final l10n = AppLocalizations.of(context)!;
  ///   return [
  ///     LayoutModeOption(id: 'standard', label: l10n.standard, ...),
  ///     LayoutModeOption(id: 'reverse', label: l10n.reverse, ...),
  ///   ];
  /// }
  /// ```
  ///
  /// If not provided, the Play screen shows no layout selector and uses
  /// the default layout from the data provider.
  final List<LayoutModeOption> Function(BuildContext)? playLayoutModeOptionsBuilder;

  /// Title for the layout mode selector in the Play screen.
  ///
  /// Can be a function that receives context for localization.
  final String Function(BuildContext)? playLayoutModeSelectorTitleBuilder;

  /// Data provider for the Practice tab.
  ///
  /// When provided, [QuizApp] will:
  /// - Load practice questions using [PracticeDataProvider.loadPracticeData]
  /// - Mark questions as practiced after practice session completes
  /// - Update practice progress when regular quizzes complete
  ///
  /// This integrates the full practice mode experience without requiring
  /// external callback wiring.
  final PracticeDataProvider? practiceDataProvider;

  /// Callback invoked when achievements are unlocked.
  ///
  /// Returns the list of newly unlocked achievements. Use this to show
  /// notifications or play sounds when achievements are unlocked.
  final void Function(List<Achievement> achievements)? onAchievementsUnlocked;

  /// Whether to show achievement notifications automatically.
  ///
  /// When true, a banner notification will be shown when achievements
  /// are unlocked. Defaults to true.
  final bool showAchievementNotifications;

  /// Builder for the Settings tab content.
  ///
  /// If not provided and Settings tab is in tabs, uses [QuizSettingsScreen].
  final Widget Function(BuildContext context)? settingsBuilder;

  /// Configuration for the built-in settings screen.
  ///
  /// Used when [settingsBuilder] is not provided.
  final QuizSettingsConfig? settingsConfig;

  /// Locale override.
  final Locale? locale;

  /// Date formatter for session cards.
  final DateFormatter? formatDate;

  /// Status formatter for session cards.
  final StatusFormatter? formatStatus;

  /// Duration formatter for statistics.
  final String Function(int seconds)? formatDuration;

  /// Optional configuration for the share bottom sheet.
  ///
  /// When [ShareService] is configured in [QuizServices], a "Share" button
  /// will appear on the results screen. This config customizes the UI.
  final ShareBottomSheetConfig? shareConfig;

  /// Creates a [QuizApp].
  const QuizApp({
    super.key,
    required this.services,
    this.categories,
    this.dataProvider,
    this.homeConfig = const QuizHomeScreenConfig(),
    this.callbacks = const QuizAppCallbacks(),
    this.config = const QuizAppConfig(),
    this.homeBuilder,
    this.historyDataProvider,
    this.statisticsDataProvider,
    this.achievementsDataProvider,
    this.onAchievementTap,
    this.onQuizCompleted,
    this.playTabTypes = const {...PlayTabType.values},
    this.challenges,
    this.challengeLayoutModeOptionsBuilder,
    this.challengeLayoutModeSelectorTitleBuilder,
    this.playLayoutModeOptionsBuilder,
    this.playLayoutModeSelectorTitleBuilder,
    this.practiceDataProvider,
    this.onAchievementsUnlocked,
    this.showAchievementNotifications = true,
    this.settingsBuilder,
    this.settingsConfig,
    this.locale,
    this.formatDate,
    this.formatStatus,
    this.formatDuration,
    this.shareConfig,
  });

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  late QuizSettings _currentSettings;
  late StreamSubscription<QuizSettings> _settingsSubscription;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  AchievementNotificationController? _notificationController;
  StreamSubscription<List<Achievement>>? _achievementSubscription;

  // Convenience getters for services
  QuizServices get _services => widget.services;
  SettingsService get _settingsService => _services.settingsService;
  StorageService get _storageService => _services.storageService;
  AchievementService get _achievementService => _services.achievementService;
  AnalyticsService get _screenAnalyticsService => _services.screenAnalyticsService;
  QuizAnalyticsService get _quizAnalyticsService => _services.quizAnalyticsService;

  @override
  void initState() {
    super.initState();
    _currentSettings = _settingsService.currentSettings;
    _settingsSubscription = _settingsService.settingsStream.listen(
      _onSettingsChanged,
    );

    // Create notification controller if notifications are enabled
    if (widget.showAchievementNotifications) {
      _notificationController = AchievementNotificationController(
        analyticsService: _screenAnalyticsService,
      );

      // Listen to achievement unlocks
      _achievementSubscription = _achievementService
          .onAchievementsUnlocked
          .listen(_showAchievementNotifications);
    }
  }

  void _onSettingsChanged(QuizSettings settings) {
    if (mounted) {
      setState(() {
        _currentSettings = settings;
      });
    }
  }

  @override
  void dispose() {
    _settingsSubscription.cancel();
    _achievementSubscription?.cancel();
    _notificationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget app = QuizServicesProvider(
      services: _services,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: widget.config.title ?? '',
        debugShowCheckedModeBanner: widget.config.debugShowCheckedModeBanner,
        theme: _buildLightTheme(),
        darkTheme: _buildDarkTheme(),
        themeMode: _currentSettings.flutterThemeMode,
        localizationsDelegates: _buildLocalizationDelegates(),
        supportedLocales: widget.config.supportedLocales,
        locale: widget.locale,
        localeResolutionCallback:
            widget.config.localeResolutionCallback ??
            _defaultLocaleResolutionCallback,
        navigatorObservers: widget.config.navigatorObservers,
        home: _wrapWithNotifications(_buildHome(context)),
      ),
    );

    // Wrap with RateAppConfigProvider if rate app is configured
    final rateAppConfig = widget.config.rateAppConfig;
    if (rateAppConfig != null) {
      app = RateAppConfigProvider(
        config: rateAppConfig,
        child: app,
      );
    }

    return app;
  }

  Widget _wrapWithNotifications(Widget child) {
    if (_notificationController == null) {
      return child;
    }

    return AchievementNotifications(
      controller: _notificationController,
      child: child,
    );
  }

  /// Shows achievement notifications for the given achievements.
  void _showAchievementNotifications(List<Achievement> achievements) {
    final controller = _notificationController;
    if (controller == null) return;

    for (final achievement in achievements) {
      controller.show(achievement);
    }

    // Also call the user's callback
    widget.onAchievementsUnlocked?.call(achievements);
  }

  ThemeData _buildLightTheme() {
    if (widget.config.lightTheme != null) {
      return widget.config.lightTheme!;
    }

    return ThemeData(
      useMaterial3: widget.config.useMaterial3,
      primaryColor: widget.config.primaryColor ?? Colors.white,
      scaffoldBackgroundColor:
          widget.config.scaffoldBackgroundColor ?? Colors.white,
      appBarTheme: widget.config.appBarTheme ?? const AppBarTheme(elevation: 0),
      visualDensity: VisualDensity.adaptivePlatformDensity,
    );
  }

  ThemeData _buildDarkTheme() {
    if (widget.config.darkTheme != null) {
      return widget.config.darkTheme!;
    }

    return ThemeData.dark(useMaterial3: widget.config.useMaterial3);
  }

  List<LocalizationsDelegate<dynamic>> _buildLocalizationDelegates() {
    return [
      const QuizLocalizationsDelegate(),
      ...widget.config.appLocalizationDelegates,
    ];
  }

  Locale _defaultLocaleResolutionCallback(
    Locale? locale,
    Iterable<Locale> supportedLocales,
  ) {
    if (locale != null && supportedLocales.contains(locale)) {
      return locale;
    }
    return const Locale('en');
  }

  Widget _buildHome(BuildContext context) {
    if (widget.homeBuilder != null) {
      return widget.homeBuilder!(context);
    }

    // When dataProvider is provided, QuizApp handles navigation internally
    final hasDataProvider = widget.dataProvider != null;

    // Use Builder to get a context inside MaterialApp with localizations
    return Builder(
      builder: (innerContext) {
        // Build the config with play tabs if playTabTypes is provided
        // Pass context for localization
        final homeConfig = _buildHomeConfig(innerContext);

        return QuizHomeScreen(
          categories: widget.categories ?? [],
          config: homeConfig,
          onCategorySelected:
              hasDataProvider
                  ? (category) =>
                      _handleCategorySelected(innerContext, category)
                  : widget.callbacks.onCategorySelected != null
                  ? (category) {
                    _trackCategorySelected(innerContext, category);
                    widget.callbacks.onCategorySelected!(category);
                  }
                  : null,
          onSettingsPressed:
              hasDataProvider
                  ? () => _openSettings(innerContext)
                  : widget.callbacks.onSettingsPressed,
          onSessionTap: widget.callbacks.onSessionTap,
          onViewAllSessions: widget.callbacks.onViewAllSessions,
          historyDataProvider: widget.historyDataProvider,
          statisticsDataProvider: widget.statisticsDataProvider,
          achievementsDataProvider:
              widget.achievementsDataProvider != null
                  ? () =>
                      widget.achievementsDataProvider!.loadAchievementsData()
                  : null,
          onAchievementTap: widget.onAchievementTap,
          settingsBuilder: _buildSettingsBuilder(),
          formatDate: widget.formatDate,
          formatStatus: widget.formatStatus,
          formatDuration: widget.formatDuration,
          // Services (analytics, storage) are obtained from QuizServicesProvider via context
        );
      },
    );
  }

  /// Builds the home config, optionally generating play tabs from [playTabTypes].
  QuizHomeScreenConfig _buildHomeConfig(BuildContext context) {
    // If playTabTypes is not provided, use the original config
    if (widget.playTabTypes == null) {
      return widget.homeConfig;
    }

    // Build play screen tabs from the enum set
    final playTabs = _buildPlayScreenTabs(context);

    // Build tabbed play screen config with layout options
    final tabbedConfig = _buildTabbedPlayScreenConfig(context);

    // Return config with the generated tabs
    return QuizHomeScreenConfig(
      tabConfig: widget.homeConfig.tabConfig,
      playScreenConfig: widget.homeConfig.playScreenConfig,
      playScreenTabs: playTabs.isNotEmpty ? playTabs : null,
      initialPlayTabId: widget.homeConfig.initialPlayTabId,
      tabbedPlayScreenConfig: tabbedConfig,
      showSettingsInAppBar: widget.homeConfig.showSettingsInAppBar,
      appBarActions: widget.homeConfig.appBarActions,
    );
  }

  /// Builds the tabbed play screen config with layout options.
  ///
  /// Always sets `showAppBar: false` since [QuizHomeScreen] provides the app bar.
  TabbedPlayScreenConfig _buildTabbedPlayScreenConfig(BuildContext context) {
    final baseConfig = widget.homeConfig.tabbedPlayScreenConfig ??
        const TabbedPlayScreenConfig();
    final layoutOptions = widget.playLayoutModeOptionsBuilder?.call(context);

    // If no layout options, return config with showAppBar disabled
    if (layoutOptions == null || layoutOptions.isEmpty) {
      return TabbedPlayScreenConfig(
        title: baseConfig.title,
        showAppBar: false, // QuizHomeScreen provides the app bar
        showSettingsAction: baseConfig.showSettingsAction,
        appBarActions: baseConfig.appBarActions,
        tabBarIndicatorColor: baseConfig.tabBarIndicatorColor,
        tabBarLabelColor: baseConfig.tabBarLabelColor,
        tabBarUnselectedLabelColor: baseConfig.tabBarUnselectedLabelColor,
        tabBarIndicatorWeight: baseConfig.tabBarIndicatorWeight,
        tabBarIsScrollable: baseConfig.tabBarIsScrollable,
        playScreenConfig: baseConfig.playScreenConfig,
      );
    }

    // Get selected mode from settings
    final selectedModeId = _settingsService.currentSettings.preferredLayoutModeId;

    return TabbedPlayScreenConfig(
      title: baseConfig.title,
      showAppBar: false, // QuizHomeScreen provides the app bar
      showSettingsAction: baseConfig.showSettingsAction,
      appBarActions: baseConfig.appBarActions,
      tabBarIndicatorColor: baseConfig.tabBarIndicatorColor,
      tabBarLabelColor: baseConfig.tabBarLabelColor,
      tabBarUnselectedLabelColor: baseConfig.tabBarUnselectedLabelColor,
      tabBarIndicatorWeight: baseConfig.tabBarIndicatorWeight,
      tabBarIsScrollable: baseConfig.tabBarIsScrollable,
      playScreenConfig: baseConfig.playScreenConfig,
      layoutModeOptions: layoutOptions,
      layoutModeSelectorTitle: widget.playLayoutModeSelectorTitleBuilder?.call(context),
      selectedLayoutModeId: selectedModeId,
      onLayoutModeChanged: (option) {
        _settingsService.setPreferredLayoutMode(option.id);
        // Force rebuild to update the UI with the new selection
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  /// Builds play screen tabs from [playTabTypes].
  List<PlayScreenTab> _buildPlayScreenTabs(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final tabs = <PlayScreenTab>[];
    final types = widget.playTabTypes ?? {};

    for (final type in types) {
      switch (type) {
        case PlayTabType.quiz:
          tabs.add(
            PlayScreenTab.categories(
              id: 'quiz',
              label: l10n.play,
              icon: Icons.play_arrow,
              categories: widget.categories ?? [],
            ),
          );
        case PlayTabType.challenges:
          if (widget.challenges != null && widget.dataProvider != null) {
            tabs.add(
              PlayScreenTab.custom(
                id: 'challenges',
                label: l10n.challenges,
                icon: Icons.emoji_events,
                builder:
                    (context) => ChallengesScreen(
                      challenges: widget.challenges!,
                      categories: widget.categories ?? [],
                      dataProvider: widget.dataProvider!,
                      layoutModeOptions: widget.challengeLayoutModeOptionsBuilder?.call(context),
                      layoutModeSelectorTitle: widget.challengeLayoutModeSelectorTitleBuilder?.call(context),
                      onQuizCompleted: _handleQuizCompleted,
                      shareConfig: widget.shareConfig,
                    ),
              ),
            );
          }
        case PlayTabType.practice:
          // Only add practice tab if practiceDataProvider is configured
          if (widget.practiceDataProvider != null) {
            tabs.add(
              PlayScreenTab.custom(
                id: 'practice',
                label: l10n.practiceMode,
                icon: Icons.school,
                builder:
                    (ctx) => _PracticeTabContent(
                      practiceDataProvider: widget.practiceDataProvider!,
                      dataProvider: widget.dataProvider,
                      onPracticeCompleted: _handlePracticeCompleted,
                      onStartQuiz: () => _navigateToPlayTab(),
                    ),
              ),
            );
          }
      }
    }

    return tabs;
  }

  Widget Function(BuildContext)? _buildSettingsBuilder() {
    if (widget.settingsBuilder != null) {
      return widget.settingsBuilder;
    }

    // Check if settings tab is in the tabs
    final tabs =
        widget.homeConfig.tabConfig.tabs.isNotEmpty
            ? widget.homeConfig.tabConfig.tabs
            : QuizTabConfig.defaultConfig().tabs;

    final hasSettingsTab = tabs.any((tab) => tab is SettingsTab);

    if (!hasSettingsTab) {
      return null;
    }

    // Provide default settings screen
    return (context) => QuizSettingsScreen(
      config:
          widget.settingsConfig ?? const QuizSettingsConfig(showAppBar: false),
    );
  }

  /// Handles category selection with analytics tracking.
  void _handleCategorySelected(BuildContext context, QuizCategory category) {
    _trackCategorySelected(context, category);
    _startQuiz(context, category);
  }

  /// Tracks the category_selected analytics event.
  void _trackCategorySelected(BuildContext context, QuizCategory category) {
    // Get the category index from the categories list
    final categories = widget.categories ?? [];
    final categoryIndex = categories.indexOf(category);

    final event = InteractionEvent.categorySelected(
      categoryId: category.id,
      categoryName: category.title(context),
      categoryIndex: categoryIndex >= 0 ? categoryIndex : 0,
    );

    _screenAnalyticsService.logEvent(event);
  }

  /// Starts a quiz for the given category.
  ///
  /// This is called when [dataProvider] is provided and handles:
  /// - Pre-quiz lives validation (shows restore dialog if no lives)
  /// - Loading questions from the data provider
  /// - Creating quiz configuration
  /// - Navigating to the QuizWidget
  /// - Calling [achievementsDataProvider.onSessionCompleted] after quiz ends
  Future<void> _startQuiz(BuildContext context, QuizCategory category) async {
    final dataProvider = widget.dataProvider;
    final storageService = _storageService;
    final resourceManager = _services.resourceManager;

    if (dataProvider == null) {
      // Fallback to callback if no data provider
      widget.callbacks.onCategorySelected?.call(category);
      return;
    }

    // Create quiz config to check if lives mode is enabled
    final quizConfig =
        dataProvider.createQuizConfig(context, category) ??
        QuizConfig(quizId: category.id, hintConfig: HintConfig.noHints());

    // Pre-quiz lives validation:
    // Check if this quiz uses lives mode and ResourceManager is available
    final usesLives = quizConfig.modeConfig.lives != null;
    if (usesLives && resourceManager.isInitialized) {
      final livesAvailable = resourceManager.isAvailable(ResourceType.lives());

      // If no lives available, show restore dialog
      if (!livesAvailable && context.mounted) {
        final restoredAmount = await RestoreResourceDialog.show(
          context: context,
          resourceType: ResourceType.lives(),
          manager: resourceManager,
        );

        // If user didn't restore lives, don't start the quiz
        if (restoredAmount == null) {
          return;
        }
      }
    }

    // Load questions
    final questions = await dataProvider.loadQuestions(context, category);

    // Create storage config
    final storageConfig = dataProvider.createStorageConfig(context, category);

    // Get layout config - prefer saved preference, fallback to data provider
    final layoutConfig = _getLayoutConfigForQuiz(context, category);

    // Apply storage config and layout config to quiz config
    final configWithStorage = quizConfig.copyWith(
      storageConfig: storageConfig,
      layoutConfig: layoutConfig,
    );

    // Create storage adapter
    final storageAdapter = QuizStorageAdapter(storageService);

    // Create config manager that applies user settings
    // Note: showAnswerFeedback now comes from category/mode, not global settings
    final configManager = ConfigManager(
      defaultConfig: configWithStorage,
      getSettings:
          () => {
            'soundEnabled': _settingsService.currentSettings.soundEnabled,
            'hapticEnabled':
                _settingsService.currentSettings.hapticEnabled,
            'showAnswerFeedback': category.showAnswerFeedback,
          },
    );

    // Navigate to quiz
    if (context.mounted) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          settings: const RouteSettings(name: 'quiz'),
          builder:
              (ctx) => QuizWidget(
                quizEntry: QuizWidgetEntry(
                  title: category.title(context),
                  dataProvider: () async => questions,
                  configManager: configManager,
                  storageService: storageAdapter,
                  quizAnalyticsService: _quizAnalyticsService,
                  categoryId: category.id,
                  categoryName: category.title(context),
                  onQuizCompleted: (results) => _handleQuizCompleted(results),
                  useResourceManager: true,
                  shareConfig: widget.shareConfig,
                ),
              ),
        ),
      );
    }
  }

  /// Gets the layout config for a quiz, preferring saved preference over data provider default.
  ///
  /// Checks if the user has a saved layout mode preference in settings.
  /// If found, looks up the corresponding [LayoutModeOption] from [playLayoutModeOptionsBuilder]
  /// and uses its layout config. Falls back to the data provider's default layout.
  QuizLayoutConfig _getLayoutConfigForQuiz(
    BuildContext context,
    QuizCategory category,
  ) {
    // Check for saved layout preference
    final preferredModeId = _settingsService.currentSettings.preferredLayoutModeId;

    if (preferredModeId != null && widget.playLayoutModeOptionsBuilder != null) {
      // Get layout options
      final options = widget.playLayoutModeOptionsBuilder!(context);

      // Find the option matching the saved preference
      final selectedOption = options
          .where((o) => o.id == preferredModeId)
          .firstOrNull;

      if (selectedOption != null) {
        return selectedOption.layoutConfig;
      }
    }

    // Fallback to data provider's layout
    return widget.dataProvider?.createLayoutConfig(context, category) ??
        const ImageQuestionTextAnswersLayout();
  }

  /// Handles quiz completion by notifying achievements provider and calling callback.
  Future<void> _handleQuizCompleted(QuizResults results) async {
    // Call the app's custom callback first
    widget.onQuizCompleted?.call(results);

    // Handle achievements if provider is available
    final achievementsProvider = widget.achievementsDataProvider;
    final storageService = _storageService;
    final sessionId = results.sessionId;

    if (sessionId != null) {
      final sessionResult = await storageService.getQuizSession(sessionId);
      final session = sessionResult.valueOrNull;
      if (session != null) {
        // Notify achievements provider
        if (achievementsProvider != null) {
          await achievementsProvider.onSessionCompleted(session);
        }

        // Update practice progress with wrong answers
        // Get wrong answers from the session repository
        final practiceProvider = widget.practiceDataProvider;
        if (practiceProvider != null) {
          final sessionWithAnswers = await storageService
              .getSessionWithAnswers(sessionId);
          final wrongAnswers =
              sessionWithAnswers.valueOrNull?.wrongAnswers ?? [];
          if (wrongAnswers.isNotEmpty) {
            await practiceProvider.updatePracticeProgress(
              session,
              wrongAnswers,
            );
          }
        }
      }
    }
  }

  /// Handles practice session completion.
  Future<void> _handlePracticeCompleted(List<String> correctQuestionIds) async {
    final practiceProvider = widget.practiceDataProvider;
    if (practiceProvider != null && correctQuestionIds.isNotEmpty) {
      await practiceProvider.onPracticeSessionCompleted(correctQuestionIds);
    }
  }

  /// Navigates to the Play (quiz) tab.
  void _navigateToPlayTab() {
    // This is a simple implementation - in a more complex app,
    // you might use a different navigation approach
    // For now, we just pop back to the home screen
    _navigatorKey.currentState?.popUntil((route) => route.isFirst);
  }

  /// Opens the settings screen.
  ///
  /// Uses [settingsBuilder] if provided, otherwise shows [QuizSettingsScreen].
  void _openSettings(BuildContext context) {
    final settingsWidget =
        widget.settingsBuilder?.call(context) ??
        QuizSettingsScreen(
          config: widget.settingsConfig ?? const QuizSettingsConfig(),
        );

    _navigatorKey.currentState?.push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'settings'),
        builder: (context) => settingsWidget,
      ),
    );
  }
}

/// Builder widget for QuizApp with service initialization.
///
/// Use this when you want QuizApp to handle service initialization
/// internally with a loading screen.
///
/// ```dart
/// QuizAppBuilder(
///   initializeServices: () async {
///     await SharedServicesInitializer.initialize();
///     final settingsService = sl.get<SettingsService>();
///     final storageService = sl.get<StorageService>();
///     return QuizServices(
///       settingsService: settingsService,
///       storageService: storageService,
///       // ... other services
///     );
///   },
///   builder: (context, services) => QuizApp(
///     services: services,
///     categories: myCategories,
///   ),
/// )
/// ```
class QuizAppBuilder extends StatefulWidget {
  /// Function to initialize services.
  ///
  /// Should return the initialized [QuizServices] bundle.
  final Future<QuizServices> Function() initializeServices;

  /// Builder for the QuizApp once services are initialized.
  final Widget Function(BuildContext context, QuizServices services) builder;

  /// Widget to show while initializing.
  final Widget? loadingWidget;

  /// Widget to show if initialization fails.
  final Widget Function(BuildContext context, Object error)? errorBuilder;

  /// Creates a [QuizAppBuilder].
  const QuizAppBuilder({
    super.key,
    required this.initializeServices,
    required this.builder,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  State<QuizAppBuilder> createState() => _QuizAppBuilderState();
}

class _QuizAppBuilderState extends State<QuizAppBuilder> {
  late Future<QuizServices> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.initializeServices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuizServices>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, snapshot.error!);
          }
          return MaterialApp(
            localizationsDelegates: const [
              QuizLocalizationsDelegate(),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en')],
            home: Builder(
              builder:
                  (ctx) => Scaffold(
                    body: Center(
                      child: Text(
                        QuizL10n.of(
                          ctx,
                        ).initializationError(snapshot.error.toString()),
                      ),
                    ),
                  ),
            ),
          );
        }

        if (!snapshot.hasData) {
          return widget.loadingWidget ??
              const MaterialApp(
                home: Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                ),
              );
        }

        return widget.builder(context, snapshot.data!);
      },
    );
  }
}

/// Internal widget for the Practice tab content.
///
/// Handles loading practice data, showing the start screen,
/// running the practice quiz, and showing completion results.
///
/// Services are obtained from [QuizServicesProvider] via context.
class _PracticeTabContent extends StatefulWidget {
  const _PracticeTabContent({
    required this.practiceDataProvider,
    this.dataProvider,
    this.onPracticeCompleted,
    this.onStartQuiz,
  });

  final PracticeDataProvider practiceDataProvider;
  final QuizDataProvider? dataProvider;
  final void Function(List<String> correctQuestionIds)? onPracticeCompleted;
  final VoidCallback? onStartQuiz;

  @override
  State<_PracticeTabContent> createState() => _PracticeTabContentState();
}

class _PracticeTabContentState extends State<_PracticeTabContent> {
  PracticeTabData? _practiceData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Defer data loading to after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPracticeData();
    });
  }

  Future<void> _loadPracticeData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await widget.practiceDataProvider.loadPracticeData(context);
      if (mounted) {
        setState(() {
          _practiceData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _loadPracticeData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final data = _practiceData;
    if (data == null || !data.hasQuestions) {
      return const PracticeEmptyState();
    }

    // Show practice start screen
    return PracticeStartScreen(
      questionCount: data.questionCount,
      onStartPractice: () => _startPractice(context, data),
    );
  }

  void _startPractice(BuildContext context, PracticeTabData data) {
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'practice_quiz'),
        builder:
            (ctx) => _PracticeQuizScreen(
              practiceData: data,
              onPracticeCompleted: (correctIds, wrongCount) {
                widget.onPracticeCompleted?.call(correctIds);
                _showPracticeComplete(ctx, correctIds.length, wrongCount);
              },
              onCancel: () => Navigator.of(ctx).pop(),
            ),
      ),
    );
  }

  void _showPracticeComplete(
    BuildContext context,
    int correctCount,
    int wrongCount,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'practice_complete'),
        builder:
            (ctx) => PracticeCompleteScreen(
              correctCount: correctCount,
              needMorePracticeCount: wrongCount,
              onDone: () {
                Navigator.of(ctx).pop();
                // Refresh the practice data
                _loadPracticeData();
              },
            ),
      ),
    );
  }
}

/// Internal widget for the practice quiz itself.
///
/// Services are obtained from [QuizServicesProvider] via context.
class _PracticeQuizScreen extends StatefulWidget {
  const _PracticeQuizScreen({
    required this.practiceData,
    required this.onPracticeCompleted,
    required this.onCancel,
  });

  final PracticeTabData practiceData;
  final void Function(List<String> correctIds, int wrongCount)
  onPracticeCompleted;
  final VoidCallback onCancel;

  @override
  State<_PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<_PracticeQuizScreen> {
  // Service accessors via context
  SettingsService get _settingsService => context.settingsService;
  QuizAnalyticsService get _quizAnalyticsService => context.quizAnalyticsService;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    // Create practice quiz configuration
    // Practice mode: standard (no lives, no time limit), no storage, no hints
    final practiceConfig = QuizConfig(
      quizId: 'practice',
      modeConfig: QuizModeConfig.standard(showAnswerFeedback: true),
      hintConfig: const HintConfig.noHints(),
      storageConfig: StorageConfig.disabled,
    );

    final configManager = ConfigManager(
      defaultConfig: practiceConfig,
      getSettings:
          () => {
            'soundEnabled': _settingsService.currentSettings.soundEnabled,
            'hapticEnabled': _settingsService.currentSettings.hapticEnabled,
            'showAnswerFeedback': true,
          },
    );

    return QuizWidget(
      quizEntry: QuizWidgetEntry(
        title: l10n.practice,
        // Localized practice title
        // Use ALL questions for option generation
        dataProvider: () async => widget.practiceData.allQuestions,
        configManager: configManager,
        storageService: null,
        // Practice sessions are not stored
        // Filter to only ask practice questions
        filter: widget.practiceData.filter,
        onQuizCompleted: (results) {
          // Collect correctly answered question IDs
          // The question ID is stored in the question's answer.otherOptions['id']
          final correctIds =
              results.answers
                  .where((a) => a.isCorrect)
                  .map((a) => a.question.answer.otherOptions['id'] as String?)
                  .whereType<String>()
                  .toList();
          final wrongCount = results.answers.where((a) => !a.isCorrect).length;

          widget.onPracticeCompleted(correctIds, wrongCount);
        },
        quizAnalyticsService: _quizAnalyticsService,
      ),
    );
  }
}
