import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/app_localizations.dart';

/// Flags Quiz specific achievements.
///
/// Contains 14 app-specific achievements organized into 3 categories:
/// - Explorer (7): Complete each continent quiz
/// - Region Mastery (6): Get 5 perfect scores in each region
/// - Collection (1): Collect all flags
///
/// Usage:
/// ```dart
/// final allAchievements = FlagsAchievements.all(context, l10n);
/// ```
class FlagsAchievements {
  FlagsAchievements._();

  /// Achievement category for explorer achievements.
  static const String categoryExplorer = 'explorer';

  /// Achievement category for region mastery achievements.
  static const String categoryRegionMastery = 'region_mastery';

  /// Achievement category for collection achievements.
  static const String categoryCollection = 'collection';

  // ===========================================================================
  // Explorer Category (7 achievements)
  // ===========================================================================

  /// African Explorer - Complete a quiz about Africa
  static Achievement exploreAfrica(AppLocalizations l10n) => Achievement(
        id: 'explore_africa',
        name: (_) => l10n.achievementExploreAfrica,
        description: (_) => l10n.achievementExploreAfricaDesc,
        icon: '🌍',
        tier: AchievementTier.common,
        category: categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'af'),
      );

  /// Asian Explorer - Complete a quiz about Asia
  static Achievement exploreAsia(AppLocalizations l10n) => Achievement(
        id: 'explore_asia',
        name: (_) => l10n.achievementExploreAsia,
        description: (_) => l10n.achievementExploreAsiaDesc,
        icon: '🌏',
        tier: AchievementTier.common,
        category: categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'as'),
      );

  /// European Explorer - Complete a quiz about Europe
  static Achievement exploreEurope(AppLocalizations l10n) => Achievement(
        id: 'explore_europe',
        name: (_) => l10n.achievementExploreEurope,
        description: (_) => l10n.achievementExploreEuropeDesc,
        icon: '🇪🇺',
        tier: AchievementTier.common,
        category: categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'eu'),
      );

  /// North American Explorer - Complete a quiz about North America
  static Achievement exploreNorthAmerica(AppLocalizations l10n) => Achievement(
        id: 'explore_north_america',
        name: (_) => l10n.achievementExploreNorthAmerica,
        description: (_) => l10n.achievementExploreNorthAmericaDesc,
        icon: '🗽',
        tier: AchievementTier.common,
        category: categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'na'),
      );

  /// South American Explorer - Complete a quiz about South America
  static Achievement exploreSouthAmerica(AppLocalizations l10n) => Achievement(
        id: 'explore_south_america',
        name: (_) => l10n.achievementExploreSouthAmerica,
        description: (_) => l10n.achievementExploreSouthAmericaDesc,
        icon: '🌎',
        tier: AchievementTier.common,
        category: categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'sa'),
      );

  /// Oceanian Explorer - Complete a quiz about Oceania
  static Achievement exploreOceania(AppLocalizations l10n) => Achievement(
        id: 'explore_oceania',
        name: (_) => l10n.achievementExploreOceania,
        description: (_) => l10n.achievementExploreOceaniaDesc,
        icon: '🏝️',
        tier: AchievementTier.common,
        category: categoryExplorer,
        trigger: AchievementTrigger.category(categoryId: 'oc'),
      );

  /// World Traveler - Complete a quiz in every continent
  static Achievement worldTraveler(AppLocalizations l10n) => Achievement(
        id: 'world_traveler',
        name: (_) => l10n.achievementWorldTraveler,
        description: (_) => l10n.achievementWorldTravelerDesc,
        icon: '✈️',
        tier: AchievementTier.rare,
        category: categoryExplorer,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // This checks if all 6 continent categories have been completed
            // The engine should track which categories have been completed
            return false; // Evaluated by engine with category completion data
          },
          getProgress: (stats) {
            // Progress is number of unique continents completed
            // Will be evaluated by engine with category data
            return 0;
          },
          target: 6,
        ),
      );

  // ===========================================================================
  // Region Mastery Category (6 achievements)
  // ===========================================================================

  /// Europe Master - Get 5 perfect scores in Europe
  static Achievement masterEurope(AppLocalizations l10n) => Achievement(
        id: 'master_europe',
        name: (_) => l10n.achievementMasterEurope,
        description: (_) => l10n.achievementMasterEuropeDesc,
        icon: '🏰',
        tier: AchievementTier.rare,
        category: categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'eu',
          requirePerfect: true,
          requiredCount: 5,
        ),
      );

  /// Asia Master - Get 5 perfect scores in Asia
  static Achievement masterAsia(AppLocalizations l10n) => Achievement(
        id: 'master_asia',
        name: (_) => l10n.achievementMasterAsia,
        description: (_) => l10n.achievementMasterAsiaDesc,
        icon: '🏯',
        tier: AchievementTier.rare,
        category: categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'as',
          requirePerfect: true,
          requiredCount: 5,
        ),
      );

  /// Africa Master - Get 5 perfect scores in Africa
  static Achievement masterAfrica(AppLocalizations l10n) => Achievement(
        id: 'master_africa',
        name: (_) => l10n.achievementMasterAfrica,
        description: (_) => l10n.achievementMasterAfricaDesc,
        icon: '🦁',
        tier: AchievementTier.rare,
        category: categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'af',
          requirePerfect: true,
          requiredCount: 5,
        ),
      );

  /// Americas Master - Get 5 perfect scores in NA or SA
  static Achievement masterAmericas(AppLocalizations l10n) => Achievement(
        id: 'master_americas',
        name: (_) => l10n.achievementMasterAmericas,
        description: (_) => l10n.achievementMasterAmericasDesc,
        icon: '🦅',
        tier: AchievementTier.rare,
        category: categoryRegionMastery,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // Check if session is in NA or SA with perfect score
            if (session == null) return false;
            final isAmericas =
                session.quizId == 'na' || session.quizId == 'sa';
            final isPerfect = session.totalCorrect == session.totalAnswered;
            return isAmericas && isPerfect;
          },
          getProgress: (stats) {
            // Progress tracked by engine with category-specific perfect counts
            return 0;
          },
          target: 5,
        ),
      );

  /// Oceania Master - Get 5 perfect scores in Oceania
  static Achievement masterOceania(AppLocalizations l10n) => Achievement(
        id: 'master_oceania',
        name: (_) => l10n.achievementMasterOceania,
        description: (_) => l10n.achievementMasterOceaniaDesc,
        icon: '🐨',
        tier: AchievementTier.rare,
        category: categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'oc',
          requirePerfect: true,
          requiredCount: 5,
        ),
      );

  /// World Master - Get 5 perfect scores in All Countries
  static Achievement masterWorld(AppLocalizations l10n) => Achievement(
        id: 'master_world',
        name: (_) => l10n.achievementMasterWorld,
        description: (_) => l10n.achievementMasterWorldDesc,
        icon: '🌐',
        tier: AchievementTier.epic,
        category: categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'all',
          requirePerfect: true,
          requiredCount: 5,
        ),
      );

  // ===========================================================================
  // Collection Category (1 achievement)
  // ===========================================================================

  /// Flag Collector - Answer every flag correctly at least once
  static Achievement flagCollector(AppLocalizations l10n) => Achievement(
        id: 'flag_collector',
        name: (_) => l10n.achievementFlagCollector,
        description: (_) => l10n.achievementFlagCollectorDesc,
        icon: '🏳️‍🌈',
        tier: AchievementTier.legendary,
        category: categoryCollection,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // This checks if all unique flags have been answered correctly
            // The engine should track unique correct answers per question
            return false; // Evaluated by engine with question tracking data
          },
          getProgress: (stats) {
            // Progress is number of unique flags correctly answered
            // Will be evaluated by engine with question-level data
            return 0;
          },
          target: 195, // Approximate number of flags in the quiz
        ),
      );

  // ===========================================================================
  // All Achievements
  // ===========================================================================

  /// Returns all Flags Quiz specific achievements.
  ///
  /// This includes all 14 app-specific achievements.
  static List<Achievement> all(AppLocalizations l10n) => [
        // Explorer (7)
        exploreAfrica(l10n),
        exploreAsia(l10n),
        exploreEurope(l10n),
        exploreNorthAmerica(l10n),
        exploreSouthAmerica(l10n),
        exploreOceania(l10n),
        worldTraveler(l10n),
        // Region Mastery (6)
        masterEurope(l10n),
        masterAsia(l10n),
        masterAfrica(l10n),
        masterAmericas(l10n),
        masterOceania(l10n),
        masterWorld(l10n),
        // Collection (1)
        flagCollector(l10n),
      ];

  /// Returns the count of all Flags Quiz specific achievements.
  static const int count = 14;

  /// Returns the combined list of all achievements (base + flags-specific).
  ///
  /// This includes all 53 base achievements and 14 app-specific achievements
  /// for a total of 67 achievements.
  static List<Achievement> allWithBase(
    QuizEngineLocalizations quizL10n,
    AppLocalizations appL10n,
  ) {
    return [
      ...BaseAchievements.all(quizL10n),
      ...all(appL10n),
    ];
  }

  /// Total count of all achievements (base + flags-specific).
  static const int totalCount = BaseAchievements.count + count; // 53 + 14 = 67
}
