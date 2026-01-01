import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../data/flags_challenges.dart';
import '../data/flags_layout_options.dart';
import '../deeplink/deeplink_exports.dart';
import '../initialization/flags_quiz_dependencies.dart';
import '../l10n/app_localizations.dart';
import '../practice/flags_practice_data_provider.dart';

/// The main Flags Quiz application widget.
///
/// Uses [QuizApp] from quiz_engine with app-specific configuration.
/// All navigation, achievement handling, and settings are managed
/// automatically by QuizApp.
///
/// Includes deep link handling for `flagsquiz://` URLs:
/// - `flagsquiz://quiz/{categoryId}` - Opens a quiz category
/// - `flagsquiz://achievement/{id}` - Shows achievement details
/// - `flagsquiz://challenge/{id}` - Opens a challenge
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
    return DeepLinkHandler(
      deepLinkService: dependencies.deepLinkService,
      analyticsService: dependencies.services.screenAnalyticsService,
      onRoute: _handleDeepLinkRoute,
      child: QuizApp(
      services: dependencies.services,
      categories: dependencies.categories,
      dataProvider: dependencies.dataProvider,
      achievementsDataProvider: dependencies.achievementsProvider,
      challenges: FlagsChallenges.all,
      challengeLayoutModeOptionsBuilder: createFlagsLayoutOptions,
      challengeLayoutModeSelectorTitleBuilder: (context) =>
          AppLocalizations.of(context)!.quizMode,
      playLayoutModeOptionsBuilder: createFlagsLayoutOptions,
      playLayoutModeSelectorTitleBuilder: (context) =>
          AppLocalizations.of(context)!.quizMode,
      practiceDataProvider: FlagsPracticeDataProvider.fromServiceLocator(),
      shareConfig: const ShareBottomSheetConfig(
        appName: 'Flags Quiz',
        showTextOption: true,
        showImageOption: true,
      ),
      config: QuizAppConfig(
        title: 'Flags Quiz',
        appLocalizationDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        useMaterial3: false,
        primaryColor: Colors.white,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(elevation: 0),
        navigatorObservers: [dependencies.navigatorObserver],
        rateAppConfig: const RateAppUiConfig(
          appName: 'Flags Quiz',
          feedbackEmail: 'support@flagsquiz.app',
          delaySeconds: 2,
        ),
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
      ),
    );
  }

  /// Handles parsed deep link routes.
  ///
  /// Currently logs the route for debugging. Navigation will be implemented
  /// when proper navigation APIs are exposed from QuizApp.
  void _handleDeepLinkRoute(BuildContext context, FlagsQuizDeepLinkRoute route) {
    // Log the route for debugging
    if (kDebugMode) {
      debugPrint('FlagsQuizApp: Received deep link route: $route');
    }

    // Handle different route types
    switch (route) {
      case QuizRoute(:final categoryId):
        debugPrint('FlagsQuizApp: Navigate to quiz category: $categoryId');
        // TODO: Navigate to quiz category when QuizApp exposes navigation API
        // For now, the deep link is logged and can be handled in future sprints
        break;

      case AchievementRoute(:final achievementId):
        debugPrint('FlagsQuizApp: Navigate to achievement: $achievementId');
        // TODO: Navigate to achievement details
        break;

      case ChallengeRoute(:final challengeId):
        debugPrint('FlagsQuizApp: Navigate to challenge: $challengeId');
        // TODO: Navigate to challenge
        break;

      case UnknownRoute(:final uri):
        debugPrint('FlagsQuizApp: Unknown deep link route: $uri');
        break;
    }
  }
}
