/// Builder widget for connecting PracticeBloc to practice screens.
library;

import 'package:flutter/material.dart';

import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'practice_bloc.dart';
import 'practice_event.dart';
import 'practice_state.dart';

/// A builder widget that connects [PracticeBloc] to practice screen UI.
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, ready, complete, or error).
class PracticeBuilder extends StatefulWidget {
  /// Creates a [PracticeBuilder].
  const PracticeBuilder({
    super.key,
    required this.bloc,
    required this.readyBuilder,
    required this.completeBuilder,
  });

  /// The practice BLoC to connect to.
  final PracticeBloc bloc;

  /// Builder for the ready state (shows practice start screen).
  final Widget Function(BuildContext context, PracticeReady state) readyBuilder;

  /// Builder for the complete state (shows practice results).
  final Widget Function(BuildContext context, PracticeComplete state)
      completeBuilder;

  @override
  State<PracticeBuilder> createState() => _PracticeBuilderState();
}

class _PracticeBuilderState extends State<PracticeBuilder> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(PracticeEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PracticeState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          PracticeLoading() => _buildLoading(),
          PracticeReady() => widget.readyBuilder(context, state),
          PracticeComplete() => widget.completeBuilder(context, state),
          PracticeError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }

  Widget _buildError(PracticeError state) {
    return Scaffold(
      body: ErrorStateWidget(
        message: state.message,
        onRetry: () => widget.bloc.add(PracticeEvent.load()),
      ),
    );
  }
}
