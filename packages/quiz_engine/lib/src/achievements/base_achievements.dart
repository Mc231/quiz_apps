import 'package:shared_services/shared_services.dart';

import '../l10n/generated/quiz_engine_localizations.dart';
import 'achievement_category.dart';

/// Base achievements that work for any quiz app.
///
/// Contains 53 generic achievements organized into 8 categories:
/// - Beginner (3): First steps achievements
/// - Progress (11): Cumulative milestones
/// - Mastery (7): Score-based achievements
/// - Speed (4): Time-based achievements
/// - Streak (4): Consecutive correct achievements
/// - Challenge (10): Challenge mode achievements
/// - Dedication (8): Time and consistency achievements
/// - Skill (6): Special gameplay achievements
///
/// Usage:
/// ```dart
/// final achievements = BaseAchievements.all(context);
/// ```
class BaseAchievements {
  BaseAchievements._();

  // ===========================================================================
  // Beginner Category (3 achievements)
  // ===========================================================================

  /// First Steps - Complete your first quiz
  static Achievement firstQuiz(QuizEngineLocalizations l10n) => Achievement(
        id: 'first_quiz',
        name: (_) => l10n.achievementFirstQuiz,
        description: (_) => l10n.achievementFirstQuizDesc,
        icon: '🎯',
        tier: AchievementTier.common,
        category: AchievementCategory.beginner.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 1,
        ),
      );

  /// Perfectionist - Get your first perfect score
  static Achievement firstPerfect(QuizEngineLocalizations l10n) => Achievement(
        id: 'first_perfect',
        name: (_) => l10n.achievementFirstPerfect,
        description: (_) => l10n.achievementFirstPerfectDesc,
        icon: '⭐',
        tier: AchievementTier.common,
        category: AchievementCategory.beginner.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalPerfectScores,
          target: 1,
        ),
      );

  /// Challenger - Complete your first challenge mode
  static Achievement firstChallenge(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'first_challenge',
        name: (_) => l10n.achievementFirstChallenge,
        description: (_) => l10n.achievementFirstChallengeDesc,
        icon: '🏆',
        tier: AchievementTier.common,
        category: AchievementCategory.beginner.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // Any challenge completion triggers this
            // Challenge modes have specific quizId like 'survival', 'blitz', etc.
            final challengeIds = [
              'survival',
              'time_attack',
              'speed_run',
              'marathon',
              'blitz',
            ];
            return session != null && challengeIds.contains(session.quizId);
          },
          target: 1,
        ),
      );

  // ===========================================================================
  // Progress Category (11 achievements)
  // ===========================================================================

  /// Getting Started - Complete 10 quizzes
  static Achievement quizzes10(QuizEngineLocalizations l10n) => Achievement(
        id: 'quizzes_10',
        name: (_) => l10n.achievementQuizzes10,
        description: (_) => l10n.achievementQuizzes10Desc,
        icon: '📚',
        tier: AchievementTier.common,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 10,
        ),
      );

  /// Quiz Enthusiast - Complete 50 quizzes
  static Achievement quizzes50(QuizEngineLocalizations l10n) => Achievement(
        id: 'quizzes_50',
        name: (_) => l10n.achievementQuizzes50,
        description: (_) => l10n.achievementQuizzes50Desc,
        icon: '📖',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 50,
        ),
      );

  /// Quiz Master - Complete 100 quizzes
  static Achievement quizzes100(QuizEngineLocalizations l10n) => Achievement(
        id: 'quizzes_100',
        name: (_) => l10n.achievementQuizzes100,
        description: (_) => l10n.achievementQuizzes100Desc,
        icon: '🎓',
        tier: AchievementTier.rare,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 100,
        ),
      );

  /// Quiz Legend - Complete 500 quizzes
  static Achievement quizzes500(QuizEngineLocalizations l10n) => Achievement(
        id: 'quizzes_500',
        name: (_) => l10n.achievementQuizzes500,
        description: (_) => l10n.achievementQuizzes500Desc,
        icon: '👑',
        tier: AchievementTier.epic,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCompletedSessions,
          target: 500,
        ),
      );

  /// Century - Answer 100 questions
  static Achievement questions100(QuizEngineLocalizations l10n) => Achievement(
        id: 'questions_100',
        name: (_) => l10n.achievementQuestions100,
        description: (_) => l10n.achievementQuestions100Desc,
        icon: '💯',
        tier: AchievementTier.common,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalQuestionsAnswered,
          target: 100,
        ),
      );

  /// Half Thousand - Answer 500 questions
  static Achievement questions500(QuizEngineLocalizations l10n) => Achievement(
        id: 'questions_500',
        name: (_) => l10n.achievementQuestions500,
        description: (_) => l10n.achievementQuestions500Desc,
        icon: '🔢',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalQuestionsAnswered,
          target: 500,
        ),
      );

  /// Thousand Club - Answer 1000 questions
  static Achievement questions1000(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'questions_1000',
        name: (_) => l10n.achievementQuestions1000,
        description: (_) => l10n.achievementQuestions1000Desc,
        icon: '🧮',
        tier: AchievementTier.rare,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalQuestionsAnswered,
          target: 1000,
        ),
      );

  /// Expert - Answer 5000 questions
  static Achievement questions5000(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'questions_5000',
        name: (_) => l10n.achievementQuestions5000,
        description: (_) => l10n.achievementQuestions5000Desc,
        icon: '🧠',
        tier: AchievementTier.epic,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalQuestionsAnswered,
          target: 5000,
        ),
      );

  /// Sharp Eye - Get 100 correct answers
  static Achievement correct100(QuizEngineLocalizations l10n) => Achievement(
        id: 'correct_100',
        name: (_) => l10n.achievementCorrect100,
        description: (_) => l10n.achievementCorrect100Desc,
        icon: '✅',
        tier: AchievementTier.common,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCorrectAnswers,
          target: 100,
        ),
      );

  /// Knowledge Keeper - Get 500 correct answers
  static Achievement correct500(QuizEngineLocalizations l10n) => Achievement(
        id: 'correct_500',
        name: (_) => l10n.achievementCorrect500,
        description: (_) => l10n.achievementCorrect500Desc,
        icon: '🎯',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCorrectAnswers,
          target: 500,
        ),
      );

  /// Scholar - Get 1000 correct answers
  static Achievement correct1000(QuizEngineLocalizations l10n) => Achievement(
        id: 'correct_1000',
        name: (_) => l10n.achievementCorrect1000,
        description: (_) => l10n.achievementCorrect1000Desc,
        icon: '🏅',
        tier: AchievementTier.rare,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalCorrectAnswers,
          target: 1000,
        ),
      );

  // ===========================================================================
  // Mastery Category (7 achievements)
  // ===========================================================================

  /// Rising Star - Get 5 perfect scores
  static Achievement perfect5(QuizEngineLocalizations l10n) => Achievement(
        id: 'perfect_5',
        name: (_) => l10n.achievementPerfect5,
        description: (_) => l10n.achievementPerfect5Desc,
        icon: '⭐',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalPerfectScores,
          target: 5,
        ),
      );

  /// Shining Bright - Get 10 perfect scores
  static Achievement perfect10(QuizEngineLocalizations l10n) => Achievement(
        id: 'perfect_10',
        name: (_) => l10n.achievementPerfect10,
        description: (_) => l10n.achievementPerfect10Desc,
        icon: '🌟',
        tier: AchievementTier.rare,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalPerfectScores,
          target: 10,
        ),
      );

  /// Constellation - Get 25 perfect scores
  static Achievement perfect25(QuizEngineLocalizations l10n) => Achievement(
        id: 'perfect_25',
        name: (_) => l10n.achievementPerfect25,
        description: (_) => l10n.achievementPerfect25Desc,
        icon: '✨',
        tier: AchievementTier.epic,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalPerfectScores,
          target: 25,
        ),
      );

  /// Galaxy - Get 50 perfect scores
  static Achievement perfect50(QuizEngineLocalizations l10n) => Achievement(
        id: 'perfect_50',
        name: (_) => l10n.achievementPerfect50,
        description: (_) => l10n.achievementPerfect50Desc,
        icon: '💫',
        tier: AchievementTier.legendary,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalPerfectScores,
          target: 50,
        ),
      );

  /// High Achiever - Score 90%+ in 10 quizzes
  static Achievement score9010(QuizEngineLocalizations l10n) => Achievement(
        id: 'score_90_10',
        name: (_) => l10n.achievementScore9010,
        description: (_) => l10n.achievementScore9010Desc,
        icon: '📈',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.sessionsWithScore90Plus,
          target: 10,
        ),
      );

  /// Excellence - Score 95%+ in 10 quizzes
  static Achievement score9510(QuizEngineLocalizations l10n) => Achievement(
        id: 'score_95_10',
        name: (_) => l10n.achievementScore9510,
        description: (_) => l10n.achievementScore9510Desc,
        icon: '🔥',
        tier: AchievementTier.rare,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.sessionsWithScore95Plus,
          target: 10,
        ),
      );

  /// Flawless Run - Get 3 perfect scores in a row
  static Achievement perfectStreak3(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'perfect_streak_3',
        name: (_) => l10n.achievementPerfectStreak3,
        description: (_) => l10n.achievementPerfectStreak3Desc,
        icon: '🔮',
        tier: AchievementTier.epic,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutivePerfectScores,
          target: 3,
        ),
      );

  // ===========================================================================
  // Speed Category (4 achievements)
  // ===========================================================================

  /// Speed Demon - Complete a quiz in under 60 seconds
  static Achievement speedDemon(QuizEngineLocalizations l10n) => Achievement(
        id: 'speed_demon',
        name: (_) => l10n.achievementSpeedDemon,
        description: (_) => l10n.achievementSpeedDemonDesc,
        icon: '💨',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionDurationSeconds,
          value: 60,
          operator: ThresholdOperator.lessThan,
        ),
      );

  /// Lightning Fast - Complete a quiz in under 30 seconds
  static Achievement lightning(QuizEngineLocalizations l10n) => Achievement(
        id: 'lightning',
        name: (_) => l10n.achievementLightning,
        description: (_) => l10n.achievementLightningDesc,
        icon: '⚡',
        tier: AchievementTier.rare,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionDurationSeconds,
          value: 30,
          operator: ThresholdOperator.lessThan,
        ),
      );

  /// Quick Thinker - Answer 10 questions in under 2 seconds each
  static Achievement quickAnswer10(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'quick_answer_10',
        name: (_) => l10n.achievementQuickAnswer10,
        description: (_) => l10n.achievementQuickAnswer10Desc,
        icon: '🚀',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.quickAnswersCount,
          target: 10,
        ),
      );

  /// Rapid Fire - Answer 50 questions in under 2 seconds each
  static Achievement quickAnswer50(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'quick_answer_50',
        name: (_) => l10n.achievementQuickAnswer50,
        description: (_) => l10n.achievementQuickAnswer50Desc,
        icon: '🏎️',
        tier: AchievementTier.rare,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.quickAnswersCount,
          target: 50,
        ),
      );

  // ===========================================================================
  // Streak Category (4 achievements)
  // ===========================================================================

  /// On Fire - Get 10 correct answers in a row
  static Achievement streak10(QuizEngineLocalizations l10n) => Achievement(
        id: 'streak_10',
        name: (_) => l10n.achievementStreak10,
        description: (_) => l10n.achievementStreak10Desc,
        icon: '🔥',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 10),
      );

  /// Unstoppable - Get 25 correct answers in a row
  static Achievement streak25(QuizEngineLocalizations l10n) => Achievement(
        id: 'streak_25',
        name: (_) => l10n.achievementStreak25,
        description: (_) => l10n.achievementStreak25Desc,
        icon: '💪',
        tier: AchievementTier.rare,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 25),
      );

  /// Legendary Streak - Get 50 correct answers in a row
  static Achievement streak50(QuizEngineLocalizations l10n) => Achievement(
        id: 'streak_50',
        name: (_) => l10n.achievementStreak50,
        description: (_) => l10n.achievementStreak50Desc,
        icon: '🌋',
        tier: AchievementTier.epic,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 50),
      );

  /// Mythical - Get 100 correct answers in a row
  static Achievement streak100(QuizEngineLocalizations l10n) => Achievement(
        id: 'streak_100',
        name: (_) => l10n.achievementStreak100,
        description: (_) => l10n.achievementStreak100Desc,
        icon: '🐉',
        tier: AchievementTier.legendary,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 100),
      );

  // ===========================================================================
  // Challenge Category (10 achievements)
  // ===========================================================================

  /// Survivor - Complete Survival mode
  static Achievement survivalComplete(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'survival_complete',
        name: (_) => l10n.achievementSurvivalComplete,
        description: (_) => l10n.achievementSurvivalCompleteDesc,
        icon: '❤️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(challengeId: 'survival'),
      );

  /// Immortal - Complete Survival without losing a life
  static Achievement survivalPerfect(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'survival_perfect',
        name: (_) => l10n.achievementSurvivalPerfect,
        description: (_) => l10n.achievementSurvivalPerfectDesc,
        icon: '💖',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(
          challengeId: 'survival',
          requireNoLivesLost: true,
        ),
      );

  /// Blitz Master - Complete Blitz mode
  static Achievement blitzComplete(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'blitz_complete',
        name: (_) => l10n.achievementBlitzComplete,
        description: (_) => l10n.achievementBlitzCompleteDesc,
        icon: '⚡',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(challengeId: 'blitz'),
      );

  /// Lightning God - Complete Blitz with perfect score
  static Achievement blitzPerfect(QuizEngineLocalizations l10n) => Achievement(
        id: 'blitz_perfect',
        name: (_) => l10n.achievementBlitzPerfect,
        description: (_) => l10n.achievementBlitzPerfectDesc,
        icon: '🌩️',
        tier: AchievementTier.epic,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(
          challengeId: 'blitz',
          requirePerfect: true,
        ),
      );

  /// Time Warrior - Answer 20+ correct in Time Attack
  static Achievement timeAttack20(QuizEngineLocalizations l10n) => Achievement(
        id: 'time_attack_20',
        name: (_) => l10n.achievementTimeAttack20,
        description: (_) => l10n.achievementTimeAttack20Desc,
        icon: '⏱️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session?.quizId != 'time_attack') return false;
            return (session?.totalCorrect ?? 0) >= 20;
          },
          target: 1,
        ),
      );

  /// Time Lord - Answer 30+ correct in Time Attack
  static Achievement timeAttack30(QuizEngineLocalizations l10n) => Achievement(
        id: 'time_attack_30',
        name: (_) => l10n.achievementTimeAttack30,
        description: (_) => l10n.achievementTimeAttack30Desc,
        icon: '⏰',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session?.quizId != 'time_attack') return false;
            return (session?.totalCorrect ?? 0) >= 30;
          },
          target: 1,
        ),
      );

  /// Endurance - Answer 50 questions in Marathon
  static Achievement marathon50(QuizEngineLocalizations l10n) => Achievement(
        id: 'marathon_50',
        name: (_) => l10n.achievementMarathon50,
        description: (_) => l10n.achievementMarathon50Desc,
        icon: '🏃',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session?.quizId != 'marathon') return false;
            return (session?.totalAnswered ?? 0) >= 50;
          },
          target: 1,
        ),
      );

  /// Ultra Marathon - Answer 100 questions in Marathon
  static Achievement marathon100(QuizEngineLocalizations l10n) => Achievement(
        id: 'marathon_100',
        name: (_) => l10n.achievementMarathon100,
        description: (_) => l10n.achievementMarathon100Desc,
        icon: '🏃‍♂️',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session?.quizId != 'marathon') return false;
            return (session?.totalAnswered ?? 0) >= 100;
          },
          target: 1,
        ),
      );

  /// Speed Runner - Complete Speed Run in under 2 minutes
  static Achievement speedRunFast(QuizEngineLocalizations l10n) => Achievement(
        id: 'speed_run_fast',
        name: (_) => l10n.achievementSpeedRunFast,
        description: (_) => l10n.achievementSpeedRunFastDesc,
        icon: '🏁',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session?.quizId != 'speed_run') return false;
            return (session?.durationSeconds ?? 999) < 120;
          },
          target: 1,
        ),
      );

  /// Challenge Champion - Complete all challenge modes
  static Achievement allChallenges(QuizEngineLocalizations l10n) =>
      Achievement(
        id: 'all_challenges',
        name: (_) => l10n.achievementAllChallenges,
        description: (_) => l10n.achievementAllChallengesDesc,
        icon: '🎖️',
        tier: AchievementTier.epic,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // This should check if all 5 challenges have been completed
            // Will be evaluated by checking challenge data in context
            return false; // Needs context data, evaluated in engine
          },
          target: 5,
        ),
      );

  // ===========================================================================
  // Dedication Category (8 achievements)
  // ===========================================================================

  /// Dedicated - Play for 1 hour total
  static Achievement time1h(QuizEngineLocalizations l10n) => Achievement(
        id: 'time_1h',
        name: (_) => l10n.achievementTime1h,
        description: (_) => l10n.achievementTime1hDesc,
        icon: '⏰',
        tier: AchievementTier.common,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalTimePlayedSeconds,
          target: 3600, // 1 hour in seconds
        ),
      );

  /// Committed - Play for 5 hours total
  static Achievement time5h(QuizEngineLocalizations l10n) => Achievement(
        id: 'time_5h',
        name: (_) => l10n.achievementTime5h,
        description: (_) => l10n.achievementTime5hDesc,
        icon: '🕐',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalTimePlayedSeconds,
          target: 18000, // 5 hours in seconds
        ),
      );

  /// Devoted - Play for 10 hours total
  static Achievement time10h(QuizEngineLocalizations l10n) => Achievement(
        id: 'time_10h',
        name: (_) => l10n.achievementTime10h,
        description: (_) => l10n.achievementTime10hDesc,
        icon: '🕛',
        tier: AchievementTier.rare,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalTimePlayedSeconds,
          target: 36000, // 10 hours in seconds
        ),
      );

  /// Fanatic - Play for 24 hours total
  static Achievement time24h(QuizEngineLocalizations l10n) => Achievement(
        id: 'time_24h',
        name: (_) => l10n.achievementTime24h,
        description: (_) => l10n.achievementTime24hDesc,
        icon: '⌛',
        tier: AchievementTier.epic,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalTimePlayedSeconds,
          target: 86400, // 24 hours in seconds
        ),
      );

  /// Regular - Play 3 days in a row
  static Achievement days3(QuizEngineLocalizations l10n) => Achievement(
        id: 'days_3',
        name: (_) => l10n.achievementDays3,
        description: (_) => l10n.achievementDays3Desc,
        icon: '📅',
        tier: AchievementTier.common,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 3,
        ),
      );

  /// Weekly Warrior - Play 7 days in a row
  static Achievement days7(QuizEngineLocalizations l10n) => Achievement(
        id: 'days_7',
        name: (_) => l10n.achievementDays7,
        description: (_) => l10n.achievementDays7Desc,
        icon: '🗓️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 7,
        ),
      );

  /// Two Week Streak - Play 14 days in a row
  static Achievement days14(QuizEngineLocalizations l10n) => Achievement(
        id: 'days_14',
        name: (_) => l10n.achievementDays14,
        description: (_) => l10n.achievementDays14Desc,
        icon: '📆',
        tier: AchievementTier.rare,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 14,
        ),
      );

  /// Monthly Master - Play 30 days in a row
  static Achievement days30(QuizEngineLocalizations l10n) => Achievement(
        id: 'days_30',
        name: (_) => l10n.achievementDays30,
        description: (_) => l10n.achievementDays30Desc,
        icon: '🏛️',
        tier: AchievementTier.epic,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 30,
        ),
      );

  // ===========================================================================
  // Skill Category (6 achievements)
  // ===========================================================================

  /// Purist - Complete a quiz without using hints
  static Achievement noHints(QuizEngineLocalizations l10n) => Achievement(
        id: 'no_hints',
        name: (_) => l10n.achievementNoHints,
        description: (_) => l10n.achievementNoHintsDesc,
        icon: '🧩',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionHintsUsed,
          value: 0,
          operator: ThresholdOperator.equal,
        ),
      );

  /// True Expert - Complete 10 quizzes without hints
  static Achievement noHints10(QuizEngineLocalizations l10n) => Achievement(
        id: 'no_hints_10',
        name: (_) => l10n.achievementNoHints10,
        description: (_) => l10n.achievementNoHints10Desc,
        icon: '💎',
        tier: AchievementTier.rare,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.sessionsWithoutHints,
          target: 10,
        ),
      );

  /// Determined - Complete a quiz without skipping
  static Achievement noSkip(QuizEngineLocalizations l10n) => Achievement(
        id: 'no_skip',
        name: (_) => l10n.achievementNoSkip,
        description: (_) => l10n.achievementNoSkipDesc,
        icon: '🎯',
        tier: AchievementTier.common,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionSkippedQuestions,
          value: 0,
          operator: ThresholdOperator.equal,
        ),
      );

  /// Flawless Victory - Perfect score, no hints, no lives lost
  static Achievement flawless(QuizEngineLocalizations l10n) => Achievement(
        id: 'flawless',
        name: (_) => l10n.achievementFlawless,
        description: (_) => l10n.achievementFlawlessDesc,
        icon: '👑',
        tier: AchievementTier.legendary,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.composite(
          triggers: [
            AchievementTrigger.threshold(
              field: StatField.sessionScorePercentage,
              value: 100,
              operator: ThresholdOperator.equal,
            ),
            AchievementTrigger.threshold(
              field: StatField.sessionHintsUsed,
              value: 0,
              operator: ThresholdOperator.equal,
            ),
            AchievementTrigger.threshold(
              field: StatField.sessionLivesUsed,
              value: 0,
              operator: ThresholdOperator.equal,
            ),
          ],
        ),
      );

  /// Comeback King - Win after losing 4+ lives
  static Achievement comeback(QuizEngineLocalizations l10n) => Achievement(
        id: 'comeback',
        name: (_) => l10n.achievementComeback,
        description: (_) => l10n.achievementComebackDesc,
        icon: '🦸',
        tier: AchievementTier.rare,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionLivesUsed,
          value: 4,
          operator: ThresholdOperator.greaterOrEqual,
        ),
      );

  /// Clutch Player - Complete Survival with 1 life remaining
  static Achievement clutch(QuizEngineLocalizations l10n) => Achievement(
        id: 'clutch',
        name: (_) => l10n.achievementClutch,
        description: (_) => l10n.achievementClutchDesc,
        icon: '🎪',
        tier: AchievementTier.rare,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session?.quizId != 'survival') return false;
            // Survival has 1 lives,
            return session?.totalFailed == 2;
          },
          target: 1,
        ),
      );

  // ===========================================================================
  // All Achievements
  // ===========================================================================

  /// Returns all base achievements.
  ///
  /// This includes all 53 generic achievements that work for any quiz app.
  static List<Achievement> all(QuizEngineLocalizations l10n) => [
        // Beginner (3)
        firstQuiz(l10n),
        firstPerfect(l10n),
        firstChallenge(l10n),
        // Progress (11)
        quizzes10(l10n),
        quizzes50(l10n),
        quizzes100(l10n),
        quizzes500(l10n),
        questions100(l10n),
        questions500(l10n),
        questions1000(l10n),
        questions5000(l10n),
        correct100(l10n),
        correct500(l10n),
        correct1000(l10n),
        // Mastery (7)
        perfect5(l10n),
        perfect10(l10n),
        perfect25(l10n),
        perfect50(l10n),
        score9010(l10n),
        score9510(l10n),
        perfectStreak3(l10n),
        // Speed (4)
        speedDemon(l10n),
        lightning(l10n),
        quickAnswer10(l10n),
        quickAnswer50(l10n),
        // Streak (4)
        streak10(l10n),
        streak25(l10n),
        streak50(l10n),
        streak100(l10n),
        // Challenge (10)
        survivalComplete(l10n),
        survivalPerfect(l10n),
        blitzComplete(l10n),
        blitzPerfect(l10n),
        timeAttack20(l10n),
        timeAttack30(l10n),
        marathon50(l10n),
        marathon100(l10n),
        speedRunFast(l10n),
        allChallenges(l10n),
        // Dedication (8)
        time1h(l10n),
        time5h(l10n),
        time10h(l10n),
        time24h(l10n),
        days3(l10n),
        days7(l10n),
        days14(l10n),
        days30(l10n),
        // Skill (6)
        noHints(l10n),
        noHints10(l10n),
        noSkip(l10n),
        flawless(l10n),
        comeback(l10n),
        clutch(l10n),
      ];

  /// Returns the count of all base achievements.
  static const int count = 53;

  /// Returns achievements grouped by category.
  static Map<AchievementCategory, List<Achievement>> byCategory(
    QuizEngineLocalizations l10n,
  ) {
    final achievements = all(l10n);
    final result = <AchievementCategory, List<Achievement>>{};

    for (final category in AchievementCategory.values) {
      result[category] = achievements
          .where((a) => a.category == category.name)
          .toList();
    }

    return result;
  }
}
