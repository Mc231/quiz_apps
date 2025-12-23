/// Repository for user settings operations.
///
/// Provides a unified interface for managing user settings with
/// caching, reactive updates via Streams, and migration support from
/// SharedPreferences.
library;

import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import '../data_sources/settings_data_source.dart';
import '../models/user_settings_model.dart';

/// Abstract interface for settings repository operations.
abstract class SettingsRepository {
  // ===========================================================================
  // Full Settings
  // ===========================================================================

  /// Gets the current user settings.
  Future<UserSettingsModel> getSettings();

  /// Updates user settings.
  Future<void> updateSettings(UserSettingsModel settings);

  /// Resets settings to defaults.
  Future<void> resetSettings();

  // ===========================================================================
  // Sound Settings
  // ===========================================================================

  /// Gets whether sound is enabled.
  Future<bool> isSoundEnabled();

  /// Sets whether sound is enabled.
  Future<void> setSoundEnabled(bool enabled);

  // ===========================================================================
  // Haptic Settings
  // ===========================================================================

  /// Gets whether haptic feedback is enabled.
  Future<bool> isHapticEnabled();

  /// Sets whether haptic feedback is enabled.
  Future<void> setHapticEnabled(bool enabled);

  // ===========================================================================
  // Exit Confirmation Settings
  // ===========================================================================

  /// Gets whether exit confirmation is enabled.
  Future<bool> isExitConfirmationEnabled();

  /// Sets whether exit confirmation is enabled.
  Future<void> setExitConfirmationEnabled(bool enabled);

  // ===========================================================================
  // Theme Settings
  // ===========================================================================

  /// Gets the current theme mode.
  Future<AppThemeMode> getThemeMode();

  /// Sets the theme mode.
  Future<void> setThemeMode(AppThemeMode mode);

  // ===========================================================================
  // Language Settings
  // ===========================================================================

  /// Gets the current language code.
  Future<String> getLanguage();

  /// Sets the language code.
  Future<void> setLanguage(String language);

  // ===========================================================================
  // Hints Management
  // ===========================================================================

  /// Gets available 50/50 hints.
  Future<int> getHints5050Available();

  /// Gets available skip hints.
  Future<int> getHintsSkipAvailable();

  /// Uses one 50/50 hint.
  Future<void> useHint5050();

  /// Uses one skip hint.
  Future<void> useHintSkip();

  /// Adds hints (e.g., after purchase or reward).
  Future<void> addHints({int fiftyFifty = 0, int skip = 0});

  /// Gets the total hint count.
  Future<({int fiftyFifty, int skip})> getHintCounts();

  // ===========================================================================
  // Last Played
  // ===========================================================================

  /// Gets the last played quiz type.
  Future<String?> getLastPlayedQuizType();

  /// Gets the last played category.
  Future<String?> getLastPlayedCategory();

  /// Sets the last played quiz info.
  Future<void> setLastPlayed({String? quizType, String? category});

  // ===========================================================================
  // Migration
  // ===========================================================================

  /// Migrates settings from SharedPreferences to the database.
  ///
  /// This is a one-time operation that should be called during app startup
  /// if the app was previously using SharedPreferences for settings storage.
  Future<bool> migrateFromSharedPreferences();

  /// Checks if migration has been completed.
  Future<bool> isMigrationCompleted();

  // ===========================================================================
  // Caching & Reactive Updates
  // ===========================================================================

  /// Clears the settings cache.
  void clearCache();

  /// Watches settings for changes.
  Stream<UserSettingsModel> watchSettings();

  /// Disposes of resources.
  void dispose();
}

/// Implementation of [SettingsRepository].
class SettingsRepositoryImpl implements SettingsRepository {
  /// Creates a [SettingsRepositoryImpl].
  SettingsRepositoryImpl({
    required SettingsDataSource dataSource,
    Duration cacheDuration = const Duration(minutes: 10),
  })  : _dataSource = dataSource,
        _cacheDuration = cacheDuration;

  final SettingsDataSource _dataSource;
  final Duration _cacheDuration;

  // Cache
  _CacheEntry<UserSettingsModel>? _settingsCache;

  // Stream controller
  final _settingsController = StreamController<UserSettingsModel>.broadcast();

