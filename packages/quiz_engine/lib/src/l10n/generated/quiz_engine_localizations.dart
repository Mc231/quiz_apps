import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'quiz_engine_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of QuizEngineLocalizations
/// returned by `QuizEngineLocalizations.of(context)`.
///
/// Applications need to include `QuizEngineLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/quiz_engine_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: QuizEngineLocalizations.localizationsDelegates,
///   supportedLocales: QuizEngineLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the QuizEngineLocalizations.supportedLocales
/// property.
abstract class QuizEngineLocalizations {
  QuizEngineLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static QuizEngineLocalizations? of(BuildContext context) {
    return Localizations.of<QuizEngineLocalizations>(
      context,
      QuizEngineLocalizations,
    );
  }

  static const LocalizationsDelegate<QuizEngineLocalizations> delegate =
      _QuizEngineLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// Play tab label
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get play;

  /// History tab label
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// Statistics tab label
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Settings tab/screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Score label
  ///
  /// In en, this message translates to:
  /// **'Score'**
  String get score;

  /// Correct answer label
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get correct;

  /// Incorrect answer label
  ///
  /// In en, this message translates to:
  /// **'Incorrect'**
  String get incorrect;

  /// Duration label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Questions count label
  ///
  /// In en, this message translates to:
  /// **'questions'**
  String get questions;

  /// Exit dialog title
  ///
  /// In en, this message translates to:
  /// **'Exit Quiz?'**
  String get exitDialogTitle;

  /// Exit dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to exit? Your progress will be lost.'**
  String get exitDialogMessage;

  /// Exit dialog confirm button
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get exitDialogConfirm;

  /// Exit dialog cancel button
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get exitDialogCancel;

  /// Correct answer feedback
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correctFeedback;

  /// Incorrect answer feedback
  ///
  /// In en, this message translates to:
  /// **'Incorrect!'**
  String get incorrectFeedback;

  /// Video load error message
  ///
  /// In en, this message translates to:
  /// **'Failed to load video'**
  String get videoLoadError;

  /// 50/50 hint label
  ///
  /// In en, this message translates to:
  /// **'50/50'**
  String get hint5050Label;

  /// Skip hint label
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get hintSkipLabel;

  /// Timer seconds suffix
  ///
  /// In en, this message translates to:
  /// **'s'**
  String get timerSecondsSuffix;

  /// Hours unit
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get hours;

  /// Minutes unit
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutes;

  /// Seconds unit
  ///
  /// In en, this message translates to:
  /// **'sec'**
  String get seconds;

  /// Session completed status
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get sessionCompleted;

  /// Session cancelled status
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get sessionCancelled;

  /// Session timeout status
  ///
  /// In en, this message translates to:
  /// **'Timeout'**
  String get sessionTimeout;

  /// Session failed status
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get sessionFailed;

  /// Perfect score label
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get perfectScore;

  /// Today date label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Yesterday date label
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// Days ago label
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No sessions yet empty state title
  ///
  /// In en, this message translates to:
  /// **'No quiz sessions yet'**
  String get noSessionsYet;

  /// No sessions yet empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Start playing to see your history here'**
  String get startPlayingToSee;

  /// Session details screen title
  ///
  /// In en, this message translates to:
  /// **'Session Details'**
  String get sessionDetails;

  /// Review answers section title
  ///
  /// In en, this message translates to:
  /// **'Review Answers'**
  String get reviewAnswers;

  /// Question number label
  ///
  /// In en, this message translates to:
  /// **'Question {number}'**
  String questionNumber(int number);

  /// Your answer label
  ///
  /// In en, this message translates to:
  /// **'Your answer'**
  String get yourAnswer;

  /// Correct answer label (for review)
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get correctAnswer;

  /// Skipped question label
  ///
  /// In en, this message translates to:
  /// **'Skipped'**
  String get skipped;

  /// Practice wrong answers button
  ///
  /// In en, this message translates to:
  /// **'Practice Wrong Answers'**
  String get practiceWrongAnswers;

  /// Total sessions stat label
  ///
  /// In en, this message translates to:
  /// **'Total Sessions'**
  String get totalSessions;

  /// Total questions stat label
  ///
  /// In en, this message translates to:
  /// **'Total Questions'**
  String get totalQuestions;

  /// Average score stat label
  ///
  /// In en, this message translates to:
  /// **'Average Score'**
  String get averageScore;

  /// Best score stat label
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get bestScore;

  /// Accuracy stat label
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// Time played stat label
  ///
  /// In en, this message translates to:
  /// **'Time Played'**
  String get timePlayed;

  /// Perfect scores count label
  ///
  /// In en, this message translates to:
  /// **'Perfect Scores'**
  String get perfectScores;

  /// Current streak label
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// Best streak label
  ///
  /// In en, this message translates to:
  /// **'Best Streak'**
  String get bestStreak;

  /// Weekly trend section title
  ///
  /// In en, this message translates to:
  /// **'Weekly Trend'**
  String get weeklyTrend;

  /// Improving trend label
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get improving;

