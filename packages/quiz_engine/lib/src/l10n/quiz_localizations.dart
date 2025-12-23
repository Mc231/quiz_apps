import 'package:flutter/widgets.dart';

import 'quiz_localizations_en.dart';

/// Abstract class defining all localized strings for the quiz engine.
///
/// Apps can either:
/// 1. Use the default English implementation via [QuizLocalizationsEn]
/// 2. Create custom implementations for other languages
/// 3. Use [QuizLocalizations.override] to customize specific strings
///
/// To access localizations in widgets:
/// ```dart
/// final l10n = QuizLocalizations.of(context);
/// Text(l10n.play);
/// ```
abstract class QuizLocalizations {
  const QuizLocalizations();

  /// Retrieves the [QuizLocalizations] for the given [context].
  ///
  /// Returns the localization provided by [QuizLocalizationsDelegate]
  /// in the widget tree, or falls back to English defaults.
  static QuizLocalizations of(BuildContext context) {
    return Localizations.of<QuizLocalizations>(context, QuizLocalizations) ??
        const QuizLocalizationsEn();
  }

  /// Creates an overridden localization that uses [base] but replaces
  /// specific strings with values from [overrides].
  ///
  /// Useful when apps want to customize only a few strings.
  ///
  /// Example:
  /// ```dart
  /// final customL10n = QuizLocalizations.override(
  ///   base: QuizLocalizationsEn(),
  ///   overrides: {'play': 'Start Game', 'history': 'Past Games'},
  /// );
  /// ```
  factory QuizLocalizations.override({
    required QuizLocalizations base,
    required Map<String, String> overrides,
    Map<String, String Function(int)>? pluralOverrides,
    Map<String, String Function(String)>? parameterizedOverrides,
  }) = _OverriddenQuizLocalizations;

  // ============================================================
  // Navigation (4 strings)
  // ============================================================

  /// Play tab label
  String get play;

  /// History tab label
  String get history;

  /// Statistics tab label
  String get statistics;

  /// Settings tab/screen title
  String get settings;

  // ============================================================
  // Quiz UI (12 strings)
  // ============================================================

  /// Score label
  String get score;

  /// Correct answer label
  String get correct;

  /// Incorrect answer label
  String get incorrect;

  /// Duration label
  String get duration;

  /// Questions count label
  String get questions;

  /// Exit dialog title
  String get exitDialogTitle;

  /// Exit dialog message
  String get exitDialogMessage;

  /// Exit dialog confirm button
  String get exitDialogConfirm;

  /// Exit dialog cancel button
  String get exitDialogCancel;

  /// Correct answer feedback
  String get correctFeedback;

  /// Incorrect answer feedback
  String get incorrectFeedback;

  /// Video load error message
  String get videoLoadError;

  // ============================================================
  // Hints (2 strings)
  // ============================================================

  /// 50/50 hint label
  String get hint5050Label;

  /// Skip hint label
  String get hintSkipLabel;

  // ============================================================
  // Timer (4 strings)
  // ============================================================

  /// Timer seconds suffix (e.g., "s")
  String get timerSecondsSuffix;

  /// Hours unit
  String get hours;

  /// Minutes unit
  String get minutes;

  /// Seconds unit
  String get seconds;

  // ============================================================
  // Session Status (5 strings)
  // ============================================================

  /// Session completed status
  String get sessionCompleted;

  /// Session cancelled status
  String get sessionCancelled;

  /// Session timeout status
  String get sessionTimeout;

  /// Session failed status
  String get sessionFailed;

  /// Perfect score label
  String get perfectScore;

  // ============================================================
  // History Screen (8 strings)
  // ============================================================

  /// Today date label
  String get today;

  /// Yesterday date label
  String get yesterday;

  /// Days ago label (e.g., "3 days ago")
  String daysAgo(int count);

  /// No sessions yet empty state title
  String get noSessionsYet;

  /// No sessions yet empty state subtitle
  String get startPlayingToSee;

  /// Session details screen title
  String get sessionDetails;

  /// Review answers section title
  String get reviewAnswers;

  /// Question number label (e.g., "Question 5")
  String questionNumber(int number);

  // ============================================================
  // Question Review (4 strings)
  // ============================================================

  /// Your answer label
  String get yourAnswer;

  /// Correct answer label (for review)
  String get correctAnswer;

  /// Skipped question label
  String get skipped;

  /// Practice wrong answers button
  String get practiceWrongAnswers;

  // ============================================================
  // Statistics Screen (18 strings)
  // ============================================================

  /// Total sessions stat label
  String get totalSessions;

  /// Total questions stat label
  String get totalQuestions;

  /// Average score stat label
  String get averageScore;

