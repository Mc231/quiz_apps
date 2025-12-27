/// Builder widget for connecting SettingsBloc to QuizSettingsScreen.
library;

import 'package:flutter/material.dart';

import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_indicator.dart';
import 'settings_bloc.dart';
import 'settings_event.dart';
import 'settings_state.dart';

/// A builder widget that connects [SettingsBloc] to settings screen UI.
///
/// This widget listens to the BLoC stream and renders the appropriate UI
/// based on the current state (loading, error, or loaded).
class SettingsBuilder extends StatefulWidget {
  /// Creates a [SettingsBuilder].
  const SettingsBuilder({
    super.key,
    required this.bloc,
    required this.builder,
  });

  /// The settings BLoC to connect to.
  final SettingsBloc bloc;

  /// Builder for the loaded state.
  final Widget Function(BuildContext context, SettingsLoaded state) builder;

  @override
  State<SettingsBuilder> createState() => _SettingsBuilderState();
}

class _SettingsBuilderState extends State<SettingsBuilder> {
  @override
  void initState() {
    super.initState();
    // Load settings when the widget is first created
    widget.bloc.add(SettingsEvent.load());
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<SettingsState>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;

        return switch (state) {
          SettingsLoading() => _buildLoading(),
          SettingsLoaded() => widget.builder(context, state),
          SettingsError() => _buildError(state),
        };
      },
    );
  }

  Widget _buildLoading() {
    return const Scaffold(
      body: LoadingIndicator(),
    );
  }

  Widget _buildError(SettingsError state) {
    return Scaffold(
      body: ErrorStateWidget(
        message: state.message,
        onRetry: () => widget.bloc.add(SettingsEvent.load()),
      ),
    );
  }
}
