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
}
