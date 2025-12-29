import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../data/flags_challenges.dart';
import '../initialization/flags_quiz_dependencies.dart';
import '../l10n/app_localizations.dart';
import '../practice/flags_practice_data_provider.dart';

/// The main Flags Quiz application widget.
///
/// Uses [QuizApp] from quiz_engine with app-specific configuration.
/// All navigation, achievement handling, and settings are managed
/// automatically by QuizApp.
///
/// Use [FlagsQuizAppProvider.provideApp] to create a fully initialized instance:
/// ```dart
/// void main() async {
///   runApp(await FlagsQuizAppProvider.provideApp());
/// }
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
      services: dependencies.services,
      categories: dependencies.categories,
      dataProvider: dependencies.dataProvider,
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
        navigatorObservers: [dependencies.navigatorObserver],
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
