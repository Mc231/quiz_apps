import 'dart:io';

import 'package:shared_services/shared_services.dart';

/// Game service configuration for the Flags Quiz app.
///
/// This configuration maps internal leaderboard and achievement IDs
/// to platform-specific IDs (Game Center for iOS, Play Games for Android).
///
/// **IMPORTANT:** Replace placeholder IDs with actual IDs from:
/// - iOS: App Store Connect → Game Center
/// - Android: Google Play Console → Play Games Services
///
/// **Leaderboard ID Format:**
/// - iOS Game Center: Usually formatted as 'grp.com.yourcompany.app.leaderboard.name'
/// - Android Play Games: Usually formatted as 'CgkI...' (auto-generated)
///
/// **Achievement ID Format:**
/// - iOS Game Center: Usually the achievement reference name from App Store Connect
/// - Android Play Games: Usually formatted as 'CgkI...' (auto-generated)
class FlagsGameServiceConfig {
  /// Creates the production game service configuration.
  ///
  /// Pass actual platform IDs from App Store Connect and Google Play Console.
  static GameServiceConfig production({
    // Leaderboard IDs from platforms
    String? globalLeaderboardGameCenterId,
    String? globalLeaderboardPlayGamesId,
    String? europeLeaderboardGameCenterId,
    String? europeLeaderboardPlayGamesId,
    String? asiaLeaderboardGameCenterId,
    String? asiaLeaderboardPlayGamesId,
    String? africaLeaderboardGameCenterId,
    String? africaLeaderboardPlayGamesId,
    String? americasLeaderboardGameCenterId,
    String? americasLeaderboardPlayGamesId,
    String? oceaniaLeaderboardGameCenterId,
    String? oceaniaLeaderboardPlayGamesId,
    // Achievement ID mappings
    Map<String, String>? achievementIdMap,
  }) {
    return GameServiceConfig(
      isEnabled: true,
      cloudSyncEnabled: true,
      syncOnLaunch: true,
      syncAfterQuizCompletion: true,
      showAccountInSettings: true,
      leaderboards: [
        LeaderboardConfig(
          id: 'global',
          gameCenterId: globalLeaderboardGameCenterId,
          playGamesId: globalLeaderboardPlayGamesId,
          scoreType: LeaderboardScoreType.highScore,
        ),
        LeaderboardConfig(
          id: 'europe',
          gameCenterId: europeLeaderboardGameCenterId,
          playGamesId: europeLeaderboardPlayGamesId,
          scoreType: LeaderboardScoreType.highScore,
        ),
        LeaderboardConfig(
          id: 'asia',
          gameCenterId: asiaLeaderboardGameCenterId,
          playGamesId: asiaLeaderboardPlayGamesId,
          scoreType: LeaderboardScoreType.highScore,
        ),
        LeaderboardConfig(
          id: 'africa',
          gameCenterId: africaLeaderboardGameCenterId,
          playGamesId: africaLeaderboardPlayGamesId,
          scoreType: LeaderboardScoreType.highScore,
        ),
        LeaderboardConfig(
          id: 'americas',
          gameCenterId: americasLeaderboardGameCenterId,
          playGamesId: americasLeaderboardPlayGamesId,
          scoreType: LeaderboardScoreType.highScore,
        ),
        LeaderboardConfig(
          id: 'oceania',
          gameCenterId: oceaniaLeaderboardGameCenterId,
          playGamesId: oceaniaLeaderboardPlayGamesId,
          scoreType: LeaderboardScoreType.highScore,
        ),
      ],
      achievementIdMap: achievementIdMap ?? _defaultAchievementIdMap,
    );
  }

