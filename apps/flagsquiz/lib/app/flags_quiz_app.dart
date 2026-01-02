import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import '../data/flags_challenges.dart';
import '../data/flags_layout_options.dart';
import '../deeplink/deeplink_exports.dart';
import '../initialization/flags_quiz_dependencies.dart';
import '../l10n/app_localizations.dart';
import '../practice/flags_practice_data_provider.dart';

/// Builds a representative flag icon for a category (continent).
///
/// Returns a flag image widget that represents the category in share images.
/// Each continent gets a representative country's flag.
Widget _buildShareCategoryIcon(String categoryId) {
  // Strip suffixes like _reverse, _mixed to get base continent ID
  final baseId = categoryId.split('_').first;

  // Map continent ID to a representative country code
  final countryCode = switch (baseId) {
    'all' => 'UN', // United Nations flag for "World"
    'af' => 'ZA', // South Africa for Africa
    'eu' => 'FR', // France for Europe
    'as' => 'JP', // Japan for Asia
    'na' => 'US', // USA for North America
    'sa' => 'BR', // Brazil for South America
    'oc' => 'AU', // Australia for Oceania
    _ => 'UN', // Default to UN flag
  };

  return Image.asset(
    'assets/images/$countryCode.png',
    fit: BoxFit.cover,
    errorBuilder: (_, __, ___) => const Icon(
      Icons.flag,
      size: 100,
      color: Colors.white,
    ),
  );
}

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
class FlagsQuizApp extends StatefulWidget {
  /// Creates a [FlagsQuizApp].
  const FlagsQuizApp({
    super.key,
    required this.dependencies,
  });

  /// All dependencies needed to run the app.
  final FlagsQuizDependencies dependencies;

  @override
  State<FlagsQuizApp> createState() => _FlagsQuizAppState();
}

class _FlagsQuizAppState extends State<FlagsQuizApp> {
  FlagsQuizDependencies get _deps => widget.dependencies;

