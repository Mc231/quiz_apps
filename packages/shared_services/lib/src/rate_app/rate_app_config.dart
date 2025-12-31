/// Configuration for the Rate App service.
///
/// Controls when and how rate prompts are shown to users.
///
/// Example usage:
/// ```dart
/// final config = RateAppConfig(
///   minCompletedQuizzes: 5,
///   minDaysSinceInstall: 7,
///   minScorePercentage: 70,
///   cooldownDays: 90,
/// );
/// ```
class RateAppConfig {
  /// Whether rate prompts are enabled.
  final bool isEnabled;

  /// Minimum number of quizzes completed before prompting.
  final int minCompletedQuizzes;

  /// Minimum days since first launch before prompting.
  final int minDaysSinceInstall;

  /// Minimum score percentage to trigger prompt (0-100).
  final int minScorePercentage;

  /// Days to wait between prompts.
  final int cooldownDays;

  /// Maximum lifetime prompts before stopping.
  final int maxLifetimePrompts;

  /// Maximum declines before stopping.
  final int maxDeclines;

  /// Whether to use the two-step "Love Dialog" approach.
  ///
  /// If true, shows "Are you enjoying the app?" first.
  /// If false, shows native rating dialog directly.
  final bool useLoveDialog;

  /// Email address for unhappy user feedback.
  ///
  /// If null, feedback option won't be shown.
  final String? feedbackEmail;

  /// Creates a new [RateAppConfig].
  const RateAppConfig({
    this.isEnabled = true,
    this.minCompletedQuizzes = 5,
    this.minDaysSinceInstall = 7,
    this.minScorePercentage = 70,
    this.cooldownDays = 90,
    this.maxLifetimePrompts = 5,
    this.maxDeclines = 3,
    this.useLoveDialog = true,
    this.feedbackEmail,
  });

  /// Creates a disabled configuration.
  const RateAppConfig.disabled()
      : isEnabled = false,
        minCompletedQuizzes = 0,
        minDaysSinceInstall = 0,
        minScorePercentage = 0,
        cooldownDays = 0,
        maxLifetimePrompts = 0,
        maxDeclines = 0,
        useLoveDialog = false,
        feedbackEmail = null;

  /// Creates a test configuration with relaxed requirements.
  const RateAppConfig.test()
      : isEnabled = true,
        minCompletedQuizzes = 1,
        minDaysSinceInstall = 0,
        minScorePercentage = 0,
        cooldownDays = 0,
        maxLifetimePrompts = 100,
        maxDeclines = 100,
        useLoveDialog = true,
        feedbackEmail = 'test@example.com';

  /// Creates a copy of this config with the given fields replaced.
  RateAppConfig copyWith({
    bool? isEnabled,
    int? minCompletedQuizzes,
    int? minDaysSinceInstall,
    int? minScorePercentage,
    int? cooldownDays,
    int? maxLifetimePrompts,
    int? maxDeclines,
    bool? useLoveDialog,
    String? feedbackEmail,
  }) {
    return RateAppConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      minCompletedQuizzes: minCompletedQuizzes ?? this.minCompletedQuizzes,
      minDaysSinceInstall: minDaysSinceInstall ?? this.minDaysSinceInstall,
      minScorePercentage: minScorePercentage ?? this.minScorePercentage,
      cooldownDays: cooldownDays ?? this.cooldownDays,
      maxLifetimePrompts: maxLifetimePrompts ?? this.maxLifetimePrompts,
      maxDeclines: maxDeclines ?? this.maxDeclines,
      useLoveDialog: useLoveDialog ?? this.useLoveDialog,
      feedbackEmail: feedbackEmail ?? this.feedbackEmail,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RateAppConfig &&
        other.isEnabled == isEnabled &&
        other.minCompletedQuizzes == minCompletedQuizzes &&
        other.minDaysSinceInstall == minDaysSinceInstall &&
        other.minScorePercentage == minScorePercentage &&
        other.cooldownDays == cooldownDays &&
        other.maxLifetimePrompts == maxLifetimePrompts &&
        other.maxDeclines == maxDeclines &&
        other.useLoveDialog == useLoveDialog &&
        other.feedbackEmail == feedbackEmail;
  }

  @override
  int get hashCode {
    return Object.hash(
      isEnabled,
      minCompletedQuizzes,
      minDaysSinceInstall,
      minScorePercentage,
      cooldownDays,
      maxLifetimePrompts,
      maxDeclines,
      useLoveDialog,
      feedbackEmail,
    );
  }

  @override
  String toString() {
    return 'RateAppConfig('
        'isEnabled: $isEnabled, '
        'minCompletedQuizzes: $minCompletedQuizzes, '
        'minDaysSinceInstall: $minDaysSinceInstall, '
        'minScorePercentage: $minScorePercentage, '
        'cooldownDays: $cooldownDays, '
        'maxLifetimePrompts: $maxLifetimePrompts, '
        'maxDeclines: $maxDeclines, '
        'useLoveDialog: $useLoveDialog, '
        'feedbackEmail: $feedbackEmail)';
  }
}
