/// Builder widget for connecting SessionDetailBloc to SessionDetailScreen.
library;

import 'package:flutter/material.dart';

import '../../screens/session_detail_screen.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'session_detail_bloc.dart';
import 'session_detail_event.dart';
import 'session_detail_state.dart';

/// A builder widget that connects [SessionDetailBloc] to [SessionDetailScreen].
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class SessionDetailBuilder extends StatefulWidget {
  /// Creates a [SessionDetailBuilder].
  const SessionDetailBuilder({
    super.key,
    required this.bloc,
    required this.sessionId,
    required this.texts,
    this.onPracticeWrongAnswers,
    this.onExport,
    this.onDeleted,
    this.imageBuilder,
  });

  /// The session detail BLoC to connect to.
  final SessionDetailBloc bloc;

  /// The ID of the session to load.
  final String sessionId;

  /// Localization texts for the screen.
  final SessionDetailTexts texts;

  /// Callback to practice wrong answers.
  final void Function(SessionDetailData session)? onPracticeWrongAnswers;

  /// Callback to export session.
  final void Function(SessionDetailData session)? onExport;

  /// Callback when session is deleted successfully.
  final VoidCallback? onDeleted;

  /// Optional image builder for question images.
  final Widget Function(String path)? imageBuilder;

  @override
  State<SessionDetailBuilder> createState() => _SessionDetailBuilderState();
}

class _SessionDetailBuilderState extends State<SessionDetailBuilder> {
  bool _deleteTriggered = false;

  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(SessionDetailEvent.load(widget.sessionId));
  }

  @override
  void didUpdateWidget(SessionDetailBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reload if session ID changed
    if (oldWidget.sessionId != widget.sessionId) {
      _deleteTriggered = false;
      widget.bloc.add(SessionDetailEvent.load(widget.sessionId));
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SessionDetailState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          SessionDetailLoading() => _buildLoading(),
          SessionDetailLoaded() => _buildLoaded(state),
          SessionDetailError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const LoadingIndicator();
  }

  Widget _buildError(SessionDetailError state) {
    return ErrorStateWidget(
      message: state.message,
      onRetry: () => widget.bloc.add(SessionDetailEvent.load(widget.sessionId)),
    );
  }

  Widget _buildLoaded(SessionDetailLoaded state) {
    // Check if delete just completed
    if (_deleteTriggered && !state.isDeleting) {
      // Deletion completed - call the callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _deleteTriggered = false;
        widget.onDeleted?.call();
      });
    }

    return SessionDetailContent(
      session: state.session,
      texts: widget.texts,
      filterMode: state.filterMode,
      isDeleting: state.isDeleting,
      onFilterModeChanged: (mode) =>
          widget.bloc.add(SessionDetailEvent.changeFilterMode(mode)),
      onPracticeWrongAnswers: widget.onPracticeWrongAnswers != null
          ? () => widget.onPracticeWrongAnswers!(state.session)
          : null,
      onExport: widget.onExport != null
          ? () => widget.onExport!(state.session)
          : null,
      onDelete: () {
        _deleteTriggered = true;
        widget.bloc.add(SessionDetailEvent.delete());
      },
      imageBuilder: widget.imageBuilder,
    );
  }
}
