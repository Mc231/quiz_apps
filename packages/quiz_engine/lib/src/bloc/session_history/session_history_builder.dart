/// Builder widget for connecting SessionHistoryBloc to SessionHistoryScreen.
library;

import 'package:flutter/material.dart';

import '../../screens/session_history_screen.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/session_card.dart';
import 'session_history_bloc.dart';
import 'session_history_event.dart';
import 'session_history_state.dart';

/// A builder widget that connects [SessionHistoryBloc] to [SessionHistoryScreen].
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class SessionHistoryBuilder extends StatefulWidget {
  /// Creates a [SessionHistoryBuilder].
  const SessionHistoryBuilder({
    super.key,
    required this.bloc,
    required this.texts,
    required this.onSessionTap,
    this.loadMoreThreshold = 3,
  });

  /// The session history BLoC to connect to.
  final SessionHistoryBloc bloc;

  /// Localization texts for the screen.
  final SessionHistoryTexts texts;

  /// Callback when a session card is tapped.
  final void Function(SessionCardData session) onSessionTap;

  /// Number of items from the end to trigger load more.
  final int loadMoreThreshold;

  @override
  State<SessionHistoryBuilder> createState() => _SessionHistoryBuilderState();
}

class _SessionHistoryBuilderState extends State<SessionHistoryBuilder> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(SessionHistoryEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SessionHistoryState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          SessionHistoryLoading() => _buildLoading(),
          SessionHistoryLoaded() => _buildLoaded(state),
          SessionHistoryError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const LoadingIndicator();
  }

  Widget _buildError(SessionHistoryError state) {
    return ErrorStateWidget(
      message: state.message,
      onRetry: () => widget.bloc.add(SessionHistoryEvent.load()),
    );
  }

  Widget _buildLoaded(SessionHistoryLoaded state) {
    return SessionHistoryContent(
      sessions: state.sessions,
      texts: widget.texts,
      onSessionTap: widget.onSessionTap,
      hasMore: state.hasMore,
      isLoadingMore: state.isLoadingMore,
      loadMoreThreshold: widget.loadMoreThreshold,
      onRefresh: () async {
        widget.bloc.add(SessionHistoryEvent.refresh());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
      onLoadMore: () => widget.bloc.add(SessionHistoryEvent.loadMore()),
    );
  }
}
