import 'package:flutter/widgets.dart';

import 'quiz_navigation.dart';

/// Extension on [BuildContext] for convenient access to [QuizNavigation].
///
/// Usage:
/// ```dart
/// // Navigate to quiz
/// final result = await context.quizNavigation.navigateToQuiz('europe');
///
/// // Safe access (returns null if not available)
/// final nav = context.maybeQuizNavigation;
/// if (nav != null && nav.isReady) {
///   await nav.navigateToQuiz('europe');
/// }
/// ```
extension QuizNavigationContext on BuildContext {
  /// Gets the [QuizNavigation] from context.
  ///
  /// Throws if no [QuizNavigationProvider] is found in the widget tree.
  /// Use [maybeQuizNavigation] for safe access.
  QuizNavigation get quizNavigation => QuizNavigationProvider.of(this);

  /// Gets the [QuizNavigation] from context, or null if not available.
  ///
  /// Use this when navigation might not be available, such as in
  /// deep link handlers that may run before the widget tree is built.
  QuizNavigation? get maybeQuizNavigation =>
      QuizNavigationProvider.maybeOf(this);
}