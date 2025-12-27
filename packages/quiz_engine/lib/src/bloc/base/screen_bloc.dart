/// Base class for screen-level BLoCs with common functionality.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'base_bloc_state.dart';

/// A base class for screen-level BLoCs with analytics integration.
///
/// Extends [SingleSubscriptionBloc] with common functionality for
/// screen BLoCs including:
/// - Optional analytics integration
/// - State tracking for loaded/error states
/// - Common utility methods
///
/// Example:
/// ```dart
/// class MyScreenBloc extends ScreenBloc<MyState> {
///   MyScreenBloc({AnalyticsService? analytics})
///     : super(analytics: analytics);
///
///   @override
///   MyState get initialState => const MyLoading();
///
///   void add(MyEvent event) {
///     // Handle events
///   }
/// }
/// ```
abstract class ScreenBloc<S> extends SingleSubscriptionBloc<S> {
  /// Creates a [ScreenBloc].
  ///
  /// [analytics] is optional and used to track screen-related analytics.
  /// [screenName] is the name used for analytics screen tracking.
  ScreenBloc({
    this.analytics,
    this.screenName,
  });

  /// Optional analytics service for tracking events.
  final AnalyticsService? analytics;

  /// The screen name for analytics tracking.
  final String? screenName;

  /// Whether analytics is available.
  bool get hasAnalytics => analytics != null;

  /// The current state, tracked internally.
  ///
  /// This is `null` before any state has been dispatched.
  S? _currentState;

  /// Gets the current state.
  ///
  /// Returns the last dispatched state, or `null` if no state
  /// has been dispatched yet.
  S? get currentState => _currentState;

  /// Whether the current state is a loading state.
  ///
  /// Returns `true` if the current state implements [LoadableState]
  /// and is loading.
  bool get isLoading {
    final state = _currentState;
    return state != null && BlocStateUtils.isLoading(state);
  }

  /// Whether the current state is an error state.
  ///
  /// Returns `true` if the current state implements [ErrorState].
  bool get hasError {
    final state = _currentState;
    return state != null && BlocStateUtils.hasError(state);
  }

  /// The current error message, if in an error state.
  String? get errorMessage {
    final state = _currentState;
    if (state != null) {
      return BlocStateUtils.getErrorMessage(state);
    }
    return null;
  }

  @override
  void dispatchState(S state) {
    _currentState = state;
    super.dispatchState(state);
  }

  /// Logs an analytics event if analytics is available.
  ///
  /// This is a convenience method that silently does nothing
  /// if analytics is not configured.
  Future<void> logAnalyticsEvent(AnalyticsEvent event) async {
    await analytics?.logEvent(event);
  }

  /// Tracks the current screen in analytics.
  ///
  /// Uses the [screenName] if provided, otherwise uses the provided name.
  Future<void> trackScreen([String? name]) async {
    final screen = name ?? screenName;
    if (screen != null) {
      await analytics?.setCurrentScreen(
        screenName: screen,
        screenClass: runtimeType.toString(),
      );
    }
  }
}

/// A [ScreenBloc] with built-in loaded state tracking.
///
/// This class automatically tracks the last loaded state, making it
/// easier to implement refresh and update operations that need access
/// to the current data.
///
/// Example:
/// ```dart
/// class MyBloc extends TrackedScreenBloc<MyState, MyLoaded> {
///   @override
///   MyState get initialState => const MyLoading();
///
///   @override
///   bool isLoadedState(MyState state) => state is MyLoaded;
///
///   @override
///   MyLoaded? extractLoaded(MyState state) {
///     return state is MyLoaded ? state : null;
///   }
///
///   void refresh() {
///     final current = lastLoadedState;
///     if (current == null) return;
///     // Use current data during refresh
///   }
/// }
/// ```
abstract class TrackedScreenBloc<S, L> extends ScreenBloc<S> {
  /// Creates a [TrackedScreenBloc].
  TrackedScreenBloc({
    super.analytics,
    super.screenName,
  });

  /// The last loaded state, if any.
  L? _lastLoadedState;

  /// Gets the last loaded state.
  ///
  /// Returns the most recent state that was identified as a "loaded" state
  /// by [isLoadedState]. This is useful for refresh operations that need
  /// access to the current data.
  L? get lastLoadedState => _lastLoadedState;

  /// Whether the current state is a loaded state.
  ///
  /// Subclasses must implement this to identify which states are
  /// considered "loaded" states.
  bool isLoadedState(S state);

  /// Extracts the loaded state from a general state.
  ///
  /// Returns the state cast to [L] if it's a loaded state,
  /// or `null` otherwise.
  L? extractLoaded(S state);

  @override
  void dispatchState(S state) {
    final loaded = extractLoaded(state);
    if (loaded != null) {
      _lastLoadedState = loaded;
    }
    super.dispatchState(state);
  }

  /// Clears the tracked loaded state.
  ///
  /// Call this when you want to reset the tracked state,
  /// for example when an error occurs.
  void clearLoadedState() {
    _lastLoadedState = null;
  }
}
