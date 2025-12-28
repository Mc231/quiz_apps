import 'package:flutter/widgets.dart';

import 'quiz_services.dart';

/// An InheritedWidget that provides [QuizServices] to descendant widgets.
///
/// Use [QuizServicesProvider.of] to access the services from any descendant:
///
/// ```dart
/// final services = QuizServicesProvider.of(context);
/// services.settingsService.getCurrentSettings();
/// ```
///
/// Or use the context extension for more convenient access:
///
/// ```dart
/// context.services.settingsService.getCurrentSettings();
/// context.settingsService.getCurrentSettings(); // Direct shortcut
/// ```
///
/// ## Example
///
/// ```dart
/// QuizServicesProvider(
///   services: QuizServices(
///     settingsService: settingsService,
///     storageService: storageService,
///     achievementService: achievementService,
///     screenAnalyticsService: analyticsService,
///     quizAnalyticsService: quizAnalyticsService,
///   ),
///   child: MaterialApp(...),
/// )
/// ```
class QuizServicesProvider extends InheritedWidget {
  /// Creates a [QuizServicesProvider].
  const QuizServicesProvider({
    super.key,
    required this.services,
    required super.child,
  });

  /// The services container being provided.
  final QuizServices services;

  /// Returns the [QuizServices] from the closest [QuizServicesProvider] ancestor.
  ///
  /// Throws a [FlutterError] if no [QuizServicesProvider] is found.
  ///
  /// Use [maybeOf] if you want to handle the missing provider case yourself.
  static QuizServices of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<QuizServicesProvider>();
    if (provider == null) {
      throw FlutterError.fromParts([
        ErrorSummary('QuizServicesProvider.of() called with a context '
            'that does not contain a QuizServicesProvider.'),
        ErrorDescription(
            'No QuizServicesProvider ancestor could be found starting from '
            'the context that was passed to QuizServicesProvider.of().'),
        ErrorHint(
            'This can happen if the context you use comes from a widget above '
            'the QuizServicesProvider in the widget tree.'),
        context.describeElement('The context used was'),
      ]);
    }
    return provider.services;
  }

  /// Returns the [QuizServices] from the closest [QuizServicesProvider] ancestor,
  /// or null if no such ancestor exists.
  ///
  /// Use [of] if you want to assert that a provider exists.
  static QuizServices? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<QuizServicesProvider>();
    return provider?.services;
  }

  @override
  bool updateShouldNotify(QuizServicesProvider oldWidget) {
    return services != oldWidget.services;
  }
}