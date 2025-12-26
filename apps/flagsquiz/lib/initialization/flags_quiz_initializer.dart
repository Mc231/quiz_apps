import 'package:flutter/widgets.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../achievements/flags_achievements_data_provider.dart';
import '../data/country_counts.dart';
import '../data/flags_categories.dart';
import '../data/flags_data_provider.dart';

/// Contains all dependencies needed to run the Flags Quiz app.
///
/// Created by [FlagsQuizInitializer.initialize] and passed to [FlagsQuizApp].
class FlagsQuizDependencies {
  /// Creates [FlagsQuizDependencies].
  const FlagsQuizDependencies({
    required this.settingsService,
    required this.storageService,
    required this.achievementService,
    required this.achievementsProvider,
    required this.dataProvider,
    required this.categories,
  });

  /// Settings service for app preferences.
  final SettingsService settingsService;

  /// Storage service for quiz data persistence.
  final StorageService storageService;

  /// Achievement service for tracking achievements.
  final AchievementService achievementService;

  /// Achievements data provider for loading achievement definitions.
  final FlagsAchievementsDataProvider achievementsProvider;

  /// Data provider for loading quiz questions.
  final FlagsDataProvider dataProvider;

  /// Quiz categories available in the app.
  final List<QuizCategory> categories;
}

/// Initializes all dependencies for the Flags Quiz app.
///
/// Handles Flutter binding initialization, shared services setup,
/// and creation of all app dependencies.
///
/// Example:
/// ```dart
/// void main() async {
///   final dependencies = await FlagsQuizInitializer.initialize();
///   runApp(FlagsQuizApp(dependencies: dependencies));
/// }
/// ```
class FlagsQuizInitializer {
  FlagsQuizInitializer._();

  /// Initializes the app and returns all required dependencies.
  ///
  /// This method:
  /// 1. Ensures Flutter bindings are initialized
  /// 2. Initializes shared services (database, settings, etc.)
  /// 3. Loads country data for accurate question counts
  /// 4. Creates and initializes the achievements provider
  /// 5. Syncs achievements to catch any missed unlocks
  static Future<FlagsQuizDependencies> initialize() async {
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

    return FlagsQuizDependencies(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      achievementsProvider: achievementsProvider,
      dataProvider: dataProvider,
      categories: categories,
    );
  }
}
