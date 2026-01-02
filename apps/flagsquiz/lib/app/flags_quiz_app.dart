import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  /// Uses [QuizNavigation] from the quiz_engine package to navigate
  /// to the appropriate screen based on the deep link route type.
  void _handleDeepLinkRoute(
      BuildContext context, FlagsQuizDeepLinkRoute route) {
    // Log the route for debugging
    if (kDebugMode) {
      debugPrint('FlagsQuizApp: Received deep link route: $route');
    }

    // Handle unknown routes immediately
    if (route is UnknownRoute) {
      debugPrint('FlagsQuizApp: Unknown deep link route: ${route.uri}');
      return;
    }

    // Defer navigation to next frame to ensure widget tree is built
    // and QuizNavigationProvider is available
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _executeNavigation(context, route);
    });
  }

  /// Executes navigation after the widget tree is fully built.
  Future<void> _executeNavigation(
      BuildContext context, FlagsQuizDeepLinkRoute route) async {
    // Get navigation from static instance (registered by QuizApp)
    var nav = QuizNavigationProvider.instance;

    // If not available yet, wait a bit and retry
    if (nav == null || !nav.isReady) {
      debugPrint('FlagsQuizApp: QuizNavigation not ready, waiting...');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      nav = QuizNavigationProvider.instance;
      if (nav == null || !nav.isReady) {
        debugPrint('FlagsQuizApp: QuizNavigation still not ready, giving up');
        return;
      }
    }

    // Execute navigation based on route type
    final result = await switch (route) {
      QuizRoute(:final categoryId) => nav.navigateToQuiz(categoryId),
      AchievementRoute(:final achievementId) =>
        nav.navigateToAchievement(achievementId),
      ChallengeRoute(:final challengeId) => nav.navigateToChallenge(challengeId),
      UnknownRoute() =>
        Future.value(QuizNavigationResult.error('unknown')),
    };

    // Log result
    if (kDebugMode) {
      debugPrint('FlagsQuizApp: Navigation result: $result');
    }

    // Handle navigation failures (e.g., show snackbar)
    if (result.isFailure && context.mounted) {
      _handleNavigationFailure(context, route, result);
    }
  }

  /// Handles navigation failures by showing appropriate feedback.
  void _handleNavigationFailure(
    BuildContext context,
    FlagsQuizDeepLinkRoute route,
    QuizNavigationResult result,
  ) {
    final message = switch (result) {
      NavigationInvalidId(:final id, :final type) =>
        'Could not find $type: $id',
      NavigationNotReady() => 'App not ready for navigation',
      NavigationError(:final message) => 'Navigation error: $message',
      NavigationSuccess() => null,
    };

    if (message != null) {
      debugPrint('FlagsQuizApp: $message');
      // Optionally show snackbar to user
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(message)),
      // );
    }
  }
}
