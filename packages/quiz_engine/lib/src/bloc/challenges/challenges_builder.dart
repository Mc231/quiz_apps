/// Builder widget for connecting ChallengesBloc to ChallengesScreen.
library;

import 'package:flutter/material.dart';

import '../../models/challenge_mode.dart';
import '../../models/quiz_category.dart';
import '../../screens/challenges_screen.dart';
import '../../widgets/challenge_list.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'challenges_bloc.dart';
import 'challenges_event.dart';
import 'challenges_state.dart';

/// A builder widget that connects [ChallengesBloc] to [ChallengesScreen].
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class ChallengesBuilder extends StatefulWidget {
  /// Creates a [ChallengesBuilder].
  const ChallengesBuilder({
    super.key,
    required this.bloc,
    required this.onChallengeSelected,
    this.listConfig = const ChallengeListConfig(),
  });

  /// The challenges BLoC to connect to.
  final ChallengesBloc bloc;

  /// Callback when a challenge and category are selected.
  final void Function(ChallengeMode challenge, QuizCategory category)
      onChallengeSelected;

  /// Configuration for the challenge list.
  final ChallengeListConfig listConfig;

  @override
  State<ChallengesBuilder> createState() => _ChallengesBuilderState();
}

class _ChallengesBuilderState extends State<ChallengesBuilder> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(ChallengesEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ChallengesState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          ChallengesLoading() => _buildLoading(),
          ChallengesLoaded() => _buildLoaded(state),
          ChallengesError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const LoadingIndicator();
  }

  Widget _buildError(ChallengesError state) {
    return ErrorStateWidget(
      message: state.message,
      onRetry: () => widget.bloc.add(ChallengesEvent.load()),
    );
  }

  Widget _buildLoaded(ChallengesLoaded state) {
    return ChallengesContent(
      challenges: state.challenges,
      categories: state.categories,
      listConfig: widget.listConfig,
      onChallengeSelected: widget.onChallengeSelected,
      isRefreshing: state.isRefreshing,
      onRefresh: () async {
        widget.bloc.add(ChallengesEvent.refresh());
        // Wait a bit for the refresh to complete
        await Future.delayed(const Duration(milliseconds: 500));
      },
    );
  }
}
