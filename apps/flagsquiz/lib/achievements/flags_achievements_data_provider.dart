import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/app_localizations.dart';
import '../models/continent.dart';
import 'flags_achievements.dart';

/// Data provider for the Achievements tab in Flags Quiz.
///
/// Uses [AchievementService] to load achievements and their progress.
class FlagsAchievementsDataProvider {
  final AchievementService _achievementService;
  final QuizSessionRepository _sessionRepository;

  /// All achievements (created lazily).
  List<Achievement>? _cachedAchievements;

  /// Cached category completion data for sync access.
  Map<String, CategoryCompletionData> _cachedCategoryData = {};

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Creates a [FlagsAchievementsDataProvider].
  FlagsAchievementsDataProvider({
    required AchievementService achievementService,
    required QuizSessionRepository sessionRepository,
  })  : _achievementService = achievementService,
        _sessionRepository = sessionRepository;

  /// Gets all achievements using LocalizedString functions.
  List<Achievement> _getAllAchievements() {
    if (_cachedAchievements != null) return _cachedAchievements!;

    _cachedAchievements = [
      // Beginner (3)
      Achievement(
        id: 'first_quiz',
        name: (ctx) => QuizL10n.of(ctx).achievementFirstQuiz,
        description: (ctx) => QuizL10n.of(ctx).achievementFirstQuizDesc,
        icon: '🎯',
        tier: AchievementTier.common,
        category: 'beginner',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 1),
      ),
      Achievement(
        id: 'first_perfect',
        name: (ctx) => QuizL10n.of(ctx).achievementFirstPerfect,
        description: (ctx) => QuizL10n.of(ctx).achievementFirstPerfectDesc,
        icon: '⭐',
        tier: AchievementTier.common,
        category: 'beginner',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 1),
      ),
      Achievement(
        id: 'first_challenge',
        name: (ctx) => QuizL10n.of(ctx).achievementFirstChallenge,
        description: (ctx) => QuizL10n.of(ctx).achievementFirstChallengeDesc,
        icon: '🏆',
        tier: AchievementTier.common,
        category: 'beginner',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 1),
      ),
      // Progress (8)
      Achievement(
        id: 'quizzes_10',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes10,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes10Desc,
        icon: '📚',
        tier: AchievementTier.common,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 10),
      ),
      Achievement(
        id: 'quizzes_50',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes50,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes50Desc,
        icon: '📖',
        tier: AchievementTier.uncommon,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 50),
      ),
      Achievement(
        id: 'quizzes_100',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes100,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes100Desc,
        icon: '📕',
        tier: AchievementTier.rare,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 100),
      ),
      Achievement(
        id: 'quizzes_500',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes500,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes500Desc,
        icon: '📗',
        tier: AchievementTier.epic,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 500),
      ),
      Achievement(
        id: 'questions_100',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions100,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions100Desc,
        icon: '❓',
        tier: AchievementTier.common,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 100),
      ),
      Achievement(
        id: 'questions_500',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions500,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions500Desc,
        icon: '❔',
        tier: AchievementTier.uncommon,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 500),
      ),
      Achievement(
        id: 'questions_1000',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions1000,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions1000Desc,
        icon: '💬',
        tier: AchievementTier.rare,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 1000),
      ),
      Achievement(
        id: 'correct_1000',
        name: (ctx) => QuizL10n.of(ctx).achievementCorrect1000,
        description: (ctx) => QuizL10n.of(ctx).achievementCorrect1000Desc,
        icon: '✅',
        tier: AchievementTier.rare,
        category: 'progress',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCorrectAnswers, target: 1000),
      ),
      // Mastery (3)
      Achievement(
        id: 'perfect_5',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfect5,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfect5Desc,
        icon: '🌟',
        tier: AchievementTier.uncommon,
        category: 'mastery',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 5),
      ),
      Achievement(
        id: 'perfect_25',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfect25,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfect25Desc,
        icon: '✨',
        tier: AchievementTier.rare,
        category: 'mastery',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 25),
      ),
      Achievement(
        id: 'time_1h',
        name: (ctx) => QuizL10n.of(ctx).achievementTime1h,
        description: (ctx) => QuizL10n.of(ctx).achievementTime1hDesc,
        icon: '⏰',
        tier: AchievementTier.common,
        category: 'time',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalTimePlayedSeconds, target: 3600),
      ),
      Achievement(
        id: 'time_10h',
        name: (ctx) => QuizL10n.of(ctx).achievementTime10h,
        description: (ctx) => QuizL10n.of(ctx).achievementTime10hDesc,
        icon: '⏱️',
        tier: AchievementTier.uncommon,
        category: 'time',
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalTimePlayedSeconds, target: 36000),
      ),
      // Flags-specific (6)
      Achievement(
        id: 'explore_africa',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreAfrica ??
            'African Explorer',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreAfricaDesc ??
            'Complete a quiz about Africa',
        icon: '🌍',
        tier: AchievementTier.common,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'af'),
      ),
      Achievement(
        id: 'explore_europe',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreEurope ??
            'European Explorer',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreEuropeDesc ??
            'Complete a quiz about Europe',
        icon: '🇪🇺',
        tier: AchievementTier.common,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'eu'),
      ),
      Achievement(
        id: 'explore_asia',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreAsia ?? 'Asian Explorer',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreAsiaDesc ??
            'Complete a quiz about Asia',
        icon: '🌏',
        tier: AchievementTier.common,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'as'),
      ),
      Achievement(
        id: 'explore_north_america',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreNorthAmerica ??
            'North American Explorer',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreNorthAmericaDesc ??
            'Complete a quiz about North America',
        icon: '🗽',
        tier: AchievementTier.common,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'na'),
      ),
      Achievement(
        id: 'explore_south_america',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreSouthAmerica ??
            'South American Explorer',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreSouthAmericaDesc ??
            'Complete a quiz about South America',
        icon: '🌎',
        tier: AchievementTier.common,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'sa'),
      ),
      Achievement(
        id: 'explore_oceania',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreOceania ??
            'Oceanian Explorer',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementExploreOceaniaDesc ??
            'Complete a quiz about Oceania',
        icon: '🏝️',
        tier: AchievementTier.common,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'oc'),
      ),
    ];
    return _cachedAchievements!;
  }

  /// Initializes the achievement service with all achievements.
  ///
  /// Call this at app startup to ensure achievements can be checked
  /// even before the Achievements tab is opened.
  Future<void> initialize() async {
    _ensureInitialized();

    // Set up category data provider
    _achievementService.categoryDataProvider = _getCategoryData;

    // Load initial category data
    await refreshCategoryData();
  }

  void _ensureInitialized() {
    if (_isInitialized) return;

    final achievements = _getAllAchievements();
    _achievementService.initialize(achievements);
    _isInitialized = true;
  }

  /// Returns cached category completion data synchronously.
  ///
  /// This is called by [AchievementService] when checking achievements.
  Map<String, CategoryCompletionData> _getCategoryData() {
    return _cachedCategoryData;
  }

  /// Refreshes the cached category completion data from storage.
  ///
  /// Call this after quiz completion to update category stats.
  Future<void> refreshCategoryData() async {
    final Map<String, CategoryCompletionData> categoryData = {};

    // Get completion counts for each continent category
    for (final continent in Continent.values) {
      if (continent == Continent.all) continue;

      final categoryId = continent.name;

      // Get completed sessions for this category
      final sessions = await _sessionRepository.getSessions(
        filter: QuizSessionFilter(
          quizCategory: categoryId,
          completionStatus: CompletionStatus.completed,
        ),
      );

      // Count total and perfect completions
      int totalCompletions = sessions.length;
      int perfectCompletions =
          sessions.where((s) => s.scorePercentage >= 100.0).length;

      categoryData[categoryId] = CategoryCompletionData(
        categoryId: categoryId,
        totalCompletions: totalCompletions,
        perfectCompletions: perfectCompletions,
      );
    }

    _cachedCategoryData = categoryData;
  }

  /// Loads achievements data for the Achievements tab.
  Future<AchievementsTabData> loadAchievementsData() async {
    _ensureInitialized();

    final allAchievements = _getAllAchievements();

    // Get all progress from the service
    final progressList = await _achievementService.getAllProgress();

    // Create a map for quick lookup
    final progressMap = {
      for (final p in progressList) p.achievementId: p,
    };

    // Get summary for total points
    final summary = await _achievementService.getSummary();

    // Create display data for each achievement
    final displayData = <AchievementDisplayData>[];

    for (final achievement in allAchievements) {
      final progress = progressMap[achievement.id] ??
          AchievementProgress.locked(
            achievementId: achievement.id,
            targetValue: achievement.progressTarget,
          );

      displayData.add(AchievementDisplayData(
        achievement: achievement,
        progress: progress,
      ));
    }

    return AchievementsTabData(
      screenData: AchievementsScreenData(
        achievements: displayData,
        totalPoints: summary.totalPoints,
      ),
    );
  }
}
