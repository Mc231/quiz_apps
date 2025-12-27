/// Event classes for the Session History BLoC.
library;

/// Base sealed class for session history events.
sealed class SessionHistoryEvent {
  const SessionHistoryEvent();

  /// Factory constructor for load event.
  factory SessionHistoryEvent.load() = LoadSessionHistory;

  /// Factory constructor for refresh event.
  factory SessionHistoryEvent.refresh() = RefreshSessionHistory;

  /// Factory constructor for load more event (pagination).
  factory SessionHistoryEvent.loadMore() = LoadMoreSessionHistory;

  /// Factory constructor for delete session event.
  factory SessionHistoryEvent.deleteSession(String sessionId) =
      DeleteSession;
}

/// Event to load initial session history.
class LoadSessionHistory extends SessionHistoryEvent {
  /// Creates a [LoadSessionHistory] event.
  const LoadSessionHistory();
}

/// Event to refresh session history.
class RefreshSessionHistory extends SessionHistoryEvent {
  /// Creates a [RefreshSessionHistory] event.
  const RefreshSessionHistory();
}

/// Event to load more sessions (pagination).
class LoadMoreSessionHistory extends SessionHistoryEvent {
  /// Creates a [LoadMoreSessionHistory] event.
  const LoadMoreSessionHistory();
}

/// Event to delete a session from history.
class DeleteSession extends SessionHistoryEvent {
  /// Creates a [DeleteSession] event.
  const DeleteSession(this.sessionId);

  /// The ID of the session to delete.
  final String sessionId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeleteSession && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}
