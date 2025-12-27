/// Event classes for the Session Detail BLoC.
library;

import '../../screens/session_detail_screen.dart';

/// Sealed class representing all possible events for session detail.
sealed class SessionDetailEvent {
  /// Creates a [SessionDetailEvent].
  const SessionDetailEvent();

  /// Creates a load event to load session by ID.
  factory SessionDetailEvent.load(String sessionId) = LoadSessionDetail;

  /// Creates a refresh event.
  factory SessionDetailEvent.refresh() = RefreshSessionDetail;

  /// Creates an event to change the question filter mode.
  factory SessionDetailEvent.changeFilterMode(QuestionFilterMode filterMode) =
      ChangeFilterMode;

  /// Creates a delete event.
  factory SessionDetailEvent.delete() = DeleteSessionDetail;
}

/// Event to load session detail by ID.
class LoadSessionDetail extends SessionDetailEvent {
  /// Creates a [LoadSessionDetail].
  const LoadSessionDetail(this.sessionId);

  /// The ID of the session to load.
  final String sessionId;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LoadSessionDetail && other.sessionId == sessionId;
  }

  @override
  int get hashCode => sessionId.hashCode;
}

/// Event to refresh session detail.
class RefreshSessionDetail extends SessionDetailEvent {
  /// Creates a [RefreshSessionDetail].
  const RefreshSessionDetail();
}

/// Event to change the question filter mode.
class ChangeFilterMode extends SessionDetailEvent {
  /// Creates a [ChangeFilterMode].
  const ChangeFilterMode(this.filterMode);

  /// The new filter mode.
  final QuestionFilterMode filterMode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChangeFilterMode && other.filterMode == filterMode;
  }

  @override
  int get hashCode => filterMode.hashCode;
}

/// Event to delete the session.
class DeleteSessionDetail extends SessionDetailEvent {
  /// Creates a [DeleteSessionDetail].
  const DeleteSessionDetail();
}
