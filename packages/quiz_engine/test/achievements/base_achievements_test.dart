import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/achievements/achievement_category.dart';
import 'package:quiz_engine/src/achievements/base_achievements.dart';
import 'package:quiz_engine/src/l10n/generated/quiz_engine_localizations.dart';
import 'package:shared_services/shared_services.dart';

/// Mock localizations for testing.
class MockQuizEngineLocalizations extends QuizEngineLocalizations {
  MockQuizEngineLocalizations() : super('en');

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
  String get achievementSpeedDemonDesc =>
      'Complete a quiz in under 60 seconds';
  @override
  String get achievementLightning => 'Lightning Fast';
  @override
  String get achievementLightningDesc =>
      'Complete a quiz in under 30 seconds';
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
  String get achievementFlawlessDesc => 'Perfect score, no hints, no lives lost';
  @override
  String get achievementComeback => 'Comeback King';
  @override
  String get achievementComebackDesc => 'Win after losing 4+ lives';
  @override
  String get achievementClutch => 'Clutch Player';
  @override
  String get achievementClutchDesc =>
      'Complete Survival with 1 life remaining';

  // Other required overrides with default values
  @override
  String get play => 'Play';
  @override
  String get challenges => 'Challenges';
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
  String get exitDialogMessage => 'Are you sure?';
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
  String daysAgo(int count) => '$count days ago';
  @override
  String get noSessionsYet => 'No sessions';
  @override
  String get startPlayingToSee => 'Start playing';
  @override
  String get sessionDetails => 'Details';
  @override
  String get reviewAnswers => 'Review';
  @override
  String questionNumber(int number) => 'Question $number';
  @override
  String get yourAnswer => 'Your answer';
  @override
  String get correctAnswer => 'Correct answer';
  @override
  String get skipped => 'Skipped';
  @override
  String get practiceWrongAnswers => 'Practice';
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
  String get noStatisticsYet => 'No stats';
  @override
  String get playQuizzesToSee => 'Play quizzes';
  @override
  String get overview => 'Overview';
  @override
  String get insights => 'Insights';
  @override
  String get days => 'days';
  @override
  String get audioAndHaptics => 'Audio';
  @override
  String get soundEffects => 'Sound';
  @override
  String get soundEffectsDescription => 'Sound effects';
  @override
  String get backgroundMusic => 'Music';
  @override
  String get backgroundMusicDescription => 'Background music';
  @override
  String get hapticFeedback => 'Haptics';
  @override
  String get hapticFeedbackDescription => 'Vibrate';
  @override
  String get quizBehavior => 'Quiz';
  @override
  String get showAnswerFeedback => 'Feedback';
  @override
  String get showAnswerFeedbackDescription => 'Show feedback';
  @override
  String get appearance => 'Appearance';
  @override
  String get theme => 'Theme';
  @override
  String get themeLight => 'Light';
  @override
  String get themeDark => 'Dark';
  @override
  String get themeSystem => 'System';
  @override
  String get selectTheme => 'Select Theme';
  @override
  String get about => 'About';
  @override
  String get version => 'Version';
  @override
  String get build => 'Build';
  @override
  String get aboutThisApp => 'About';
  @override
  String get privacyPolicy => 'Privacy';
  @override
  String get termsOfService => 'Terms';
  @override
  String get openSourceLicenses => 'Licenses';
  @override
  String get advanced => 'Advanced';
  @override
  String get resetToDefaults => 'Reset';
  @override
  String get resetToDefaultsDescription => 'Reset all';
  @override
  String get resetSettings => 'Reset Settings';
  @override
  String get resetSettingsMessage => 'Reset all settings?';
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
  String get exportSession => 'Export';
  @override
  String get exportAsJson => 'JSON';
  @override
  String get exportAsCsv => 'CSV';
  @override
  String get exportSuccess => 'Exported';
  @override
  String get exportError => 'Export failed';
  @override
  String get deleteSession => 'Delete Session';
  @override
  String get deleteSessionMessage => 'Delete?';
  @override
  String get sessionDeleted => 'Deleted';
  @override
  String get recentSessions => 'Recent';
  @override
  String get settingsResetToDefaults => 'Settings reset';
  @override
  String couldNotOpenUrl(String url) => 'Could not open $url';
  @override
  String get gameOverText => 'Your Score';
  @override
  String get noData => 'No data';
  @override
  String initializationError(String error) => 'Error: $error';
  @override
  String get quizComplete => 'Complete!';
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
  String get reviewThisSession => 'Review';
  @override
  String get reviewWrongAnswers => 'Review Wrong';
  @override
  String get done => 'Done';
  @override
  String get playAgain => 'Play Again';
  @override
  String scoreOf(int correct, int total) => '$correct of $total';
  @override
  String get timedOut => 'Timed Out';
  @override
  String get hintsUsed => 'Hints Used';
  @override
  String get comingSoon => 'Coming Soon';
  @override
  String get categoryBreakdown => 'Category Breakdown';
  @override
  String get noCategoryData => 'No category data';
  @override
  String sessionsCount(int count) => '$count sessions';
  @override
  String get noProgressData => 'No progress data';
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
  String get noLeaderboardData => 'No leaderboard data';
  @override
  String get globalLeaderboard => 'Global Leaderboard';
  @override
  String get globalLeaderboardComingSoon => 'Compete with players worldwide';
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
  String get allTimeData => 'All time';
  @override
  String get highestScore => 'Highest';
  @override
  String get lowestScore => 'Lowest';
  @override
  String get noPracticeItems => 'No practice items';
  @override
  String get noPracticeItemsDescription => 'No wrong answers';
  @override
  String get practice => 'Practice';
  @override
  String get practiceMode => 'Practice';
  @override
  String get practiceEmptyTitle => 'No questions to practice';
  @override
  String get practiceEmptyMessage => 'Great job!';
  @override
  String get practiceStartQuiz => 'Start a Quiz';
  @override
  String get practiceStartTitle => 'Practice Mode';
  @override
  String practiceQuestionCount(int count) => '$count questions to practice';
  @override
  String get practiceDescription => 'These are questions you got wrong';
  @override
  String get startPractice => 'Start Practice';
  @override
  String get practiceCompleteTitle => 'Practice Complete!';
  @override
  String practiceCorrectCount(int count) => '$count correct';
  @override
  String practiceNeedMorePractice(int count) => '$count need more practice';
  @override
  String get practiceKeepGoing => 'Keep practicing!';
  @override
  String get practiceAllCorrect => 'Perfect!';
  @override
  String get practiceDone => 'Done';
  @override
  String wrongCount(int count) => 'Wrong $count times';
  @override
  String get achievements => 'Achievements';
  @override
  String get achievementUnlocked => 'Achievement Unlocked!';
  @override
  String achievementsUnlocked(int count, int total) => '$count of $total';
  @override
  String achievementPoints(int points) => '$points pts';
  @override
  String get hiddenAchievement => 'Hidden';
  @override
  String get hiddenAchievementDesc => 'Keep playing!';

