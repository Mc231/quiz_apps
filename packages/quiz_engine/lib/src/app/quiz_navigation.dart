import 'package:flutter/widgets.dart';

import 'quiz_navigation_result.dart';

/// Navigation capabilities exposed via context.
///
/// Access navigation from any widget in the tree:
/// ```dart
/// // Navigate to a quiz category
/// final result = await context.quizNavigation.navigateToQuiz('europe');
///
/// // Switch to achievements tab
/// context.quizNavigation.switchToTab(1);
/// ```
///
/// This interface is implemented internally by QuizApp and provided
/// via [QuizNavigationProvider].
abstract class QuizNavigation {
  /// Navigate to quiz for the specified category ID.
  ///
  /// Looks up the category by ID in the app's categories list,
  /// loads questions, and navigates to the quiz screen.
  ///
  /// Returns [NavigationSuccess] if navigation succeeded,
  /// [NavigationInvalidId] if category was not found,
  /// [NavigationNotReady] if the navigator is not yet available.
  Future<QuizNavigationResult> navigateToQuiz(String categoryId);

  /// Navigate to achievement details.
  ///
  /// Switches to the achievements tab and highlights/scrolls to
  /// the specified achievement.
  ///
  /// Returns [NavigationSuccess] if navigation succeeded,
  /// [NavigationInvalidId] if achievement was not found,
  /// [NavigationNotReady] if the navigator is not yet available.
  Future<QuizNavigationResult> navigateToAchievement(String achievementId);

  /// Navigate to a challenge.
  ///
  /// Switches to the play tab, selects challenges sub-tab,
  /// and opens the category picker for the specified challenge.
  ///
  /// Returns [NavigationSuccess] if navigation succeeded,
  /// [NavigationInvalidId] if challenge was not found,
  /// [NavigationNotReady] if the navigator is not yet available.
  Future<QuizNavigationResult> navigateToChallenge(String challengeId);

  /// Switch to a specific bottom navigation tab.
  ///
  /// Tab indices are based on the app's tab configuration:
  /// - 0: Play tab
  /// - 1: Achievements tab (if configured)
  /// - 2: History tab (if configured)
  /// - 3: Statistics tab (if configured)
  ///
  /// Does nothing if index is out of range.
  void switchToTab(int tabIndex);

  /// Whether navigation is ready.
  ///
  /// Returns true if the navigator is mounted and ready to accept
  /// navigation commands. Returns false during app initialization
  /// or if the home screen hasn't been rendered yet.
  bool get isReady;
}

/// Provides [QuizNavigation] to descendant widgets via context.
///
/// This is an internal widget used by [QuizApp] to expose navigation
/// capabilities. Use [QuizNavigationProvider.of] or the context extension
/// to access navigation.
///
/// ```dart
/// // Via static method
/// final nav = QuizNavigationProvider.of(context);
///
/// // Via context extension (preferred)
/// final nav = context.quizNavigation;
///
/// // Via static instance (for deep link handlers outside widget tree)
/// final nav = QuizNavigationProvider.instance;
/// ```
class QuizNavigationProvider extends InheritedWidget {
  /// The navigation instance to provide.
  final QuizNavigation navigation;

  /// Static instance for access outside widget tree (e.g., deep link handlers).
  static QuizNavigation? _instance;

  /// Gets the current navigation instance, if registered.
  ///
  /// Use this when you need to access navigation from outside the widget tree,
  /// such as in deep link handlers that run before the widget tree is built.
  ///
  /// Returns null if no navigation has been registered (app not yet initialized).
  static QuizNavigation? get instance => _instance;

  /// Registers a navigation instance for static access.
  ///
  /// Called internally by QuizApp when the navigation is ready.
  static void register(QuizNavigation navigation) {
    _instance = navigation;
  }

  /// Unregisters the navigation instance.
  ///
  /// Called internally by QuizApp when disposed.
  static void unregister() {
    _instance = null;
  }

  /// Creates a provider for the given navigation.
  const QuizNavigationProvider({
    super.key,
    required this.navigation,
    required super.child,
  });

  /// Gets the navigation from the closest [QuizNavigationProvider] ancestor.
  ///
  /// Throws if no [QuizNavigationProvider] is found in the widget tree.
  static QuizNavigation of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<QuizNavigationProvider>();
    assert(
      provider != null,
      'No QuizNavigationProvider found in context. '
      'Make sure your widget is a descendant of QuizApp.',
    );
    return provider!.navigation;
  }

  /// Gets the navigation from the closest [QuizNavigationProvider] ancestor,
  /// or null if none is found.
  ///
  /// Use this when navigation might not be available (e.g., in deep link
  /// handlers that run before the widget tree is fully built).
  static QuizNavigation? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<QuizNavigationProvider>();
    return provider?.navigation;
  }

  @override
  bool updateShouldNotify(QuizNavigationProvider oldWidget) {
    return navigation != oldWidget.navigation;
  }
}

/// A no-op implementation of [QuizNavigation] for testing.
///
/// All navigation methods return [NavigationNotReady].
class NoOpQuizNavigation implements QuizNavigation {
  /// Creates a no-op navigation instance.
  const NoOpQuizNavigation();

  @override
  Future<QuizNavigationResult> navigateToQuiz(String categoryId) async {
    return const NavigationNotReady();
  }

  @override
  Future<QuizNavigationResult> navigateToAchievement(
      String achievementId) async {
    return const NavigationNotReady();
  }

  @override
  Future<QuizNavigationResult> navigateToChallenge(String challengeId) async {
    return const NavigationNotReady();
  }

  @override
  void switchToTab(int tabIndex) {}

  @override
  bool get isReady => false;
}