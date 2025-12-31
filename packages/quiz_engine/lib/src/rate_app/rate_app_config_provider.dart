import 'package:flutter/widgets.dart';

import '../app/quiz_app.dart';

/// InheritedWidget that provides [RateAppUiConfig] to descendant widgets.
///
/// This allows QuizResultsScreen to access rate app configuration
/// without passing it through every widget in the tree.
///
/// ## Usage
///
/// ```dart
/// // Provide at app level
/// RateAppConfigProvider(
///   config: RateAppUiConfig(appName: 'My App'),
///   child: MaterialApp(...),
/// )
///
/// // Access from descendants
/// final config = RateAppConfigProvider.of(context);
/// ```
class RateAppConfigProvider extends InheritedWidget {
  /// Creates a [RateAppConfigProvider].
  const RateAppConfigProvider({
    super.key,
    required this.config,
    required super.child,
  });

  /// The rate app UI configuration.
  final RateAppUiConfig config;

  /// Returns the [RateAppUiConfig] from the closest ancestor,
  /// or null if no provider is found.
  static RateAppUiConfig? of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<RateAppConfigProvider>();
    return provider?.config;
  }

  @override
  bool updateShouldNotify(RateAppConfigProvider oldWidget) {
    return config != oldWidget.config;
  }
}