  /// Creates a test/development configuration.
  ///
  /// Uses real Play Games IDs for testing on Android.
  /// Uses real Game Center IDs for testing on iOS.
  ///
  /// TODO: Before production release:
  /// 1. Replace all placeholder leaderboard IDs with real Play Games/Game Center IDs
  /// 2. Replace all placeholder achievement IDs in achievement maps
  /// 3. Create category-specific leaderboards (europe, asia, africa, americas, oceania)
  /// 4. Switch to production() config in FlagsQuizAppProvider
  static GameServiceConfig development() {
    // Select platform-specific achievement IDs
    final achievementMap = (Platform.isIOS || Platform.isMacOS)
        ? _developmentGameCenterAchievementIdMap
        : _developmentPlayGamesAchievementIdMap;

    return GameServiceConfig(
      isEnabled: true,
      cloudSyncEnabled: true,
      syncOnLaunch: true,
      syncAfterQuizCompletion: true,
      showAccountInSettings: true,
      leaderboards: [
        const LeaderboardConfig(
          id: 'global',
          // TODO: Replace with real Game Center leaderboard ID
          gameCenterId: 'PLACEHOLDER_global_leaderboard',
          // TODO: Replace with real Play Games leaderboard ID
          playGamesId: 'PLACEHOLDER_global_leaderboard',
          scoreType: LeaderboardScoreType.highScore,
        ),
        const LeaderboardConfig(
          id: 'europe',
          gameCenterId: 'PLACEHOLDER_europe_leaderboard',
          playGamesId: 'PLACEHOLDER_europe_leaderboard',
          scoreType: LeaderboardScoreType.highScore,
        ),
        const LeaderboardConfig(
          id: 'asia',
          gameCenterId: 'PLACEHOLDER_asia_leaderboard',
          playGamesId: 'PLACEHOLDER_asia_leaderboard',
          scoreType: LeaderboardScoreType.highScore,
        ),
        const LeaderboardConfig(
          id: 'africa',
          gameCenterId: 'PLACEHOLDER_africa_leaderboard',
          playGamesId: 'PLACEHOLDER_africa_leaderboard',
          scoreType: LeaderboardScoreType.highScore,
        ),
        const LeaderboardConfig(
          id: 'americas',
          gameCenterId: 'PLACEHOLDER_americas_leaderboard',
          playGamesId: 'PLACEHOLDER_americas_leaderboard',
          scoreType: LeaderboardScoreType.highScore,
        ),
        const LeaderboardConfig(
          id: 'oceania',
          gameCenterId: 'PLACEHOLDER_oceania_leaderboard',
          playGamesId: 'PLACEHOLDER_oceania_leaderboard',
          scoreType: LeaderboardScoreType.highScore,
        ),
      ],
      achievementIdMap: achievementMap,
    );
  }