  /// Best score stat label
  String get bestScore;

  /// Accuracy stat label
  String get accuracy;

  /// Time played stat label
  String get timePlayed;

  /// Perfect scores count label
  String get perfectScores;

  /// Current streak label
  String get currentStreak;

  /// Best streak label
  String get bestStreak;

  /// Weekly trend section title
  String get weeklyTrend;

  /// Improving trend label
  String get improving;

  /// Declining trend label
  String get declining;

  /// Stable trend label
  String get stable;

  /// No statistics yet empty state title
  String get noStatisticsYet;

  /// No statistics yet empty state subtitle
  String get playQuizzesToSee;

  /// Overview section title
  String get overview;

  /// Insights section title
  String get insights;

  /// Days unit
  String get days;

  // ============================================================
  // Settings Screen (22 strings)
  // ============================================================

  /// Audio & Haptics section header
  String get audioAndHaptics;

  /// Sound effects toggle title
  String get soundEffects;

  /// Sound effects description
  String get soundEffectsDescription;

  /// Background music toggle title
  String get backgroundMusic;

  /// Background music description
  String get backgroundMusicDescription;

  /// Haptic feedback toggle title
  String get hapticFeedback;

  /// Haptic feedback description
  String get hapticFeedbackDescription;

  /// Quiz behavior section header
  String get quizBehavior;

  /// Show answer feedback toggle title
  String get showAnswerFeedback;

  /// Show answer feedback description
  String get showAnswerFeedbackDescription;

  /// Appearance section header
  String get appearance;

  /// Theme setting title
  String get theme;

  /// Light theme option
  String get themeLight;

  /// Dark theme option
  String get themeDark;

  /// System theme option
  String get themeSystem;

  /// Theme selection dialog title
  String get selectTheme;

  /// About section header
  String get about;

  /// Version label
  String get version;

  /// Build label
  String get build;

  /// About this app menu item
  String get aboutThisApp;

  /// Privacy policy menu item
  String get privacyPolicy;

  /// Terms of service menu item
  String get termsOfService;

  // ============================================================
  // Advanced Settings (6 strings)
  // ============================================================

  /// Open source licenses menu item
  String get openSourceLicenses;

  /// Advanced section header
  String get advanced;

  /// Reset to defaults menu item
  String get resetToDefaults;

  /// Reset to defaults description
  String get resetToDefaultsDescription;

  /// Reset settings dialog title
  String get resetSettings;

  /// Reset settings dialog message
  String get resetSettingsMessage;

  // ============================================================
  // Common Actions (8 strings)
  // ============================================================

  /// Cancel button
  String get cancel;

  /// Reset button
  String get reset;

  /// Close button
  String get close;

  /// Share button
  String get share;

  /// Delete button
  String get delete;

  /// View all button
  String get viewAll;

  /// Credits section title
  String get credits;

  /// Attributions section title
  String get attributions;

  // ============================================================
  // Export (4 strings)
  // ============================================================

  /// Export session button
  String get exportSession;

  /// Export as JSON option
  String get exportAsJson;

  /// Export as CSV option
  String get exportAsCsv;

  /// Export success message
  String get exportSuccess;

  /// Export error message
  String get exportError;

  // ============================================================
  // Delete Session (3 strings)
  // ============================================================

  /// Delete session dialog title
  String get deleteSession;

  /// Delete session confirmation message
  String get deleteSessionMessage;

  /// Session deleted success message
  String get sessionDeleted;

  // ============================================================
  // Parameterized Strings (2 strings)
  // ============================================================

  /// Recent sessions section title
  String get recentSessions;

  /// Settings reset confirmation message
  String get settingsResetToDefaults;

  /// Could not open URL error
  String couldNotOpenUrl(String url);
}

/// Implementation that wraps a base localization and overrides specific strings.
class _OverriddenQuizLocalizations extends QuizLocalizations {
  final QuizLocalizations _base;
  final Map<String, String> _overrides;
  final Map<String, String Function(int)>? _pluralOverrides;
  final Map<String, String Function(String)>? _parameterizedOverrides;

  const _OverriddenQuizLocalizations({
    required QuizLocalizations base,
    required Map<String, String> overrides,
    Map<String, String Function(int)>? pluralOverrides,
    Map<String, String Function(String)>? parameterizedOverrides,
  })  : _base = base,
        _overrides = overrides,
        _pluralOverrides = pluralOverrides,
        _parameterizedOverrides = parameterizedOverrides;

  String _get(String key, String Function() baseGetter) {
    return _overrides[key] ?? baseGetter();
  }

  // Navigation
  @override
  String get play => _get('play', () => _base.play);
  @override
  String get history => _get('history', () => _base.history);
  @override
  String get statistics => _get('statistics', () => _base.statistics);
  @override
  String get settings => _get('settings', () => _base.settings);

