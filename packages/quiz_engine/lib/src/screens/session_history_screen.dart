import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../services/quiz_services_context.dart';
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
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class SessionHistoryScreen extends StatefulWidget {
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
  State<SessionHistoryScreen> createState() => _SessionHistoryScreenState();
}

class _SessionHistoryScreenState extends State<SessionHistoryScreen> {
  /// Gets the analytics service from context.
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  void initState() {
    super.initState();
    // Log screen view after first frame when context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _logScreenView();
    });
  }

  void _logScreenView() {
    _analyticsService.logEvent(
      ScreenViewEvent.history(sessionCount: widget.sessions.length),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const LoadingIndicator();
    }

    if (widget.sessions.isEmpty) {
      return EmptyStateWidget(
        icon: Icons.history,
        title: widget.texts.emptyTitle,
        message: widget.texts.emptySubtitle,
      );
    }

    // Calculate total items including loading indicator
    final itemCount = widget.sessions.length + (widget.hasMore && widget.isLoadingMore ? 1 : 0);

    final content = ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        // Show loading indicator at the end
        if (index >= widget.sessions.length) {
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
        if (widget.hasMore &&
            !widget.isLoadingMore &&
            widget.onLoadMore != null &&
            index >= widget.sessions.length - widget.loadMoreThreshold) {
          // Use post-frame callback to avoid calling during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            widget.onLoadMore?.call();
          });
        }

        final session = widget.sessions[index];
        return SessionCard(
          data: session,
          questionsLabel: widget.texts.questionsLabel,
          formatDate: widget.texts.formatDate,
          formatStatus: widget.texts.formatStatus,
          onTap: () => widget.onSessionTap(session),
        );
      },
    );

    if (widget.onRefresh != null) {
      return RefreshIndicator(
        onRefresh: _handleRefresh,
        child: content,
      );
    }

    return content;
  }

  /// Handles pull-to-refresh with analytics tracking.
  Future<void> _handleRefresh() async {
    final stopwatch = Stopwatch()..start();
    bool success = true;

    try {
      await widget.onRefresh!();
    } catch (e) {
      success = false;
      rethrow;
    } finally {
      stopwatch.stop();
      _analyticsService.logEvent(
        InteractionEvent.pullToRefresh(
          screenName: 'session_history',
          refreshDuration: stopwatch.elapsed,
          success: success,
        ),
      );
    }
  }
}

/// BLoC-compatible content widget for session history.
///
/// This widget receives all state and callbacks externally, making it
/// suitable for use with [SessionHistoryBloc] via [SessionHistoryBuilder].
///
/// Analytics service is obtained from [QuizServicesProvider] via context.
class SessionHistoryContent extends StatelessWidget {
  /// Creates a [SessionHistoryContent].
  const SessionHistoryContent({
    super.key,
    required this.sessions,
    required this.texts,
    required this.onSessionTap,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.loadMoreThreshold = 3,
    this.onRefresh,
    this.onLoadMore,
  });

  /// List of sessions to display.
  final List<SessionCardData> sessions;

  /// Localization texts.
  final SessionHistoryTexts texts;

  /// Callback when a session card is tapped.
  final void Function(SessionCardData session) onSessionTap;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Whether more items are currently being loaded.
  final bool isLoadingMore;

  /// Number of items from the end to trigger [onLoadMore].
  final int loadMoreThreshold;

  /// Callback for pull-to-refresh.
  final Future<void> Function()? onRefresh;

  /// Callback when more items should be loaded.
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
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
      return Builder(
        builder: (ctx) => RefreshIndicator(
          onRefresh: () => _handleRefresh(ctx, onRefresh!),
          child: content,
        ),
      );
    }

    return content;
  }

  /// Handles pull-to-refresh with analytics tracking.
  Future<void> _handleRefresh(
    BuildContext context,
    Future<void> Function() originalOnRefresh,
  ) async {
    final stopwatch = Stopwatch()..start();
    bool success = true;

    try {
      await originalOnRefresh();
    } catch (e) {
      success = false;
      rethrow;
    } finally {
      stopwatch.stop();
      context.screenAnalyticsService.logEvent(
        InteractionEvent.pullToRefresh(
          screenName: 'session_history',
          refreshDuration: stopwatch.elapsed,
          success: success,
        ),
      );
    }
  }
}