  // Migration key
  static const _migrationKey = 'settings_migration_completed';

  // Legacy SharedPreferences keys (for migration)
  static const _legacySoundKey = 'sound_enabled';
  static const _legacyHapticKey = 'haptic_enabled';
  static const _legacyExitConfirmKey = 'exit_confirmation_enabled';
  static const _legacyThemeKey = 'theme_mode';
  static const _legacyLanguageKey = 'language';
  static const _legacyHints5050Key = 'hints_5050';
  static const _legacyHintsSkipKey = 'hints_skip';
  static const _legacyLastQuizTypeKey = 'last_quiz_type';
  static const _legacyLastCategoryKey = 'last_category';

  // ===========================================================================
  // Full Settings
  // ===========================================================================

  @override
  Future<UserSettingsModel> getSettings() async {
    if (_settingsCache != null && !_settingsCache!.isExpired) {
      return _settingsCache!.value;
    }

    final settings = await _dataSource.getSettings();
    _settingsCache = _CacheEntry(settings, _cacheDuration);

    return settings;
  }

  @override
  Future<void> updateSettings(UserSettingsModel settings) async {
    await _dataSource.updateSettings(settings);

    // Update cache
    _settingsCache = _CacheEntry(settings, _cacheDuration);

    // Notify listeners
    _notifySettingsChanged(settings);
  }

  @override
  Future<void> resetSettings() async {
    await _dataSource.resetSettings();

    // Invalidate cache
    _settingsCache = null;

    // Notify listeners
    final newSettings = await getSettings();
    _notifySettingsChanged(newSettings);
  }

  // ===========================================================================
  // Sound Settings
  // ===========================================================================

  @override
  Future<bool> isSoundEnabled() => _dataSource.getSoundEnabled();

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await _dataSource.setSoundEnabled(enabled);
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Haptic Settings
  // ===========================================================================

  @override
  Future<bool> isHapticEnabled() => _dataSource.getHapticEnabled();

