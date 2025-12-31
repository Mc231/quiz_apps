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

  /// Retry button label
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Generic error title
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get errorTitle;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get errorGeneric;

  /// Network error message
  ///
  /// In en, this message translates to:
  /// **'Unable to connect. Please check your connection.'**
  String get errorNetwork;

  /// Server error message
  ///
  /// In en, this message translates to:
  /// **'Something went wrong on our end. Please try again later.'**
  String get errorServer;

  /// Generic loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingData;

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

  /// Global leaderboard title
  ///
  /// In en, this message translates to:
  /// **'Global Leaderboard'**
  String get globalLeaderboard;

  /// Global leaderboard coming soon description
  ///
  /// In en, this message translates to:
  /// **'Compete with players worldwide'**
  String get globalLeaderboardComingSoon;

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

  /// Challenges tab label
  ///
  /// In en, this message translates to:
  /// **'Challenges'**
  String get challenges;

  /// Achievements tab/screen title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Achievement unlocked notification title
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked!'**
  String get achievementUnlocked;

  /// Achievements progress display
  ///
  /// In en, this message translates to:
  /// **'{count} of {total} Unlocked'**
  String achievementsUnlocked(int count, int total);

  /// Achievement points display
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String achievementPoints(int points);

  /// Hidden achievement placeholder name
  ///
  /// In en, this message translates to:
  /// **'Hidden Achievement'**
  String get hiddenAchievement;

  /// Hidden achievement placeholder description
  ///
  /// In en, this message translates to:
  /// **'Keep playing to discover!'**
  String get hiddenAchievementDesc;

  /// Achievement name: first_quiz
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get achievementFirstQuiz;

  /// Achievement description: first_quiz
  ///
  /// In en, this message translates to:
  /// **'Complete your first quiz'**
  String get achievementFirstQuizDesc;

  /// Achievement name: first_perfect
  ///
  /// In en, this message translates to:
  /// **'Perfectionist'**
  String get achievementFirstPerfect;

  /// Achievement description: first_perfect
  ///
  /// In en, this message translates to:
  /// **'Get your first perfect score'**
  String get achievementFirstPerfectDesc;

  /// Achievement name: first_challenge
  ///
  /// In en, this message translates to:
  /// **'Challenger'**
  String get achievementFirstChallenge;

  /// Achievement description: first_challenge
  ///
  /// In en, this message translates to:
  /// **'Complete your first challenge mode'**
  String get achievementFirstChallengeDesc;

  /// Achievement name: quizzes_10
  ///
  /// In en, this message translates to:
  /// **'Getting Started'**
  String get achievementQuizzes10;

  /// Achievement description: quizzes_10
  ///
  /// In en, this message translates to:
  /// **'Complete 10 quizzes'**
  String get achievementQuizzes10Desc;

  /// Achievement name: quizzes_50
  ///
  /// In en, this message translates to:
  /// **'Quiz Enthusiast'**
  String get achievementQuizzes50;

  /// Achievement description: quizzes_50
  ///
  /// In en, this message translates to:
  /// **'Complete 50 quizzes'**
  String get achievementQuizzes50Desc;

  /// Achievement name: quizzes_100
  ///
  /// In en, this message translates to:
  /// **'Quiz Master'**
  String get achievementQuizzes100;

  /// Achievement description: quizzes_100
  ///
  /// In en, this message translates to:
  /// **'Complete 100 quizzes'**
  String get achievementQuizzes100Desc;

  /// Achievement name: quizzes_500
  ///
  /// In en, this message translates to:
  /// **'Quiz Legend'**
  String get achievementQuizzes500;

  /// Achievement description: quizzes_500
  ///
  /// In en, this message translates to:
  /// **'Complete 500 quizzes'**
  String get achievementQuizzes500Desc;

  /// Achievement name: questions_100
  ///
  /// In en, this message translates to:
  /// **'Century'**
  String get achievementQuestions100;

  /// Achievement description: questions_100
  ///
  /// In en, this message translates to:
  /// **'Answer 100 questions'**
  String get achievementQuestions100Desc;

  /// Achievement name: questions_500
  ///
  /// In en, this message translates to:
  /// **'Half Thousand'**
  String get achievementQuestions500;

  /// Achievement description: questions_500
  ///
  /// In en, this message translates to:
  /// **'Answer 500 questions'**
  String get achievementQuestions500Desc;

  /// Achievement name: questions_1000
  ///
  /// In en, this message translates to:
  /// **'Thousand Club'**
  String get achievementQuestions1000;

  /// Achievement description: questions_1000
  ///
  /// In en, this message translates to:
  /// **'Answer 1000 questions'**
  String get achievementQuestions1000Desc;

  /// Achievement name: questions_5000
  ///
  /// In en, this message translates to:
  /// **'Expert'**
  String get achievementQuestions5000;

  /// Achievement description: questions_5000
  ///
  /// In en, this message translates to:
  /// **'Answer 5000 questions'**
  String get achievementQuestions5000Desc;

  /// Achievement name: correct_100
  ///
  /// In en, this message translates to:
  /// **'Sharp Eye'**
  String get achievementCorrect100;

  /// Achievement description: correct_100
  ///
  /// In en, this message translates to:
  /// **'Get 100 correct answers'**
  String get achievementCorrect100Desc;

  /// Achievement name: correct_500
  ///
  /// In en, this message translates to:
  /// **'Knowledge Keeper'**
  String get achievementCorrect500;

  /// Achievement description: correct_500
  ///
  /// In en, this message translates to:
  /// **'Get 500 correct answers'**
  String get achievementCorrect500Desc;

  /// Achievement name: correct_1000
  ///
  /// In en, this message translates to:
  /// **'Scholar'**
  String get achievementCorrect1000;

  /// Achievement description: correct_1000
  ///
  /// In en, this message translates to:
  /// **'Get 1000 correct answers'**
  String get achievementCorrect1000Desc;

  /// Achievement name: perfect_5
  ///
  /// In en, this message translates to:
  /// **'Rising Star'**
  String get achievementPerfect5;

  /// Achievement description: perfect_5
  ///
  /// In en, this message translates to:
  /// **'Get 5 perfect scores'**
  String get achievementPerfect5Desc;

  /// Achievement name: perfect_10
  ///
  /// In en, this message translates to:
  /// **'Shining Bright'**
  String get achievementPerfect10;

  /// Achievement description: perfect_10
  ///
  /// In en, this message translates to:
  /// **'Get 10 perfect scores'**
  String get achievementPerfect10Desc;

  /// Achievement name: perfect_25
  ///
  /// In en, this message translates to:
  /// **'Constellation'**
  String get achievementPerfect25;

  /// Achievement description: perfect_25
  ///
  /// In en, this message translates to:
  /// **'Get 25 perfect scores'**
  String get achievementPerfect25Desc;

  /// Achievement name: perfect_50
  ///
  /// In en, this message translates to:
  /// **'Galaxy'**
  String get achievementPerfect50;

  /// Achievement description: perfect_50
  ///
  /// In en, this message translates to:
  /// **'Get 50 perfect scores'**
  String get achievementPerfect50Desc;

  /// Achievement name: score_90_10
  ///
  /// In en, this message translates to:
  /// **'High Achiever'**
  String get achievementScore9010;

  /// Achievement description: score_90_10
  ///
  /// In en, this message translates to:
  /// **'Score 90%+ in 10 quizzes'**
  String get achievementScore9010Desc;

  /// Achievement name: score_95_10
  ///
  /// In en, this message translates to:
  /// **'Excellence'**
  String get achievementScore9510;

  /// Achievement description: score_95_10
  ///
  /// In en, this message translates to:
  /// **'Score 95%+ in 10 quizzes'**
  String get achievementScore9510Desc;

  /// Achievement name: perfect_streak_3
  ///
  /// In en, this message translates to:
  /// **'Flawless Run'**
  String get achievementPerfectStreak3;

  /// Achievement description: perfect_streak_3
  ///
  /// In en, this message translates to:
  /// **'Get 3 perfect scores in a row'**
  String get achievementPerfectStreak3Desc;

  /// Achievement name: speed_demon
  ///
  /// In en, this message translates to:
  /// **'Speed Demon'**
  String get achievementSpeedDemon;

  /// Achievement description: speed_demon
  ///
  /// In en, this message translates to:
  /// **'Complete a quiz in under 60 seconds'**
  String get achievementSpeedDemonDesc;

  /// Achievement name: lightning
  ///
  /// In en, this message translates to:
  /// **'Lightning Fast'**
  String get achievementLightning;

  /// Achievement description: lightning
  ///
  /// In en, this message translates to:
  /// **'Complete a quiz in under 30 seconds'**
  String get achievementLightningDesc;

  /// Achievement name: quick_answer_10
  ///
  /// In en, this message translates to:
  /// **'Quick Thinker'**
  String get achievementQuickAnswer10;

  /// Achievement description: quick_answer_10
  ///
  /// In en, this message translates to:
  /// **'Answer 10 questions in under 2 seconds each'**
  String get achievementQuickAnswer10Desc;

  /// Achievement name: quick_answer_50
  ///
  /// In en, this message translates to:
  /// **'Rapid Fire'**
  String get achievementQuickAnswer50;

  /// Achievement description: quick_answer_50
  ///
  /// In en, this message translates to:
  /// **'Answer 50 questions in under 2 seconds each'**
  String get achievementQuickAnswer50Desc;

  /// Achievement name: streak_10
  ///
  /// In en, this message translates to:
  /// **'On Fire'**
  String get achievementStreak10;

  /// Achievement description: streak_10
  ///
  /// In en, this message translates to:
  /// **'Get 10 correct answers in a row'**
  String get achievementStreak10Desc;

  /// Achievement name: streak_25
  ///
  /// In en, this message translates to:
  /// **'Unstoppable'**
  String get achievementStreak25;

  /// Achievement description: streak_25
  ///
  /// In en, this message translates to:
  /// **'Get 25 correct answers in a row'**
  String get achievementStreak25Desc;

  /// Achievement name: streak_50
  ///
  /// In en, this message translates to:
  /// **'Legendary Streak'**
  String get achievementStreak50;

  /// Achievement description: streak_50
  ///
  /// In en, this message translates to:
  /// **'Get 50 correct answers in a row'**
  String get achievementStreak50Desc;

  /// Achievement name: streak_100
  ///
  /// In en, this message translates to:
  /// **'Mythical'**
  String get achievementStreak100;

  /// Achievement description: streak_100
  ///
  /// In en, this message translates to:
  /// **'Get 100 correct answers in a row'**
  String get achievementStreak100Desc;

  /// Achievement name: survival_complete
  ///
  /// In en, this message translates to:
  /// **'Survivor'**
  String get achievementSurvivalComplete;

  /// Achievement description: survival_complete
  ///
  /// In en, this message translates to:
  /// **'Complete Survival mode'**
  String get achievementSurvivalCompleteDesc;

  /// Achievement name: survival_perfect
  ///
  /// In en, this message translates to:
  /// **'Immortal'**
  String get achievementSurvivalPerfect;

  /// Achievement description: survival_perfect
  ///
  /// In en, this message translates to:
  /// **'Complete Survival without losing a life'**
  String get achievementSurvivalPerfectDesc;

  /// Achievement name: blitz_complete
  ///
  /// In en, this message translates to:
  /// **'Blitz Master'**
  String get achievementBlitzComplete;

  /// Achievement description: blitz_complete
  ///
  /// In en, this message translates to:
  /// **'Complete Blitz mode'**
  String get achievementBlitzCompleteDesc;

  /// Achievement name: blitz_perfect
  ///
  /// In en, this message translates to:
  /// **'Lightning God'**
  String get achievementBlitzPerfect;

  /// Achievement description: blitz_perfect
  ///
  /// In en, this message translates to:
  /// **'Complete Blitz with perfect score'**
  String get achievementBlitzPerfectDesc;

  /// Achievement name: time_attack_20
  ///
  /// In en, this message translates to:
  /// **'Time Warrior'**
  String get achievementTimeAttack20;

  /// Achievement description: time_attack_20
  ///
  /// In en, this message translates to:
  /// **'Answer 20+ correct in Time Attack'**
  String get achievementTimeAttack20Desc;

  /// Achievement name: time_attack_30
  ///
  /// In en, this message translates to:
  /// **'Time Lord'**
  String get achievementTimeAttack30;

  /// Achievement description: time_attack_30
  ///
  /// In en, this message translates to:
  /// **'Answer 30+ correct in Time Attack'**
  String get achievementTimeAttack30Desc;

  /// Achievement name: marathon_50
  ///
  /// In en, this message translates to:
  /// **'Endurance'**
  String get achievementMarathon50;

  /// Achievement description: marathon_50
  ///
  /// In en, this message translates to:
  /// **'Answer 50 questions in Marathon'**
  String get achievementMarathon50Desc;

  /// Achievement name: marathon_100
  ///
  /// In en, this message translates to:
  /// **'Ultra Marathon'**
  String get achievementMarathon100;

  /// Achievement description: marathon_100
  ///
  /// In en, this message translates to:
  /// **'Answer 100 questions in Marathon'**
  String get achievementMarathon100Desc;

  /// Achievement name: speed_run_fast
  ///
  /// In en, this message translates to:
  /// **'Speed Runner'**
  String get achievementSpeedRunFast;

  /// Achievement description: speed_run_fast
  ///
  /// In en, this message translates to:
  /// **'Complete Speed Run in under 2 minutes'**
  String get achievementSpeedRunFastDesc;

  /// Achievement name: all_challenges
  ///
  /// In en, this message translates to:
  /// **'Challenge Champion'**
  String get achievementAllChallenges;

  /// Achievement description: all_challenges
  ///
  /// In en, this message translates to:
  /// **'Complete all challenge modes'**
  String get achievementAllChallengesDesc;

  /// Achievement name: time_1h
  ///
  /// In en, this message translates to:
  /// **'Dedicated'**
  String get achievementTime1h;

  /// Achievement description: time_1h
  ///
  /// In en, this message translates to:
  /// **'Play for 1 hour total'**
  String get achievementTime1hDesc;

  /// Achievement name: time_5h
  ///
  /// In en, this message translates to:
  /// **'Committed'**
  String get achievementTime5h;

  /// Achievement description: time_5h
  ///
  /// In en, this message translates to:
  /// **'Play for 5 hours total'**
  String get achievementTime5hDesc;

  /// Achievement name: time_10h
  ///
  /// In en, this message translates to:
  /// **'Devoted'**
  String get achievementTime10h;

  /// Achievement description: time_10h
  ///
  /// In en, this message translates to:
  /// **'Play for 10 hours total'**
  String get achievementTime10hDesc;

  /// Achievement name: time_24h
  ///
  /// In en, this message translates to:
  /// **'Fanatic'**
  String get achievementTime24h;

  /// Achievement description: time_24h
  ///
  /// In en, this message translates to:
  /// **'Play for 24 hours total'**
  String get achievementTime24hDesc;

  /// Achievement name: days_3
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get achievementDays3;

  /// Achievement description: days_3
  ///
  /// In en, this message translates to:
  /// **'Play 3 days in a row'**
  String get achievementDays3Desc;

  /// Achievement name: days_7
  ///
  /// In en, this message translates to:
  /// **'Weekly Warrior'**
  String get achievementDays7;

  /// Achievement description: days_7
  ///
  /// In en, this message translates to:
  /// **'Play 7 days in a row'**
  String get achievementDays7Desc;

  /// Achievement name: days_14
  ///
  /// In en, this message translates to:
  /// **'Two Week Streak'**
  String get achievementDays14;

  /// Achievement description: days_14
  ///
  /// In en, this message translates to:
  /// **'Play 14 days in a row'**
  String get achievementDays14Desc;

  /// Achievement name: days_30
  ///
  /// In en, this message translates to:
  /// **'Monthly Master'**
  String get achievementDays30;

  /// Achievement description: days_30
  ///
  /// In en, this message translates to:
  /// **'Play 30 days in a row'**
  String get achievementDays30Desc;

  /// Achievement name: no_hints
  ///
  /// In en, this message translates to:
  /// **'Purist'**
  String get achievementNoHints;

  /// Achievement description: no_hints
  ///
  /// In en, this message translates to:
  /// **'Complete a quiz without using hints'**
  String get achievementNoHintsDesc;

  /// Achievement name: no_hints_10
  ///
  /// In en, this message translates to:
  /// **'True Expert'**
  String get achievementNoHints10;

  /// Achievement description: no_hints_10
  ///
  /// In en, this message translates to:
  /// **'Complete 10 quizzes without hints'**
  String get achievementNoHints10Desc;

  /// Achievement name: no_skip
  ///
  /// In en, this message translates to:
  /// **'Determined'**
  String get achievementNoSkip;

  /// Achievement description: no_skip
  ///
  /// In en, this message translates to:
  /// **'Complete a quiz without skipping'**
  String get achievementNoSkipDesc;

  /// Achievement name: flawless
  ///
  /// In en, this message translates to:
  /// **'Flawless Victory'**
  String get achievementFlawless;

  /// Achievement description: flawless
  ///
  /// In en, this message translates to:
  /// **'Perfect score, no hints, no lives lost'**
  String get achievementFlawlessDesc;

  /// Achievement name: comeback
  ///
  /// In en, this message translates to:
  /// **'Comeback King'**
  String get achievementComeback;

  /// Achievement description: comeback
  ///
  /// In en, this message translates to:
  /// **'Win after losing 4+ lives'**
  String get achievementComebackDesc;

  /// Achievement name: clutch
  ///
  /// In en, this message translates to:
  /// **'Clutch Player'**
  String get achievementClutch;

  /// Achievement description: clutch
  ///
  /// In en, this message translates to:
  /// **'Answer 15+ questions correctly in Survival'**
  String get achievementClutchDesc;

  /// Empty state when no achievements match filter
  ///
  /// In en, this message translates to:
  /// **'No achievements found'**
  String get noAchievementsFound;

  /// Hint when no achievements match filter
  ///
  /// In en, this message translates to:
  /// **'Try changing the filter'**
  String get tryChangingFilter;

  /// Empty state for category with no achievements
  ///
  /// In en, this message translates to:
  /// **'No achievements in this category'**
  String get noAchievementsInCategory;

  /// Category name for uncategorized achievements
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherAchievements;

  /// Filter option: show all achievements
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Filter option: show unlocked achievements
  ///
  /// In en, this message translates to:
  /// **'Unlocked'**
  String get filterUnlocked;

  /// Filter option: show achievements with progress
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get filterInProgress;

  /// Filter option: show locked achievements
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get filterLocked;

  /// Filter option: show all achievement tiers
  ///
  /// In en, this message translates to:
  /// **'All Tiers'**
  String get allTiers;

  /// Achievement progress display
  ///
  /// In en, this message translates to:
  /// **'{current}/{target}'**
  String achievementProgress(int current, int target);

  /// Points remaining to earn
  ///
  /// In en, this message translates to:
  /// **'{points} remaining'**
  String pointsRemaining(int points);

  /// Message when all achievement points are earned
  ///
  /// In en, this message translates to:
  /// **'All earned!'**
  String get allPointsEarned;

  /// Completion percentage display
  ///
  /// In en, this message translates to:
  /// **'{percent}%'**
  String completionPercentage(int percent);

  /// Accessibility hint for tappable items
  ///
  /// In en, this message translates to:
  /// **'Double tap to view details'**
  String get accessibilityDoubleTapToView;

  /// Accessibility hint for dismissable notifications
  ///
  /// In en, this message translates to:
  /// **'Double tap to dismiss'**
  String get accessibilityDoubleTapToDismiss;

  /// Accessibility label for unlocked achievement
  ///
  /// In en, this message translates to:
  /// **'{name}, {tier} achievement, {points} points, unlocked'**
  String accessibilityAchievementUnlocked(String name, String tier, int points);

  /// Accessibility label for locked achievement with progress
  ///
  /// In en, this message translates to:
  /// **'{name}, {tier} achievement, {points} points, locked, {progress} percent complete'**
  String accessibilityAchievementLocked(
    String name,
    String tier,
    int points,
    int progress,
  );

  /// Accessibility label for achievement notification
  ///
  /// In en, this message translates to:
  /// **'Achievement unlocked: {name}, {tier}, plus {points} points'**
  String accessibilityAchievementNotification(
    String name,
    String tier,
    int points,
  );

  /// Accessibility label for progress bar
  ///
  /// In en, this message translates to:
  /// **'Progress: {current} of {target}'**
  String accessibilityProgressBar(int current, int target);

  /// Accessibility label for tier badge
  ///
  /// In en, this message translates to:
  /// **'{tier} tier'**
  String accessibilityTierBadge(String tier);

  /// Accessibility label for points badge
  ///
  /// In en, this message translates to:
  /// **'{points} points'**
  String accessibilityPointsBadge(int points);

  /// Practice mode label
  ///
  /// In en, this message translates to:
  /// **'Practice'**
  String get practiceMode;

  /// Title when there are no practice questions
  ///
  /// In en, this message translates to:
  /// **'No questions to practice'**
  String get practiceEmptyTitle;

  /// Message when there are no practice questions
  ///
  /// In en, this message translates to:
  /// **'Great job! You\'ve mastered all the questions you got wrong. Keep playing to challenge yourself!'**
  String get practiceEmptyMessage;

  /// Button to start a quiz from empty practice state
  ///
  /// In en, this message translates to:
  /// **'Start a Quiz'**
  String get practiceStartQuiz;

  /// Practice start screen title
  ///
  /// In en, this message translates to:
  /// **'Practice Mode'**
  String get practiceStartTitle;

  /// Number of questions to practice
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 question to practice} other{{count} questions to practice}}'**
  String practiceQuestionCount(int count);

  /// Description on practice start screen
  ///
  /// In en, this message translates to:
  /// **'These are questions you\'ve answered incorrectly before.'**
  String get practiceDescription;

  /// Button to start practice session
  ///
  /// In en, this message translates to:
  /// **'Start Practice'**
  String get startPractice;

  /// Title when practice session is complete
  ///
  /// In en, this message translates to:
  /// **'Practice Complete!'**
  String get practiceCompleteTitle;

  /// Number of correct answers in practice
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 correct} other{{count} correct}}'**
  String practiceCorrectCount(int count);

  /// Number of questions needing more practice
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 needs more practice} other{{count} need more practice}}'**
  String practiceNeedMorePractice(int count);

  /// Encouragement message after practice
  ///
  /// In en, this message translates to:
  /// **'Keep practicing to master all the questions!'**
  String get practiceKeepGoing;

  /// Message when all practice answers are correct
  ///
  /// In en, this message translates to:
  /// **'Perfect! You\'ve mastered all the questions!'**
  String get practiceAllCorrect;

  /// Button to finish practice
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get practiceDone;

  /// How many times a question was answered incorrectly
  ///
  /// In en, this message translates to:
  /// **'Wrong {count, plural, =1{1 time} other{{count} times}}'**
  String wrongCount(int count);

  /// Points abbreviation label
  ///
  /// In en, this message translates to:
  /// **'pts'**
  String get pointsLabel;

  /// Total score label
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get totalScore;

  /// Base points label in score breakdown
  ///
  /// In en, this message translates to:
  /// **'Base Points'**
  String get basePoints;

  /// Time bonus label in score breakdown
  ///
  /// In en, this message translates to:
  /// **'Time Bonus'**
  String get timeBonus;

  /// Streak bonus label in score breakdown
  ///
  /// In en, this message translates to:
  /// **'Streak Bonus'**
  String get streakBonus;

  /// Generic bonus label
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get bonus;

  /// Score breakdown section title
  ///
  /// In en, this message translates to:
  /// **'Score Breakdown'**
  String get scoreBreakdown;

  /// Points earned display
  ///
  /// In en, this message translates to:
  /// **'{points} pts'**
  String pointsEarned(int points);

  /// Score plus bonus display
  ///
  /// In en, this message translates to:
  /// **'{base} + {bonus} bonus'**
  String scorePlusBonus(int base, int bonus);

  /// Lives resource label
  ///
  /// In en, this message translates to:
  /// **'Lives'**
  String get livesLabel;

  /// Lives tooltip explaining the resource
  ///
  /// In en, this message translates to:
  /// **'Lives remaining. Lose a life when you answer incorrectly.'**
  String get livesTooltip;

  /// Accessibility label for lives count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No lives remaining} =1{1 life remaining} other{{count} lives remaining}}'**
  String livesAccessibilityLabel(int count);

  /// 50/50 hint tooltip explaining the resource
  ///
  /// In en, this message translates to:
  /// **'50/50 hint. Eliminates two wrong answers.'**
  String get fiftyFiftyTooltip;

  /// Accessibility label for 50/50 count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No 50/50 hints remaining} =1{1 fifty-fifty hint remaining} other{{count} fifty-fifty hints remaining}}'**
  String fiftyFiftyAccessibilityLabel(int count);

  /// Skip hint tooltip explaining the resource
  ///
  /// In en, this message translates to:
  /// **'Skip hint. Skip this question without penalty.'**
  String get skipTooltip;

  /// Accessibility label for skip count
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No skip hints remaining} =1{1 skip hint remaining} other{{count} skip hints remaining}}'**
  String skipAccessibilityLabel(int count);

  /// Message when a resource is depleted
  ///
  /// In en, this message translates to:
  /// **'No more available'**
  String get resourceDepleted;

  /// Button/dialog title to get more lives
  ///
  /// In en, this message translates to:
  /// **'Get More Lives'**
  String get getMoreLives;

  /// Button/dialog title to get more hints
  ///
  /// In en, this message translates to:
  /// **'Get More Hints'**
  String get getMoreHints;

  /// Short label for 50/50 hint
  ///
  /// In en, this message translates to:
  /// **'50/50'**
  String get fiftyFiftyLabel;

  /// Short label for skip hint
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skipLabel;

  /// Dialog title when lives are depleted
  ///
  /// In en, this message translates to:
  /// **'Need More Lives?'**
  String get needMoreLives;

  /// Dialog title when hints are depleted
  ///
  /// In en, this message translates to:
  /// **'Need More Hints?'**
  String get needMoreHints;

  /// Dialog title when skips are depleted
  ///
  /// In en, this message translates to:
  /// **'Need More Skips?'**
  String get needMoreSkips;

  /// Resource count remaining
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{0 remaining} =1{1 remaining} other{{count} remaining}}'**
  String resourceRemaining(int count);

  /// Button to watch ad for resources
  ///
  /// In en, this message translates to:
  /// **'Watch Ad for +{count} {resource}'**
  String watchAdForResource(int count, String resource);

  /// Button to open purchase sheet
  ///
  /// In en, this message translates to:
  /// **'Buy {resource}...'**
  String buyResource(String resource);

  /// Button to dismiss restore dialog
  ///
  /// In en, this message translates to:
  /// **'No Thanks'**
  String get noThanks;

  /// Purchase sheet title for lives
  ///
  /// In en, this message translates to:
  /// **'Buy Lives'**
  String get buyLives;

  /// Purchase sheet title for hints
  ///
  /// In en, this message translates to:
  /// **'Buy Hints'**
  String get buyHints;

  /// Purchase sheet title for skips
  ///
  /// In en, this message translates to:
  /// **'Buy Skips'**
  String get buySkips;

  /// Badge for best value pack
  ///
  /// In en, this message translates to:
  /// **'Best Value'**
  String get bestValue;

  /// Button to restore previous purchases
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// Title when device is offline
  ///
  /// In en, this message translates to:
  /// **'No Connection'**
  String get noConnection;

  /// Message when offline and trying to restore
  ///
  /// In en, this message translates to:
  /// **'Connect to the internet to restore your resources.'**
  String get connectToRestore;

  /// OK button
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Success message after purchase
  ///
  /// In en, this message translates to:
  /// **'Purchase successful! +{count} {resource}'**
  String purchaseSuccess(int count, String resource);

  /// Error message when purchase fails
  ///
  /// In en, this message translates to:
  /// **'Purchase failed. Please try again.'**
  String get purchaseFailed;

  /// Message when user cancels purchase
  ///
  /// In en, this message translates to:
  /// **'Purchase cancelled.'**
  String get purchaseCancelled;

  /// Message when purchase is pending approval
  ///
  /// In en, this message translates to:
  /// **'Purchase pending. Please wait.'**
  String get purchasePending;

  /// Message when product is not available for purchase
  ///
  /// In en, this message translates to:
  /// **'This product is not available.'**
  String get purchaseNotAvailable;

  /// Message when user tries to buy an item they already own
  ///
  /// In en, this message translates to:
  /// **'You already own this item.'**
  String get purchaseAlreadyOwned;

  /// Message after restoring purchases
  ///
  /// In en, this message translates to:
  /// **'Purchases restored successfully.'**
  String get purchasesRestored;

  /// Success message after watching ad
  ///
  /// In en, this message translates to:
  /// **'+{count} {resource} added!'**
  String adWatchSuccess(int count, String resource);

  /// Message when no ad is available
  ///
  /// In en, this message translates to:
  /// **'Ad not available. Please try again later.'**
  String get adNotAvailable;

  /// Notification when daily limits reset
  ///
  /// In en, this message translates to:
  /// **'Daily resources reset!'**
  String get dailyLimitReset;

  /// Info about daily free resources
  ///
  /// In en, this message translates to:
  /// **'{count} free {resource} per day'**
  String freeResourcesInfo(int count, String resource);

  /// Accessibility label for category card button
  ///
  /// In en, this message translates to:
  /// **'{category} quiz category'**
  String accessibilityCategoryButton(String category);

  /// Accessibility label for category with question count
  ///
  /// In en, this message translates to:
  /// **'{category}, {count} questions'**
  String accessibilityCategoryWithQuestions(String category, int count);

  /// Accessibility hint for selectable items
  ///
  /// In en, this message translates to:
  /// **'Double tap to select'**
  String get accessibilityDoubleTapToSelect;

  /// Accessibility hint for start actions
  ///
  /// In en, this message translates to:
  /// **'Double tap to start'**
  String get accessibilityDoubleTapToStart;

  /// Accessibility label for challenge card
  ///
  /// In en, this message translates to:
  /// **'{name} challenge, {difficulty} difficulty'**
  String accessibilityChallengeButton(String name, String difficulty);

  /// Accessibility label for quiz answer option
  ///
  /// In en, this message translates to:
  /// **'Answer option: {answer}'**
  String accessibilityAnswerOption(String answer);

  /// Accessibility label for disabled answer option
  ///
  /// In en, this message translates to:
  /// **'Answer option {answer}, eliminated'**
  String accessibilityAnswerDisabled(String answer);

  /// Accessibility label for session card
  ///
  /// In en, this message translates to:
  /// **'Quiz session from {date}, score {score} out of {total}'**
  String accessibilitySessionCard(String date, int score, int total);

  /// Accessibility label for statistic value
  ///
  /// In en, this message translates to:
  /// **'{label}: {value}'**
  String accessibilityStatistic(String label, String value);

  /// Accessibility label for progress indicator
  ///
  /// In en, this message translates to:
  /// **'Progress: {percent} percent'**
  String accessibilityProgress(int percent);

  /// Accessibility label for lives count
  ///
  /// In en, this message translates to:
  /// **'{count} lives remaining'**
  String accessibilityLivesRemaining(int count);

  /// Accessibility label for hints count
  ///
  /// In en, this message translates to:
  /// **'{count} {type} hints remaining'**
  String accessibilityHintsRemaining(int count, String type);

  /// Accessibility label for timer
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds remaining'**
  String accessibilityTimer(int seconds);

  /// Accessibility announcement for correct answer
  ///
  /// In en, this message translates to:
  /// **'Correct answer'**
  String get accessibilityCorrectAnswer;

  /// Accessibility announcement for incorrect answer
  ///
  /// In en, this message translates to:
  /// **'Incorrect answer'**
  String get accessibilityIncorrectAnswer;

  /// Accessibility label for question progress
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String accessibilityQuestionNumber(int current, int total);

  /// Export data menu item title
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get exportData;

  /// Export data menu item subtitle
  ///
  /// In en, this message translates to:
  /// **'Download all your data (GDPR)'**
  String get exportDataDescription;

  /// Message explaining what data export does
  ///
  /// In en, this message translates to:
  /// **'Export all your data to a JSON file. This includes your complete quiz history, statistics, and settings.'**
  String get exportDataDialogMessage;

  /// Header for export includes list
  ///
  /// In en, this message translates to:
  /// **'This export includes:'**
  String get exportDataIncludes;

  /// Export includes quiz history
  ///
  /// In en, this message translates to:
  /// **'All quiz sessions and results'**
  String get exportIncludesQuizHistory;

  /// Export includes answers
  ///
  /// In en, this message translates to:
  /// **'Your answers to all questions'**
  String get exportIncludesAnswers;

  /// Export includes statistics
  ///
  /// In en, this message translates to:
  /// **'Performance statistics'**
  String get exportIncludesStatistics;

  /// Export includes settings
  ///
  /// In en, this message translates to:
  /// **'App preferences and settings'**
  String get exportIncludesSettings;

  /// Export button label
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get export;

  /// Subject line when sharing export file
  ///
  /// In en, this message translates to:
  /// **'My Quiz Data Export'**
  String get exportDataSubject;

  /// Success message after export
  ///
  /// In en, this message translates to:
  /// **'Successfully exported {count} items'**
  String exportDataSuccess(int count);

  /// Error message when export fails
  ///
  /// In en, this message translates to:
  /// **'Failed to export data. Please try again.'**
  String get exportDataError;

  /// Data & Privacy section header in settings
  ///
  /// In en, this message translates to:
  /// **'Data & Privacy'**
  String get dataAndPrivacy;

  /// Shop section header in settings
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// Remove ads purchase title
  ///
  /// In en, this message translates to:
  /// **'Remove Ads'**
  String get removeAds;

  /// Remove ads purchase description
  ///
  /// In en, this message translates to:
  /// **'Enjoy ad-free gameplay forever'**
  String get removeAdsDescription;

  /// Status when remove ads is already purchased
  ///
  /// In en, this message translates to:
  /// **'Ads Removed'**
  String get removeAdsPurchased;

  /// Description when remove ads is already purchased
  ///
  /// In en, this message translates to:
  /// **'Thank you for your purchase!'**
  String get removeAdsPurchasedDescription;

  /// Bundles subsection title
  ///
  /// In en, this message translates to:
  /// **'Bundles'**
  String get bundles;

  /// Starter bundle title
  ///
  /// In en, this message translates to:
  /// **'Starter Pack'**
  String get bundleStarterTitle;

  /// Starter bundle description
  ///
  /// In en, this message translates to:
  /// **'5 lives + 5 fifty-fifty + 5 skips'**
  String get bundleStarterDescription;

  /// Value bundle title
  ///
  /// In en, this message translates to:
  /// **'Value Pack'**
  String get bundleValueTitle;

  /// Value bundle description
  ///
  /// In en, this message translates to:
  /// **'15 lives + 15 fifty-fifty + 15 skips'**
  String get bundleValueDescription;

  /// Pro bundle title
  ///
  /// In en, this message translates to:
  /// **'Pro Pack'**
  String get bundleProTitle;

  /// Pro bundle description
  ///
  /// In en, this message translates to:
  /// **'50 lives + 50 fifty-fifty + 50 skips'**
  String get bundleProDescription;

  /// Loading state while purchasing
  ///
  /// In en, this message translates to:
  /// **'Purchasing...'**
  String get purchasing;

  /// Loading state while restoring purchases
  ///
  /// In en, this message translates to:
  /// **'Restoring...'**
  String get restoring;

  /// Restore purchases description
  ///
  /// In en, this message translates to:
  /// **'Restore previous purchases on this device'**
  String get restorePurchasesDescription;

  /// Message when store is not available
  ///
  /// In en, this message translates to:
  /// **'Store unavailable'**
  String get storeUnavailable;

  /// Description when store is unavailable
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to the store. Please check your connection.'**
  String get storeUnavailableDescription;

  /// Message when no purchases found to restore
  ///
  /// In en, this message translates to:
  /// **'No purchases to restore'**
  String get noPurchasesToRestore;

  /// Message showing number of purchases restored
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 purchase restored} other{{count} purchases restored}}'**
  String purchasesRestoredCount(int count);

  /// Buy button label
  ///
  /// In en, this message translates to:
  /// **'Buy'**
  String get buy;

  /// Status label for purchased items
  ///
  /// In en, this message translates to:
  /// **'Purchased'**
  String get purchased;

  /// Love dialog title asking if user enjoys the app
  ///
  /// In en, this message translates to:
  /// **'Are you enjoying {appName}?'**
  String rateAppLoveDialogTitle(String appName);

  /// Positive response button in love dialog
  ///
  /// In en, this message translates to:
  /// **'Yes!'**
  String get rateAppLoveDialogYes;

  /// Negative response button in love dialog
  ///
  /// In en, this message translates to:
  /// **'Not Really'**
  String get rateAppLoveDialogNo;

  /// Feedback dialog title
  ///
  /// In en, this message translates to:
  /// **'We\'d love to hear from you'**
  String get rateAppFeedbackTitle;

  /// Feedback dialog message
  ///
  /// In en, this message translates to:
  /// **'What could we do better?'**
  String get rateAppFeedbackMessage;

  /// Button to send feedback via email
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get rateAppFeedbackEmailButton;

  /// Button to dismiss feedback dialog
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get rateAppFeedbackDismiss;

  /// Thank you message after feedback
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get rateAppThankYou;

  /// Accessibility label for rate dialog
  ///
  /// In en, this message translates to:
  /// **'App rating dialog'**
  String get accessibilityRateDialogTitle;

  /// Accessibility label for feedback dialog
  ///
  /// In en, this message translates to:
  /// **'Feedback dialog'**
  String get accessibilityFeedbackDialogTitle;

  /// Accessibility label for image answer option
  ///
  /// In en, this message translates to:
  /// **'Image answer: {label}'**
  String accessibilityImageAnswer(String label);

  /// Accessibility label for disabled image answer option
  ///
  /// In en, this message translates to:
  /// **'Image answer {label}, eliminated'**
  String accessibilityImageAnswerDisabled(String label);

  /// Error message when image fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load image'**
  String get imageLoadError;

  /// Generic question template for reverse layout (text question, image answers)
  ///
  /// In en, this message translates to:
  /// **'Which one is {name}?'**
  String whichOneIs(String name);

  /// Alternative question template for reverse layout
  ///
  /// In en, this message translates to:
  /// **'Select the {name}'**
  String selectThe(String name);

  /// Label for standard layout (image question, text answers)
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get layoutStandard;

  /// Label for reverse layout (text question, image answers)
  ///
  /// In en, this message translates to:
  /// **'Reverse'**
  String get layoutReverse;

  /// Label for mixed layout (alternating between layouts)
  ///
  /// In en, this message translates to:
  /// **'Mixed'**
  String get layoutMixed;
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
