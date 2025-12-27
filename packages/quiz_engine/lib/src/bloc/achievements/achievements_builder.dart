/// Builder widget for connecting AchievementsBloc to AchievementsScreen.
library;

import 'package:flutter/material.dart';

import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'achievements_bloc.dart';
import 'achievements_event.dart';
import 'achievements_state.dart';

/// A builder widget that connects [AchievementsBloc] to achievements screen UI.
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class AchievementsBuilder extends StatefulWidget {
  /// Creates an [AchievementsBuilder].
  const AchievementsBuilder({
    super.key,
    required this.bloc,
    required this.builder,
  });

  /// The achievements BLoC to connect to.
  final AchievementsBloc bloc;

  /// Builder for the loaded state.
  final Widget Function(BuildContext context, AchievementsLoaded state) builder;

  @override
  State<AchievementsBuilder> createState() => _AchievementsBuilderState();
}

class _AchievementsBuilderState extends State<AchievementsBuilder> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(AchievementsEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AchievementsState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          AchievementsLoading() => _buildLoading(),
          AchievementsLoaded() => widget.builder(context, state),
          AchievementsError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }

  Widget _buildError(AchievementsError state) {
    return Scaffold(
      body: ErrorStateWidget(
        message: state.message,
        onRetry: () => widget.bloc.add(AchievementsEvent.load()),
      ),
    );
  }
}