  @override
  Widget build(BuildContext context) {
    return DeepLinkHandler(
      deepLinkService: _deps.deepLinkService,
      analyticsService: _deps.services.screenAnalyticsService,
      onRoute: _handleDeepLinkRoute,
      child: QuizApp(
        services: _deps.services,
        categories: _deps.categories,
        dataProvider: _deps.dataProvider,
        achievementsDataProvider: _deps.achievementsProvider,
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
          appLogoAsset: 'assets/app_icon.png',
          showTextOption: true,
          showImageOption: true,
        ),
        shareCategoryIconBuilder: _buildShareCategoryIcon,
        playTabHeaderWidgetBuilder: _buildDailyChallengeCard,
        config: QuizAppConfig(
          title: 'Flags Quiz',
          appLocalizationDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          useMaterial3: false,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          appBarTheme: const AppBarTheme(elevation: 0),
          navigatorObservers: [_deps.navigatorObserver],
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

  /// Builds the daily challenge card for the Play tab header.
  Widget _buildDailyChallengeCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DailyChallengeCardBuilder(
        service: _deps.dailyChallengeService,
        onStartChallenge: (challenge) => _navigateToDailyChallenge(context, challenge),
        onViewResults: (result) => _navigateToDailyChallengeResults(context, result),
        style: const DailyChallengeCardStyle(
          compact: true,
          showCountdown: true,
        ),
      ),
    );
  }

  /// Navigates to the daily challenge intro screen.
  Future<void> _navigateToDailyChallenge(
    BuildContext context,
    DailyChallenge challenge,
  ) async {
    // Get current result (if any)
    final result = await _deps.dailyChallengeService.getTodaysResult();
    final timeRemaining = _deps.dailyChallengeService.getTimeUntilNextChallenge();

    // Build status
    final status = DailyChallengeStatus(
      challenge: challenge,
      result: result,
      isCompleted: result != null,
      timeUntilNextChallenge: timeRemaining,
    );

    // Get category name for display
    final l10n = AppLocalizations.of(context);
    final categoryName = _getCategoryName(challenge.categoryId, l10n);

    if (!context.mounted) return;

    // Navigate to daily challenge screen
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (context) => DailyChallengeScreen(
          data: DailyChallengeScreenData(
            status: status,
            categoryName: categoryName,
          ),
          onStartChallenge: () => _startDailyChallengeQuiz(context, challenge),
          onViewResults: result != null
              ? () => _navigateToDailyChallengeResults(
                  context,
                  result,
                  challenge.categoryId,
                )
              : null,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  /// Starts the actual quiz for the daily challenge.
  Future<void> _startDailyChallengeQuiz(
    BuildContext context,
    DailyChallenge challenge,
  ) async {
    // Get current streak for analytics
    final stats = await _deps.dailyChallengeService.getStats();

    // Log challenge started event
    await _deps.services.screenAnalyticsService.logEvent(
      DailyChallengeEvent.started(
        challengeId: challenge.id,
        categoryId: challenge.categoryId,
        totalQuestions: challenge.questionCount,
        timeLimitSeconds: challenge.timeLimitSeconds,
        currentStreak: stats.currentStreak,
      ),
    );

    // Load questions
    final questions = await _deps.dailyChallengeDataProvider.loadQuestions(
      context,
      categoryId: challenge.categoryId,
      seed: challenge.seed,
      count: challenge.questionCount,
    );

    if (!context.mounted) return;

    // Create quiz config
    final quizConfig = _deps.dailyChallengeDataProvider.createQuizConfig(
      challengeId: challenge.id,
      timeLimitSeconds: challenge.timeLimitSeconds,
    );

    final storageConfig = _deps.dailyChallengeDataProvider.createStorageConfig(
      challenge.categoryId,
    );

    final layoutConfig = _deps.dailyChallengeDataProvider.createLayoutConfig();

    // Get localized title
    final l10n = AppLocalizations.of(context);
    final categoryName = _getCategoryName(challenge.categoryId, l10n);

    // Create config manager for the quiz
    final configManager = ConfigManager(
      defaultConfig: quizConfig.copyWith(
        storageConfig: storageConfig,
        layoutConfig: layoutConfig,
      ),
      getSettings: () => {
        'soundEnabled': _deps.services.settingsService.currentSettings.soundEnabled,
        'hapticEnabled': _deps.services.settingsService.currentSettings.hapticEnabled,
        'showAnswerFeedback': true,
      },
    );

    // Navigate to quiz using QuizWidget
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'daily_challenge_quiz'),
        builder: (ctx) => QuizWidget(
          quizEntry: QuizWidgetEntry(
            title: categoryName ?? 'Daily Challenge',
            dataProvider: () async => questions,
            configManager: configManager,
            storageService: null, // Don't store daily challenge sessions in quiz history
            quizAnalyticsService: _deps.services.quizAnalyticsService,
            categoryId: challenge.categoryId,
            categoryName: categoryName ?? challenge.categoryId,
            onQuizCompleted: (results) async {
              // Pop back from quiz screen
              if (ctx.mounted) {
                Navigator.of(ctx).pop();
              }
              // Submit the result
              if (context.mounted) {
                await _submitDailyChallengeResult(context, challenge, results);
              }
            },
          ),
        ),
      ),
    );
  }

  /// Submits the daily challenge result and shows results screen.
  Future<void> _submitDailyChallengeResult(
    BuildContext context,
    DailyChallenge challenge,
    QuizResults quizResults,
  ) async {
    // Submit result to service (returns result with calculated bonuses)
    final dailyChallengeResult = await _deps.dailyChallengeService.submitResult(
      challengeId: challenge.id,
      correctCount: quizResults.correctAnswers,
      totalQuestions: quizResults.totalQuestions,
      completionTimeSeconds: quizResults.durationSeconds,
    );

    // Get updated streak for analytics and statistics
    final stats = await _deps.dailyChallengeService.getStats();

    // Update global statistics with daily challenge data
    await _deps.statisticsRepository.updateDailyChallengeStats(
      isPerfect: dailyChallengeResult.isPerfectScore,
      currentStreak: stats.currentStreak,
    );

    // Check if early bird (completed before 7 AM local time)
    final now = DateTime.now();
    final isEarlyBird = now.hour < 7;

    // Create a session for achievement checking
    final dailyChallengeSession = QuizSession(
      id: dailyChallengeResult.id,
      quizId: 'daily_${challenge.id}',
      quizName: 'Daily Challenge',
      quizType: 'daily_challenge',
      quizCategory: challenge.categoryId,
      totalQuestions: dailyChallengeResult.totalQuestions,
      totalAnswered: dailyChallengeResult.totalQuestions,
      totalCorrect: dailyChallengeResult.correctCount,
      totalFailed: dailyChallengeResult.incorrectCount,
      totalSkipped: 0,
      scorePercentage: dailyChallengeResult.scorePercentage,
      score: dailyChallengeResult.score,
      startTime: dailyChallengeResult.completedAt.subtract(
        Duration(seconds: dailyChallengeResult.completionTimeSeconds),
      ),
      endTime: dailyChallengeResult.completedAt,
      durationSeconds: dailyChallengeResult.completionTimeSeconds,
      completionStatus: CompletionStatus.completed,
      mode: QuizMode.timed,
      appVersion: '1.0.0',
      createdAt: now,
      updatedAt: now,
    );

    // Check achievements for this session
    await _deps.services.achievementService.checkAfterSession(dailyChallengeSession);

    // Log challenge completed event
    await _deps.services.screenAnalyticsService.logEvent(
      DailyChallengeEvent.completed(
        challengeId: challenge.id,
        categoryId: challenge.categoryId,
        score: dailyChallengeResult.score,
        correctCount: dailyChallengeResult.correctCount,
        totalQuestions: dailyChallengeResult.totalQuestions,
        completionTimeSeconds: dailyChallengeResult.completionTimeSeconds,
        streakBonus: dailyChallengeResult.streakBonus,
        timeBonus: dailyChallengeResult.timeBonus,
        isPerfect: dailyChallengeResult.isPerfectScore,
        currentStreak: stats.currentStreak,
        isEarlyBird: isEarlyBird,
      ),
    );

    // Navigate to results screen
    if (context.mounted) {
      await _navigateToDailyChallengeResults(
        context,
        dailyChallengeResult,
        challenge.categoryId,
      );
    }
  }