  @override
  Future<void> setHapticEnabled(bool enabled) async {
    await _dataSource.setHapticEnabled(enabled);
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Exit Confirmation Settings
  // ===========================================================================

  @override
  Future<bool> isExitConfirmationEnabled() =>
      _dataSource.getExitConfirmationEnabled();

  @override
  Future<void> setExitConfirmationEnabled(bool enabled) async {
    await _dataSource.setExitConfirmationEnabled(enabled);
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Theme Settings
  // ===========================================================================

  @override
  Future<AppThemeMode> getThemeMode() => _dataSource.getThemeMode();

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    await _dataSource.setThemeMode(mode);
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Language Settings
  // ===========================================================================

  @override
  Future<String> getLanguage() => _dataSource.getLanguage();

  @override
  Future<void> setLanguage(String language) async {
    await _dataSource.setLanguage(language);
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Hints Management
  // ===========================================================================

  @override
  Future<int> getHints5050Available() => _dataSource.getHints5050Available();

  @override
  Future<int> getHintsSkipAvailable() => _dataSource.getHintsSkipAvailable();

  @override
  Future<void> useHint5050() async {
    await _dataSource.useHint5050();
    _invalidateCacheAndNotify();
  }

  @override
  Future<void> useHintSkip() async {
    await _dataSource.useHintSkip();
    _invalidateCacheAndNotify();
  }

  @override
  Future<void> addHints({int fiftyFifty = 0, int skip = 0}) async {
    await _dataSource.addHints(fiftyFifty: fiftyFifty, skip: skip);
    _invalidateCacheAndNotify();
  }

  @override
  Future<({int fiftyFifty, int skip})> getHintCounts() async {
    final settings = await getSettings();
    return (
      fiftyFifty: settings.hints5050Available,
      skip: settings.hintsSkipAvailable,
    );
  }

  // ===========================================================================
  // Last Played
  // ===========================================================================

  @override
  Future<String?> getLastPlayedQuizType() =>
      _dataSource.getLastPlayedQuizType();

  @override
  Future<String?> getLastPlayedCategory() =>
      _dataSource.getLastPlayedCategory();

  @override
  Future<void> setLastPlayed({String? quizType, String? category}) async {
    await _dataSource.setLastPlayed(quizType: quizType, category: category);
    _invalidateCacheAndNotify();
  }

  // ===========================================================================
  // Migration
  // ===========================================================================

  @override
  Future<bool> migrateFromSharedPreferences() async {
    // Check if already migrated
    if (await isMigrationCompleted()) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // Check if there's any legacy data to migrate
      final hasLegacyData = prefs.containsKey(_legacySoundKey) ||
          prefs.containsKey(_legacyHapticKey) ||
          prefs.containsKey(_legacyThemeKey) ||
          prefs.containsKey(_legacyLanguageKey) ||
          prefs.containsKey(_legacyHints5050Key) ||
          prefs.containsKey(_legacyHintsSkipKey);

      if (!hasLegacyData) {
        // No legacy data, just mark as migrated
        await prefs.setBool(_migrationKey, true);
        return false;
      }

      // Get current settings as base
      final currentSettings = await getSettings();

      // Build migrated settings
      final migratedSettings = currentSettings.copyWith(
        soundEnabled: prefs.getBool(_legacySoundKey) ?? currentSettings.soundEnabled,
        hapticEnabled: prefs.getBool(_legacyHapticKey) ?? currentSettings.hapticEnabled,
        exitConfirmationEnabled: prefs.getBool(_legacyExitConfirmKey) ??
            currentSettings.exitConfirmationEnabled,
        themeMode: _parseThemeMode(prefs.getString(_legacyThemeKey)) ??
            currentSettings.themeMode,
        language: prefs.getString(_legacyLanguageKey) ?? currentSettings.language,
        hints5050Available:
            prefs.getInt(_legacyHints5050Key) ?? currentSettings.hints5050Available,
        hintsSkipAvailable:
            prefs.getInt(_legacyHintsSkipKey) ?? currentSettings.hintsSkipAvailable,
        lastPlayedQuizType: prefs.getString(_legacyLastQuizTypeKey),
        lastPlayedCategory: prefs.getString(_legacyLastCategoryKey),
        updatedAt: DateTime.now(),
      );

      // Save migrated settings
      await updateSettings(migratedSettings);

      // Mark as migrated
      await prefs.setBool(_migrationKey, true);

      // Optionally clean up legacy keys
      await _cleanupLegacyKeys(prefs);

      return true;
    } catch (e) {
      // Migration failed, but don't throw - app should continue
      return false;
    }
  }

  @override
  Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_migrationKey) ?? false;
  }

  AppThemeMode? _parseThemeMode(String? value) {
    if (value == null) return null;
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> _cleanupLegacyKeys(SharedPreferences prefs) async {
    final keysToRemove = [
      _legacySoundKey,
      _legacyHapticKey,
      _legacyExitConfirmKey,
      _legacyThemeKey,
      _legacyLanguageKey,
      _legacyHints5050Key,
      _legacyHintsSkipKey,
      _legacyLastQuizTypeKey,
      _legacyLastCategoryKey,
    ];

    for (final key in keysToRemove) {
      if (prefs.containsKey(key)) {
        await prefs.remove(key);
      }
    }
  }

  // ===========================================================================
  // Caching & Reactive Updates
  // ===========================================================================

  @override
  void clearCache() {
    _settingsCache = null;
  }

  @override
  Stream<UserSettingsModel> watchSettings() {
    // Emit initial value
    getSettings().then((settings) {
      if (!_settingsController.isClosed) {
        _settingsController.add(settings);
      }
    });

    return _settingsController.stream;
  }

  @override
  void dispose() {
    _settingsController.close();
  }

  // ===========================================================================
  // Private Helpers
  // ===========================================================================

  void _invalidateCacheAndNotify() {
    _settingsCache = null;

    if (_settingsController.hasListener) {
      getSettings().then((settings) {
        if (!_settingsController.isClosed) {
          _settingsController.add(settings);
        }
      });
    }
  }

  void _notifySettingsChanged(UserSettingsModel settings) {
    if (!_settingsController.isClosed) {
      _settingsController.add(settings);
    }
  }
}

/// Cache entry with expiration.
class _CacheEntry<T> {
  _CacheEntry(this.value, Duration duration)
      : _expiresAt = DateTime.now().add(duration);

  final T value;
  final DateTime _expiresAt;

  bool get isExpired => DateTime.now().isAfter(_expiresAt);
}