  // New UI localization strings
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
  String achievementProgress(int current, int target) => '$current/$target';
  @override
  String pointsRemaining(int points) => '$points remaining';
  @override
  String get allPointsEarned => 'All earned!';
  @override
  String completionPercentage(int percent) => '$percent%';

  // Accessibility labels
  @override
  String get accessibilityDoubleTapToView => 'Double tap to view details';
  @override
  String get accessibilityDoubleTapToDismiss => 'Double tap to dismiss';
  @override
  String accessibilityAchievementUnlocked(String name, String tier, int points) =>
      '$name, $tier achievement, $points points, unlocked';
  @override
  String accessibilityAchievementLocked(
          String name, String tier, int points, int progress) =>
      '$name, $tier achievement, $points points, locked, $progress percent complete';
  @override
  String accessibilityAchievementNotification(
          String name, String tier, int points) =>
      'Achievement unlocked: $name, $tier, plus $points points';
  @override
  String accessibilityProgressBar(int current, int target) =>
      'Progress: $current of $target';
  @override
  String accessibilityTierBadge(String tier) => '$tier tier';
  @override
  String accessibilityPointsBadge(int points) => '$points points';

  // Score display strings
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
  String pointsEarned(int points) => '$points pts';
  @override
  String scorePlusBonus(int base, int bonus) => '$base + $bonus bonus';
  @override
  String get livesLabel => 'Lives';
  @override
  String get livesTooltip => 'Lives remaining.';
  @override
  String livesAccessibilityLabel(int count) => '$count lives remaining';
  @override
  String get fiftyFiftyTooltip => '50/50 hint.';
  @override
  String fiftyFiftyAccessibilityLabel(int count) => '$count 50/50 hints remaining';
  @override
  String get skipTooltip => 'Skip hint.';
  @override
  String skipAccessibilityLabel(int count) => '$count skip hints remaining';
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
  String resourceRemaining(int count) => '$count remaining';
  @override
  String watchAdForResource(int count, String resource) =>
      'Watch Ad for +$count $resource';
  @override
  String buyResource(String resource) => 'Buy $resource...';
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
  String get connectToRestore => 'Connect to restore';
  @override
  String get ok => 'OK';
  @override
  String purchaseSuccess(int count, String resource) =>
      'Purchase successful! +$count $resource';
  @override
  String get purchaseFailed => 'Purchase failed';
  @override
  String get purchaseCancelled => 'Purchase cancelled';
  @override
  String get purchasePending => 'Purchase pending';
  @override
  String get purchasesRestored => 'Purchases restored';
  @override
  String adWatchSuccess(int count, String resource) =>
      '+$count $resource added!';
  @override
  String get adNotAvailable => 'Ad not available';
  @override
  String get dailyLimitReset => 'Daily resources reset!';
  @override
  String freeResourcesInfo(int count, String resource) =>
      '$count free $resource per day';

