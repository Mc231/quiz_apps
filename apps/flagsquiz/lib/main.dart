import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart' hide QuizDataProvider;
import 'package:shared_services/shared_services.dart' as services show QuizDataProvider;

import 'achievements/flags_achievements_data_provider.dart';
import 'data/country_counts.dart';
import 'data/flags_categories.dart';
import 'data/flags_challenges.dart';
import 'data/flags_data_provider.dart';
import 'l10n/app_localizations.dart';
import 'models/country.dart';
import 'practice/flags_practice_data_provider.dart';

/// Type alias for the shared services QuizDataProvider to avoid name collision.
typedef SharedQuizDataProvider<T> = services.QuizDataProvider<T>;

/// The entry point of the Flags Quiz application.
///
/// Uses [QuizApp] from quiz_engine with [FlagsDataProvider] for loading
/// country quiz data. All navigation and achievement handling is managed
/// automatically by QuizApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedServicesInitializer.initialize();

  // Load country counts from JSON to display accurate question counts
  final countryCounts = await CountryCounts.load();

  // Get services
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

  runApp(
    FlagsQuizApp(
      settingsService: settingsService,
      storageService: storageService,
      achievementService: achievementService,
      achievementsProvider: achievementsProvider,
      dataProvider: dataProvider,
      categories: categories,
    ),
  );
}

/// The main Flags Quiz application widget.
///
/// This widget wraps [QuizApp] and provides the practice data provider
/// which needs access to the app's localizations.
class FlagsQuizApp extends StatelessWidget {
  /// Creates a [FlagsQuizApp].
  const FlagsQuizApp({
    super.key,
    required this.settingsService,
    required this.storageService,
    required this.achievementService,
    required this.achievementsProvider,
    required this.dataProvider,
    required this.categories,
  });

  /// Settings service.
  final SettingsService settingsService;

  /// Storage service.
  final StorageService storageService;

  /// Achievement service.
  final AchievementService achievementService;

  /// Achievements data provider.
  final FlagsAchievementsDataProvider achievementsProvider;

  /// Data provider for loading quiz questions.
  final FlagsDataProvider dataProvider;

  /// Quiz categories.
  final List<QuizCategory> categories;

  @override
  Widget build(BuildContext context) {
    return QuizApp(
      settingsService: settingsService,
      categories: categories,
      dataProvider: dataProvider,
      storageService: storageService,
      achievementService: achievementService,
      // AchievementsDataProvider handles both loading data and session completion
      achievementsDataProvider: achievementsProvider,
      // Simplified play tabs configuration using enum set
      // Challenges are now configured via this parameter
      challenges: FlagsChallenges.all,
      // Practice data provider for Practice Mistakes mode
      practiceDataProvider: FlagsPracticeDataProvider(
        repository: sl.get<PracticeProgressRepository>(),
        countryProvider: SharedQuizDataProvider<Country>.standard(
          'assets/Countries.json',
          (data) => Country.fromJson(
            data,
            // Note: This uses English fallback for now
            // Full localization would require context from a Builder widget
            (key) => key.toUpperCase(),
          ),
        ),
      ),
      config: QuizAppConfig(
        title: 'Flags Quiz',
        appLocalizationDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        useMaterial3: false,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0),
      ),
      homeConfig: QuizHomeScreenConfig(
        // Bottom navigation tabs: Play, Achievements, History, Statistics
        tabConfig: QuizTabConfig(
          tabs: [
            QuizTab.play(),
            QuizTab.achievements(),
            QuizTab.history(),
            QuizTab.statistics(),
          ],
        ),
        showSettingsInAppBar: true,
      ),
    );
  }
}