  /// Development Game Center achievement ID mapping for iOS testing.
  ///
  /// Maps internal achievement IDs to Game Center achievement IDs
  /// from App Store Connect → Game Center → Achievements.
  static const Map<String, String> _developmentGameCenterAchievementIdMap = {
    // TODO: Replace with real Game Center achievement IDs
    'first_quiz': 'PLACEHOLDER_first_quiz',
    'first_perfect': 'PLACEHOLDER_first_perfect',
    'first_challenge': 'PLACEHOLDER_first_challenge',
    'quizzes_10': 'PLACEHOLDER_quizzes_10',
    'quizzes_50': 'PLACEHOLDER_quizzes_50',
    'quizzes_100': 'PLACEHOLDER_quizzes_100',
    'quizzes_500': 'PLACEHOLDER_quizzes_500',
    'questions_100': 'PLACEHOLDER_questions_100',
    'questions_500': 'PLACEHOLDER_questions_500',
    'questions_1000': 'PLACEHOLDER_questions_1000',
    'questions_5000': 'PLACEHOLDER_questions_5000',
    'correct_100': 'PLACEHOLDER_correct_100',
    'correct_500': 'PLACEHOLDER_correct_500',
    'correct_1000': 'PLACEHOLDER_correct_1000',
    'perfect_5': 'PLACEHOLDER_perfect_5',
    'perfect_10': 'PLACEHOLDER_perfect_10',
    'perfect_25': 'PLACEHOLDER_perfect_25',
    'perfect_50': 'PLACEHOLDER_perfect_50',
    'score_90_10': 'PLACEHOLDER_score_90_10',
    'score_95_10': 'PLACEHOLDER_score_95_10',
    'perfect_streak_3': 'PLACEHOLDER_perfect_streak_3',
    'speed_demon': 'PLACEHOLDER_speed_demon',
    'lightning': 'PLACEHOLDER_lightning',
    'quick_answer_10': 'PLACEHOLDER_quick_answer_10',
    'quick_answer_50': 'PLACEHOLDER_quick_answer_50',
    'streak_10': 'PLACEHOLDER_streak_10',
    'streak_25': 'PLACEHOLDER_streak_25',
    'streak_50': 'PLACEHOLDER_streak_50',
    'streak_100': 'PLACEHOLDER_streak_100',
    'survival_complete': 'PLACEHOLDER_survival_complete',
    'survival_perfect': 'PLACEHOLDER_survival_perfect',
    'blitz_complete': 'PLACEHOLDER_blitz_complete',
    'blitz_perfect': 'PLACEHOLDER_blitz_perfect',
    'time_attack_20': 'PLACEHOLDER_time_attack_20',
    'time_attack_30': 'PLACEHOLDER_time_attack_30',
    'marathon_50': 'PLACEHOLDER_marathon_50',
    'marathon_100': 'PLACEHOLDER_marathon_100',
    'speed_run_fast': 'PLACEHOLDER_speed_run_fast',
    'all_challenges': 'PLACEHOLDER_all_challenges',
    'time_1h': 'PLACEHOLDER_time_1h',
    'time_5h': 'PLACEHOLDER_time_5h',
    'time_10h': 'PLACEHOLDER_time_10h',
    'time_24h': 'PLACEHOLDER_time_24h',
    'days_3': 'PLACEHOLDER_days_3',
    'days_7': 'PLACEHOLDER_days_7',
    'days_14': 'PLACEHOLDER_days_14',
    'days_30': 'PLACEHOLDER_days_30',
    'no_hints': 'PLACEHOLDER_no_hints',
    'no_hints_10': 'PLACEHOLDER_no_hints_10',
    'no_skip': 'PLACEHOLDER_no_skip',
    'flawless': 'PLACEHOLDER_flawless',
    'comeback': 'PLACEHOLDER_comeback',
    'clutch': 'PLACEHOLDER_clutch',
    'explore_africa': 'PLACEHOLDER_explore_africa',
    'explore_asia': 'PLACEHOLDER_explore_asia',
    'explore_europe': 'PLACEHOLDER_explore_europe',
    'explore_north_america': 'PLACEHOLDER_explore_north_america',
    'explore_south_america': 'PLACEHOLDER_explore_south_america',
    'explore_oceania': 'PLACEHOLDER_explore_oceania',
    'world_traveler': 'PLACEHOLDER_world_traveler',
    'master_europe': 'PLACEHOLDER_master_europe',
    'master_asia': 'PLACEHOLDER_master_asia',
    'master_africa': 'PLACEHOLDER_master_africa',
    'master_americas': 'PLACEHOLDER_master_americas',
    'master_oceania': 'PLACEHOLDER_master_oceania',
    'master_world': 'PLACEHOLDER_master_world',
    'flag_collector': 'PLACEHOLDER_flag_collector',
    'first_flame': 'PLACEHOLDER_first_flame',
    'week_warrior': 'PLACEHOLDER_week_warrior',
    'monthly_master': 'PLACEHOLDER_monthly_master',
    'centurion': 'PLACEHOLDER_centurion',
    'dedication': 'PLACEHOLDER_dedication',
    'daily_devotee': 'PLACEHOLDER_daily_devotee',
    'perfect_day': 'PLACEHOLDER_perfect_day',
    'early_bird': 'PLACEHOLDER_early_bird',
  };

