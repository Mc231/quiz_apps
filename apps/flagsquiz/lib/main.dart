import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import 'data/country_counts.dart';
import 'data/flags_categories.dart';
import 'data/flags_challenges.dart';
import 'data/flags_data_provider.dart';
import 'l10n/app_localizations.dart';

/// The entry point of the Flags Quiz application.
///
/// Uses [QuizApp] from quiz_engine with [FlagsDataProvider] for loading
/// country quiz data. All navigation is handled automatically by QuizApp.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedServicesInitializer.initialize();

  // Load country counts from JSON to display accurate question counts
  final countryCounts = await CountryCounts.load();

  // Get services
  final settingsService = sl.get<SettingsService>();
  final storageService = sl.get<StorageService>();

  // Create categories and data provider
  final categories = createFlagsCategories(countryCounts);
  const dataProvider = FlagsDataProvider();

  runApp(
    QuizApp(
      settingsService: settingsService,
      categories: categories,
      dataProvider: dataProvider,
      storageService: storageService,
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
        tabConfig: QuizTabConfig.defaultConfig(),
        showSettingsInAppBar: true,
        // Configure the 3 tabs: Play, Challenges, Practice
        playScreenTabs: [
          // Tab 1: Play - Standard quiz with hints and skip
          PlayScreenTab.categories(
            id: 'play',
            label: 'Play',
            icon: Icons.play_arrow,
            categories: categories,
          ),
          // Tab 2: Challenges - Different game modes
          PlayScreenTab.custom(
            id: 'challenges',
            label: 'Challenges',
            icon: Icons.emoji_events,
            builder: (context) => ChallengesScreen(
              challenges: FlagsChallenges.all,
              categories: categories,
              dataProvider: dataProvider,
              settingsService: settingsService,
              storageService: storageService,
            ),
          ),
          // Tab 3: Practice - Review wrong answers
          PlayScreenTab.practice(
            id: 'practice',
            label: 'Practice',
            icon: Icons.school,
            onLoadWrongAnswers: () async {
              // TODO: Load categories from wrong answers
              // For now, return empty to show "No practice items" message
              return [];
            },
          ),
        ],
      ),
    ),
  );
}
