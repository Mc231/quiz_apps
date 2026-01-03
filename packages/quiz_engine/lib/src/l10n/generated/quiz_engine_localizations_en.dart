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
  String get correctAnswerLabel => 'Correct answer:';

  @override
  String get videoLoadError => 'Failed to load video';

  @override
  String get retry => 'Retry';

  @override
  String get errorTitle => 'Something Went Wrong';

  @override
  String get errorGeneric => 'An unexpected error occurred. Please try again.';

  @override
  String get errorNetwork => 'Unable to connect. Please check your connection.';

  @override
  String get errorServer =>
      'Something went wrong on our end. Please try again later.';

  @override
  String get loadingData => 'Loading...';

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
  String get livesDescription =>
      'Lives let you continue playing after wrong answers. Each life saves you from one mistake, so you can keep learning without starting over.';

  @override
  String get fiftyFiftyDescription =>
      '50/50 hints remove two wrong answers, leaving only two choices. Use them on difficult questions to improve your chances of getting the right answer.';

  @override
  String get skipDescription =>
      'Skips let you pass difficult questions without losing a life or affecting your score. Move instantly to the next question when you\'re stuck.';

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
  String get purchaseNotAvailable => 'This product is not available.';

  @override
  String get purchaseAlreadyOwned => 'You already own this item.';

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

  @override
  String accessibilityCategoryButton(String category) {
    return '$category quiz category';
  }

  @override
  String accessibilityCategoryWithQuestions(String category, int count) {
    return '$category, $count questions';
  }

  @override
  String get accessibilityDoubleTapToSelect => 'Double tap to select';

  @override
  String get accessibilityDoubleTapToStart => 'Double tap to start';

  @override
  String accessibilityChallengeButton(String name, String difficulty) {
    return '$name challenge, $difficulty difficulty';
  }

  @override
  String accessibilityAnswerOption(String answer) {
    return 'Answer option: $answer';
  }

  @override
  String accessibilityAnswerDisabled(String answer) {
    return 'Answer option $answer, eliminated';
  }

  @override
  String accessibilitySessionCard(String date, int score, int total) {
    return 'Quiz session from $date, score $score out of $total';
  }

  @override
  String accessibilityStatistic(String label, String value) {
    return '$label: $value';
  }

  @override
  String accessibilityProgress(int percent) {
    return 'Progress: $percent percent';
  }

  @override
  String accessibilityLivesRemaining(int count) {
    return '$count lives remaining';
  }

  @override
  String accessibilityHintsRemaining(int count, String type) {
    return '$count $type hints remaining';
  }

  @override
  String accessibilityTimer(int seconds) {
    return '$seconds seconds remaining';
  }

  @override
  String get accessibilityCorrectAnswer => 'Correct answer';

  @override
  String get accessibilityIncorrectAnswer => 'Incorrect answer';

  @override
  String accessibilityQuestionNumber(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDescription => 'Download all your data (GDPR)';

  @override
  String get exportDataDialogMessage =>
      'Export all your data to a JSON file. This includes your complete quiz history, statistics, and settings.';

  @override
  String get exportDataIncludes => 'This export includes:';

  @override
  String get exportIncludesQuizHistory => 'All quiz sessions and results';

  @override
  String get exportIncludesAnswers => 'Your answers to all questions';

  @override
  String get exportIncludesStatistics => 'Performance statistics';

  @override
  String get exportIncludesSettings => 'App preferences and settings';

  @override
  String get export => 'Export';

  @override
  String get exportDataSubject => 'My Quiz Data Export';

  @override
  String exportDataSuccess(int count) {
    return 'Successfully exported $count items';
  }

  @override
  String get exportDataError => 'Failed to export data. Please try again.';

  @override
  String get dataAndPrivacy => 'Data & Privacy';

  @override
  String get shop => 'Shop';

  @override
  String get removeAds => 'Remove Ads';

  @override
  String get removeAdsDescription => 'Enjoy ad-free gameplay forever';

  @override
  String get removeAdsPurchased => 'Ads Removed';

  @override
  String get removeAdsPurchasedDescription => 'Thank you for your purchase!';

  @override
  String get bundles => 'Bundles';

  @override
  String get bundleStarterTitle => 'Starter Pack';

  @override
  String get bundleStarterDescription => '5 lives + 5 fifty-fifty + 5 skips';

  @override
  String get bundleValueTitle => 'Value Pack';

  @override
  String get bundleValueDescription => '15 lives + 15 fifty-fifty + 15 skips';

  @override
  String get bundleProTitle => 'Pro Pack';

  @override
  String get bundleProDescription => '50 lives + 50 fifty-fifty + 50 skips';

  @override
  String get purchasing => 'Purchasing...';

  @override
  String get restoring => 'Restoring...';

  @override
  String get restorePurchasesDescription =>
      'Restore previous purchases on this device';

  @override
  String get storeUnavailable => 'Store unavailable';

  @override
  String get storeUnavailableDescription =>
      'Unable to connect to the store. Please check your connection.';

  @override
  String get noPurchasesToRestore => 'No purchases to restore';

  @override
  String purchasesRestoredCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count purchases restored',
      one: '1 purchase restored',
    );
    return '$_temp0';
  }

  @override
  String get buy => 'Buy';

  @override
  String get purchased => 'Purchased';

  @override
  String rateAppLoveDialogTitle(String appName) {
    return 'Are you enjoying $appName?';
  }

  @override
  String get rateAppLoveDialogYes => 'Yes!';

  @override
  String get rateAppLoveDialogNo => 'Not Really';

  @override
  String get rateAppFeedbackTitle => 'We\'d love to hear from you';

  @override
  String get rateAppFeedbackMessage => 'What could we do better?';

  @override
  String get rateAppFeedbackEmailButton => 'Send Feedback';

  @override
  String get rateAppFeedbackDismiss => 'Maybe Later';

  @override
  String get rateAppThankYou => 'Thank you for your feedback!';

  @override
  String get accessibilityRateDialogTitle => 'App rating dialog';

  @override
  String get accessibilityFeedbackDialogTitle => 'Feedback dialog';

  @override
  String accessibilityImageAnswer(String label) {
    return 'Image answer: $label';
  }

  @override
  String accessibilityImageAnswerDisabled(String label) {
    return 'Image answer $label, eliminated';
  }

  @override
  String get imageLoadError => 'Failed to load image';

  @override
  String whichOneIs(String name) {
    return 'Which one is $name?';
  }

  @override
  String selectThe(String name) {
    return 'Select the $name';
  }

  @override
  String get layoutStandard => 'Standard';

  @override
  String get layoutReverse => 'Reverse';

  @override
  String get layoutMixed => 'Mixed';

  @override
  String get layoutImageQuestionTextAnswers => 'Image → Text';

  @override
  String get layoutTextQuestionImageAnswers => 'Text → Image';

  @override
  String get layoutTextQuestionTextAnswers => 'Text → Text';

  @override
  String get layoutAudioQuestionTextAnswers => 'Audio → Text';

  @override
  String get layoutText => 'Text';

  @override
  String get layoutAudio => 'Audio';

  @override
  String get layoutMode => 'Layout';

  @override
  String get quizModeTitle => 'Quiz Mode';

  @override
  String get quizModeSubtitle => 'Choose how questions are displayed';

  @override
  String get layoutModeUsed => 'Layout used';

  @override
  String get layoutBreakdown => 'Layout Breakdown';

  @override
  String get accessibilityLayoutModeSelector => 'Layout mode selector';

  @override
  String get accessibilityLayoutModeSelectorHint =>
      'Select how questions and answers are displayed';

  @override
  String accessibilityLayoutModeBadge(String mode) {
    return 'Layout mode: $mode';
  }

  @override
  String accessibilityLayoutModeSelected(String mode) {
    return '$mode layout selected';
  }

  @override
  String accessibilityStarRating(int stars, int total) {
    return '$stars out of $total stars';
  }

  @override
  String get accessibilityFilterQuestions => 'Filter questions';

  @override
  String get accessibilityFilterHint => 'Select which questions to display';

  @override
  String get sharePerfectScore => 'PERFECT SCORE!';

  @override
  String get shareAchievementUnlocked => 'ACHIEVEMENT UNLOCKED';

  @override
  String get shareCallToAction => 'Can you beat my score?';

  @override
  String get shareImageGenerating => 'Generating share image...';

  @override
  String get shareImageError => 'Failed to generate share image';

  @override
  String get shareAsImage => 'Share as Image';

  @override
  String get shareAsImageDescription => 'Create a beautiful image to share';

  @override
  String get shareAsText => 'Share as Text';

  @override
  String get shareAsTextDescription => 'Share your score as a message';

  @override
  String get shareUnavailable => 'Sharing is not available on this device';

  @override
  String get shareResult => 'Share Result';

  @override
  String get shareScore => 'Share Score';

  @override
  String get shareAchievement => 'Share Achievement';

  @override
  String get shareSuccess => 'Shared successfully!';

  @override
  String get shareCancelled => 'Share cancelled';

  @override
  String get shareError => 'Failed to share. Please try again.';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get streakDayStreak => 'day streak';

  @override
  String get streakActive => 'On Fire!';

  @override
  String get streakAtRisk => 'Keep your streak alive!';

  @override
  String get streakBroken => 'Streak lost';

  @override
  String get streakNone => 'Start your streak today!';

  @override
  String get streakPlayToday => 'Play today to keep going!';

  @override
  String get streakPlayedToday => 'You played today!';

  @override
  String streakNextMilestone(int days) {
    return 'Next: $days days';
  }

  @override
  String streakMilestoneReached(int days) {
    return '$days Day Streak!';
  }

  @override
  String get streakMilestone7 => 'Week Warrior';

  @override
  String get streakMilestone14 => 'Two Week Champion';

  @override
  String get streakMilestone30 => 'Monthly Master';

  @override
  String get streakMilestone50 => 'Fifty Day Legend';

  @override
  String get streakMilestone100 => 'Centurion';

  @override
  String get streakMilestone365 => 'Year of Dedication';

  @override
  String get streakMilestoneMessage => 'Amazing dedication! Keep it up!';

  @override
  String get streakNewRecord => 'New personal best!';

  @override
  String get streakLongestLabel => 'Longest';

  @override
  String get streakTotalDaysLabel => 'Total Days';

  @override
  String get streakTooltipNoStreak => 'Start playing to build your streak!';

  @override
  String get streakTooltipSingular => '1 day streak - keep it going!';

  @override
  String streakTooltipPlural(int count) {
    return '$count day streak - amazing!';
  }

  @override
  String accessibilityStreakBadge(int count, String status) {
    return '$count day streak, $status';
  }

  @override
  String accessibilityStreakCard(int count, String message) {
    return 'Current streak: $count days. $message';
  }

  @override
  String accessibilityStreakMilestone(int days, String title) {
    return 'Milestone reached: $days day streak. $title';
  }

  @override
  String get dailyChallenge => 'Daily Challenge';

  @override
  String get dailyChallengeSubtitle =>
      'Test your knowledge with today\'s challenge';

  @override
  String get dailyChallengeCompleted => 'Completed!';

  @override
  String get dailyChallengeAvailable => 'Available Now';

  @override
  String dailyChallengeNextIn(String time) {
    return 'Next in $time';
  }

  @override
  String dailyChallengeQuestions(int count) {
    return '$count Questions';
  }

  @override
  String dailyChallengeTimeLimit(int minutes) {
    return '$minutes min limit';
  }

  @override
  String get dailyChallengeNoTimeLimit => 'No time limit';

  @override
  String dailyChallengeTimePerQuestion(int seconds) {
    return '$seconds sec/question';
  }

  @override
  String get timePerQuestion => 'Per Question';

  @override
  String get dailyChallengeStart => 'Start Challenge';

  @override
  String get dailyChallengeRules => 'Challenge Rules';

  @override
  String get dailyChallengeRule1 => 'Answer all questions to complete';

  @override
  String get dailyChallengeRule2 => 'Earn bonus points for streaks';

  @override
  String get dailyChallengeRule3 => 'Complete quickly for time bonus';

  @override
  String get dailyChallengeRule4 => 'One attempt per day';

  @override
  String get dailyChallengeResultTitle => 'Challenge Complete!';

  @override
  String get dailyChallengeYourScore => 'Your Score';

  @override
  String get dailyChallengeYesterdayScore => 'Yesterday\'s Score';

  @override
  String get dailyChallengeNoYesterday => 'No data from yesterday';

  @override
  String dailyChallengeImprovement(int points) {
    return '+$points improvement!';
  }

  @override
  String dailyChallengeDecline(int points) {
    return '$points less than yesterday';
  }

  @override
  String get dailyChallengeSameScore => 'Same as yesterday!';

  @override
  String get dailyChallengeCurrentStreak => 'Current Streak';

  @override
  String get dailyChallengeBestStreak => 'Best Streak';

  @override
  String get dailyChallengeStreak => 'Streak';

  @override
  String get dailyChallengeNewBestStreak => 'New Best!';

  @override
  String get dailyChallengeAlreadyCompleted => 'Already Completed';

  @override
  String get dailyChallengeAlreadyCompletedMessage =>
      'You\'ve already completed today\'s challenge. Come back tomorrow for a new one!';

  @override
  String get dailyChallengeViewResults => 'View Results';

  @override
  String dailyChallengeCategory(String category) {
    return 'Category: $category';
  }

  @override
  String get dailyChallengeScoreBreakdown => 'Score Breakdown';

  @override
  String get dailyChallengeBaseScore => 'Base Score';

  @override
  String get dailyChallengeStreakBonus => 'Streak Bonus';

  @override
  String get dailyChallengeTimeBonus => 'Time Bonus';

  @override
  String get dailyChallengeTotalScore => 'Total Score';

  @override
  String get dailyChallengePerfectScore => 'Perfect Score!';

  @override
  String get dailyChallengeCompletionTime => 'Completion Time';

  @override
  String accessibilityDailyChallengeCard(String status) {
    return 'Daily challenge, $status';
  }

  @override
  String accessibilityDailyChallengeCountdown(String time) {
    return 'Next daily challenge available in $time';
  }

  @override
  String get achievementDetailsHiddenMessage =>
      'This achievement is hidden. Keep playing to discover it!';

  @override
  String achievementDetailsUnlockedOn(String date) {
    return 'Unlocked on $date';
  }

  @override
  String get achievementDetailsKeepPlaying => 'Keep playing to unlock!';

  @override
  String accessibilityAchievementDetails(String name) {
    return 'Achievement details for $name';
  }
}
