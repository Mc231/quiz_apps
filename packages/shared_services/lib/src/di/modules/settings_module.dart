/// Module for registering settings-related dependencies.
library;

import '../../settings/settings_service.dart';
import '../dependency_module.dart';
import '../service_locator.dart';

/// Dependency module for settings-related services.
///
/// Registers SettingsService with the service locator.
///
/// Example:
/// ```dart
/// // Register settings dependencies with async initialization
/// await SettingsModule.initializeAsync(sl);
///
/// // Or register lazily (initialize on first access)
/// SettingsModule().register(sl);
/// ```
class SettingsModule extends DependencyModule {
  @override
  void register(ServiceLocator sl) {
    // Register SettingsService as lazy singleton
    // Note: initialize() must be called before using the service
    sl.registerLazySingleton<SettingsService>(() => SettingsService());
  }

  /// Initializes settings dependencies with async setup.
  ///
  /// Use this method to ensure SettingsService is fully initialized
  /// before the app starts.
  ///
  /// Example:
  /// ```dart
  /// await SettingsModule.initializeAsync(sl);
  /// final settings = sl.get<SettingsService>();
  /// ```
  static Future<void> initializeAsync(ServiceLocator sl) async {
    final settingsService = SettingsService();
    await settingsService.initialize();
    sl.registerSingleton<SettingsService>(settingsService);
  }

  @override
  Future<void> dispose() async {
    final settingsService = sl.getOrNull<SettingsService>();
    settingsService?.dispose();
  }
}