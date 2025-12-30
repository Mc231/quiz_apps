/// Initializer for shared services dependency injection.
///
/// Provides a simple API for apps to initialize all shared services
/// with a single call.
library;

import '../storage/database/database_initializer.dart';
import 'dependency_module.dart';
import 'modules/settings_module.dart';
import 'modules/storage_module.dart';
import 'service_locator.dart';

/// Configuration options for shared services initialization.
class SharedServicesConfig {
  /// Creates a [SharedServicesConfig].
  const SharedServicesConfig({
    this.initializeDatabase = true,
    this.customModules = const [],
    this.onError,
    this.onTiming,
  });

  /// Default configuration with all services enabled.
  static const defaultConfig = SharedServicesConfig();

  /// Whether to initialize the database on startup.
  ///
  /// If true, the database will be opened during initialization.
  /// If false, the database will be lazily initialized on first access.
  final bool initializeDatabase;

  /// Additional custom modules to register.
  final List<DependencyModule> customModules;

  /// Callback for handling initialization errors.
  ///
  /// If provided, errors during initialization will be reported here
  /// instead of being thrown. The service that failed will be skipped.
  final void Function(String serviceName, Object error, StackTrace stack)?
      onError;

  /// Callback for performance timing.
  ///
  /// Reports the duration of each initialization step.
  final void Function(String stepName, Duration duration)? onTiming;
}

/// Result of shared services initialization.
class SharedServicesInitResult {
  /// Creates a [SharedServicesInitResult].
  const SharedServicesInitResult({
    required this.success,
    required this.totalDuration,
    this.failedServices = const [],
    this.timings = const {},
  });

  /// Whether all services initialized successfully.
  final bool success;

  /// Total initialization duration.
  final Duration totalDuration;

  /// List of services that failed to initialize.
  final List<String> failedServices;

  /// Timing for each initialization step.
  final Map<String, Duration> timings;

  /// Whether initialization completed within the recommended time (<500ms).
  bool get isPerformant => totalDuration.inMilliseconds < 500;

  @override
  String toString() {
    final buffer = StringBuffer('SharedServicesInitResult(\n');
    buffer.writeln('  success: $success,');
    buffer.writeln('  totalDuration: ${totalDuration.inMilliseconds}ms,');
    buffer.writeln('  isPerformant: $isPerformant,');
    if (failedServices.isNotEmpty) {
      buffer.writeln('  failedServices: $failedServices,');
    }
    if (timings.isNotEmpty) {
      buffer.writeln('  timings: {');
      for (final entry in timings.entries) {
        buffer.writeln('    ${entry.key}: ${entry.value.inMilliseconds}ms,');
      }
      buffer.writeln('  },');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

/// Initializer for shared services.
///
/// Use this class to initialize all shared services with a single call
/// during app startup.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///
///   // Initialize shared services
///   await SharedServicesInitializer.initialize();
///
///   runApp(MyApp());
/// }
/// ```
class SharedServicesInitializer {
  SharedServicesInitializer._();

  static final _modules = <DependencyModule>[];
  static bool _isInitialized = false;

  /// Whether shared services have been initialized.
  static bool get isInitialized => _isInitialized;

  /// Initializes all shared services.
  ///
  /// This method registers all shared service dependencies with the
  /// service locator and optionally initializes async resources like
  /// the database.
  ///
  /// This should be called once during app startup before runApp().
  ///
  /// Returns a [SharedServicesInitResult] with timing and error information.
  ///
  /// Example:
  /// ```dart
  /// await SharedServicesInitializer.initialize();
  /// ```
  ///
  /// With custom configuration and error handling:
  /// ```dart
  /// final result = await SharedServicesInitializer.initialize(
  ///   config: SharedServicesConfig(
  ///     initializeDatabase: false,
  ///     customModules: [MyCustomModule()],
  ///     onError: (service, error, stack) {
  ///       debugPrint('Failed to init $service: $error');
  ///     },
  ///     onTiming: (step, duration) {
  ///       debugPrint('$step took ${duration.inMilliseconds}ms');
  ///     },
  ///   ),
  /// );
  /// if (!result.isPerformant) {
  ///   debugPrint('Warning: Initialization took ${result.totalDuration}');
  /// }
  /// ```
  static Future<SharedServicesInitResult> initialize({
    SharedServicesConfig config = SharedServicesConfig.defaultConfig,
    ServiceLocator? serviceLocator,
  }) async {
    final totalStopwatch = Stopwatch()..start();
    final timings = <String, Duration>{};
    final failedServices = <String>[];

    if (_isInitialized) {
      totalStopwatch.stop();
      return SharedServicesInitResult(
        success: true,
        totalDuration: totalStopwatch.elapsed,
        timings: timings,
      );
    }

    final locator = serviceLocator ?? sl;

    // Helper to time and handle errors for each step
    Future<bool> runStep(
      String stepName,
      Future<void> Function() action,
    ) async {
      final stepwatch = Stopwatch()..start();
      try {
        await action();
        stepwatch.stop();
        timings[stepName] = stepwatch.elapsed;
        config.onTiming?.call(stepName, stepwatch.elapsed);
        return true;
      } catch (e, stack) {
        stepwatch.stop();
        timings[stepName] = stepwatch.elapsed;
        failedServices.add(stepName);
        if (config.onError != null) {
          config.onError!(stepName, e, stack);
          return false;
        } else {
          // Re-throw if no error handler provided
          rethrow;
        }
      }
    }

    // Initialize database factory for web platform
    await runStep('DatabaseInitializer', () async {
      await DatabaseInitializer.initialize();
    });

    // Register settings module (async initialization for SharedPreferences)
    await runStep('SettingsModule', () async {
      final settingsModule = SettingsModule();
      _modules.add(settingsModule);
      await SettingsModule.initializeAsync(locator);
    });

    // Register storage module
    await runStep('StorageModule', () async {
      final storageModule = StorageModule();
      _modules.add(storageModule);

      if (config.initializeDatabase) {
        // Initialize with async database setup
        await StorageModule.initializeAsync(locator);
      } else {
        // Register without immediate initialization
        storageModule.register(locator);
      }
    });

    // Register custom modules
    for (final module in config.customModules) {
      final moduleName = module.runtimeType.toString();
      await runStep(moduleName, () async {
        module.register(locator);
        _modules.add(module);
      });
    }

    _isInitialized = true;
    totalStopwatch.stop();

    return SharedServicesInitResult(
      success: failedServices.isEmpty,
      totalDuration: totalStopwatch.elapsed,
      failedServices: failedServices,
      timings: timings,
    );
  }

  /// Disposes all shared services.
  ///
  /// This should be called when the app is shutting down to properly
  /// clean up resources.
  ///
  /// Example:
  /// ```dart
  /// await SharedServicesInitializer.dispose();
  /// ```
  static Future<void> dispose() async {
    if (!_isInitialized) {
      return;
    }

    // Dispose modules in reverse order
    for (final module in _modules.reversed) {
      await module.dispose();
    }

    _modules.clear();

    // Reset service locator
    await sl.reset(dispose: true);

    _isInitialized = false;
  }

  /// Resets shared services for testing.
  ///
  /// This clears all registrations and allows re-initialization.
  /// Should only be used in tests.
  static Future<void> resetForTesting() async {
    await dispose();
    sl.resetSync();
  }
}
