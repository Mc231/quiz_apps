import '../widgets/session_card.dart';

/// Localization texts for StatisticsScreen.
class StatisticsTexts {
  /// Creates [StatisticsTexts].
  const StatisticsTexts({
    required this.title,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.overviewLabel,
    required this.insightsLabel,
    required this.recentSessionsLabel,
    required this.viewAllLabel,
    required this.totalSessionsLabel,
    required this.totalQuestionsLabel,
    required this.averageScoreLabel,
    required this.bestScoreLabel,
    required this.accuracyLabel,
    required this.timePlayedLabel,
    required this.perfectScoresLabel,
    required this.currentStreakLabel,
    required this.bestStreakLabel,
    required this.weeklyTrendLabel,
    required this.improvingLabel,
    required this.decliningLabel,
    required this.stableLabel,
    required this.questionsLabel,
    required this.daysLabel,
    required this.formatDate,
    required this.formatStatus,
    required this.formatDuration,
  });

  /// Screen title.
  final String title;

  /// Empty state title.
  final String emptyTitle;

  /// Empty state subtitle.
  final String emptySubtitle;

  /// Overview section label.
  final String overviewLabel;

  /// Insights section label.
  final String insightsLabel;

  /// Recent sessions section label.
  final String recentSessionsLabel;

  /// View all button label.
  final String viewAllLabel;

  /// Total sessions label.
  final String totalSessionsLabel;

  /// Total questions label.
  final String totalQuestionsLabel;

  /// Average score label.
  final String averageScoreLabel;

  /// Best score label.
  final String bestScoreLabel;

  /// Accuracy label.
  final String accuracyLabel;

  /// Time played label.
  final String timePlayedLabel;

  /// Perfect scores label.
  final String perfectScoresLabel;

  /// Current streak label.
  final String currentStreakLabel;

  /// Best streak label.
  final String bestStreakLabel;

  /// Weekly trend label.
  final String weeklyTrendLabel;

  /// Improving trend label.
  final String improvingLabel;

  /// Declining trend label.
  final String decliningLabel;

  /// Stable trend label.
  final String stableLabel;

  /// Questions label.
  final String questionsLabel;

  /// Days label.
  final String daysLabel;

  /// Date formatter.
  final DateFormatter formatDate;

  /// Status formatter.
  final StatusFormatter formatStatus;

  /// Duration formatter.
  final String Function(int seconds) formatDuration;
}
