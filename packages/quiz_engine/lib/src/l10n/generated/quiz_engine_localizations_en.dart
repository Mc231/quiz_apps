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
}