  // Quiz UI
  @override
  String get score => _get('score', () => _base.score);
  @override
  String get correct => _get('correct', () => _base.correct);
  @override
  String get incorrect => _get('incorrect', () => _base.incorrect);
  @override
  String get duration => _get('duration', () => _base.duration);
  @override
  String get questions => _get('questions', () => _base.questions);
  @override
  String get exitDialogTitle => _get('exitDialogTitle', () => _base.exitDialogTitle);
  @override
  String get exitDialogMessage => _get('exitDialogMessage', () => _base.exitDialogMessage);
  @override
  String get exitDialogConfirm => _get('exitDialogConfirm', () => _base.exitDialogConfirm);
  @override
  String get exitDialogCancel => _get('exitDialogCancel', () => _base.exitDialogCancel);
  @override
  String get correctFeedback => _get('correctFeedback', () => _base.correctFeedback);
  @override
  String get incorrectFeedback => _get('incorrectFeedback', () => _base.incorrectFeedback);
  @override
  String get videoLoadError => _get('videoLoadError', () => _base.videoLoadError);

  // Hints
  @override
  String get hint5050Label => _get('hint5050Label', () => _base.hint5050Label);
  @override
  String get hintSkipLabel => _get('hintSkipLabel', () => _base.hintSkipLabel);

  // Timer
  @override
  String get timerSecondsSuffix => _get('timerSecondsSuffix', () => _base.timerSecondsSuffix);
  @override
  String get hours => _get('hours', () => _base.hours);
  @override
  String get minutes => _get('minutes', () => _base.minutes);
  @override
  String get seconds => _get('seconds', () => _base.seconds);

  // Session Status
  @override
  String get sessionCompleted => _get('sessionCompleted', () => _base.sessionCompleted);
  @override
  String get sessionCancelled => _get('sessionCancelled', () => _base.sessionCancelled);
  @override
  String get sessionTimeout => _get('sessionTimeout', () => _base.sessionTimeout);
  @override
  String get sessionFailed => _get('sessionFailed', () => _base.sessionFailed);
  @override
  String get perfectScore => _get('perfectScore', () => _base.perfectScore);

  // History Screen
  @override
  String get today => _get('today', () => _base.today);
  @override
  String get yesterday => _get('yesterday', () => _base.yesterday);
  @override
  String daysAgo(int count) => _pluralOverrides?['daysAgo']?.call(count) ?? _base.daysAgo(count);
  @override
  String get noSessionsYet => _get('noSessionsYet', () => _base.noSessionsYet);
  @override
  String get startPlayingToSee => _get('startPlayingToSee', () => _base.startPlayingToSee);
  @override
  String get sessionDetails => _get('sessionDetails', () => _base.sessionDetails);
  @override
  String get reviewAnswers => _get('reviewAnswers', () => _base.reviewAnswers);
  @override
  String questionNumber(int number) => _pluralOverrides?['questionNumber']?.call(number) ?? _base.questionNumber(number);

  // Question Review
  @override
  String get yourAnswer => _get('yourAnswer', () => _base.yourAnswer);
  @override
  String get correctAnswer => _get('correctAnswer', () => _base.correctAnswer);
  @override
  String get skipped => _get('skipped', () => _base.skipped);
  @override
  String get practiceWrongAnswers => _get('practiceWrongAnswers', () => _base.practiceWrongAnswers);

  // Statistics Screen
  @override
  String get totalSessions => _get('totalSessions', () => _base.totalSessions);
  @override
  String get totalQuestions => _get('totalQuestions', () => _base.totalQuestions);
  @override
  String get averageScore => _get('averageScore', () => _base.averageScore);
  @override
  String get bestScore => _get('bestScore', () => _base.bestScore);
  @override
  String get accuracy => _get('accuracy', () => _base.accuracy);
  @override
  String get timePlayed => _get('timePlayed', () => _base.timePlayed);
  @override
  String get perfectScores => _get('perfectScores', () => _base.perfectScores);
  @override
  String get currentStreak => _get('currentStreak', () => _base.currentStreak);
  @override
  String get bestStreak => _get('bestStreak', () => _base.bestStreak);
  @override
  String get weeklyTrend => _get('weeklyTrend', () => _base.weeklyTrend);
  @override
  String get improving => _get('improving', () => _base.improving);
  @override
  String get declining => _get('declining', () => _base.declining);
  @override
  String get stable => _get('stable', () => _base.stable);
  @override
  String get noStatisticsYet => _get('noStatisticsYet', () => _base.noStatisticsYet);
  @override
  String get playQuizzesToSee => _get('playQuizzesToSee', () => _base.playQuizzesToSee);
  @override
  String get overview => _get('overview', () => _base.overview);
  @override
  String get insights => _get('insights', () => _base.insights);
  @override
  String get days => _get('days', () => _base.days);

