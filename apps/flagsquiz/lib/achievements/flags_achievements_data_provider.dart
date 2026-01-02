import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/app_localizations.dart';
import '../models/continent.dart';
import 'flags_achievements.dart';

/// Data provider for the Achievements tab in Flags Quiz.
///
/// Uses [AchievementService] to load achievements and their progress.
/// Implements [AchievementsDataProvider] for integration with [QuizApp].
class FlagsAchievementsDataProvider implements AchievementsDataProvider {
  final AchievementService _achievementService;
  final QuizSessionRepository _sessionRepository;

  /// All achievements (created lazily).
  List<Achievement>? _cachedAchievements;

  /// Cached category completion data for sync access.
  Map<String, CategoryCompletionData> _cachedCategoryData = {};

  /// Cached challenge completion data for sync access.
  Map<String, ChallengeCompletionData> _cachedChallengeData = {};

  /// Challenge IDs used in Flags Quiz.
  static const _challengeIds = [
    'survival',
    'time_attack',
    'speed_run',
    'marathon',
    'blitz',
  ];

  /// Checks if a quiz ID matches a challenge ID.
  ///
  /// quizId format is '${category}_${challenge}' (e.g., 'eu_survival')
  static bool _isChallengeQuiz(String quizId, String challengeId) {
    return quizId.endsWith('_$challengeId') || quizId == challengeId;
  }

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Creates a [FlagsAchievementsDataProvider].
  FlagsAchievementsDataProvider({
    required AchievementService achievementService,
    required QuizSessionRepository sessionRepository,
  })  : _achievementService = achievementService,
        _sessionRepository = sessionRepository;