  // Additional accessibility methods
  @override
  String accessibilityCategoryButton(String title) => 'Category: $title';
  @override
  String accessibilityChallengeButton(String name, String difficulty) =>
      '$name, $difficulty challenge';
  @override
  String accessibilityAnswerOption(String answer) => 'Answer option: $answer';
  @override
  String accessibilityAnswerDisabled(String answer) => '$answer, disabled';
  @override
  String accessibilitySessionCard(String date, int score, int total) =>
      'Quiz session from $date, score $score out of $total';
  @override
  String get accessibilityDoubleTapToSelect => 'Double tap to select';
  @override
  String get accessibilityDoubleTapToStart => 'Double tap to start';
  @override
  String accessibilityProgress(int percent) => '$percent percent complete';
  @override
  String accessibilityTimer(int seconds) => '$seconds seconds remaining';
  @override
  String accessibilityLivesRemaining(int count) => '$count lives remaining';
  @override
  String accessibilityStatistic(String label, String value) => '$label: $value';
  @override
  String accessibilityQuestionNumber(int current, int total) =>
      'Question $current of $total';
  @override
  String get accessibilityCorrectAnswer => 'Correct answer';
  @override
  String get accessibilityIncorrectAnswer => 'Incorrect answer';
  @override
  String accessibilityCategoryWithQuestions(String category, int count) =>
      '$category, $count questions';
  @override
  String accessibilityHintsRemaining(int count, String type) =>
      '$count $type hints remaining';

  // Export data methods
  @override
  String get exportData => 'Export Data';
  @override
  String get exportDataDescription => 'Export your quiz data';
  @override
  String get exportDataDialogMessage => 'Export?';
  @override
  String get exportDataIncludes => 'Includes:';
  @override
  String get exportIncludesQuizHistory => 'Quiz history';
  @override
  String get exportIncludesAnswers => 'Answer details';
  @override
  String get exportIncludesStatistics => 'Statistics';
  @override
  String get exportIncludesSettings => 'Settings';
  @override
  String get export => 'Export';
  @override
  String get exportDataSubject => 'Quiz Data Export';
  @override
  String exportDataSuccess(int count) => 'Exported $count sessions';
  @override
  String get exportDataError => 'Export failed';
  @override
  String get dataAndPrivacy => 'Data & Privacy';
  @override
  String get purchaseNotAvailable => 'This product is not available.';
  @override
  String get purchaseAlreadyOwned => 'You already own this item.';

