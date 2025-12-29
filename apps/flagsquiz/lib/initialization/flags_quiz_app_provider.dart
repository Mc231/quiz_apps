import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../achievements/flags_achievements_data_provider.dart';
import '../app/flags_quiz_app.dart';
import '../data/country_counts.dart';
import '../data/flags_categories.dart';
import '../data/flags_data_provider.dart';
import 'flags_quiz_dependencies.dart';

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
    final screenAnalyticsService = CompositeAnalyticsService(
      providers: [
        AnalyticsProviderConfig(
          provider: ConsoleAnalyticsService(),
          name: 'Console',
        ),
      ],
    );
    await screenAnalyticsService.initialize();

    // Wrap with adapter to implement QuizAnalyticsService interface
    final quizAnalyticsService = QuizAnalyticsAdapter(screenAnalyticsService);

    // Create navigator observer for automatic screen tracking
    final navigatorObserver = AnalyticsNavigatorObserver(
      analyticsService: screenAnalyticsService,
    );

    // Create and initialize resource manager with SQLite persistence
    final resourceManager = ResourceManager(
      config: ResourceConfig.standard(),
      repository: SqliteResourceRepository(sl.get<AppDatabase>()),
      analyticsService: screenAnalyticsService,
    );
    await resourceManager.initialize();

    // Bundle all services together
    final services = QuizServices(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      screenAnalyticsService: screenAnalyticsService,
      quizAnalyticsService: quizAnalyticsService,
      resourceManager: resourceManager,
    );

    return FlagsQuizDependencies(
      services: services,
      achievementsProvider: achievementsProvider,
      dataProvider: dataProvider,
      categories: categories,
      navigatorObserver: navigatorObserver,
    );
  }
}