  /// Declining trend label
  ///
  /// In en, this message translates to:
  /// **'Declining'**
  String get declining;

  /// Stable trend label
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// No statistics yet empty state title
  ///
  /// In en, this message translates to:
  /// **'No statistics yet'**
  String get noStatisticsYet;

  /// No statistics yet empty state subtitle
  ///
  /// In en, this message translates to:
  /// **'Play some quizzes to see your statistics'**
  String get playQuizzesToSee;

  /// Overview section title
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Insights section title
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Days unit
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// Audio & Haptics section header
  ///
  /// In en, this message translates to:
  /// **'Audio & Haptics'**
  String get audioAndHaptics;

  /// Sound effects toggle title
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get soundEffects;

  /// Sound effects description
  ///
  /// In en, this message translates to:
  /// **'Play sounds for answers and interactions'**
  String get soundEffectsDescription;

  /// Background music toggle title
  ///
  /// In en, this message translates to:
  /// **'Background Music'**
  String get backgroundMusic;

  /// Background music description
  ///
  /// In en, this message translates to:
  /// **'Play background music during quiz'**
  String get backgroundMusicDescription;

  /// Haptic feedback toggle title
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Haptic feedback description
  ///
  /// In en, this message translates to:
  /// **'Vibrate on button presses and answers'**
  String get hapticFeedbackDescription;

  /// Quiz behavior section header
  ///
  /// In en, this message translates to:
  /// **'Quiz Behavior'**
  String get quizBehavior;

  /// Show answer feedback toggle title
  ///
  /// In en, this message translates to:
  /// **'Show Answer Feedback'**
  String get showAnswerFeedback;

  /// Show answer feedback description
  ///
  /// In en, this message translates to:
  /// **'Display animations when answering'**
  String get showAnswerFeedbackDescription;

  /// Appearance section header
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// Theme setting title
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// Theme selection dialog title
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// About section header
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Version label
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Build label
  ///
  /// In en, this message translates to:
  /// **'Build'**
  String get build;

  /// About this app menu item
  ///
  /// In en, this message translates to:
  /// **'About This App'**
  String get aboutThisApp;

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms of service menu item
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// Open source licenses menu item
  ///
  /// In en, this message translates to:
  /// **'Open Source Licenses'**
  String get openSourceLicenses;

  /// Advanced section header
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get advanced;

  /// Reset to defaults menu item
  ///
  /// In en, this message translates to:
  /// **'Reset to Defaults'**
  String get resetToDefaults;

  /// Reset to defaults description
  ///
  /// In en, this message translates to:
  /// **'Restore all settings to default values'**
  String get resetToDefaultsDescription;

  /// Reset settings dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset Settings'**
  String get resetSettings;

  /// Reset settings dialog message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to reset all settings to their default values? This cannot be undone.'**
  String get resetSettingsMessage;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Reset button
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Share button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// View all button
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// Credits section title
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get credits;

  /// Attributions section title
  ///
  /// In en, this message translates to:
  /// **'Attributions'**
  String get attributions;

  /// Export session button
  ///
  /// In en, this message translates to:
  /// **'Export Session'**
  String get exportSession;

  /// Export as JSON option
  ///
  /// In en, this message translates to:
  /// **'Export as JSON'**
  String get exportAsJson;

  /// Export as CSV option
  ///
  /// In en, this message translates to:
  /// **'Export as CSV'**
  String get exportAsCsv;

  /// Export success message
  ///
  /// In en, this message translates to:
  /// **'Session exported successfully'**
  String get exportSuccess;

  /// Export error message
  ///
  /// In en, this message translates to:
  /// **'Failed to export session'**
  String get exportError;

  /// Delete session dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Session'**
  String get deleteSession;

  /// Delete session confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this session? This cannot be undone.'**
  String get deleteSessionMessage;

  /// Session deleted success message
  ///
  /// In en, this message translates to:
  /// **'Session deleted'**
  String get sessionDeleted;

  /// Recent sessions section title
  ///
  /// In en, this message translates to:
  /// **'Recent Sessions'**
  String get recentSessions;

  /// Settings reset confirmation message
  ///
  /// In en, this message translates to:
  /// **'Settings reset to defaults'**
  String get settingsResetToDefaults;

  /// Could not open URL error
  ///
  /// In en, this message translates to:
  /// **'Could not open {url}'**
  String couldNotOpenUrl(String url);

  /// Game over screen title showing the user's score
  ///
  /// In en, this message translates to:
  /// **'Your Score'**
  String get gameOverText;

  /// Displayed when there is no data to show
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// Error message shown during app initialization
  ///
  /// In en, this message translates to:
  /// **'Initialization error: {error}'**
  String initializationError(String error);

  /// Title shown when quiz is finished
  ///
  /// In en, this message translates to:
  /// **'Quiz Complete!'**
  String get quizComplete;

  /// Message for 5 stars (100%)
  ///
  /// In en, this message translates to:
  /// **'Excellent!'**
  String get excellent;

  /// Message for 4 stars (80-99%)
  ///
  /// In en, this message translates to:
  /// **'Great Job!'**
  String get greatJob;