  /// Development Play Games achievement ID mapping for Android testing.
  ///
  /// Maps internal achievement IDs to Play Games achievement IDs
  /// from Google Play Console → Play Games Services → Achievements.
  static const Map<String, String> _developmentPlayGamesAchievementIdMap = {
    // TODO: Replace with real Play Games achievement IDs
    'first_quiz': 'PLACEHOLDER_first_quiz',
    'first_perfect': 'PLACEHOLDER_first_perfect',
    'first_challenge': 'PLACEHOLDER_first_challenge',
    'quizzes_10': 'PLACEHOLDER_quizzes_10',
    'quizzes_50': 'PLACEHOLDER_quizzes_50',
    'quizzes_100': 'PLACEHOLDER_quizzes_100',
    'quizzes_500': 'PLACEHOLDER_quizzes_500',
    'questions_100': 'PLACEHOLDER_questions_100',
    'questions_500': 'PLACEHOLDER_questions_500',
    'questions_1000': 'PLACEHOLDER_questions_1000',
    'questions_5000': 'PLACEHOLDER_questions_5000',
    'correct_100': 'PLACEHOLDER_correct_100',
    'correct_500': 'PLACEHOLDER_correct_500',
    'correct_1000': 'PLACEHOLDER_correct_1000',
    'perfect_5': 'PLACEHOLDER_perfect_5',
    'perfect_10': 'PLACEHOLDER_perfect_10',
    'perfect_25': 'PLACEHOLDER_perfect_25',
    'perfect_50': 'PLACEHOLDER_perfect_50',
    'score_90_10': 'PLACEHOLDER_score_90_10',
    'score_95_10': 'PLACEHOLDER_score_95_10',
    'perfect_streak_3': 'PLACEHOLDER_perfect_streak_3',
    'speed_demon': 'PLACEHOLDER_speed_demon',
    'lightning': 'PLACEHOLDER_lightning',
    'quick_answer_10': 'PLACEHOLDER_quick_answer_10',
    'quick_answer_50': 'PLACEHOLDER_quick_answer_50',
    'streak_10': 'PLACEHOLDER_streak_10',
    'streak_25': 'PLACEHOLDER_streak_25',
    'streak_50': 'PLACEHOLDER_streak_50',
    'streak_100': 'PLACEHOLDER_streak_100',
    'survival_complete': 'PLACEHOLDER_survival_complete',
    'survival_perfect': 'PLACEHOLDER_survival_perfect',
    'blitz_complete': 'PLACEHOLDER_blitz_complete',
    'blitz_perfect': 'PLACEHOLDER_blitz_perfect',
    'time_attack_20': 'PLACEHOLDER_time_attack_20',
    'time_attack_30': 'PLACEHOLDER_time_attack_30',
    'marathon_50': 'PLACEHOLDER_marathon_50',
    'marathon_100': 'PLACEHOLDER_marathon_100',
    'speed_run_fast': 'PLACEHOLDER_speed_run_fast',
    'all_challenges': 'PLACEHOLDER_all_challenges',
    'time_1h': 'PLACEHOLDER_time_1h',
    'time_5h': 'PLACEHOLDER_time_5h',
    'time_10h': 'PLACEHOLDER_time_10h',
    'time_24h': 'PLACEHOLDER_time_24h',
    'days_3': 'PLACEHOLDER_days_3',
    'days_7': 'PLACEHOLDER_days_7',
    'days_14': 'PLACEHOLDER_days_14',
    'days_30': 'PLACEHOLDER_days_30',
    'no_hints': 'PLACEHOLDER_no_hints',
    'no_hints_10': 'PLACEHOLDER_no_hints_10',
    'no_skip': 'PLACEHOLDER_no_skip',
    'flawless': 'PLACEHOLDER_flawless',
    'comeback': 'PLACEHOLDER_comeback',
    'clutch': 'PLACEHOLDER_clutch',
    'explore_africa': 'PLACEHOLDER_explore_africa',
    'explore_asia': 'PLACEHOLDER_explore_asia',
    'explore_europe': 'PLACEHOLDER_explore_europe',
    'explore_north_america': 'PLACEHOLDER_explore_north_america',
    'explore_south_america': 'PLACEHOLDER_explore_south_america',
    'explore_oceania': 'PLACEHOLDER_explore_oceania',
    'world_traveler': 'PLACEHOLDER_world_traveler',
    'master_europe': 'PLACEHOLDER_master_europe',
    'master_asia': 'PLACEHOLDER_master_asia',
    'master_africa': 'PLACEHOLDER_master_africa',
    'master_americas': 'PLACEHOLDER_master_americas',
    'master_oceania': 'PLACEHOLDER_master_oceania',
    'master_world': 'PLACEHOLDER_master_world',
    'flag_collector': 'PLACEHOLDER_flag_collector',
    'first_flame': 'PLACEHOLDER_first_flame',
    'week_warrior': 'PLACEHOLDER_week_warrior',
    'monthly_master': 'PLACEHOLDER_monthly_master',
    'centurion': 'PLACEHOLDER_centurion',
    'dedication': 'PLACEHOLDER_dedication',
    'daily_devotee': 'PLACEHOLDER_daily_devotee',
    'perfect_day': 'PLACEHOLDER_perfect_day',
    'early_bird': 'PLACEHOLDER_early_bird',
  };

  /// Creates a disabled configuration.
  ///
  /// Use when game services should be completely disabled.
  static const GameServiceConfig disabled = GameServiceConfig.disabled();