  /// Navigates to the daily challenge results screen.
  ///
  /// The [categoryId] is optional - if not provided, it will be retrieved
  /// from today's challenge via the service.
  Future<void> _navigateToDailyChallengeResults(
    BuildContext context,
    DailyChallengeResult result, [
    String? categoryId,
  ]) async {
    // Get streak info from stats
    final stats = await _deps.dailyChallengeService.getStats();

    // Get categoryId from challenge if not provided
    var resolvedCategoryId = categoryId;
    if (resolvedCategoryId == null) {
      final challenge = await _deps.dailyChallengeService.getTodaysChallenge();
      resolvedCategoryId = challenge.categoryId;
    }

    if (!context.mounted) return;

    // Get category name for display
    final l10n = AppLocalizations.of(context);
    final categoryName = _getCategoryName(resolvedCategoryId, l10n);

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        settings: const RouteSettings(name: 'daily_challenge_results'),
        builder: (ctx) => DailyChallengeResultsScreen(
          data: DailyChallengeResultsData(
            todayResult: result,
            currentStreak: stats.currentStreak,
            bestStreak: stats.longestStreak,
            categoryName: categoryName,
          ),
          onDone: () => Navigator.of(ctx).pop(),
          onShareResult: () => _shareDailyChallengeResult(
            ctx,
            result,
            categoryName,
            stats.currentStreak,
          ),
        ),
      ),
    );
  }

  /// Gets localized category name from category ID.
  String? _getCategoryName(String categoryId, AppLocalizations? l10n) {
    if (l10n == null) return null;

    return switch (categoryId.toLowerCase()) {
      'all' => l10n.all,
      'af' => l10n.africa,
      'eu' => l10n.europe,
      'as' => l10n.asia,
      'na' => l10n.northAmerica,
      'sa' => l10n.southAmerica,
      'oc' => l10n.oceania,
      _ => null,
    };
  }

  /// Shares daily challenge result using the share bottom sheet.
  Future<void> _shareDailyChallengeResult(
    BuildContext context,
    DailyChallengeResult result,
    String? categoryName,
    int currentStreak,
  ) async {
    final shareService = _deps.services.shareService;
    if (shareService == null) return;

    final shareResult = ShareResult(
      score: result.score.toDouble(),
      categoryName: categoryName ?? 'Daily Challenge',
      correctCount: result.correctCount,
      totalCount: result.totalQuestions,
      mode: 'daily_challenge',
      timestamp: result.completedAt,
      streakCount: currentStreak,
      timeTaken: Duration(seconds: result.completionTimeSeconds),
    );

    await ShareBottomSheet.show(
      context: context,
      result: shareResult,
      shareService: shareService,
      config: ShareBottomSheetConfig(
        appName: 'Flags Quiz',
        showImageOption: shareService.canShareImage(),
      ),
    );
  }

  // ===========================================================================
  // Deep Link Handling
  // ===========================================================================

  /// Handles parsed deep link routes.
  ///
  /// Uses [QuizNavigation] from the quiz_engine package to navigate
  /// to the appropriate screen based on the deep link route type.
  void _handleDeepLinkRoute(
    BuildContext context,
    FlagsQuizDeepLinkRoute route,
  ) {
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