  // Shop section
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
  String get restorePurchasesDescription => 'Restore previous purchases';
  @override
  String get storeUnavailable => 'Store unavailable';
  @override
  String get storeUnavailableDescription => 'Unable to connect to the store.';
  @override
  String get noPurchasesToRestore => 'No purchases to restore';
  @override
  String purchasesRestoredCount(int count) => '$count purchases restored';
  @override
  String get buy => 'Buy';
  @override
  String get purchased => 'Purchased';

  // Rate App localizations
  @override
  String rateAppLoveDialogTitle(String appName) => 'Enjoying $appName?';
  @override
  String get rateAppLoveDialogYes => 'Yes!';
  @override
  String get rateAppLoveDialogNo => 'Not Really';
  @override
  String get rateAppFeedbackTitle => 'Feedback';
  @override
  String get rateAppFeedbackMessage => 'What could be better?';
  @override
  String get rateAppFeedbackEmailButton => 'Send Email';
  @override
  String get rateAppFeedbackDismiss => 'Maybe Later';
  @override
  String get rateAppThankYou => 'Thank you!';
  @override
  String get accessibilityRateDialogTitle => 'Rate dialog';
  @override
  String get accessibilityFeedbackDialogTitle => 'Feedback dialog';

  // Image answer accessibility localizations
  @override
  String accessibilityImageAnswer(String label) => 'Image answer: $label';
  @override
  String accessibilityImageAnswerDisabled(String label) =>
      'Image answer $label, eliminated';
  @override
  String get imageLoadError => 'Failed to load image';

  // Layout mode localizations
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
  String get layoutModeUsed => 'Layout used';
  @override
  String get layoutBreakdown => 'Layout Breakdown';

  // Reverse layout question templates
  @override
  String selectThe(String name) => 'Select the $name';
  @override
  String whichOneIs(String name) => 'Which one is $name';

  // Accessibility strings
  @override
  String get accessibilityLayoutModeSelector => 'Layout mode selector';
  @override
  String get accessibilityLayoutModeSelectorHint =>
      'Select how questions and answers are displayed';
  @override
  String accessibilityLayoutModeBadge(String mode) => 'Layout mode: $mode';
  @override
  String accessibilityLayoutModeSelected(String mode) => '$mode layout selected';
  @override
  String accessibilityStarRating(int stars, int total) =>
      '$stars out of $total stars';
  @override
  String get accessibilityFilterQuestions => 'Filter questions';
  @override
  String get accessibilityFilterHint => 'Select which questions to display';

  // Share strings
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
  String get shareImageGenerating => 'Generating share image...';
  @override
  String get shareImageError => 'Failed to generate share image';
  @override
  String get shareAchievementUnlocked => 'Achievement Unlocked';
  @override
  String get sharePerfectScore => 'Perfect Score!';
  @override
  String get shareCallToAction => 'Try it yourself!';
}

