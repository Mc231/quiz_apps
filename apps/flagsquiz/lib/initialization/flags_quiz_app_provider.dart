import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import '../achievements/flags_achievements_data_provider.dart';
import '../app/flags_quiz_app.dart';
import '../data/country_counts.dart';
import '../data/flags_categories.dart';
import '../data/flags_data_provider.dart';

/// Contains all dependencies needed to run the Flags Quiz app.
///
/// This class is internal to the app initialization process.
/// Use [FlagsQuizAppProvider.provideApp] instead of creating this directly.
class FlagsQuizDependencies {
  /// Creates [FlagsQuizDependencies]. Internal use only.
  const FlagsQuizDependencies({
    required this.settingsService,
    required this.storageService,
    required this.achievementService,
    required this.achievementsProvider,
    required this.dataProvider,
    required this.categories,
    required this.screenAnalyticsService,
    required this.quizAnalyticsService,
    required this.navigatorObserver,
  });

  final SettingsService settingsService;
  final StorageService storageService;
  final AchievementService achievementService;
  final FlagsAchievementsDataProvider achievementsProvider;
  final FlagsDataProvider dataProvider;
  final List<QuizCategory> categories;
  final AnalyticsService screenAnalyticsService;
  final QuizAnalyticsService quizAnalyticsService;

  /// Navigator observer for automatic screen tracking.
  final AnalyticsNavigatorObserver navigatorObserver;
}

/// Provides a fully initialized [FlagsQuizApp] instance.
///
/// Handles Flutter binding initialization, shared services setup,
/// and creation of all app dependencies internally.
///
/// Example:
/// ```dart
/// void main() async {
///   runApp(await FlagsQuizAppProvider.provideApp());
/// }
/// ```
class FlagsQuizAppProvider {
  FlagsQuizAppProvider._();

  /// Provides a fully initialized [FlagsQuizApp].
  ///
  /// This method:
  /// 1. Ensures Flutter bindings are initialized
  /// 2. Initializes shared services (database, settings, etc.)
  /// 3. Loads country data for accurate question counts
  /// 4. Creates and initializes the achievements provider
  /// 5. Syncs achievements to catch any missed unlocks
  /// 6. Returns a configured [FlagsQuizApp] widget
  static Future<Widget> provideApp() async {
    final dependencies = await _initialize();
    return FlagsQuizApp(dependencies: dependencies);
  }

  /// Initializes all dependencies for the Flags Quiz app.
  static Future<FlagsQuizDependencies> _initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    await SharedServicesInitializer.initialize();

    // Load country counts from JSON to display accurate question counts
    final countryCounts = await CountryCounts.load();

    // Get services from service locator
    final settingsService = sl.get<SettingsService>();
    final storageService = sl.get<StorageService>();
    final achievementService = sl.get<AchievementService>();
    final sessionRepository = sl.get<QuizSessionRepository>();

    // Create categories and data provider
    final categories = createFlagsCategories(countryCounts);
    const dataProvider = FlagsDataProvider();

    // Create achievements data provider and initialize at startup
    final achievementsProvider = FlagsAchievementsDataProvider(
      achievementService: achievementService,
      sessionRepository: sessionRepository,
    );
    await achievementsProvider.initialize();

    // Sync achievements on app start to catch any missed unlocks
    await achievementService.checkAll();

    // Initialize analytics with console logging for debugging
    final analytics = CompositeAnalyticsService(
      providers: [
        AnalyticsProviderConfig(
          provider: ConsoleAnalyticsService(),
          name: 'Console',
        ),
      ],
    );
    await analytics.initialize();

    // Wrap with adapter to implement QuizAnalyticsService interface
    final quizAnalytics = QuizAnalyticsAdapter(analytics);

    // Create navigator observer for automatic screen tracking
    final navigatorObserver = AnalyticsNavigatorObserver(
      analyticsService: analytics,
    );

    return FlagsQuizDependencies(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      achievementsProvider: achievementsProvider,
      dataProvider: dataProvider,
      categories: categories,
      screenAnalyticsService: analytics,
      quizAnalyticsService: quizAnalytics,
      navigatorObserver: navigatorObserver,
    );
  }
}
