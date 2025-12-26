import 'package:flutter/material.dart';

import '../widgets/empty_state_widget.dart';
import '../widgets/loading_indicator.dart';
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

/// Screen displaying quiz session history with pagination support.
///
/// Supports infinite scroll for loading more sessions when the user
/// reaches the bottom of the list.
class SessionHistoryScreen extends StatelessWidget {
  /// Creates a [SessionHistoryScreen].
  const SessionHistoryScreen({
    super.key,
    required this.sessions,
    required this.texts,
    required this.onSessionTap,
    this.isLoading = false,
    this.onRefresh,
    this.onLoadMore,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreThreshold = 3,
  });

  /// List of sessions to display.
  final List<SessionCardData> sessions;

  /// Localization texts.
  final SessionHistoryTexts texts;

  /// Callback when a session card is tapped.
  final void Function(SessionCardData session) onSessionTap;

  /// Whether initial data is being loaded.
  final bool isLoading;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Callback when more items should be loaded.
  ///
  /// Called when the user scrolls near the end of the list.
  final VoidCallback? onLoadMore;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Whether more items are currently being loaded.
  final bool isLoadingMore;

  /// Number of items from the end to trigger [onLoadMore].
  ///
  /// Defaults to 3, meaning load more will be triggered when
  /// the user is 3 items from the end of the list.
  final int loadMoreThreshold;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingIndicator();
    }

    if (sessions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: texts.emptyTitle,
        message: texts.emptySubtitle,
      );
    }

    // Calculate total items including loading indicator
    final itemCount = sessions.length + (hasMore && isLoadingMore ? 1 : 0);

    final content = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index >= sessions.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        // Trigger load more when approaching the end
        if (hasMore &&
            !isLoadingMore &&
            onLoadMore != null &&
            index >= sessions.length - loadMoreThreshold) {
          // Use post-frame callback to avoid calling during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onLoadMore?.call();
          });
        }

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
}
