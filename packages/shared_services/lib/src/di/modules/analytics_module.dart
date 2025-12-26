/// Module for registering analytics-related dependencies.
library;

import '../../analytics/analytics_service.dart';
import '../../analytics/services/console_analytics_service.dart';
import '../../analytics/services/no_op_analytics_service.dart';
import '../dependency_module.dart';
import '../service_locator.dart';

/// Dependency module for analytics-related services.
///
/// Registers AnalyticsService with the service locator.
/// By default, registers ConsoleAnalyticsService for development.
///
/// Example:
/// ```dart
/// // Register with default console analytics (development)
/// AnalyticsModule().register(sl);
///
/// // Or register with async initialization
/// await AnalyticsModule.initializeAsync(sl);
///
/// // For production, use Firebase:
/// await AnalyticsModule.initializeAsync(
///   sl,
///   factory: () => FirebaseAnalyticsService(),
/// );
///
/// // For testing, use no-op:
/// await AnalyticsModule.initializeAsync(
///   sl,
///   factory: () => NoOpAnalyticsService(),
/// );
/// ```
class AnalyticsModule extends DependencyModule {
  /// Creates an analytics module.
  ///
  /// [useNoOp] - If true, uses NoOpAnalyticsService (for testing).
  /// [enableLogging] - If true, enables console logging (for ConsoleAnalyticsService).
  AnalyticsModule({
    this.useNoOp = false,
    this.enableLogging = true,
  });

  /// Whether to use NoOpAnalyticsService instead of ConsoleAnalyticsService.
  final bool useNoOp;

  /// Whether to enable logging in ConsoleAnalyticsService.
  final bool enableLogging;

  @override
  void register(ServiceLocator sl) {
    if (useNoOp) {
      sl.registerLazySingleton<AnalyticsService>(() => NoOpAnalyticsService());
    } else {
      sl.registerLazySingleton<AnalyticsService>(
        () => ConsoleAnalyticsService(enableLogging: enableLogging),
      );
    }
  }

  /// Initializes analytics dependencies with async setup.
  ///
  /// Use this method to ensure AnalyticsService is fully initialized
  /// before the app starts.
  ///
  /// [factory] - Optional factory to create a custom analytics service.
  ///             Defaults to ConsoleAnalyticsService.
  ///
  /// Example:
  /// ```dart
  /// // Default (console analytics)
  /// await AnalyticsModule.initializeAsync(sl);
  ///
  /// // With Firebase
  /// await AnalyticsModule.initializeAsync(
  ///   sl,
  ///   factory: () => FirebaseAnalyticsService(),
  /// );
  /// ```
  static Future<void> initializeAsync(
    ServiceLocator sl, {
    AnalyticsService Function()? factory,
  }) async {
    final analyticsService = factory?.call() ?? ConsoleAnalyticsService();
    await analyticsService.initialize();
    sl.registerSingleton<AnalyticsService>(analyticsService);
  }

  /// Registers a NoOpAnalyticsService for testing.
  ///
  /// Use this in unit tests to avoid analytics logging.
  ///
  /// Example:
  /// ```dart
  /// setUp(() {
  ///   AnalyticsModule.registerNoOp(sl);
  /// });
  /// ```
  static void registerNoOp(ServiceLocator sl) {
    sl.registerSingleton<AnalyticsService>(NoOpAnalyticsService());
  }

  @override
  Future<void> dispose() async {
    final analyticsService = sl.getOrNull<AnalyticsService>();
    analyticsService?.dispose();
  }
}
