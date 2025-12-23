/// Base class for dependency modules.
///
/// Modules organize related dependencies into logical groups.
/// Each module is responsible for registering its own dependencies
/// with the [ServiceLocator].
///
/// Example:
/// ```dart
/// class StorageModule extends DependencyModule {
///   @override
///   void register(ServiceLocator sl) {
///     sl.registerLazySingleton<Database>(() => DatabaseImpl());
///     sl.registerLazySingleton<Repository>(() => RepositoryImpl(sl.get()));
///   }
/// }
///
/// // In app initialization
/// StorageModule().register(sl);
/// ```
library;

import 'service_locator.dart';

/// Base class for organizing dependency registrations into modules.
///
/// Extend this class to create logical groupings of related dependencies.
/// Each module should be responsible for a specific feature or layer
/// of the application.
abstract class DependencyModule {
  /// Registers all dependencies for this module.
  ///
  /// Override this method to register your module's dependencies
  /// with the service locator.
  ///
  /// Example:
  /// ```dart
  /// @override
  /// void register(ServiceLocator sl) {
  ///   sl.registerLazySingleton<MyService>(() => MyServiceImpl());
  /// }
  /// ```
  void register(ServiceLocator sl);

  /// Disposes resources when this module is no longer needed.
  ///
  /// Override this method if your module needs to perform cleanup
  /// when the application is shutting down.
  ///
  /// The default implementation does nothing.
  Future<void> dispose() async {}
}

/// A collection of modules that can be registered together.
///
/// Use this to organize multiple modules and register them
/// in a single call.
///
/// Example:
/// ```dart
/// final modules = ModuleRegistry([
///   StorageModule(),
///   NetworkModule(),
///   AnalyticsModule(),
/// ]);
///
/// await modules.registerAll();
/// ```
class ModuleRegistry {
  /// Creates a module registry with the given modules.
  ModuleRegistry(this._modules);

  final List<DependencyModule> _modules;

  /// Registers all modules with the default service locator.
  void registerAll() {
    for (final module in _modules) {
      module.register(sl);
    }
  }

  /// Registers all modules with a specific service locator.
  void registerAllWith(ServiceLocator serviceLocator) {
    for (final module in _modules) {
      module.register(serviceLocator);
    }
  }

  /// Disposes all modules.
  Future<void> disposeAll() async {
    for (final module in _modules) {
      await module.dispose();
    }
  }
}
