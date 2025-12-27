/// State classes for the Session Detail BLoC.
library;

import '../../screens/session_detail_screen.dart';

/// Sealed class representing all possible states for session detail.
sealed class SessionDetailState {
  /// Creates a [SessionDetailState].
  const SessionDetailState();

  /// Creates a loading state.
  factory SessionDetailState.loading() = SessionDetailLoading;

  /// Creates a loaded state with session data.
  factory SessionDetailState.loaded({
    required SessionDetailData session,
    QuestionFilterMode filterMode,
    bool isDeleting,
  }) = SessionDetailLoaded;

  /// Creates an error state.
  factory SessionDetailState.error({
    required String message,
    Object? error,
  }) = SessionDetailError;
}

/// State when session detail is loading.
class SessionDetailLoading extends SessionDetailState {
  /// Creates a [SessionDetailLoading].
  const SessionDetailLoading();
}

/// State when session detail is loaded.
class SessionDetailLoaded extends SessionDetailState {
  /// Creates a [SessionDetailLoaded].
  const SessionDetailLoaded({
    required this.session,
    this.filterMode = QuestionFilterMode.all,
    this.isDeleting = false,
  });

  /// The loaded session data.
  final SessionDetailData session;

  /// Current filter mode for questions.
  final QuestionFilterMode filterMode;

  /// Whether the session is being deleted.
  final bool isDeleting;

  /// Creates a copy with updated values.
  SessionDetailLoaded copyWith({
    SessionDetailData? session,
    QuestionFilterMode? filterMode,
    bool? isDeleting,
  }) {
    return SessionDetailLoaded(
      session: session ?? this.session,
      filterMode: filterMode ?? this.filterMode,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionDetailLoaded &&
        other.session == session &&
        other.filterMode == filterMode &&
        other.isDeleting == isDeleting;
  }

  @override
  int get hashCode => Object.hash(session, filterMode, isDeleting);
}

/// State when there's an error loading session detail.
class SessionDetailError extends SessionDetailState {
  /// Creates a [SessionDetailError].
  const SessionDetailError({
    required this.message,
    this.error,
  });

  /// The error message to display.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SessionDetailError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