  /// Default achievement ID mapping.
  ///
  /// Maps internal achievement IDs to placeholder platform IDs.
  /// Replace with actual IDs from App Store Connect / Play Console.
  ///
  /// Format: 'internal_id': 'PLACEHOLDER_platform_id'
  static const Map<String, String> _defaultAchievementIdMap = {
    // === Beginner Achievements (Base) ===
    'first_quiz': 'PLACEHOLDER_first_quiz',
    'first_perfect': 'PLACEHOLDER_first_perfect',
    'first_challenge': 'PLACEHOLDER_first_challenge',

    // === Progress Achievements - Quiz Count (Base) ===
    'quizzes_10': 'PLACEHOLDER_quizzes_10',
    'quizzes_50': 'PLACEHOLDER_quizzes_50',
    'quizzes_100': 'PLACEHOLDER_quizzes_100',
    'quizzes_500': 'PLACEHOLDER_quizzes_500',

    // === Progress Achievements - Questions (Base) ===
    'questions_100': 'PLACEHOLDER_questions_100',
    'questions_500': 'PLACEHOLDER_questions_500',
    'questions_1000': 'PLACEHOLDER_questions_1000',
    'questions_5000': 'PLACEHOLDER_questions_5000',

    // === Progress Achievements - Correct Answers (Base) ===
    'correct_100': 'PLACEHOLDER_correct_100',
    'correct_500': 'PLACEHOLDER_correct_500',
    'correct_1000': 'PLACEHOLDER_correct_1000',

    // === Mastery Achievements - Perfect Scores (Base) ===
    'perfect_5': 'PLACEHOLDER_perfect_5',
    'perfect_10': 'PLACEHOLDER_perfect_10',
    'perfect_25': 'PLACEHOLDER_perfect_25',
    'perfect_50': 'PLACEHOLDER_perfect_50',

    // === Mastery Achievements - High Scores (Base) ===
    'score_90_10': 'PLACEHOLDER_score_90_10',
    'score_95_10': 'PLACEHOLDER_score_95_10',
    'perfect_streak_3': 'PLACEHOLDER_perfect_streak_3',

    // === Speed Achievements (Base) ===
    'speed_demon': 'PLACEHOLDER_speed_demon',
    'lightning': 'PLACEHOLDER_lightning',
    'quick_answer_10': 'PLACEHOLDER_quick_answer_10',
    'quick_answer_50': 'PLACEHOLDER_quick_answer_50',

    // === Streak Achievements (Base) ===
    'streak_10': 'PLACEHOLDER_streak_10',
    'streak_25': 'PLACEHOLDER_streak_25',
    'streak_50': 'PLACEHOLDER_streak_50',
    'streak_100': 'PLACEHOLDER_streak_100',

    // === Challenge Achievements (Base) ===
    'survival_complete': 'PLACEHOLDER_survival_complete',
    'survival_perfect': 'PLACEHOLDER_survival_perfect',
    'blitz_complete': 'PLACEHOLDER_blitz_complete',
    'blitz_perfect': 'PLACEHOLDER_blitz_perfect',
    'time_attack_20': 'PLACEHOLDER_time_attack_20',
    'time_attack_30': 'PLACEHOLDER_time_attack_30',
    'marathon_50': 'PLACEHOLDER_marathon_50',
    'marathon_100': 'PLACEHOLDER_marathon_100',
    'speed_run_fast': 'PLACEHOLDER_speed_run_fast',
    'all_challenges': 'PLACEHOLDER_all_challenges',

    // === Dedication Achievements - Time (Base) ===
    'time_1h': 'PLACEHOLDER_time_1h',
    'time_5h': 'PLACEHOLDER_time_5h',
    'time_10h': 'PLACEHOLDER_time_10h',
    'time_24h': 'PLACEHOLDER_time_24h',

    // === Dedication Achievements - Days (Base) ===
    'days_3': 'PLACEHOLDER_days_3',
    'days_7': 'PLACEHOLDER_days_7',
    'days_14': 'PLACEHOLDER_days_14',
    'days_30': 'PLACEHOLDER_days_30',

    // === Skill Achievements (Base) ===
    'no_hints': 'PLACEHOLDER_no_hints',
    'no_hints_10': 'PLACEHOLDER_no_hints_10',
    'no_skip': 'PLACEHOLDER_no_skip',
    'flawless': 'PLACEHOLDER_flawless',
    'comeback': 'PLACEHOLDER_comeback',
    'clutch': 'PLACEHOLDER_clutch',

    // === Flags Quiz Specific - Exploration ===
    'explore_africa': 'PLACEHOLDER_explore_africa',
    'explore_asia': 'PLACEHOLDER_explore_asia',
    'explore_europe': 'PLACEHOLDER_explore_europe',
    'explore_north_america': 'PLACEHOLDER_explore_north_america',
    'explore_south_america': 'PLACEHOLDER_explore_south_america',
    'explore_oceania': 'PLACEHOLDER_explore_oceania',
    'world_traveler': 'PLACEHOLDER_world_traveler',

    // === Flags Quiz Specific - Mastery ===
    'master_europe': 'PLACEHOLDER_master_europe',
    'master_asia': 'PLACEHOLDER_master_asia',
    'master_africa': 'PLACEHOLDER_master_africa',
    'master_americas': 'PLACEHOLDER_master_americas',
    'master_oceania': 'PLACEHOLDER_master_oceania',
    'master_world': 'PLACEHOLDER_master_world',
    'flag_collector': 'PLACEHOLDER_flag_collector',

    // === Flags Quiz Specific - Dedication ===
    'first_flame': 'PLACEHOLDER_first_flame',
    'week_warrior': 'PLACEHOLDER_week_warrior',
    'monthly_master': 'PLACEHOLDER_monthly_master',
    'centurion': 'PLACEHOLDER_centurion',
    'dedication': 'PLACEHOLDER_dedication',
    'daily_devotee': 'PLACEHOLDER_daily_devotee',
    'perfect_day': 'PLACEHOLDER_perfect_day',
    'early_bird': 'PLACEHOLDER_early_bird',
  };

