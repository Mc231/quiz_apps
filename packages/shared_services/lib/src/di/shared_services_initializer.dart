/// Initializer for shared services dependency injection.
///
/// Provides a simple API for apps to initialize all shared services
/// with a single call.
library;

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
  /// Example:
  /// ```dart
  /// await SharedServicesInitializer.initialize();
  /// ```
  ///
  /// With custom configuration:
  /// ```dart
  /// await SharedServicesInitializer.initialize(
  ///   config: SharedServicesConfig(
  ///     initializeDatabase: false,
  ///     customModules: [MyCustomModule()],
  ///   ),
  /// );
  /// ```
  static Future<void> initialize({
    SharedServicesConfig config = SharedServicesConfig.defaultConfig,
    ServiceLocator? serviceLocator,
  }) async {
    if (_isInitialized) {
      return;
    }

    final locator = serviceLocator ?? sl;

    // Register settings module (async initialization for SharedPreferences)
    final settingsModule = SettingsModule();
    _modules.add(settingsModule);
    await SettingsModule.initializeAsync(locator);

    // Register storage module
    final storageModule = StorageModule();
    _modules.add(storageModule);

    if (config.initializeDatabase) {
      // Initialize with async database setup
      await StorageModule.initializeAsync(locator);
    } else {
      // Register without immediate initialization
      storageModule.register(locator);
    }

    // Register custom modules
    for (final module in config.customModules) {
      module.register(locator);
      _modules.add(module);
    }

    _isInitialized = true;
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