void main() {
  late MockQuizEngineLocalizations l10n;

  setUp(() {
    l10n = MockQuizEngineLocalizations();
  });

  group('BaseAchievements', () {
    test('all() returns exactly 53 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      expect(achievements.length, equals(BaseAchievements.count));
      expect(achievements.length, equals(53));
    });

    test('all achievements have unique IDs', () {
      final achievements = BaseAchievements.all(l10n);
      final ids = achievements.map((a) => a.id).toSet();
      expect(ids.length, equals(achievements.length));
    });

    test('all achievements have valid categories', () {
      final achievements = BaseAchievements.all(l10n);
      final categoryNames =
          AchievementCategory.values.map((c) => c.name).toSet();

      for (final achievement in achievements) {
        expect(
          categoryNames.contains(achievement.category),
          isTrue,
          reason:
              'Achievement ${achievement.id} has invalid category: ${achievement.category}',
        );
      }
    });

    test('all achievements have non-empty icons', () {
      final achievements = BaseAchievements.all(l10n);

      for (final achievement in achievements) {
        expect(
          achievement.icon.isNotEmpty,
          isTrue,
          reason: 'Achievement ${achievement.id} has empty icon',
        );
      }
    });

    test('all achievements have valid tiers', () {
      final achievements = BaseAchievements.all(l10n);
      final validTiers = AchievementTier.values.toSet();

      for (final achievement in achievements) {
        expect(
          validTiers.contains(achievement.tier),
          isTrue,
          reason: 'Achievement ${achievement.id} has invalid tier',
        );
      }
    });

    test('beginner category has 3 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final beginner = achievements
          .where((a) => a.category == AchievementCategory.beginner.name)
          .toList();
      expect(beginner.length, equals(3));
    });

    test('progress category has 11 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final progress = achievements
          .where((a) => a.category == AchievementCategory.progress.name)
          .toList();
      expect(progress.length, equals(11));
    });

    test('mastery category has 7 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final mastery = achievements
          .where((a) => a.category == AchievementCategory.mastery.name)
          .toList();
      expect(mastery.length, equals(7));
    });

    test('speed category has 4 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final speed = achievements
          .where((a) => a.category == AchievementCategory.speed.name)
          .toList();
      expect(speed.length, equals(4));
    });

    test('streak category has 4 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final streak = achievements
          .where((a) => a.category == AchievementCategory.streak.name)
          .toList();
      expect(streak.length, equals(4));
    });

    test('challenge category has 10 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final challenge = achievements
          .where((a) => a.category == AchievementCategory.challenge.name)
          .toList();
      expect(challenge.length, equals(10));
    });

    test('dedication category has 8 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final dedication = achievements
          .where((a) => a.category == AchievementCategory.dedication.name)
          .toList();
      expect(dedication.length, equals(8));
    });

    test('skill category has 6 achievements', () {
      final achievements = BaseAchievements.all(l10n);
      final skill = achievements
          .where((a) => a.category == AchievementCategory.skill.name)
          .toList();
      expect(skill.length, equals(6));
    });

    test('byCategory returns all categories', () {
      final byCategory = BaseAchievements.byCategory(l10n);
      expect(byCategory.length, equals(AchievementCategory.values.length));

      for (final category in AchievementCategory.values) {
        expect(byCategory.containsKey(category), isTrue);
      }
    });

    test('individual achievements have correct IDs', () {
      expect(BaseAchievements.firstQuiz(l10n).id, equals('first_quiz'));
      expect(BaseAchievements.firstPerfect(l10n).id, equals('first_perfect'));
      expect(
        BaseAchievements.firstChallenge(l10n).id,
        equals('first_challenge'),
      );
      expect(BaseAchievements.quizzes10(l10n).id, equals('quizzes_10'));
      expect(BaseAchievements.quizzes50(l10n).id, equals('quizzes_50'));
      expect(BaseAchievements.quizzes100(l10n).id, equals('quizzes_100'));
      expect(BaseAchievements.quizzes500(l10n).id, equals('quizzes_500'));
      expect(BaseAchievements.streak10(l10n).id, equals('streak_10'));
      expect(BaseAchievements.streak100(l10n).id, equals('streak_100'));
      expect(BaseAchievements.flawless(l10n).id, equals('flawless'));
    });

    test('tier distribution is balanced', () {
      final achievements = BaseAchievements.all(l10n);
      final tierCounts = <AchievementTier, int>{};

      for (final achievement in achievements) {
        tierCounts[achievement.tier] =
            (tierCounts[achievement.tier] ?? 0) + 1;
      }

      // Verify we have achievements in each tier
      expect(tierCounts[AchievementTier.common], greaterThan(0));
      expect(tierCounts[AchievementTier.uncommon], greaterThan(0));
      expect(tierCounts[AchievementTier.rare], greaterThan(0));
      expect(tierCounts[AchievementTier.epic], greaterThan(0));
      expect(tierCounts[AchievementTier.legendary], greaterThan(0));
    });
  });

  group('AchievementCategory', () {
    test('all categories have display names', () {
      for (final category in AchievementCategory.values) {
        expect(category.displayName.isNotEmpty, isTrue);
      }
    });

    test('all categories have icons', () {
      for (final category in AchievementCategory.values) {
        expect(category.icon.isNotEmpty, isTrue);
      }
    });

    test('sort order is unique for each category', () {
      final sortOrders = AchievementCategory.values.map((c) => c.sortOrder);
      expect(sortOrders.toSet().length, equals(AchievementCategory.values.length));
    });
  });
}