  /// Creates a configuration with custom achievement ID mapping.
  ///
  /// Use this to provide actual platform IDs after registering achievements
  /// in App Store Connect and Google Play Console.
  ///
  /// Example:
  /// ```dart
  /// final config = FlagsGameServiceConfig.withAchievements(
  ///   achievementIdMap: {
  ///     'first_quiz': 'grp.com.company.flagsquiz.achievement.first_quiz',
  ///     'perfect_10': 'grp.com.company.flagsquiz.achievement.perfect_10',
  ///     // ... more mappings
  ///   },
  /// );
  /// ```
  static GameServiceConfig withAchievements({
    required Map<String, String> achievementIdMap,
    // Leaderboard IDs
    String? globalLeaderboardGameCenterId,
    String? globalLeaderboardPlayGamesId,
    String? europeLeaderboardGameCenterId,
    String? europeLeaderboardPlayGamesId,
    String? asiaLeaderboardGameCenterId,
    String? asiaLeaderboardPlayGamesId,
    String? africaLeaderboardGameCenterId,
    String? africaLeaderboardPlayGamesId,
    String? americasLeaderboardGameCenterId,
    String? americasLeaderboardPlayGamesId,
    String? oceaniaLeaderboardGameCenterId,
    String? oceaniaLeaderboardPlayGamesId,
  }) {
    return production(
      globalLeaderboardGameCenterId: globalLeaderboardGameCenterId,
      globalLeaderboardPlayGamesId: globalLeaderboardPlayGamesId,
      europeLeaderboardGameCenterId: europeLeaderboardGameCenterId,
      europeLeaderboardPlayGamesId: europeLeaderboardPlayGamesId,
      asiaLeaderboardGameCenterId: asiaLeaderboardGameCenterId,
      asiaLeaderboardPlayGamesId: asiaLeaderboardPlayGamesId,
      africaLeaderboardGameCenterId: africaLeaderboardGameCenterId,
      africaLeaderboardPlayGamesId: africaLeaderboardPlayGamesId,
      americasLeaderboardGameCenterId: americasLeaderboardGameCenterId,
      americasLeaderboardPlayGamesId: americasLeaderboardPlayGamesId,
      oceaniaLeaderboardGameCenterId: oceaniaLeaderboardGameCenterId,
      oceaniaLeaderboardPlayGamesId: oceaniaLeaderboardPlayGamesId,
      achievementIdMap: achievementIdMap,
    );
  }

  /// Returns a list of all achievement IDs that should be registered
  /// on the platform.
  ///
  /// Use this list when setting up achievements in App Store Connect
  /// and Google Play Console.
  static List<String> get allAchievementIds =>
      _defaultAchievementIdMap.keys.toList();

  /// Returns the number of achievements to register.
  static int get achievementCount => _defaultAchievementIdMap.length;

  /// Returns a list of all leaderboard IDs.
  static List<String> get allLeaderboardIds => [
        'global',
        'europe',
        'asia',
        'africa',
        'americas',
        'oceania',
      ];
}
