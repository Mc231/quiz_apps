import 'package:flutter/material.dart';

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

/// Screen displaying quiz session history.
class SessionHistoryScreen extends StatelessWidget {
  /// Creates a [SessionHistoryScreen].
  const SessionHistoryScreen({
    super.key,
    required this.sessions,
    required this.texts,
    required this.onSessionTap,
    this.isLoading = false,
    this.onRefresh,
  });

  /// List of sessions to display.
  final List<SessionCardData> sessions;

  /// Localization texts.
  final SessionHistoryTexts texts;

  /// Callback when a session card is tapped.
  final void Function(SessionCardData session) onSessionTap;

  /// Whether data is being loaded.
  final bool isLoading;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (sessions.isEmpty) {
      return _buildEmptyState(context);
    }

    final content = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return SessionCard(
          data: session,
          questionsLabel: texts.questionsLabel,
          formatDate: texts.formatDate,
          formatStatus: texts.formatStatus,
          onTap: () => onSessionTap(session),
        );
      },
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }

    return content;
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              texts.emptyTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              texts.emptySubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
