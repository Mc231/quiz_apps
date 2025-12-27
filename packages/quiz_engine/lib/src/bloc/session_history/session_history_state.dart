/// State classes for the Session History BLoC.
library;

import '../../widgets/session_card.dart';

/// Base sealed class for session history state.
sealed class SessionHistoryState {
  const SessionHistoryState();

  /// Factory constructor for initial loading state.
  factory SessionHistoryState.loading() = SessionHistoryLoading;

  /// Factory constructor for loaded state with data.
  factory SessionHistoryState.loaded({
    required List<SessionCardData> sessions,
    bool hasMore,
    bool isLoadingMore,
    bool isRefreshing,
  }) = SessionHistoryLoaded;

  /// Factory constructor for error state.
  factory SessionHistoryState.error({
    required String message,
    Object? error,
  }) = SessionHistoryError;
}

/// Initial loading state.
class SessionHistoryLoading extends SessionHistoryState {
  /// Creates a [SessionHistoryLoading] state.
  const SessionHistoryLoading();
}

/// Loaded state with session history data.
class SessionHistoryLoaded extends SessionHistoryState {
  /// Creates a [SessionHistoryLoaded] state.
  const SessionHistoryLoaded({
    required this.sessions,
    this.hasMore = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
  });

  /// List of session cards.
  final List<SessionCardData> sessions;

  /// Whether there are more sessions to load.
  final bool hasMore;

  /// Whether more sessions are being loaded.
  final bool isLoadingMore;

  /// Whether a refresh is in progress.
  final bool isRefreshing;

  /// Whether the session list is empty.
  bool get isEmpty => sessions.isEmpty;

  /// Creates a copy of this state with optional new values.
  SessionHistoryLoaded copyWith({
    List<SessionCardData>? sessions,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
  }) {
    return SessionHistoryLoaded(
      sessions: sessions ?? this.sessions,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SessionHistoryLoaded) return false;
    if (sessions.length != other.sessions.length) return false;
    for (var i = 0; i < sessions.length; i++) {
      if (sessions[i] != other.sessions[i]) return false;
    }
    return hasMore == other.hasMore &&
        isLoadingMore == other.isLoadingMore &&
        isRefreshing == other.isRefreshing;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(sessions),
        hasMore,
        isLoadingMore,
        isRefreshing,
      );
}

/// Error state when loading session history fails.
class SessionHistoryError extends SessionHistoryState {
  /// Creates a [SessionHistoryError] state.
  const SessionHistoryError({
    required this.message,
    this.error,
  });

  /// User-friendly error message.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionHistoryError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
