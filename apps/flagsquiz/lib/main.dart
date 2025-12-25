import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import 'achievements/flags_achievements_data_provider.dart';
import 'data/country_counts.dart';
import 'data/flags_categories.dart';
import 'data/flags_challenges.dart';
import 'data/flags_data_provider.dart';
import 'l10n/app_localizations.dart';

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
    QuizApp(
      settingsService: settingsService,
      categories: categories,
      dataProvider: dataProvider,
      storageService: storageService,
      achievementService: achievementService,
      // AchievementsDataProvider handles both loading data and session completion
      achievementsDataProvider: achievementsProvider,
      // Simplified play tabs configuration using enum set
      playTabTypes: {
        PlayTabType.quiz,
        PlayTabType.challenges,
        PlayTabType.practice,
      },
      // Challenges are now configured via this parameter
      challenges: FlagsChallenges.all,
      // Practice data loader (placeholder for now)
      practiceDataLoader: () async {
        // TODO: Load categories from wrong answers
        return [];
      },
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
    ),
  );
}
