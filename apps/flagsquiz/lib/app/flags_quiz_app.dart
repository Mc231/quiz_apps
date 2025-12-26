import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../data/flags_challenges.dart';
import '../initialization/flags_quiz_initializer.dart';
import '../l10n/app_localizations.dart';
import '../practice/flags_practice_data_provider.dart';

/// The main Flags Quiz application widget.
///
/// Uses [QuizApp] from quiz_engine with app-specific configuration.
/// All navigation, achievement handling, and settings are managed
/// automatically by QuizApp.
///
/// Example:
/// ```dart
/// final dependencies = await FlagsQuizInitializer.initialize();
/// runApp(FlagsQuizApp(dependencies: dependencies));
/// ```
class FlagsQuizApp extends StatelessWidget {
  /// Creates a [FlagsQuizApp].
  const FlagsQuizApp({
    super.key,
    required this.dependencies,
  });

  /// All dependencies needed to run the app.
  final FlagsQuizDependencies dependencies;

  @override
  Widget build(BuildContext context) {
    return QuizApp(
      settingsService: dependencies.settingsService,
      categories: dependencies.categories,
      dataProvider: dependencies.dataProvider,
      storageService: dependencies.storageService,
      achievementService: dependencies.achievementService,
      achievementsDataProvider: dependencies.achievementsProvider,
      challenges: FlagsChallenges.all,
      practiceDataProvider: FlagsPracticeDataProvider.fromServiceLocator(),
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
