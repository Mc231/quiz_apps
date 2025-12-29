import '../widgets/session_card.dart';

/// Localization texts for SessionHistoryScreen.
class SessionHistoryTexts {
  /// Creates [SessionHistoryTexts].
  const SessionHistoryTexts({
    required this.title,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.questionsLabel,
    required this.formatDate,
    required this.formatStatus,
  });

  /// Screen title.
  final String title;

  /// Empty state title.
  final String emptyTitle;

  /// Empty state subtitle.
  final String emptySubtitle;

  /// Label for questions count.
  final String questionsLabel;

  /// Date formatter callback.
  final DateFormatter formatDate;

  /// Status formatter callback.
  final StatusFormatter formatStatus;
}
