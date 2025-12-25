import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;

import '../achievements/achievement_notification_controller.dart';
import '../achievements/widgets/achievement_card.dart';
import '../home/quiz_home_screen.dart';
import '../l10n/quiz_localizations.dart';
import '../l10n/quiz_localizations_delegate.dart';
import '../models/quiz_category.dart';
import '../models/quiz_data_provider.dart';
import '../quiz_widget.dart';
import '../quiz_widget_entry.dart';
import '../settings/quiz_settings_screen.dart';
import '../widgets/session_card.dart';
import 'quiz_tab.dart';

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
///
/// ## Basic Usage
///
/// ```dart
/// QuizApp(
///   settingsService: settingsService,
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
///   settingsService: settingsService,
///   homeBuilder: (context) => MyCustomHomeScreen(),
/// )
/// ```
///
/// ## With Full Configuration
///
/// ```dart
/// QuizApp(
///   settingsService: settingsService,
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
  /// Service for managing app settings.
  final SettingsService settingsService;

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

  /// Storage service for persisting quiz sessions.
  ///
  /// Required when [dataProvider] is provided.
  /// Used for saving quiz history and statistics.
  final StorageService? storageService;

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
  final Future<AchievementsTabData> Function()? achievementsDataProvider;

  /// Callback when an achievement is tapped.
  final void Function(AchievementDisplayData achievement)? onAchievementTap;

  /// Callback invoked when a quiz is completed.
  ///
  /// Use this to integrate with achievement systems. The callback receives
  /// the complete [QuizResults] with all session data.
  final void Function(QuizResults results)? onQuizCompleted;

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

  /// Optional achievement service for listening to unlock events.
  ///
  /// If provided and [showAchievementNotifications] is true, the app
  /// will automatically show notifications when achievements are unlocked.
  final AchievementService? achievementService;

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

  /// Creates a [QuizApp].
  const QuizApp({
    super.key,
    required this.settingsService,
    this.categories,
    this.dataProvider,
    this.storageService,
    this.homeConfig = const QuizHomeScreenConfig(),
    this.callbacks = const QuizAppCallbacks(),
    this.config = const QuizAppConfig(),
    this.homeBuilder,
    this.historyDataProvider,
    this.statisticsDataProvider,
    this.achievementsDataProvider,
    this.onAchievementTap,
    this.onQuizCompleted,
    this.onAchievementsUnlocked,
    this.showAchievementNotifications = true,
    this.achievementService,
    this.settingsBuilder,
    this.settingsConfig,
    this.locale,
    this.formatDate,
    this.formatStatus,
    this.formatDuration,
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

  @override
  void initState() {
    super.initState();
    _currentSettings = widget.settingsService.currentSettings;
    _settingsSubscription =
        widget.settingsService.settingsStream.listen(_onSettingsChanged);

    // Create notification controller if notifications are enabled
    if (widget.showAchievementNotifications) {
      _notificationController = AchievementNotificationController();

      // Listen to achievement unlocks if service is provided
      if (widget.achievementService != null) {
        _achievementSubscription = widget.achievementService!
            .onAchievementsUnlocked
            .listen(_showAchievementNotifications);
      }
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
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: widget.config.title ?? '',
      debugShowCheckedModeBanner: widget.config.debugShowCheckedModeBanner,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _currentSettings.flutterThemeMode,
      localizationsDelegates: _buildLocalizationDelegates(),
      supportedLocales: widget.config.supportedLocales,
      locale: widget.locale,
      localeResolutionCallback: widget.config.localeResolutionCallback ??
          _defaultLocaleResolutionCallback,
      navigatorObservers: widget.config.navigatorObservers,
      home: _wrapWithNotifications(_buildHome(context)),
    );
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
      appBarTheme: widget.config.appBarTheme ??
          const AppBarTheme(
            elevation: 0,
          ),
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
      builder: (innerContext) => QuizHomeScreen(
        categories: widget.categories ?? [],
        storageService: widget.storageService,
        config: widget.homeConfig,
        onCategorySelected: hasDataProvider
            ? (category) => _startQuiz(innerContext, category)
            : widget.callbacks.onCategorySelected,
        onSettingsPressed: hasDataProvider
            ? () => _openSettings(innerContext)
            : widget.callbacks.onSettingsPressed,
        onSessionTap: widget.callbacks.onSessionTap,
        onViewAllSessions: widget.callbacks.onViewAllSessions,
        historyDataProvider: widget.historyDataProvider,
        statisticsDataProvider: widget.statisticsDataProvider,
        achievementsDataProvider: widget.achievementsDataProvider,
        onAchievementTap: widget.onAchievementTap,
        settingsBuilder: _buildSettingsBuilder(),
        formatDate: widget.formatDate,
        formatStatus: widget.formatStatus,
        formatDuration: widget.formatDuration,
      ),
    );
  }

  Widget Function(BuildContext)? _buildSettingsBuilder() {
    if (widget.settingsBuilder != null) {
      return widget.settingsBuilder;
    }

    // Check if settings tab is in the tabs
    final tabs = widget.homeConfig.tabConfig.tabs.isNotEmpty
        ? widget.homeConfig.tabConfig.tabs
        : QuizTabConfig.defaultConfig().tabs;

    final hasSettingsTab = tabs.any((tab) => tab is SettingsTab);

    if (!hasSettingsTab) {
      return null;
    }

    // Provide default settings screen
    return (context) => QuizSettingsScreen(
          settingsService: widget.settingsService,
          config: widget.settingsConfig ??
              const QuizSettingsConfig(showAppBar: false),
        );
  }

  /// Starts a quiz for the given category.
  ///
  /// This is called when [dataProvider] is provided and handles:
  /// - Loading questions from the data provider
  /// - Creating quiz configuration
  /// - Navigating to the QuizWidget
  void _startQuiz(BuildContext context, QuizCategory category) async {
    final dataProvider = widget.dataProvider;
    final storageService = widget.storageService;

    if (dataProvider == null) {
      // Fallback to callback if no data provider
      widget.callbacks.onCategorySelected?.call(category);
      return;
    }

    // Load questions
    final questions = await dataProvider.loadQuestions(context, category);

    // Create storage config
    final storageConfig = dataProvider.createStorageConfig(context, category);

    // Create quiz config
    final quizConfig = dataProvider.createQuizConfig(context, category) ??
        QuizConfig(
          quizId: category.id,
          hintConfig: HintConfig.noHints(),
        );

    // Apply storage config to quiz config
    final configWithStorage = quizConfig.copyWith(
      storageConfig: storageConfig,
    );

    // Create storage adapter if storage service is available
    QuizStorageAdapter? storageAdapter;
    if (storageService != null) {
      storageAdapter = QuizStorageAdapter(storageService);
    }

    // Create config manager that applies user settings
    // Note: showAnswerFeedback now comes from category/mode, not global settings
    final configManager = ConfigManager(
      defaultConfig: configWithStorage,
      getSettings: () => {
        'soundEnabled': widget.settingsService.currentSettings.soundEnabled,
        'hapticEnabled': widget.settingsService.currentSettings.hapticEnabled,
        'showAnswerFeedback': category.showAnswerFeedback ?? true,
      },
    );

    // Navigate to quiz
    if (context.mounted) {
      _navigatorKey.currentState?.push(
        MaterialPageRoute(
          builder: (ctx) => QuizWidget(
            quizEntry: QuizWidgetEntry(
              title: category.title(context),
              dataProvider: () async => questions,
              configManager: configManager,
              storageService: storageAdapter,
              onQuizCompleted: widget.onQuizCompleted,
            ),
          ),
        ),
      );
    }
  }

  /// Opens the settings screen.
  ///
  /// Uses [settingsBuilder] if provided, otherwise shows [QuizSettingsScreen].
  void _openSettings(BuildContext context) {
    final settingsWidget = widget.settingsBuilder?.call(context) ??
        QuizSettingsScreen(
          settingsService: widget.settingsService,
          config: widget.settingsConfig ?? const QuizSettingsConfig(),
        );

    _navigatorKey.currentState?.push(
      MaterialPageRoute(
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
///     final settingsService = SettingsService();
///     await settingsService.initialize();
///     await SharedServicesInitializer.initialize();
///     return settingsService;
///   },
///   builder: (context, settingsService) => QuizApp(
///     settingsService: settingsService,
///     categories: myCategories,
///   ),
/// )
/// ```
class QuizAppBuilder extends StatefulWidget {
  /// Function to initialize services.
  ///
  /// Should return the initialized SettingsService.
  final Future<SettingsService> Function() initializeServices;

  /// Builder for the QuizApp once services are initialized.
  final Widget Function(BuildContext context, SettingsService settingsService)
      builder;

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
  late Future<SettingsService> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = widget.initializeServices();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsService>(
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
              builder: (ctx) => Scaffold(
                body: Center(
                  child: Text(
                    QuizL10n.of(ctx).initializationError(
                      snapshot.error.toString(),
                    ),
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
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
        }

        return widget.builder(context, snapshot.data!);
      },
    );
  }
}
