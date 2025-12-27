/// Generic builder widget for BLoC state management.
library;

import 'package:flutter/material.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

/// A generic builder widget that connects a [SingleSubscriptionBloc] to the UI.
///
/// This widget listens to the BLoC stream and rebuilds when the state changes.
/// It's a simpler alternative to manually using [StreamBuilder].
///
/// Example:
/// ```dart
/// BlocBuilder<MyBloc, MyState>(
///   bloc: myBloc,
///   builder: (context, state) {
///     return switch (state) {
///       MyLoading() => const LoadingIndicator(),
///       MyLoaded(:final data) => MyContent(data: data),
///       MyError(:final message) => ErrorWidget(message: message),
///     };
///   },
/// )
/// ```
class BlocBuilder<B extends SingleSubscriptionBloc<S>, S>
    extends StatelessWidget {
  /// Creates a [BlocBuilder].
  const BlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
    this.buildWhen,
  });

  /// The BLoC to listen to.
  final B bloc;

  /// The builder function called with the current state.
  final Widget Function(BuildContext context, S state) builder;

  /// Optional condition to determine if a rebuild should occur.
  ///
  /// If provided, the builder will only be called when this function
  /// returns `true`. Useful for optimizing rebuilds.
  final bool Function(S previous, S current)? buildWhen;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: bloc.stream,
      initialData: bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? bloc.initialState;
        return builder(context, state);
      },
    );
  }
}

/// A [BlocBuilder] variant that only rebuilds when the state changes.
///
/// This widget uses a [StatefulWidget] to track the previous state and
/// only rebuilds when [buildWhen] returns `true` (or always if not provided).
class SelectiveBlocBuilder<B extends SingleSubscriptionBloc<S>, S>
    extends StatefulWidget {
  /// Creates a [SelectiveBlocBuilder].
  const SelectiveBlocBuilder({
    super.key,
    required this.bloc,
    required this.builder,
    this.buildWhen,
  });

  /// The BLoC to listen to.
  final B bloc;

  /// The builder function called with the current state.
  final Widget Function(BuildContext context, S state) builder;

  /// Condition to determine if a rebuild should occur.
  ///
  /// Called with the previous and current state. If returns `true`,
  /// the builder will be called with the new state.
  final bool Function(S previous, S current)? buildWhen;

  @override
  State<SelectiveBlocBuilder<B, S>> createState() =>
      _SelectiveBlocBuilderState<B, S>();
}

class _SelectiveBlocBuilderState<B extends SingleSubscriptionBloc<S>, S>
    extends State<SelectiveBlocBuilder<B, S>> {
  S? _previousState;
  Widget? _cachedWidget;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;
        final previous = _previousState;

        // Check if we should rebuild
        final shouldRebuild = previous == null ||
            widget.buildWhen == null ||
            widget.buildWhen!(previous, state);

        if (shouldRebuild) {
          _previousState = state;
          _cachedWidget = widget.builder(context, state);
        }

        return _cachedWidget!;
      },
    );
  }
}

/// A [BlocBuilder] that automatically triggers a load event on init.
///
/// This is useful for screens that need to load data when first displayed.
///
/// Example:
/// ```dart
/// AutoLoadBlocBuilder<MyBloc, MyState>(
///   bloc: myBloc,
///   onLoad: () => myBloc.add(MyEvent.load()),
///   builder: (context, state) => MyContent(state: state),
/// )
/// ```
class AutoLoadBlocBuilder<B extends SingleSubscriptionBloc<S>, S>
    extends StatefulWidget {
  /// Creates an [AutoLoadBlocBuilder].
  const AutoLoadBlocBuilder({
    super.key,
    required this.bloc,
    required this.onLoad,
    required this.builder,
  });

  /// The BLoC to listen to.
  final B bloc;

  /// Called when the widget is first created to trigger loading.
  final VoidCallback onLoad;

  /// The builder function called with the current state.
  final Widget Function(BuildContext context, S state) builder;

  @override
  State<AutoLoadBlocBuilder<B, S>> createState() =>
      _AutoLoadBlocBuilderState<B, S>();
}

class _AutoLoadBlocBuilderState<B extends SingleSubscriptionBloc<S>, S>
    extends State<AutoLoadBlocBuilder<B, S>> {
  @override
  void initState() {
    super.initState();
    widget.onLoad();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: widget.bloc.stream,
      initialData: widget.bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? widget.bloc.initialState;
        return widget.builder(context, state);
      },
    );
  }
}

/// A builder that handles loading, error, and loaded states.
///
/// This is a convenience widget for the common pattern of having
/// three states: loading, error, and loaded.
///
/// Example:
/// ```dart
/// TriStateBlocBuilder<MyBloc, MyState, MyLoaded>(
///   bloc: myBloc,
///   isLoading: (state) => state is MyLoading,
///   isError: (state) => state is MyError,
///   getErrorMessage: (state) => (state as MyError).message,
///   extractLoaded: (state) => state is MyLoaded ? state : null,
///   loadingBuilder: (context) => const LoadingIndicator(),
///   errorBuilder: (context, message, onRetry) => ErrorWidget(
///     message: message,
///     onRetry: onRetry,
///   ),
///   loadedBuilder: (context, loaded) => MyContent(data: loaded.data),
///   onRetry: () => myBloc.add(MyEvent.load()),
/// )
/// ```
class TriStateBlocBuilder<B extends SingleSubscriptionBloc<S>, S, L>
    extends StatelessWidget {
  /// Creates a [TriStateBlocBuilder].
  const TriStateBlocBuilder({
    super.key,
    required this.bloc,
    required this.isLoading,
    required this.isError,
    required this.getErrorMessage,
    required this.extractLoaded,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.loadedBuilder,
    this.onRetry,
  });

  /// The BLoC to listen to.
  final B bloc;

  /// Returns true if the state is a loading state.
  final bool Function(S state) isLoading;

  /// Returns true if the state is an error state.
  final bool Function(S state) isError;

  /// Extracts the error message from an error state.
  final String Function(S state) getErrorMessage;

  /// Extracts the loaded state from a general state.
  /// Returns null if not a loaded state.
  final L? Function(S state) extractLoaded;

  /// Builder for the loading state.
  final Widget Function(BuildContext context) loadingBuilder;

  /// Builder for the error state.
  /// [onRetry] is the callback to retry loading (if provided to widget).
  final Widget Function(
    BuildContext context,
    String message,
    VoidCallback? onRetry,
  ) errorBuilder;

  /// Builder for the loaded state.
  final Widget Function(BuildContext context, L loaded) loadedBuilder;

  /// Optional callback to retry loading after an error.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<S>(
      stream: bloc.stream,
      initialData: bloc.initialState,
      builder: (context, snapshot) {
        final state = snapshot.data ?? bloc.initialState;

        if (isLoading(state)) {
          return loadingBuilder(context);
        }

        if (isError(state)) {
          return errorBuilder(context, getErrorMessage(state), onRetry);
        }

        final loaded = extractLoaded(state);
        if (loaded != null) {
          return loadedBuilder(context, loaded);
        }

        // Fallback to loading for unknown states
        return loadingBuilder(context);
      },
    );
  }
}
