/// Result of a navigation attempt via [QuizNavigation].
///
/// Use pattern matching to handle different outcomes:
/// ```dart
/// final result = await context.quizNavigation.navigateToQuiz('europe');
/// switch (result) {
///   case NavigationSuccess():
///     // Navigation succeeded
///   case NavigationNotReady():
///     // Navigator not yet available, try again later
///   case NavigationInvalidId(:final id, :final type):
///     showSnackBar('Could not find $type: $id');
///   case NavigationError(:final message):
///     showSnackBar('Navigation failed: $message');
/// }
/// ```
sealed class QuizNavigationResult {
  const QuizNavigationResult();

  /// Navigation completed successfully.
  factory QuizNavigationResult.success() = NavigationSuccess;

  /// Navigator is not yet ready (UI not mounted).
  factory QuizNavigationResult.notReady() = NavigationNotReady;

  /// The requested ID was not found.
  factory QuizNavigationResult.invalidId({
    required String id,
    required String type,
  }) = NavigationInvalidId;

  /// Navigation failed with an error.
  factory QuizNavigationResult.error(String message) = NavigationError;

  /// Whether the navigation was successful.
  bool get isSuccess => this is NavigationSuccess;

  /// Whether the navigation failed.
  bool get isFailure => !isSuccess;
}

/// Navigation completed successfully.
class NavigationSuccess extends QuizNavigationResult {
  const NavigationSuccess();

  @override
  String toString() => 'NavigationSuccess()';

  @override
  bool operator ==(Object other) => other is NavigationSuccess;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// Navigator is not yet ready (UI not mounted).
///
/// This can happen when a deep link arrives before the app is fully loaded.
/// The caller should either retry after a delay or ignore the navigation.
class NavigationNotReady extends QuizNavigationResult {
  const NavigationNotReady();

  @override
  String toString() => 'NavigationNotReady()';

  @override
  bool operator ==(Object other) => other is NavigationNotReady;

  @override
  int get hashCode => runtimeType.hashCode;
}

/// The requested ID was not found.
///
/// For example, a category ID that doesn't exist in the categories list,
/// or an achievement ID that's not defined.
class NavigationInvalidId extends QuizNavigationResult {
  /// The ID that was requested but not found.
  final String id;

  /// The type of resource (e.g., 'category', 'achievement', 'challenge').
  final String type;

  const NavigationInvalidId({
    required this.id,
    required this.type,
  });

  @override
  String toString() => 'NavigationInvalidId(id: $id, type: $type)';

  @override
  bool operator ==(Object other) =>
      other is NavigationInvalidId && other.id == id && other.type == type;

  @override
  int get hashCode => Object.hash(id, type);
}

/// Navigation failed with an error.
class NavigationError extends QuizNavigationResult {
  /// Error message describing what went wrong.
  final String message;

  const NavigationError(this.message);

  @override
  String toString() => 'NavigationError(message: $message)';

  @override
  bool operator ==(Object other) =>
      other is NavigationError && other.message == message;

  @override
  int get hashCode => message.hashCode;
}