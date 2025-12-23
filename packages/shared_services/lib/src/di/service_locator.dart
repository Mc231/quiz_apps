/// Central service locator for dependency injection.
///
/// A simple, library-free dependency injection system using the
/// service locator pattern. Supports singleton, lazy singleton,
/// and factory registrations.
///
/// Example:
/// ```dart
/// // Register dependencies
/// sl.registerSingleton<Database>(database);
/// sl.registerLazySingleton<Repository>(() => RepositoryImpl(sl.get()));
/// sl.registerFactory<UseCase>(() => UseCaseImpl(sl.get()));
///
/// // Resolve dependencies
/// final repo = sl.get<Repository>();
/// ```
library;

/// Central service locator for dependency injection.
///
/// Use [ServiceLocator.instance] or the global [sl] shortcut to access
/// the singleton instance.
class ServiceLocator {
  ServiceLocator._();

  static final ServiceLocator instance = ServiceLocator._();

  final _singletons = <Type, dynamic>{};
  final _lazySingletons = <Type, dynamic Function()>{};
  final _factories = <Type, dynamic Function()>{};

  /// Registers a singleton instance that is already created.
  ///
  /// The same instance will be returned every time [get] is called.
  ///
  /// Example:
  /// ```dart
  /// final database = await Database.open();
  /// sl.registerSingleton<Database>(database);
  /// ```
  void registerSingleton<T>(T instance) {
    _assertNotRegistered<T>();
    _singletons[T] = instance;
  }

  /// Registers a lazy singleton that will be created on first access.
  ///
  /// The factory is called once when [get] is first called, and the
  /// same instance is returned on subsequent calls.
  ///
  /// Example:
  /// ```dart
  /// sl.registerLazySingleton<Repository>(() => RepositoryImpl(sl.get()));
  /// ```
  void registerLazySingleton<T>(T Function() factory) {
    _assertNotRegistered<T>();
    _lazySingletons[T] = factory;
  }

  /// Registers a factory that creates a new instance each time.
  ///
  /// A new instance is created every time [get] is called.
  ///
  /// Example:
  /// ```dart
  /// sl.registerFactory<UseCase>(() => UseCaseImpl(sl.get()));
  /// ```
  void registerFactory<T>(T Function() factory) {
    _assertNotRegistered<T>();
    _factories[T] = factory;
  }

  /// Gets a registered dependency.
  ///
  /// Throws [StateError] if the type is not registered.
  ///
  /// Example:
  /// ```dart
  /// final repo = sl.get<Repository>();
  /// ```
  T get<T>() {
    // Check singletons first (already created instances)
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }

    // Check lazy singletons (create and cache on first access)
    if (_lazySingletons.containsKey(T)) {
      final instance = _lazySingletons[T]!() as T;
      _singletons[T] = instance;
      _lazySingletons.remove(T);
      return instance;
    }

    // Check factories (create new instance each time)
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }

    throw StateError(
      'Type $T is not registered in ServiceLocator. '
      'Make sure to register it before calling get<$T>().',
    );
  }

  /// Gets a registered dependency, or null if not registered.
  ///
  /// Unlike [get], this method returns null instead of throwing
  /// if the type is not registered.
  T? getOrNull<T>() {
    try {
      return get<T>();
    } on StateError {
      return null;
    }
  }

  /// Checks if a type is registered.
  bool isRegistered<T>() {
    return _singletons.containsKey(T) ||
        _lazySingletons.containsKey(T) ||
        _factories.containsKey(T);
  }

  /// Unregisters a type.
  ///
  /// Returns true if the type was registered and removed,
  /// false if it wasn't registered.
  bool unregister<T>() {
    final removed = _singletons.remove(T) != null ||
        _lazySingletons.remove(T) != null ||
        _factories.remove(T) != null;
    return removed;
  }

  /// Resets all registrations.
  ///
  /// This is primarily useful for testing to ensure a clean state
  /// between tests.
  ///
  /// If [dispose] is true, will attempt to call dispose() on any
  /// singleton instances that implement [Disposable].
  Future<void> reset({bool dispose = false}) async {
    if (dispose) {
      for (final instance in _singletons.values) {
        if (instance is Disposable) {
          await instance.dispose();
        }
      }
    }

    _singletons.clear();
    _lazySingletons.clear();
    _factories.clear();
  }

  /// Resets all registrations synchronously.
  ///
  /// Unlike [reset], this does not dispose instances. Use [reset]
  /// if you need to properly dispose resources.
  void resetSync() {
    _singletons.clear();
    _lazySingletons.clear();
    _factories.clear();
  }

  void _assertNotRegistered<T>() {
    if (isRegistered<T>()) {
      throw StateError(
        'Type $T is already registered in ServiceLocator. '
        'Call unregister<$T>() first if you want to replace it.',
      );
    }
  }

  /// Returns debugging information about registered types.
  Map<String, List<String>> get debugInfo => {
        'singletons': _singletons.keys.map((t) => t.toString()).toList(),
        'lazySingletons': _lazySingletons.keys.map((t) => t.toString()).toList(),
        'factories': _factories.keys.map((t) => t.toString()).toList(),
      };
}

/// Global shortcut for [ServiceLocator.instance].
///
/// Example:
/// ```dart
/// sl.registerLazySingleton<Repository>(() => RepositoryImpl());
/// final repo = sl.get<Repository>();
/// ```
final sl = ServiceLocator.instance;

/// Interface for objects that can be disposed.
///
/// Implement this interface to allow the [ServiceLocator] to properly
/// clean up resources when [ServiceLocator.reset] is called with
/// `dispose: true`.
abstract class Disposable {
  /// Disposes of any resources held by this object.
  Future<void> dispose();
}