  /// Message for 3 stars (60-79%)
  ///
  /// In en, this message translates to:
  /// **'Good Work!'**
  String get goodWork;

  /// Message for 2 stars (40-59%)
  ///
  /// In en, this message translates to:
  /// **'Keep Practicing!'**
  String get keepPracticing;

  /// Message for 0-1 stars (0-39%)
  ///
  /// In en, this message translates to:
  /// **'Try Again!'**
  String get tryAgain;

  /// Button to review the completed session
  ///
  /// In en, this message translates to:
  /// **'Review This Session'**
  String get reviewThisSession;

  /// Button to review only wrong answers
  ///
  /// In en, this message translates to:
  /// **'Review Wrong Answers'**
  String get reviewWrongAnswers;

  /// Done button to return home
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Button to play the quiz again
  ///
  /// In en, this message translates to:
  /// **'Play Again'**
  String get playAgain;

  /// Score display format
  ///
  /// In en, this message translates to:
  /// **'{correct} of {total}'**
  String scoreOf(int correct, int total);

  /// Timed out questions label
  ///
  /// In en, this message translates to:
  /// **'Timed Out'**
  String get timedOut;

  /// Hints used label
  ///
  /// In en, this message translates to:
  /// **'Hints Used'**
  String get hintsUsed;

  /// Coming soon label for disabled features
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// Category breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Category Breakdown'**
  String get categoryBreakdown;

  /// Empty state for category statistics
  ///
  /// In en, this message translates to:
  /// **'No category data yet. Play some quizzes!'**
  String get noCategoryData;

  /// Sessions count label
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 session} other{{count} sessions}}'**
  String sessionsCount(int count);

  /// Empty state for progress chart
  ///
  /// In en, this message translates to:
  /// **'No progress data yet'**
  String get noProgressData;

  /// Progress summary section title
  ///
  /// In en, this message translates to:
  /// **'Progress Summary'**
  String get progressSummary;

  /// Change label for progress
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// Last week time range
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get lastWeek;

  /// Last month time range
  ///
  /// In en, this message translates to:
  /// **'Month'**
  String get lastMonth;

  /// Last 3 months time range
  ///
  /// In en, this message translates to:
  /// **'3 Months'**
  String get last3Months;

  /// Last year time range
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get lastYear;

  /// All time range
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Best scores leaderboard title
  ///
  /// In en, this message translates to:
  /// **'Best Scores'**
  String get bestScores;

  /// Fastest perfect scores leaderboard title
  ///
  /// In en, this message translates to:
  /// **'Fastest Perfect'**
  String get fastestPerfect;

  /// Most played leaderboard title
  ///
  /// In en, this message translates to:
  /// **'Most Played'**
  String get mostPlayed;

  /// Best streaks leaderboard title
  ///
  /// In en, this message translates to:
  /// **'Best Streaks'**
  String get bestStreaks;

  /// Empty state for leaderboard
  ///
  /// In en, this message translates to:
  /// **'No leaderboard entries yet. Complete some quizzes to see your best scores!'**
  String get noLeaderboardData;

  /// Progress tab label
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// Categories tab label
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// Leaderboard tab label
  ///
  /// In en, this message translates to:
  /// **'Leaderboard'**
  String get leaderboard;

  /// Score over time chart title
  ///
  /// In en, this message translates to:
  /// **'Score Over Time'**
  String get scoreOverTime;

  /// Last 7 days subtitle
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get last7Days;

  /// Last 30 days subtitle
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get last30Days;

  /// Last 90 days subtitle
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get last90Days;

  /// Last 365 days subtitle
  ///
  /// In en, this message translates to:
  /// **'Last 365 days'**
  String get last365Days;

  /// All time data subtitle
  ///
  /// In en, this message translates to:
  /// **'All time data'**
  String get allTimeData;

  /// Highest score label
  ///
  /// In en, this message translates to:
  /// **'Highest'**
  String get highestScore;

  /// Lowest score label
  ///
  /// In en, this message translates to:
  /// **'Lowest'**
  String get lowestScore;

  /// Empty state title when no wrong answers available
  ///
  /// In en, this message translates to:
  /// **'No wrong answers to practice'**
  String get noPracticeItems;

  /// Empty state description when no wrong answers available
  ///
  /// In en, this message translates to:
  /// **'Complete some quizzes and any wrong answers will appear here for practice'**
  String get noPracticeItemsDescription;

  /// Practice tab label
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practice;
}

class _QuizEngineLocalizationsDelegate
    extends LocalizationsDelegate<QuizEngineLocalizations> {
  const _QuizEngineLocalizationsDelegate();

  @override
  Future<QuizEngineLocalizations> load(Locale locale) {
    return SynchronousFuture<QuizEngineLocalizations>(
      lookupQuizEngineLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_QuizEngineLocalizationsDelegate old) => false;
}

QuizEngineLocalizations lookupQuizEngineLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return QuizEngineLocalizationsEn();
  }

  throw FlutterError(
    'QuizEngineLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
