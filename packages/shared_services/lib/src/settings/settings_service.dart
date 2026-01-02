import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'quiz_settings.dart';

/// Service for managing quiz application settings with persistence
///
/// Provides a centralized way to load, save, and observe settings changes.
/// Settings are automatically persisted using SharedPreferences and can be
/// observed via a stream for real-time updates.
///
/// Example:
/// ```dart
/// final settingsService = SettingsService();
/// await settingsService.initialize();
///
/// // Listen to settings changes
/// settingsService.settingsStream.listen((settings) {
///   print('Settings changed: $settings');
/// });
///
/// // Update a setting
/// await settingsService.updateSettings(
///   settingsService.currentSettings.copyWith(soundEnabled: false),
/// );
/// ```
class SettingsService {
  static const String _settingsKey = 'quiz_settings';

  SharedPreferences? _prefs;
  QuizSettings _currentSettings = QuizSettings.defaultSettings();

  final _settingsController = StreamController<QuizSettings>.broadcast();

  /// Stream of settings changes
  ///
  /// Emits the new settings whenever they are updated.
  /// This allows UI and services to react to settings changes in real-time.
  Stream<QuizSettings> get settingsStream => _settingsController.stream;

  /// Current settings value
  ///
  /// Returns the most recent settings. This is updated whenever
  /// settings are loaded or modified.
  QuizSettings get currentSettings => _currentSettings;

  /// Initializes the settings service
  ///
  /// Loads SharedPreferences and retrieves stored settings.
  /// If no settings are stored, uses default settings.
  ///
  /// Should be called once during app initialization.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadSettings();
  }

  /// Loads settings from SharedPreferences
  Future<void> _loadSettings() async {
    if (_prefs == null) {
      throw StateError(
        'SettingsService not initialized. Call initialize() first.',
      );
    }

    final settingsJson = _prefs!.getString(_settingsKey);

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> decoded = json.decode(settingsJson);
        _currentSettings = QuizSettings.fromJson(decoded);
      } catch (e) {
        // If parsing fails, use default settings
        _currentSettings = QuizSettings.defaultSettings();
        // Save default settings to fix corrupted data
        await _saveSettings();
      }
    } else {
      // No settings stored yet, use defaults
      _currentSettings = QuizSettings.defaultSettings();
      await _saveSettings();
    }

    // Notify listeners of initial settings
    _settingsController.add(_currentSettings);
  }

  /// Saves current settings to SharedPreferences
  Future<void> _saveSettings() async {
    if (_prefs == null) {
      throw StateError(
        'SettingsService not initialized. Call initialize() first.',
      );
    }

    final settingsJson = json.encode(_currentSettings.toJson());
    await _prefs!.setString(_settingsKey, settingsJson);
  }

  /// Updates settings and persists them
  ///
  /// [newSettings] - The new settings to save
  ///
  /// Saves the settings to SharedPreferences and notifies all listeners
  /// via the settings stream.
  Future<void> updateSettings(QuizSettings newSettings) async {
    _currentSettings = newSettings;
    await _saveSettings();
    _settingsController.add(_currentSettings);
  }

  /// Toggles sound effects on/off
  ///
  /// Returns the new sound enabled state
  Future<bool> toggleSound() async {
    final newSettings = _currentSettings.copyWith(
      soundEnabled: !_currentSettings.soundEnabled,
    );
    await updateSettings(newSettings);
    return newSettings.soundEnabled;
  }

  /// Toggles background music on/off
  ///
  /// Returns the new music enabled state
  Future<bool> toggleMusic() async {
    final newSettings = _currentSettings.copyWith(
      musicEnabled: !_currentSettings.musicEnabled,
    );
    await updateSettings(newSettings);
    return newSettings.musicEnabled;
  }

  /// Toggles haptic feedback on/off
  ///
  /// Returns the new haptic enabled state
  Future<bool> toggleHaptic() async {
    final newSettings = _currentSettings.copyWith(
      hapticEnabled: !_currentSettings.hapticEnabled,
    );
    await updateSettings(newSettings);
    return newSettings.hapticEnabled;
  }

  /// Sets the theme mode
  ///
  /// [mode] - The theme mode to set (light/dark/system)
  Future<void> setThemeMode(AppThemeMode mode) async {
    final newSettings = _currentSettings.copyWith(themeMode: mode);
    await updateSettings(newSettings);
  }

  /// Sets the preferred layout mode for Play tab quizzes
  ///
  /// [modeId] - The layout mode ID to save (e.g., 'standard', 'reverse', 'mixed')
  /// Pass null to clear the preference and use the default layout.
  Future<void> setPreferredLayoutMode(String? modeId) async {
    final newSettings = modeId == null
        ? _currentSettings.copyWith(clearPreferredLayoutModeId: true)
        : _currentSettings.copyWith(preferredLayoutModeId: modeId);
    await updateSettings(newSettings);
  }

  /// Sets the preferred layout mode for Challenge quizzes
  ///
  /// [modeId] - The layout mode ID to save (e.g., 'standard', 'reverse', 'mixed')
  /// Pass null to clear the preference and use the default layout.
  Future<void> setChallengeLayoutMode(String? modeId) async {
    final newSettings = modeId == null
        ? _currentSettings.copyWith(clearPreferredChallengeLayoutModeId: true)
        : _currentSettings.copyWith(preferredChallengeLayoutModeId: modeId);
    await updateSettings(newSettings);
  }

  /// Resets all settings to defaults
  ///
  /// Returns the default settings
  Future<QuizSettings> resetToDefaults() async {
    final defaultSettings = QuizSettings.defaultSettings();
    await updateSettings(defaultSettings);
    return defaultSettings;
  }

  /// Disposes of resources used by the settings service
  ///
  /// Should be called when the service is no longer needed.
  void dispose() {
    _settingsController.close();
  }
}
