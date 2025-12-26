// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'quiz_engine_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class QuizEngineLocalizationsEn extends QuizEngineLocalizations {
  QuizEngineLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get play => 'Play';

  @override
  String get history => 'History';

  @override
  String get statistics => 'Statistics';

  @override
  String get settings => 'Settings';

  @override
  String get score => 'Score';

  @override
  String get correct => 'Correct';

  @override
  String get incorrect => 'Incorrect';

  @override
  String get duration => 'Duration';

  @override
  String get questions => 'questions';

  @override
  String get exitDialogTitle => 'Exit Quiz?';

  @override
  String get exitDialogMessage =>
      'Are you sure you want to exit? Your progress will be lost.';

  @override
  String get exitDialogConfirm => 'Yes';

  @override
  String get exitDialogCancel => 'No';

  @override
  String get correctFeedback => 'Correct!';

  @override
  String get incorrectFeedback => 'Incorrect!';

  @override
  String get videoLoadError => 'Failed to load video';

  @override
  String get hint5050Label => '50/50';

  @override
  String get hintSkipLabel => 'Skip';

  @override
  String get timerSecondsSuffix => 's';

  @override
  String get hours => 'hr';

  @override
  String get minutes => 'min';

  @override
  String get seconds => 'sec';

  @override
  String get sessionCompleted => 'Completed';

  @override
  String get sessionCancelled => 'Cancelled';

  @override
  String get sessionTimeout => 'Timeout';

  @override
  String get sessionFailed => 'Failed';

  @override
  String get perfectScore => 'Perfect!';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get noSessionsYet => 'No quiz sessions yet';

  @override
  String get startPlayingToSee => 'Start playing to see your history here';

  @override
  String get sessionDetails => 'Session Details';

  @override
  String get reviewAnswers => 'Review Answers';

  @override
  String questionNumber(int number) {
    return 'Question $number';
  }

  @override
  String get yourAnswer => 'Your answer';

  @override
  String get correctAnswer => 'Correct answer';

  @override
  String get skipped => 'Skipped';

  @override
  String get practiceWrongAnswers => 'Practice Wrong Answers';

  @override
  String get totalSessions => 'Total Sessions';

  @override
  String get totalQuestions => 'Total Questions';

  @override
  String get averageScore => 'Average Score';

  @override
  String get bestScore => 'Best Score';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get timePlayed => 'Time Played';

  @override
  String get perfectScores => 'Perfect Scores';

  @override
  String get currentStreak => 'Current Streak';

  @override
  String get bestStreak => 'Best Streak';

  @override
  String get weeklyTrend => 'Weekly Trend';

  @override
  String get improving => 'Improving';

  @override
  String get declining => 'Declining';

  @override
  String get stable => 'Stable';

  @override
  String get noStatisticsYet => 'No statistics yet';

  @override
  String get playQuizzesToSee => 'Play some quizzes to see your statistics';

  @override
  String get overview => 'Overview';

  @override
  String get insights => 'Insights';

  @override
  String get days => 'days';

  @override
  String get audioAndHaptics => 'Audio & Haptics';

  @override
  String get soundEffects => 'Sound Effects';

  @override
  String get soundEffectsDescription =>
      'Play sounds for answers and interactions';

  @override
  String get backgroundMusic => 'Background Music';

  @override
  String get backgroundMusicDescription => 'Play background music during quiz';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get hapticFeedbackDescription =>
      'Vibrate on button presses and answers';

  @override
  String get quizBehavior => 'Quiz Behavior';

  @override
  String get showAnswerFeedback => 'Show Answer Feedback';

  @override
  String get showAnswerFeedbackDescription =>
      'Display animations when answering';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System default';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get build => 'Build';

  @override
  String get aboutThisApp => 'About This App';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get openSourceLicenses => 'Open Source Licenses';

  @override
  String get advanced => 'Advanced';

  @override
  String get resetToDefaults => 'Reset to Defaults';

  @override
  String get resetToDefaultsDescription =>
      'Restore all settings to default values';

  @override
  String get resetSettings => 'Reset Settings';

  @override
  String get resetSettingsMessage =>
      'Are you sure you want to reset all settings to their default values? This cannot be undone.';

  @override
  String get cancel => 'Cancel';

  @override
  String get reset => 'Reset';

  @override
  String get close => 'Close';

  @override
  String get share => 'Share';

  @override
  String get delete => 'Delete';

  @override
  String get viewAll => 'View All';

  @override
  String get credits => 'Credits';

  @override
  String get attributions => 'Attributions';

  @override
  String get exportSession => 'Export Session';

  @override
  String get exportAsJson => 'Export as JSON';

  @override
  String get exportAsCsv => 'Export as CSV';

  @override
  String get exportSuccess => 'Session exported successfully';

  @override
  String get exportError => 'Failed to export session';

  @override
  String get deleteSession => 'Delete Session';

  @override
  String get deleteSessionMessage =>
      'Are you sure you want to delete this session? This cannot be undone.';

  @override
  String get sessionDeleted => 'Session deleted';

  @override
  String get recentSessions => 'Recent Sessions';

  @override
  String get settingsResetToDefaults => 'Settings reset to defaults';

  @override
  String couldNotOpenUrl(String url) {
    return 'Could not open $url';
  }

  @override
  String get gameOverText => 'Your Score';

  @override
  String get noData => 'No data';

  @override
  String initializationError(String error) {
    return 'Initialization error: $error';
  }

  @override
  String get quizComplete => 'Quiz Complete!';

  @override
  String get excellent => 'Excellent!';

  @override
  String get greatJob => 'Great Job!';

  @override
  String get goodWork => 'Good Work!';

  @override
  String get keepPracticing => 'Keep Practicing!';

  @override
  String get tryAgain => 'Try Again!';

  @override
  String get reviewThisSession => 'Review This Session';

  @override
  String get reviewWrongAnswers => 'Review Wrong Answers';

  @override
  String get done => 'Done';

  @override
  String get playAgain => 'Play Again';

  @override
  String scoreOf(int correct, int total) {
    return '$correct of $total';
  }

  @override
  String get timedOut => 'Timed Out';

  @override
  String get hintsUsed => 'Hints Used';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get categoryBreakdown => 'Category Breakdown';

  @override
  String get noCategoryData => 'No category data yet. Play some quizzes!';

  @override
  String sessionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions',
      one: '1 session',
    );
    return '$_temp0';
  }

  @override
  String get noProgressData => 'No progress data yet';

  @override
  String get progressSummary => 'Progress Summary';

  @override
  String get change => 'Change';

  @override
  String get lastWeek => 'Week';

  @override
  String get lastMonth => 'Month';

  @override
  String get last3Months => '3 Months';

  @override
  String get lastYear => 'Year';

  @override
  String get allTime => 'All Time';

  @override
  String get bestScores => 'Best Scores';

  @override
  String get fastestPerfect => 'Fastest Perfect';

  @override
  String get mostPlayed => 'Most Played';

  @override
  String get bestStreaks => 'Best Streaks';

  @override
  String get noLeaderboardData =>
      'No leaderboard entries yet. Complete some quizzes to see your best scores!';

  @override
  String get globalLeaderboard => 'Global Leaderboard';

  @override
  String get globalLeaderboardComingSoon => 'Compete with players worldwide';

  @override
  String get progress => 'Progress';

  @override
  String get categories => 'Categories';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get scoreOverTime => 'Score Over Time';

  @override
  String get last7Days => 'Last 7 days';

  @override
  String get last30Days => 'Last 30 days';

  @override
  String get last90Days => 'Last 90 days';

  @override
  String get last365Days => 'Last 365 days';

  @override
  String get allTimeData => 'All time data';

  @override
  String get highestScore => 'Highest';

  @override
  String get lowestScore => 'Lowest';

  @override
  String get noPracticeItems => 'No wrong answers to practice';

  @override
  String get noPracticeItemsDescription =>
      'Complete some quizzes and any wrong answers will appear here for practice';

  @override
  String get practice => 'Practice';

  @override
  String get challenges => 'Challenges';

  @override
  String get achievements => 'Achievements';

  @override
  String get achievementUnlocked => 'Achievement Unlocked!';

  @override
  String achievementsUnlocked(int count, int total) {
    return '$count of $total Unlocked';
  }

  @override
  String achievementPoints(int points) {
    return '$points pts';
  }

  @override
  String get hiddenAchievement => 'Hidden Achievement';

  @override
  String get hiddenAchievementDesc => 'Keep playing to discover!';

  @override
  String get achievementFirstQuiz => 'First Steps';

  @override
  String get achievementFirstQuizDesc => 'Complete your first quiz';

  @override
  String get achievementFirstPerfect => 'Perfectionist';

  @override
  String get achievementFirstPerfectDesc => 'Get your first perfect score';

  @override
  String get achievementFirstChallenge => 'Challenger';

  @override
  String get achievementFirstChallengeDesc =>
      'Complete your first challenge mode';

  @override
  String get achievementQuizzes10 => 'Getting Started';

  @override
  String get achievementQuizzes10Desc => 'Complete 10 quizzes';

  @override
  String get achievementQuizzes50 => 'Quiz Enthusiast';

  @override
  String get achievementQuizzes50Desc => 'Complete 50 quizzes';

  @override
  String get achievementQuizzes100 => 'Quiz Master';

  @override
  String get achievementQuizzes100Desc => 'Complete 100 quizzes';

  @override
  String get achievementQuizzes500 => 'Quiz Legend';

  @override
  String get achievementQuizzes500Desc => 'Complete 500 quizzes';

  @override
  String get achievementQuestions100 => 'Century';

  @override
  String get achievementQuestions100Desc => 'Answer 100 questions';

  @override
  String get achievementQuestions500 => 'Half Thousand';

  @override
  String get achievementQuestions500Desc => 'Answer 500 questions';

  @override
  String get achievementQuestions1000 => 'Thousand Club';

  @override
  String get achievementQuestions1000Desc => 'Answer 1000 questions';

  @override
  String get achievementQuestions5000 => 'Expert';

  @override
  String get achievementQuestions5000Desc => 'Answer 5000 questions';

  @override
  String get achievementCorrect100 => 'Sharp Eye';

  @override
  String get achievementCorrect100Desc => 'Get 100 correct answers';

  @override
  String get achievementCorrect500 => 'Knowledge Keeper';

  @override
  String get achievementCorrect500Desc => 'Get 500 correct answers';

  @override
  String get achievementCorrect1000 => 'Scholar';

  @override
  String get achievementCorrect1000Desc => 'Get 1000 correct answers';

  @override
  String get achievementPerfect5 => 'Rising Star';

  @override
  String get achievementPerfect5Desc => 'Get 5 perfect scores';

  @override
  String get achievementPerfect10 => 'Shining Bright';

  @override
  String get achievementPerfect10Desc => 'Get 10 perfect scores';

  @override
  String get achievementPerfect25 => 'Constellation';

  @override
  String get achievementPerfect25Desc => 'Get 25 perfect scores';

  @override
  String get achievementPerfect50 => 'Galaxy';

  @override
  String get achievementPerfect50Desc => 'Get 50 perfect scores';

  @override
  String get achievementScore9010 => 'High Achiever';

  @override
  String get achievementScore9010Desc => 'Score 90%+ in 10 quizzes';

  @override
  String get achievementScore9510 => 'Excellence';

  @override
  String get achievementScore9510Desc => 'Score 95%+ in 10 quizzes';

  @override
  String get achievementPerfectStreak3 => 'Flawless Run';

  @override
  String get achievementPerfectStreak3Desc => 'Get 3 perfect scores in a row';

  @override
  String get achievementSpeedDemon => 'Speed Demon';

  @override
  String get achievementSpeedDemonDesc => 'Complete a quiz in under 60 seconds';

  @override
  String get achievementLightning => 'Lightning Fast';

  @override
  String get achievementLightningDesc => 'Complete a quiz in under 30 seconds';

  @override
  String get achievementQuickAnswer10 => 'Quick Thinker';

  @override
  String get achievementQuickAnswer10Desc =>
      'Answer 10 questions in under 2 seconds each';

  @override
  String get achievementQuickAnswer50 => 'Rapid Fire';

  @override
  String get achievementQuickAnswer50Desc =>
      'Answer 50 questions in under 2 seconds each';

  @override
  String get achievementStreak10 => 'On Fire';

  @override
  String get achievementStreak10Desc => 'Get 10 correct answers in a row';

  @override
  String get achievementStreak25 => 'Unstoppable';

  @override
  String get achievementStreak25Desc => 'Get 25 correct answers in a row';

  @override
  String get achievementStreak50 => 'Legendary Streak';

  @override
  String get achievementStreak50Desc => 'Get 50 correct answers in a row';

  @override
  String get achievementStreak100 => 'Mythical';

  @override
  String get achievementStreak100Desc => 'Get 100 correct answers in a row';

  @override
  String get achievementSurvivalComplete => 'Survivor';

  @override
  String get achievementSurvivalCompleteDesc => 'Complete Survival mode';

  @override
  String get achievementSurvivalPerfect => 'Immortal';

  @override
  String get achievementSurvivalPerfectDesc =>
      'Complete Survival without losing a life';

  @override
  String get achievementBlitzComplete => 'Blitz Master';

  @override
  String get achievementBlitzCompleteDesc => 'Complete Blitz mode';

  @override
  String get achievementBlitzPerfect => 'Lightning God';

  @override
  String get achievementBlitzPerfectDesc => 'Complete Blitz with perfect score';

  @override
  String get achievementTimeAttack20 => 'Time Warrior';

  @override
  String get achievementTimeAttack20Desc => 'Answer 20+ correct in Time Attack';

  @override
  String get achievementTimeAttack30 => 'Time Lord';

  @override
  String get achievementTimeAttack30Desc => 'Answer 30+ correct in Time Attack';

  @override
  String get achievementMarathon50 => 'Endurance';

  @override
  String get achievementMarathon50Desc => 'Answer 50 questions in Marathon';

  @override
  String get achievementMarathon100 => 'Ultra Marathon';

  @override
  String get achievementMarathon100Desc => 'Answer 100 questions in Marathon';

  @override
  String get achievementSpeedRunFast => 'Speed Runner';

  @override
  String get achievementSpeedRunFastDesc =>
      'Complete Speed Run in under 2 minutes';

  @override
  String get achievementAllChallenges => 'Challenge Champion';

  @override
  String get achievementAllChallengesDesc => 'Complete all challenge modes';

  @override
  String get achievementTime1h => 'Dedicated';

  @override
  String get achievementTime1hDesc => 'Play for 1 hour total';

  @override
  String get achievementTime5h => 'Committed';

  @override
  String get achievementTime5hDesc => 'Play for 5 hours total';

  @override
  String get achievementTime10h => 'Devoted';

  @override
  String get achievementTime10hDesc => 'Play for 10 hours total';

  @override
  String get achievementTime24h => 'Fanatic';

  @override
  String get achievementTime24hDesc => 'Play for 24 hours total';

  @override
  String get achievementDays3 => 'Regular';

  @override
  String get achievementDays3Desc => 'Play 3 days in a row';

  @override
  String get achievementDays7 => 'Weekly Warrior';

  @override
  String get achievementDays7Desc => 'Play 7 days in a row';

  @override
  String get achievementDays14 => 'Two Week Streak';

  @override
  String get achievementDays14Desc => 'Play 14 days in a row';

  @override
  String get achievementDays30 => 'Monthly Master';

  @override
  String get achievementDays30Desc => 'Play 30 days in a row';

  @override
  String get achievementNoHints => 'Purist';

  @override
  String get achievementNoHintsDesc => 'Complete a quiz without using hints';

  @override
  String get achievementNoHints10 => 'True Expert';

  @override
  String get achievementNoHints10Desc => 'Complete 10 quizzes without hints';

  @override
  String get achievementNoSkip => 'Determined';

  @override
  String get achievementNoSkipDesc => 'Complete a quiz without skipping';

  @override
  String get achievementFlawless => 'Flawless Victory';

  @override
  String get achievementFlawlessDesc =>
      'Perfect score, no hints, no lives lost';

  @override
  String get achievementComeback => 'Comeback King';

  @override
  String get achievementComebackDesc => 'Win after losing 4+ lives';

  @override
  String get achievementClutch => 'Clutch Player';

  @override
  String get achievementClutchDesc =>
      'Answer 15+ questions correctly in Survival';

  @override
  String get noAchievementsFound => 'No achievements found';

  @override
  String get tryChangingFilter => 'Try changing the filter';

  @override
  String get noAchievementsInCategory => 'No achievements in this category';

  @override
  String get otherAchievements => 'Other';

  @override
  String get filterAll => 'All';

  @override
  String get filterUnlocked => 'Unlocked';

  @override
  String get filterInProgress => 'In Progress';

  @override
  String get filterLocked => 'Locked';

  @override
  String get allTiers => 'All Tiers';

  @override
  String achievementProgress(int current, int target) {
    return '$current/$target';
  }

  @override
  String pointsRemaining(int points) {
    return '$points remaining';
  }

  @override
  String get allPointsEarned => 'All earned!';

  @override
  String completionPercentage(int percent) {
    return '$percent%';
  }

  @override
  String get accessibilityDoubleTapToView => 'Double tap to view details';

  @override
  String get accessibilityDoubleTapToDismiss => 'Double tap to dismiss';

  @override
  String accessibilityAchievementUnlocked(
    String name,
    String tier,
    int points,
  ) {
    return '$name, $tier achievement, $points points, unlocked';
  }

  @override
  String accessibilityAchievementLocked(
    String name,
    String tier,
    int points,
    int progress,
  ) {
    return '$name, $tier achievement, $points points, locked, $progress percent complete';
  }

  @override
  String accessibilityAchievementNotification(
    String name,
    String tier,
    int points,
  ) {
    return 'Achievement unlocked: $name, $tier, plus $points points';
  }

  @override
  String accessibilityProgressBar(int current, int target) {
    return 'Progress: $current of $target';
  }

  @override
  String accessibilityTierBadge(String tier) {
    return '$tier tier';
  }

  @override
  String accessibilityPointsBadge(int points) {
    return '$points points';
  }

  @override
  String get practiceMode => 'Practice';

  @override
  String get practiceEmptyTitle => 'No questions to practice';

  @override
  String get practiceEmptyMessage =>
      'Great job! You\'ve mastered all the questions you got wrong. Keep playing to challenge yourself!';

  @override
  String get practiceStartQuiz => 'Start a Quiz';

  @override
  String get practiceStartTitle => 'Practice Mode';

  @override
  String practiceQuestionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count questions to practice',
      one: '1 question to practice',
    );
    return '$_temp0';
  }

  @override
  String get practiceDescription =>
      'These are questions you\'ve answered incorrectly before.';

  @override
  String get startPractice => 'Start Practice';

  @override
  String get practiceCompleteTitle => 'Practice Complete!';

  @override
  String practiceCorrectCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count correct',
      one: '1 correct',
    );
    return '$_temp0';
  }

  @override
  String practiceNeedMorePractice(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count need more practice',
      one: '1 needs more practice',
    );
    return '$_temp0';
  }

  @override
  String get practiceKeepGoing =>
      'Keep practicing to master all the questions!';

  @override
  String get practiceAllCorrect =>
      'Perfect! You\'ve mastered all the questions!';

  @override
  String get practiceDone => 'Done';

  @override
  String wrongCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count times',
      one: '1 time',
    );
    return 'Wrong $_temp0';
  }

  @override
  String get pointsLabel => 'pts';

  @override
  String get totalScore => 'Total Score';

  @override
  String get basePoints => 'Base Points';

  @override
  String get timeBonus => 'Time Bonus';

  @override
  String get streakBonus => 'Streak Bonus';

  @override
  String get bonus => 'Bonus';

  @override
  String get scoreBreakdown => 'Score Breakdown';

  @override
  String pointsEarned(int points) {
    return '$points pts';
  }

  @override
  String scorePlusBonus(int base, int bonus) {
    return '$base + $bonus bonus';
  }

  @override
  String get livesLabel => 'Lives';

  @override
  String get livesTooltip =>
      'Lives remaining. Lose a life when you answer incorrectly.';

  @override
  String livesAccessibilityLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lives remaining',
      one: '1 life remaining',
      zero: 'No lives remaining',
    );
    return '$_temp0';
  }

  @override
  String get fiftyFiftyTooltip => '50/50 hint. Eliminates two wrong answers.';

  @override
  String fiftyFiftyAccessibilityLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fifty-fifty hints remaining',
      one: '1 fifty-fifty hint remaining',
      zero: 'No 50/50 hints remaining',
    );
    return '$_temp0';
  }

  @override
  String get skipTooltip => 'Skip hint. Skip this question without penalty.';

  @override
  String skipAccessibilityLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skip hints remaining',
      one: '1 skip hint remaining',
      zero: 'No skip hints remaining',
    );
    return '$_temp0';
  }

  @override
  String get resourceDepleted => 'No more available';

  @override
  String get getMoreLives => 'Get More Lives';

  @override
  String get getMoreHints => 'Get More Hints';

  @override
  String get fiftyFiftyLabel => '50/50';

  @override
  String get skipLabel => 'Skip';

  @override
  String get needMoreLives => 'Need More Lives?';

  @override
  String get needMoreHints => 'Need More Hints?';

  @override
  String get needMoreSkips => 'Need More Skips?';

  @override
  String resourceRemaining(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count remaining',
      one: '1 remaining',
      zero: '0 remaining',
    );
    return '$_temp0';
  }

  @override
  String watchAdForResource(int count, String resource) {
    return 'Watch Ad for +$count $resource';
  }

  @override
  String buyResource(String resource) {
    return 'Buy $resource...';
  }

  @override
  String get noThanks => 'No Thanks';

  @override
  String get buyLives => 'Buy Lives';

  @override
  String get buyHints => 'Buy Hints';

  @override
  String get buySkips => 'Buy Skips';

  @override
  String get bestValue => 'Best Value';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get noConnection => 'No Connection';

  @override
  String get connectToRestore =>
      'Connect to the internet to restore your resources.';

  @override
  String get ok => 'OK';

  @override
  String purchaseSuccess(int count, String resource) {
    return 'Purchase successful! +$count $resource';
  }

  @override
  String get purchaseFailed => 'Purchase failed. Please try again.';

  @override
  String get purchaseCancelled => 'Purchase cancelled.';

  @override
  String get purchasePending => 'Purchase pending. Please wait.';

  @override
  String get purchasesRestored => 'Purchases restored successfully.';

  @override
  String adWatchSuccess(int count, String resource) {
    return '+$count $resource added!';
  }

  @override
  String get adNotAvailable => 'Ad not available. Please try again later.';

  @override
  String get dailyLimitReset => 'Daily resources reset!';

  @override
  String freeResourcesInfo(int count, String resource) {
    return '$count free $resource per day';
  }
}