  // Settings Screen
  @override
  String get audioAndHaptics => _get('audioAndHaptics', () => _base.audioAndHaptics);
  @override
  String get soundEffects => _get('soundEffects', () => _base.soundEffects);
  @override
  String get soundEffectsDescription => _get('soundEffectsDescription', () => _base.soundEffectsDescription);
  @override
  String get backgroundMusic => _get('backgroundMusic', () => _base.backgroundMusic);
  @override
  String get backgroundMusicDescription => _get('backgroundMusicDescription', () => _base.backgroundMusicDescription);
  @override
  String get hapticFeedback => _get('hapticFeedback', () => _base.hapticFeedback);
  @override
  String get hapticFeedbackDescription => _get('hapticFeedbackDescription', () => _base.hapticFeedbackDescription);
  @override
  String get quizBehavior => _get('quizBehavior', () => _base.quizBehavior);
  @override
  String get showAnswerFeedback => _get('showAnswerFeedback', () => _base.showAnswerFeedback);
  @override
  String get showAnswerFeedbackDescription => _get('showAnswerFeedbackDescription', () => _base.showAnswerFeedbackDescription);
  @override
  String get appearance => _get('appearance', () => _base.appearance);
  @override
  String get theme => _get('theme', () => _base.theme);
  @override
  String get themeLight => _get('themeLight', () => _base.themeLight);
  @override
  String get themeDark => _get('themeDark', () => _base.themeDark);
  @override
  String get themeSystem => _get('themeSystem', () => _base.themeSystem);
  @override
  String get selectTheme => _get('selectTheme', () => _base.selectTheme);
  @override
  String get about => _get('about', () => _base.about);
  @override
  String get version => _get('version', () => _base.version);
  @override
  String get build => _get('build', () => _base.build);
  @override
  String get aboutThisApp => _get('aboutThisApp', () => _base.aboutThisApp);
  @override
  String get privacyPolicy => _get('privacyPolicy', () => _base.privacyPolicy);
  @override
  String get termsOfService => _get('termsOfService', () => _base.termsOfService);

  // Advanced Settings
  @override
  String get openSourceLicenses => _get('openSourceLicenses', () => _base.openSourceLicenses);
  @override
  String get advanced => _get('advanced', () => _base.advanced);
  @override
  String get resetToDefaults => _get('resetToDefaults', () => _base.resetToDefaults);
  @override
  String get resetToDefaultsDescription => _get('resetToDefaultsDescription', () => _base.resetToDefaultsDescription);
  @override
  String get resetSettings => _get('resetSettings', () => _base.resetSettings);
  @override
  String get resetSettingsMessage => _get('resetSettingsMessage', () => _base.resetSettingsMessage);

  // Common Actions
  @override
  String get cancel => _get('cancel', () => _base.cancel);
  @override
  String get reset => _get('reset', () => _base.reset);
  @override
  String get close => _get('close', () => _base.close);
  @override
  String get share => _get('share', () => _base.share);
  @override
  String get delete => _get('delete', () => _base.delete);
  @override
  String get viewAll => _get('viewAll', () => _base.viewAll);
  @override
  String get credits => _get('credits', () => _base.credits);
  @override
  String get attributions => _get('attributions', () => _base.attributions);

  // Export
  @override
  String get exportSession => _get('exportSession', () => _base.exportSession);
  @override
  String get exportAsJson => _get('exportAsJson', () => _base.exportAsJson);
  @override
  String get exportAsCsv => _get('exportAsCsv', () => _base.exportAsCsv);
  @override
  String get exportSuccess => _get('exportSuccess', () => _base.exportSuccess);
  @override
  String get exportError => _get('exportError', () => _base.exportError);

  // Delete Session
  @override
  String get deleteSession => _get('deleteSession', () => _base.deleteSession);
  @override
  String get deleteSessionMessage => _get('deleteSessionMessage', () => _base.deleteSessionMessage);
  @override
  String get sessionDeleted => _get('sessionDeleted', () => _base.sessionDeleted);

  // Parameterized Strings
  @override
  String get recentSessions => _get('recentSessions', () => _base.recentSessions);
  @override
  String get settingsResetToDefaults => _get('settingsResetToDefaults', () => _base.settingsResetToDefaults);
  @override
  String couldNotOpenUrl(String url) => _parameterizedOverrides?['couldNotOpenUrl']?.call(url) ?? _base.couldNotOpenUrl(url);
}
