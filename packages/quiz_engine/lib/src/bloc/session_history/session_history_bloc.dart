/// Business Logic Component for Session History.
library;

import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../../widgets/session_card.dart';
import 'session_history_event.dart';
import 'session_history_state.dart';

/// Result of loading session history with pagination info.
class SessionHistoryPage {
  /// Creates a [SessionHistoryPage].
  const SessionHistoryPage({
    required this.sessions,
    required this.hasMore,
    this.nextPageToken,
  });

  /// The sessions in this page.
  final List<SessionCardData> sessions;

  /// Whether there are more sessions to load.
  final bool hasMore;

  /// Token for loading the next page (optional).
  final String? nextPageToken;

  /// Creates an empty page.
  static const empty = SessionHistoryPage(
    sessions: [],
    hasMore: false,
  );
}

/// Abstract interface for providing session history data to the BLoC.
///
/// This interface allows apps to implement their own data fetching logic
/// while the BLoC handles state management and pagination.
abstract class SessionHistoryDataProvider {
  /// Creates a [SessionHistoryDataProvider].
  const SessionHistoryDataProvider();

  /// Loads the initial page of session history.
  ///
  /// Returns a [SessionHistoryPage] with sessions and pagination info.
  Future<SessionHistoryPage> loadInitialSessions();

  /// Loads more sessions for pagination.
  ///
  /// [pageToken] is an optional token from the previous page.
  /// [currentCount] is the number of sessions already loaded.
  Future<SessionHistoryPage> loadMoreSessions({
    String? pageToken,
    required int currentCount,
  });

  /// Deletes a session by ID.
  ///
  /// Returns true if deletion was successful.
  Future<bool> deleteSession(String sessionId);
}

/// BLoC for managing Session History state.
///
/// Handles:
/// - Loading and refreshing session history
/// - Pagination (load more)
/// - Deleting sessions
class SessionHistoryBloc extends SingleSubscriptionBloc<SessionHistoryState> {
  /// Creates a [SessionHistoryBloc].
  ///
  /// [dataProvider] is required to fetch session history data.
  SessionHistoryBloc({
    required SessionHistoryDataProvider dataProvider,
  }) : _dataProvider = dataProvider;

  final SessionHistoryDataProvider _dataProvider;

  String? _nextPageToken;

  /// Dispatches an event to the BLoC.
  void add(SessionHistoryEvent event) {
    switch (event) {
      case LoadSessionHistory():
        _handleLoad();
      case RefreshSessionHistory():
        _handleRefresh();
      case LoadMoreSessionHistory():
        _handleLoadMore();
      case DeleteSession(:final sessionId):
        _handleDelete(sessionId);
    }
  }

  @override
  SessionHistoryState get initialState => const SessionHistoryLoading();

  Future<void> _handleLoad() async {
    dispatchState(const SessionHistoryLoading());
    _nextPageToken = null;

    try {
      final page = await _dataProvider.loadInitialSessions();
      _nextPageToken = page.nextPageToken;
      dispatchState(SessionHistoryLoaded(
        sessions: page.sessions,
        hasMore: page.hasMore,
      ));
    } catch (e) {
      dispatchState(SessionHistoryError(
        message: 'Failed to load session history',
        error: e,
      ));
    }
  }

  Future<void> _handleRefresh() async {
    final currentState = _currentLoadedState;
    if (currentState == null) {
      // If not in loaded state, just do a full load
      await _handleLoad();
      return;
    }

    // Mark as refreshing
    dispatchState(currentState.copyWith(isRefreshing: true));
    _nextPageToken = null;

    try {
      final page = await _dataProvider.loadInitialSessions();
      _nextPageToken = page.nextPageToken;
      dispatchState(SessionHistoryLoaded(
        sessions: page.sessions,
        hasMore: page.hasMore,
        isRefreshing: false,
      ));
    } catch (e) {
      // On refresh failure, keep existing data but stop refreshing
      dispatchState(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<void> _handleLoadMore() async {
    final currentState = _currentLoadedState;
    if (currentState == null) return;

    // Don't load more if already loading or no more items
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    // Mark as loading more
    dispatchState(currentState.copyWith(isLoadingMore: true));

    try {
      final page = await _dataProvider.loadMoreSessions(
        pageToken: _nextPageToken,
        currentCount: currentState.sessions.length,
      );
      _nextPageToken = page.nextPageToken;

      // Get the latest state (it might have changed)
      final latestState = _currentLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(
          sessions: [...latestState.sessions, ...page.sessions],
          hasMore: page.hasMore,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      // On load more failure, stop loading but keep existing data
      final latestState = _currentLoadedState;
      if (latestState != null) {
        dispatchState(latestState.copyWith(isLoadingMore: false));
      }
    }
  }

  Future<void> _handleDelete(String sessionId) async {
    final currentState = _currentLoadedState;
    if (currentState == null) return;

    try {
      final success = await _dataProvider.deleteSession(sessionId);
      if (success) {
        // Get the latest state
        final latestState = _currentLoadedState;
        if (latestState != null) {
          final updatedSessions = latestState.sessions
              .where((s) => s.id != sessionId)
              .toList();
          dispatchState(latestState.copyWith(sessions: updatedSessions));
        }
      }
    } catch (_) {
      // Silently fail - the session remains in the list
    }
  }

  /// Gets the current state if it's a loaded state, null otherwise.
  SessionHistoryLoaded? get _currentLoadedState => _lastLoadedState;

  SessionHistoryLoaded? _lastLoadedState;

  @override
  void dispatchState(SessionHistoryState state) {
    if (state is SessionHistoryLoaded) {
      _lastLoadedState = state;
    } else if (state is SessionHistoryLoading) {
      // Keep last loaded state for refresh purposes
    } else if (state is SessionHistoryError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  /// The current sessions, if in loaded state.
  List<SessionCardData>? get sessions => _lastLoadedState?.sessions;

  /// Whether there are more sessions to load.
  bool get hasMore => _lastLoadedState?.hasMore ?? false;

  /// Whether more sessions are being loaded.
  bool get isLoadingMore => _lastLoadedState?.isLoadingMore ?? false;
}
