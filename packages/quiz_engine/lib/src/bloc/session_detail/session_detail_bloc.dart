/// BLoC for managing session detail state.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../../screens/session_detail_screen.dart';
import 'session_detail_event.dart';
import 'session_detail_state.dart';

/// Interface for providing session detail data.
///
/// Apps must implement this interface to provide data to [SessionDetailBloc].
abstract interface class SessionDetailDataProvider {
  /// Loads session detail by ID.
  ///
  /// Returns [SessionDetailData] for the given session ID.
  /// Throws an exception if the session cannot be loaded.
  Future<SessionDetailData> loadSessionDetail(String sessionId);

  /// Deletes a session by ID.
  ///
  /// Returns `true` if the session was deleted successfully.
  /// Throws an exception if the deletion fails.
  Future<bool> deleteSession(String sessionId);
}

/// BLoC for managing session detail state.
///
/// Handles loading session detail data, managing filter mode, and deletion.
class SessionDetailBloc extends SingleSubscriptionBloc<SessionDetailState> {
  /// Creates a [SessionDetailBloc].
  SessionDetailBloc({
    required SessionDetailDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final SessionDetailDataProvider _dataProvider;

  /// The current session ID being displayed.
  String? _currentSessionId;

  /// Tracks the last loaded state for access to current data.
  SessionDetailLoaded? _lastLoadedState;

  @override
  SessionDetailState get initialState => const SessionDetailLoading();

  /// Returns the current session data, if loaded.
  SessionDetailData? get session => _lastLoadedState?.session;

  /// Returns the current filter mode.
  QuestionFilterMode get filterMode =>
      _lastLoadedState?.filterMode ?? QuestionFilterMode.all;

  /// Adds an event to the BLoC.
  void add(SessionDetailEvent event) {
    switch (event) {
      case LoadSessionDetail():
        _handleLoad(event);
      case RefreshSessionDetail():
        _handleRefresh();
      case ChangeFilterMode():
        _handleChangeFilterMode(event);
      case DeleteSessionDetail():
        _handleDelete();
    }
  }

  @override
  void dispatchState(SessionDetailState state) {
    if (state is SessionDetailLoaded) {
      _lastLoadedState = state;
    } else if (state is SessionDetailLoading) {
      // Keep last loaded state for refresh purposes
    } else if (state is SessionDetailError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  Future<void> _handleLoad(LoadSessionDetail event) async {
    _currentSessionId = event.sessionId;
    dispatchState(const SessionDetailLoading());

    try {
      final session = await _dataProvider.loadSessionDetail(event.sessionId);
      dispatchState(SessionDetailState.loaded(session: session));
    } catch (e) {
      dispatchState(SessionDetailState.error(
        message: 'Failed to load session detail',
        error: e,
      ));
    }
  }

  Future<void> _handleRefresh() async {
    if (_currentSessionId == null) {
      return;
    }

    final currentState = _lastLoadedState;
    if (currentState == null) {
      // If not loaded yet, just load normally
      add(SessionDetailEvent.load(_currentSessionId!));
      return;
    }

    try {
      final session =
          await _dataProvider.loadSessionDetail(_currentSessionId!);
      dispatchState(SessionDetailState.loaded(
        session: session,
        filterMode: currentState.filterMode, // Preserve filter mode
      ));
    } catch (e) {
      // Keep existing data on refresh failure
      dispatchState(SessionDetailState.error(
        message: 'Failed to refresh session detail',
        error: e,
      ));
    }
  }

  void _handleChangeFilterMode(ChangeFilterMode event) {
    final currentState = _lastLoadedState;
    if (currentState != null) {
      dispatchState(currentState.copyWith(filterMode: event.filterMode));
    }
  }

  Future<void> _handleDelete() async {
    if (_currentSessionId == null) {
      return;
    }

    final currentState = _lastLoadedState;
    if (currentState == null) {
      return;
    }

    dispatchState(currentState.copyWith(isDeleting: true));

    try {
      await _dataProvider.deleteSession(_currentSessionId!);
      // After successful deletion, emit a state with isDeleting false
      // The parent widget should handle navigation back
      dispatchState(currentState.copyWith(isDeleting: false));
    } catch (e) {
      dispatchState(currentState.copyWith(isDeleting: false));
      dispatchState(SessionDetailState.error(
        message: 'Failed to delete session',
        error: e,
      ));
    }
  }
}
