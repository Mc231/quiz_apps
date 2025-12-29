import 'dart:ui';

/// Localization texts for SessionDetailScreen.
class SessionDetailTexts {
  /// Creates [SessionDetailTexts].
  const SessionDetailTexts({
    required this.title,
    required this.reviewAnswersLabel,
    required this.practiceWrongAnswersLabel,
    required this.exportLabel,
    required this.deleteLabel,
    required this.scoreLabel,
    required this.correctLabel,
    required this.incorrectLabel,
    required this.skippedLabel,
    required this.durationLabel,
    required this.questionLabel,
    required this.yourAnswerLabel,
    required this.correctAnswerLabel,
    required this.formatDate,
    required this.formatStatus,
    required this.deleteDialogTitle,
    required this.deleteDialogMessage,
    required this.cancelLabel,
    this.showAllLabel = 'All',
    this.showWrongOnlyLabel = 'Wrong Only',
  });

  /// Screen title.
  final String title;

  /// Review answers section label.
  final String reviewAnswersLabel;

  /// Practice wrong answers button label.
  final String practiceWrongAnswersLabel;

  /// Export button label.
  final String exportLabel;

  /// Delete button label.
  final String deleteLabel;

  /// Score label.
  final String scoreLabel;

  /// Correct label.
  final String correctLabel;

  /// Incorrect label.
  final String incorrectLabel;

  /// Skipped label.
  final String skippedLabel;

  /// Duration label.
  final String durationLabel;

  /// Question label formatter.
  final String Function(int number) questionLabel;

  /// Your answer label.
  final String yourAnswerLabel;

  /// Correct answer label.
  final String correctAnswerLabel;

  /// Date formatter callback.
  final String Function(DateTime date) formatDate;

  /// Status formatter callback.
  final (String label, Color color) Function(String status, bool isPerfect)
      formatStatus;

  /// Delete dialog title.
  final String deleteDialogTitle;

  /// Delete dialog message.
  final String deleteDialogMessage;

  /// Cancel button label.
  final String cancelLabel;

  /// Label for showing all questions.
  final String showAllLabel;

  /// Label for showing only wrong answers.
  final String showWrongOnlyLabel;
}
