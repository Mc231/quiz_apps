import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../achievements/flags_achievements_data_provider.dart';
import '../daily_challenge/flags_daily_challenge_data_provider.dart';
import '../data/flags_data_provider.dart';
import '../deeplink/flags_quiz_deep_link_service.dart';

/// Contains all dependencies needed to run the Flags Quiz app.
///
/// This class is internal to the app initialization process.
/// Use [FlagsQuizAppProvider.provideApp] instead of creating this directly.
class FlagsQuizDependencies {
  /// Creates [FlagsQuizDependencies]. Internal use only.
  const FlagsQuizDependencies({
    required this.services,
    required this.secrets,
    required this.achievementsProvider,
    required this.dataProvider,
    required this.categories,
    required this.navigatorObserver,
    required this.deepLinkService,
    required this.dailyChallengeService,
    required this.dailyChallengeDataProvider,
    required this.statisticsRepository,
    required this.gameService,
    required this.leaderboardService,
    required this.cloudAchievementService,
    required this.leaderboardIntegrationService,
    required this.achievementSyncService,
    required this.gameServiceConfig,
  });

  /// All core services bundled together.
  final QuizServices services;

  /// Secrets configuration loaded from JSON.
  final SecretsConfig secrets;

  /// Achievements data provider.
  final FlagsAchievementsDataProvider achievementsProvider;

  /// Data provider for loading quiz data.
  final FlagsDataProvider dataProvider;

  /// Quiz categories.
  final List<QuizCategory> categories;

  /// Navigator observer for automatic screen tracking.
  final AnalyticsNavigatorObserver navigatorObserver;

  /// Deep link service for handling flagsquiz:// URLs.
  final FlagsQuizDeepLinkService deepLinkService;

  /// Daily challenge service for managing daily challenges.
  final DailyChallengeService dailyChallengeService;

  /// Data provider for loading daily challenge questions.
  final FlagsDailyChallengeDataProvider dailyChallengeDataProvider;

  /// Statistics repository for updating global statistics.
  final StatisticsRepository statisticsRepository;

  /// Game service for Game Center / Play Games authentication.
  final GameService gameService;

  /// Leaderboard service for score submission.
  final LeaderboardService leaderboardService;

  /// Cloud achievement service for platform achievements.
  final CloudAchievementService cloudAchievementService;

  /// Leaderboard integration service for orchestrating score submissions.
  final LeaderboardIntegrationService leaderboardIntegrationService;

  /// Achievement sync service for syncing local achievements to platforms.
  final AchievementSyncService achievementSyncService;

  /// Game service configuration with platform IDs.
  final GameServiceConfig gameServiceConfig;
}