  /// Gets all 75 achievements (53 base + 22 flags-specific).
  ///
  /// Uses deferred localization via QuizL10n.of(ctx) and AppLocalizations.of(ctx).
  List<Achievement> _getAllAchievements() {
    if (_cachedAchievements != null) return _cachedAchievements!;

    _cachedAchievements = [
      // ===========================================================================
      // BASE ACHIEVEMENTS (53 total)
      // ===========================================================================

      // --- Beginner (3) ---
      Achievement(
        id: 'first_quiz',
        name: (ctx) => QuizL10n.of(ctx).achievementFirstQuiz,
        description: (ctx) => QuizL10n.of(ctx).achievementFirstQuizDesc,
        icon: '🎯',
        tier: AchievementTier.common,
        category: AchievementCategory.beginner.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 1),
      ),
      Achievement(
        id: 'first_perfect',
        name: (ctx) => QuizL10n.of(ctx).achievementFirstPerfect,
        description: (ctx) => QuizL10n.of(ctx).achievementFirstPerfectDesc,
        icon: '⭐',
        tier: AchievementTier.common,
        category: AchievementCategory.beginner.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 1),
      ),
      Achievement(
        id: 'first_challenge',
        name: (ctx) => QuizL10n.of(ctx).achievementFirstChallenge,
        description: (ctx) => QuizL10n.of(ctx).achievementFirstChallengeDesc,
        icon: '🏆',
        tier: AchievementTier.common,
        category: AchievementCategory.beginner.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            // quizId format is '${category}_${challenge}' (e.g., 'eu_survival')
            final quizId = session.quizId;
            return _challengeIds.any(
              (id) => quizId.endsWith('_$id') || quizId == id,
            );
          },
          target: 1,
        ),
      ),

      // --- Progress (11) ---
      Achievement(
        id: 'quizzes_10',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes10,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes10Desc,
        icon: '📚',
        tier: AchievementTier.common,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 10),
      ),
      Achievement(
        id: 'quizzes_50',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes50,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes50Desc,
        icon: '📖',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 50),
      ),
      Achievement(
        id: 'quizzes_100',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes100,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes100Desc,
        icon: '🎓',
        tier: AchievementTier.rare,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 100),
      ),
      Achievement(
        id: 'quizzes_500',
        name: (ctx) => QuizL10n.of(ctx).achievementQuizzes500,
        description: (ctx) => QuizL10n.of(ctx).achievementQuizzes500Desc,
        icon: '👑',
        tier: AchievementTier.epic,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCompletedSessions, target: 500),
      ),
      Achievement(
        id: 'questions_100',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions100,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions100Desc,
        icon: '💯',
        tier: AchievementTier.common,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 100),
      ),
      Achievement(
        id: 'questions_500',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions500,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions500Desc,
        icon: '🔢',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 500),
      ),
      Achievement(
        id: 'questions_1000',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions1000,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions1000Desc,
        icon: '🧮',
        tier: AchievementTier.rare,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 1000),
      ),
      Achievement(
        id: 'questions_5000',
        name: (ctx) => QuizL10n.of(ctx).achievementQuestions5000,
        description: (ctx) => QuizL10n.of(ctx).achievementQuestions5000Desc,
        icon: '🧠',
        tier: AchievementTier.epic,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalQuestionsAnswered, target: 5000),
      ),
      Achievement(
        id: 'correct_100',
        name: (ctx) => QuizL10n.of(ctx).achievementCorrect100,
        description: (ctx) => QuizL10n.of(ctx).achievementCorrect100Desc,
        icon: '✅',
        tier: AchievementTier.common,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCorrectAnswers, target: 100),
      ),
      Achievement(
        id: 'correct_500',
        name: (ctx) => QuizL10n.of(ctx).achievementCorrect500,
        description: (ctx) => QuizL10n.of(ctx).achievementCorrect500Desc,
        icon: '🎯',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCorrectAnswers, target: 500),
      ),
      Achievement(
        id: 'correct_1000',
        name: (ctx) => QuizL10n.of(ctx).achievementCorrect1000,
        description: (ctx) => QuizL10n.of(ctx).achievementCorrect1000Desc,
        icon: '🏅',
        tier: AchievementTier.rare,
        category: AchievementCategory.progress.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalCorrectAnswers, target: 1000),
      ),

      // --- Mastery (7) ---
      Achievement(
        id: 'perfect_5',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfect5,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfect5Desc,
        icon: '⭐',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 5),
      ),
      Achievement(
        id: 'perfect_10',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfect10,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfect10Desc,
        icon: '🌟',
        tier: AchievementTier.rare,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 10),
      ),
      Achievement(
        id: 'perfect_25',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfect25,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfect25Desc,
        icon: '✨',
        tier: AchievementTier.epic,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 25),
      ),
      Achievement(
        id: 'perfect_50',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfect50,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfect50Desc,
        icon: '💫',
        tier: AchievementTier.legendary,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalPerfectScores, target: 50),
      ),
      Achievement(
        id: 'score_90_10',
        name: (ctx) => QuizL10n.of(ctx).achievementScore9010,
        description: (ctx) => QuizL10n.of(ctx).achievementScore9010Desc,
        icon: '📈',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.sessionsWithScore90Plus, target: 10),
      ),
      Achievement(
        id: 'score_95_10',
        name: (ctx) => QuizL10n.of(ctx).achievementScore9510,
        description: (ctx) => QuizL10n.of(ctx).achievementScore9510Desc,
        icon: '🔥',
        tier: AchievementTier.rare,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.sessionsWithScore95Plus, target: 10),
      ),
      Achievement(
        id: 'perfect_streak_3',
        name: (ctx) => QuizL10n.of(ctx).achievementPerfectStreak3,
        description: (ctx) => QuizL10n.of(ctx).achievementPerfectStreak3Desc,
        icon: '🔮',
        tier: AchievementTier.epic,
        category: AchievementCategory.mastery.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.consecutivePerfectScores, target: 3),
      ),

      // --- Speed (4) ---
      Achievement(
        id: 'speed_demon',
        name: (ctx) => QuizL10n.of(ctx).achievementSpeedDemon,
        description: (ctx) => QuizL10n.of(ctx).achievementSpeedDemonDesc,
        icon: '💨',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionDurationSeconds,
          value: 60,
          operator: ThresholdOperator.lessThan,
        ),
      ),
      Achievement(
        id: 'lightning',
        name: (ctx) => QuizL10n.of(ctx).achievementLightning,
        description: (ctx) => QuizL10n.of(ctx).achievementLightningDesc,
        icon: '⚡',
        tier: AchievementTier.rare,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionDurationSeconds,
          value: 30,
          operator: ThresholdOperator.lessThan,
        ),
      ),
      Achievement(
        id: 'quick_answer_10',
        name: (ctx) => QuizL10n.of(ctx).achievementQuickAnswer10,
        description: (ctx) => QuizL10n.of(ctx).achievementQuickAnswer10Desc,
        icon: '🚀',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.quickAnswersCount, target: 10),
      ),
      Achievement(
        id: 'quick_answer_50',
        name: (ctx) => QuizL10n.of(ctx).achievementQuickAnswer50,
        description: (ctx) => QuizL10n.of(ctx).achievementQuickAnswer50Desc,
        icon: '🏎️',
        tier: AchievementTier.rare,
        category: AchievementCategory.speed.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.quickAnswersCount, target: 50),
      ),

      // --- Streak (4) ---
      Achievement(
        id: 'streak_10',
        name: (ctx) => QuizL10n.of(ctx).achievementStreak10,
        description: (ctx) => QuizL10n.of(ctx).achievementStreak10Desc,
        icon: '🔥',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 10),
      ),
      Achievement(
        id: 'streak_25',
        name: (ctx) => QuizL10n.of(ctx).achievementStreak25,
        description: (ctx) => QuizL10n.of(ctx).achievementStreak25Desc,
        icon: '💪',
        tier: AchievementTier.rare,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 25),
      ),
      Achievement(
        id: 'streak_50',
        name: (ctx) => QuizL10n.of(ctx).achievementStreak50,
        description: (ctx) => QuizL10n.of(ctx).achievementStreak50Desc,
        icon: '🌋',
        tier: AchievementTier.epic,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 50),
      ),
      Achievement(
        id: 'streak_100',
        name: (ctx) => QuizL10n.of(ctx).achievementStreak100,
        description: (ctx) => QuizL10n.of(ctx).achievementStreak100Desc,
        icon: '🐉',
        tier: AchievementTier.legendary,
        category: AchievementCategory.streak.name,
        trigger: AchievementTrigger.streak(target: 100),
      ),

      // --- Challenge (10) ---
      Achievement(
        id: 'survival_complete',
        name: (ctx) => QuizL10n.of(ctx).achievementSurvivalComplete,
        description: (ctx) => QuizL10n.of(ctx).achievementSurvivalCompleteDesc,
        icon: '❤️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(challengeId: 'survival'),
      ),
      Achievement(
        id: 'survival_perfect',
        name: (ctx) => QuizL10n.of(ctx).achievementSurvivalPerfect,
        description: (ctx) => QuizL10n.of(ctx).achievementSurvivalPerfectDesc,
        icon: '💖',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(
          challengeId: 'survival',
          requireNoLivesLost: true,
        ),
      ),
      Achievement(
        id: 'blitz_complete',
        name: (ctx) => QuizL10n.of(ctx).achievementBlitzComplete,
        description: (ctx) => QuizL10n.of(ctx).achievementBlitzCompleteDesc,
        icon: '⚡',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(challengeId: 'blitz'),
      ),
      Achievement(
        id: 'blitz_perfect',
        name: (ctx) => QuizL10n.of(ctx).achievementBlitzPerfect,
        description: (ctx) => QuizL10n.of(ctx).achievementBlitzPerfectDesc,
        icon: '🌩️',
        tier: AchievementTier.epic,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.challenge(
          challengeId: 'blitz',
          requirePerfect: true,
        ),
      ),
      Achievement(
        id: 'time_attack_20',
        name: (ctx) => QuizL10n.of(ctx).achievementTimeAttack20,
        description: (ctx) => QuizL10n.of(ctx).achievementTimeAttack20Desc,
        icon: '⏱️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            if (!_isChallengeQuiz(session.quizId, 'time_attack')) return false;
            return session.totalCorrect >= 20;
          },
          target: 1,
        ),
      ),
      Achievement(
        id: 'time_attack_30',
        name: (ctx) => QuizL10n.of(ctx).achievementTimeAttack30,
        description: (ctx) => QuizL10n.of(ctx).achievementTimeAttack30Desc,
        icon: '⏰',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            if (!_isChallengeQuiz(session.quizId, 'time_attack')) return false;
            return session.totalCorrect >= 30;
          },
          target: 1,
        ),
      ),
      Achievement(
        id: 'marathon_50',
        name: (ctx) => QuizL10n.of(ctx).achievementMarathon50,
        description: (ctx) => QuizL10n.of(ctx).achievementMarathon50Desc,
        icon: '🏃',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            if (!_isChallengeQuiz(session.quizId, 'marathon')) return false;
            return session.totalAnswered >= 50;
          },
          target: 1,
        ),
      ),
      Achievement(
        id: 'marathon_100',
        name: (ctx) => QuizL10n.of(ctx).achievementMarathon100,
        description: (ctx) => QuizL10n.of(ctx).achievementMarathon100Desc,
        icon: '🏃‍♂️',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            if (!_isChallengeQuiz(session.quizId, 'marathon')) return false;
            return session.totalAnswered >= 100;
          },
          target: 1,
        ),
      ),
      Achievement(
        id: 'speed_run_fast',
        name: (ctx) => QuizL10n.of(ctx).achievementSpeedRunFast,
        description: (ctx) => QuizL10n.of(ctx).achievementSpeedRunFastDesc,
        icon: '🏁',
        tier: AchievementTier.rare,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            if (!_isChallengeQuiz(session.quizId, 'speed_run')) return false;
            return (session.durationSeconds ?? 999) < 120;
          },
          target: 1,
        ),
      ),
      Achievement(
        id: 'all_challenges',
        name: (ctx) => QuizL10n.of(ctx).achievementAllChallenges,
        description: (ctx) => QuizL10n.of(ctx).achievementAllChallengesDesc,
        icon: '🎖️',
        tier: AchievementTier.epic,
        category: AchievementCategory.challenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) => false,
          target: 5,
        ),
      ),

      // --- Dedication (8) ---
      Achievement(
        id: 'time_1h',
        name: (ctx) => QuizL10n.of(ctx).achievementTime1h,
        description: (ctx) => QuizL10n.of(ctx).achievementTime1hDesc,
        icon: '⏰',
        tier: AchievementTier.common,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalTimePlayedSeconds, target: 3600),
      ),
      Achievement(
        id: 'time_5h',
        name: (ctx) => QuizL10n.of(ctx).achievementTime5h,
        description: (ctx) => QuizL10n.of(ctx).achievementTime5hDesc,
        icon: '🕐',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalTimePlayedSeconds, target: 18000),
      ),
      Achievement(
        id: 'time_10h',
        name: (ctx) => QuizL10n.of(ctx).achievementTime10h,
        description: (ctx) => QuizL10n.of(ctx).achievementTime10hDesc,
        icon: '🕛',
        tier: AchievementTier.rare,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalTimePlayedSeconds, target: 36000),
      ),
      Achievement(
        id: 'time_24h',
        name: (ctx) => QuizL10n.of(ctx).achievementTime24h,
        description: (ctx) => QuizL10n.of(ctx).achievementTime24hDesc,
        icon: '⌛',
        tier: AchievementTier.epic,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.totalTimePlayedSeconds, target: 86400),
      ),
      Achievement(
        id: 'days_3',
        name: (ctx) => QuizL10n.of(ctx).achievementDays3,
        description: (ctx) => QuizL10n.of(ctx).achievementDays3Desc,
        icon: '📅',
        tier: AchievementTier.common,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.consecutiveDaysPlayed, target: 3),
      ),
      Achievement(
        id: 'days_7',
        name: (ctx) => QuizL10n.of(ctx).achievementDays7,
        description: (ctx) => QuizL10n.of(ctx).achievementDays7Desc,
        icon: '🗓️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.consecutiveDaysPlayed, target: 7),
      ),
      Achievement(
        id: 'days_14',
        name: (ctx) => QuizL10n.of(ctx).achievementDays14,
        description: (ctx) => QuizL10n.of(ctx).achievementDays14Desc,
        icon: '📆',
        tier: AchievementTier.rare,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.consecutiveDaysPlayed, target: 14),
      ),
      Achievement(
        id: 'days_30',
        name: (ctx) => QuizL10n.of(ctx).achievementDays30,
        description: (ctx) => QuizL10n.of(ctx).achievementDays30Desc,
        icon: '🏛️',
        tier: AchievementTier.epic,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.consecutiveDaysPlayed, target: 30),
      ),

      // --- Skill (6) ---
      Achievement(
        id: 'no_hints',
        name: (ctx) => QuizL10n.of(ctx).achievementNoHints,
        description: (ctx) => QuizL10n.of(ctx).achievementNoHintsDesc,
        icon: '🧩',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionHintsUsed,
          value: 0,
          operator: ThresholdOperator.equal,
        ),
      ),
      Achievement(
        id: 'no_hints_10',
        name: (ctx) => QuizL10n.of(ctx).achievementNoHints10,
        description: (ctx) => QuizL10n.of(ctx).achievementNoHints10Desc,
        icon: '💎',
        tier: AchievementTier.rare,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.cumulative(
            field: StatField.sessionsWithoutHints, target: 10),
      ),
      Achievement(
        id: 'no_skip',
        name: (ctx) => QuizL10n.of(ctx).achievementNoSkip,
        description: (ctx) => QuizL10n.of(ctx).achievementNoSkipDesc,
        icon: '🎯',
        tier: AchievementTier.common,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionSkippedQuestions,
          value: 0,
          operator: ThresholdOperator.equal,
        ),
      ),
      Achievement(
        id: 'flawless',
        name: (ctx) => QuizL10n.of(ctx).achievementFlawless,
        description: (ctx) => QuizL10n.of(ctx).achievementFlawlessDesc,
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
      ),
      Achievement(
        id: 'comeback',
        name: (ctx) => QuizL10n.of(ctx).achievementComeback,
        description: (ctx) => QuizL10n.of(ctx).achievementComebackDesc,
        icon: '🦸',
        tier: AchievementTier.rare,
        category: AchievementCategory.skill.name,
        trigger: AchievementTrigger.threshold(
          field: StatField.sessionLivesUsed,
          value: 4,
          operator: ThresholdOperator.greaterOrEqual,
        ),
      ),
      Achievement(
        id: 'clutch',
        name: (ctx) => QuizL10n.of(ctx).achievementClutch,
        description: (ctx) => QuizL10n.of(ctx).achievementClutchDesc,
        icon: '🎪',
        tier: AchievementTier.rare,
        category: AchievementCategory.skill.name,
        // Answer at least 15 questions correctly in Survival (clutch performance)
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            if (!_isChallengeQuiz(session.quizId, 'survival')) return false;
            return session.totalCorrect >= 15;
          },
          target: 1,
        ),
      ),

      // ===========================================================================
      // FLAGS-SPECIFIC ACHIEVEMENTS (19 total)
      // ===========================================================================

      // --- Explorer (7) ---
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
      Achievement(
        id: 'world_traveler',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementWorldTraveler ?? 'World Traveler',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementWorldTravelerDesc ??
            'Complete a quiz in every continent',
        icon: '✈️',
        tier: AchievementTier.rare,
        category: FlagsAchievements.categoryExplorer,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) => false,
          getProgress: (stats) => 0,
          target: 6,
        ),
      ),

      // --- Region Mastery (6) ---
      Achievement(
        id: 'master_europe',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterEurope ?? 'Europe Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterEuropeDesc ??
            'Get 5 perfect scores in Europe',
        icon: '🏰',
        tier: AchievementTier.rare,
        category: FlagsAchievements.categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'eu',
          requirePerfect: true,
          requiredCount: 5,
        ),
      ),
      Achievement(
        id: 'master_asia',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterAsia ?? 'Asia Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterAsiaDesc ??
            'Get 5 perfect scores in Asia',
        icon: '🏯',
        tier: AchievementTier.rare,
        category: FlagsAchievements.categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'as',
          requirePerfect: true,
          requiredCount: 5,
        ),
      ),
      Achievement(
        id: 'master_africa',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterAfrica ?? 'Africa Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterAfricaDesc ??
            'Get 5 perfect scores in Africa',
        icon: '🦁',
        tier: AchievementTier.rare,
        category: FlagsAchievements.categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'af',
          requirePerfect: true,
          requiredCount: 5,
        ),
      ),
      Achievement(
        id: 'master_americas',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterAmericas ??
            'Americas Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterAmericasDesc ??
            'Get 5 perfect scores in North or South America',
        icon: '🦅',
        tier: AchievementTier.rare,
        category: FlagsAchievements.categoryRegionMastery,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            if (session == null) return false;
            final isAmericas =
                session.quizId == 'na' || session.quizId == 'sa';
            final isPerfect = session.totalCorrect == session.totalAnswered;
            return isAmericas && isPerfect;
          },
          getProgress: (stats) => 0,
          target: 5,
        ),
      ),
      Achievement(
        id: 'master_oceania',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterOceania ??
            'Oceania Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterOceaniaDesc ??
            'Get 5 perfect scores in Oceania',
        icon: '🐨',
        tier: AchievementTier.rare,
        category: FlagsAchievements.categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'oc',
          requirePerfect: true,
          requiredCount: 5,
        ),
      ),
      Achievement(
        id: 'master_world',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterWorld ?? 'World Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMasterWorldDesc ??
            'Get 5 perfect scores in All Countries',
        icon: '🌐',
        tier: AchievementTier.epic,
        category: FlagsAchievements.categoryRegionMastery,
        trigger: AchievementTrigger.category(
          categoryId: 'all',
          requirePerfect: true,
          requiredCount: 5,
        ),
      ),

      // --- Collection (1) ---
      Achievement(
        id: 'flag_collector',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementFlagCollector ?? 'Flag Collector',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementFlagCollectorDesc ??
            'Answer every flag correctly at least once',
        icon: '🏳️‍🌈',
        tier: AchievementTier.legendary,
        category: FlagsAchievements.categoryCollection,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) => false,
          getProgress: (stats) => 0,
          target: 195,
        ),
      ),

      // --- Daily Streak (5) - Uses 'dedication' category for UI grouping ---
      Achievement(
        id: 'first_flame',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementFirstFlame ?? 'First Flame',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementFirstFlameDesc ??
            'Complete your first day streak',
        icon: '🔥',
        tier: AchievementTier.common,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 1,
        ),
      ),
      Achievement(
        id: 'week_warrior',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementWeekWarrior ?? 'Week Warrior',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementWeekWarriorDesc ??
            'Maintain a 7 day streak',
        icon: '⚔️',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 7,
        ),
      ),
      Achievement(
        id: 'monthly_master',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMonthlyMaster ?? 'Monthly Master',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementMonthlyMasterDesc ??
            'Maintain a 30 day streak',
        icon: '📅',
        tier: AchievementTier.rare,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 30,
        ),
      ),
      Achievement(
        id: 'centurion',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementCenturion ?? 'Centurion',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementCenturionDesc ??
            'Maintain a 100 day streak',
        icon: '🏛️',
        tier: AchievementTier.epic,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 100,
        ),
      ),
      Achievement(
        id: 'dedication',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementDedication ?? 'Dedication',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementDedicationDesc ??
            'Maintain a 365 day streak',
        icon: '👑',
        tier: AchievementTier.legendary,
        category: AchievementCategory.dedication.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.consecutiveDaysPlayed,
          target: 365,
        ),
      ),

      // ===========================================================================
      // DAILY CHALLENGE ACHIEVEMENTS (3 total)
      // ===========================================================================

      // --- Daily Challenge (3) ---
      Achievement(
        id: 'daily_devotee',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementDailyDevotee ?? 'Daily Devotee',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementDailyDevoteeDesc ??
            'Complete 10 daily challenges',
        icon: '📆',
        tier: AchievementTier.uncommon,
        category: AchievementCategory.dailyChallenge.name,
        trigger: AchievementTrigger.cumulative(
          field: StatField.totalDailyChallengesCompleted,
          target: 10,
        ),
      ),
      Achievement(
        id: 'perfect_day',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementPerfectDay ?? 'Perfect Day',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementPerfectDayDesc ??
            'Get 100% on a daily challenge',
        icon: '☀️',
        tier: AchievementTier.rare,
        category: AchievementCategory.dailyChallenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // Check if this is a daily challenge with perfect score
            if (session == null) return false;
            final isDailyChallenge = session.quizId.startsWith('daily_');
            final isPerfect = session.totalCorrect == session.totalAnswered;
            return isDailyChallenge && isPerfect;
          },
          target: 1,
        ),
      ),
      Achievement(
        id: 'early_bird',
        name: (ctx) =>
            AppLocalizations.of(ctx)?.achievementEarlyBird ?? 'Early Bird',
        description: (ctx) =>
            AppLocalizations.of(ctx)?.achievementEarlyBirdDesc ??
            'Complete a daily challenge within the first hour of the day',
        icon: '🐦',
        tier: AchievementTier.rare,
        category: AchievementCategory.dailyChallenge.name,
        trigger: AchievementTrigger.custom(
          evaluate: (stats, session) {
            // Check if completed within first hour of the day
            if (session == null) return false;
            final isDailyChallenge = session.quizId.startsWith('daily_');
            if (!isDailyChallenge) return false;
            // Check if completion time is within first hour (0:00 - 1:00)
            final endTime = session.endTime;
            if (endTime == null) return false;
            return endTime.hour < 1;
          },
          target: 1,
        ),
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

    // Set up challenge data provider
    _achievementService.challengeDataProvider = _getChallengeData;

    // Load initial category and challenge data
    await refreshCategoryData();
    await refreshChallengeData();
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

  /// Returns cached challenge completion data synchronously.
  ///
  /// This is called by [AchievementService] when checking achievements.
  Map<String, ChallengeCompletionData> _getChallengeData() {
    return _cachedChallengeData;
  }

  /// Refreshes the cached challenge completion data from storage.
  ///
  /// Call this after quiz completion to update challenge stats.
  Future<void> refreshChallengeData() async {
    final Map<String, ChallengeCompletionData> challengeData = {};

    // Get all completed sessions (filter in Dart since filter doesn't support quizId)
    final allSessions = await _sessionRepository.getSessions(
      filter: const QuizSessionFilter(
        completionStatus: CompletionStatus.completed,
      ),
    );

    // Get completion counts for each challenge type
    for (final challengeId in _challengeIds) {
      // Filter sessions for this challenge
      // quizId format is '${category}_${challenge}' (e.g., 'eu_survival')
      final sessions = allSessions
          .where((s) => s.quizId.endsWith('_$challengeId') || s.quizId == challengeId)
          .toList();

      // Count completions
      int totalCompletions = sessions.length;
      int perfectCompletions = sessions
          .where((s) => s.scorePercentage >= 100.0)
          .length;
      int noLivesLostCompletions = sessions
          .where((s) => s.livesUsed == 0)
          .length;
      double bestScore = sessions.isEmpty
          ? 0.0
          : sessions.map((s) => s.scorePercentage).reduce(
              (max, score) => score > max ? score : max,
            );

      challengeData[challengeId] = ChallengeCompletionData(
        challengeId: challengeId,
        totalCompletions: totalCompletions,
        perfectCompletions: perfectCompletions,
        noLivesLostCompletions: noLivesLostCompletions,
        bestScore: bestScore,
      );
    }

    _cachedChallengeData = challengeData;
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

  @override
  Future<AchievementsTabData> loadAchievementsData() async {
    _ensureInitialized();

    // Refresh data providers to ensure we have latest stats
    await refreshCategoryData();
    await refreshChallengeData();

    // Check all achievements to catch any missed unlocks
    // This is a defensive measure in case checkAfterSession missed any
    await _achievementService.checkAll();

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

  @override
  Future<void> onSessionCompleted(QuizSession session) async {
    // Refresh category and challenge data for achievements
    await refreshCategoryData();
    await refreshChallengeData();

    // Check both session-based and cumulative achievements
    await _achievementService.checkAfterSession(session);
  }
}
