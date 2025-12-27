/// Builder widget for connecting HomeBloc to QuizHomeScreen.
library;

import 'package:flutter/material.dart';

import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'home_bloc.dart';
import 'home_event.dart';
import 'home_state.dart';

/// A builder widget that connects [HomeBloc] to home screen UI.
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class HomeBuilder extends StatefulWidget {
  /// Creates a [HomeBuilder].
  const HomeBuilder({
    super.key,
    required this.bloc,
    required this.builder,
    this.initialTabIndex = 0,
  });

  /// The home BLoC to connect to.
  final HomeBloc bloc;

  /// Builder for the loaded state.
  final Widget Function(BuildContext context, HomeLoaded state) builder;

  /// Initial tab index to load.
  final int initialTabIndex;

  @override
  State<HomeBuilder> createState() => _HomeBuilderState();
}

class _HomeBuilderState extends State<HomeBuilder> {
  @override
  void initState() {
    super.initState();
    // Load data when the widget is first created
    widget.bloc.add(HomeEvent.load(initialTabIndex: widget.initialTabIndex));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<HomeState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          HomeLoading() => _buildLoading(),
          HomeLoaded() => widget.builder(context, state),
          HomeError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }

  Widget _buildError(HomeError state) {
    return Scaffold(
      body: ErrorStateWidget(
        message: state.message,
        onRetry: () => widget.bloc.add(
          HomeEvent.load(initialTabIndex: widget.initialTabIndex),
        ),
      ),
    );
  }
}
