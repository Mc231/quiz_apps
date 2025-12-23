/// Data source for user settings database operations.
library;

import '../database/app_database.dart';
import '../database/tables/settings_table.dart';
import '../models/user_settings_model.dart';

/// Abstract interface for settings data operations.
abstract class SettingsDataSource {
  /// Gets the current user settings.
  Future<UserSettingsModel> getSettings();

  /// Updates user settings.
  Future<void> updateSettings(UserSettingsModel settings);

  /// Updates a single setting field.
  Future<void> updateSetting(String key, dynamic value);

  /// Resets settings to defaults.
  Future<void> resetSettings();

  // Convenience methods for common settings
  /// Gets whether sound is enabled.
  Future<bool> getSoundEnabled();

  /// Sets whether sound is enabled.
  Future<void> setSoundEnabled(bool enabled);

  /// Gets whether haptic feedback is enabled.
  Future<bool> getHapticEnabled();

  /// Sets whether haptic feedback is enabled.
  Future<void> setHapticEnabled(bool enabled);

  /// Gets whether exit confirmation is enabled.
  Future<bool> getExitConfirmationEnabled();

  /// Sets whether exit confirmation is enabled.
  Future<void> setExitConfirmationEnabled(bool enabled);

  /// Gets the theme mode.
  Future<AppThemeMode> getThemeMode();

  /// Sets the theme mode.
  Future<void> setThemeMode(AppThemeMode mode);

  /// Gets the language code.
  Future<String> getLanguage();

  /// Sets the language code.
  Future<void> setLanguage(String language);

  /// Gets available 50/50 hints.
  Future<int> getHints5050Available();

  /// Sets available 50/50 hints.
  Future<void> setHints5050Available(int count);

  /// Decrements 50/50 hints by 1.
  Future<void> useHint5050();

  /// Gets available skip hints.
  Future<int> getHintsSkipAvailable();

  /// Sets available skip hints.
  Future<void> setHintsSkipAvailable(int count);

  /// Decrements skip hints by 1.
  Future<void> useHintSkip();

  /// Adds hints (e.g., after purchase or reward).
  Future<void> addHints({int fiftyFifty = 0, int skip = 0});

  /// Gets the last played quiz type.
  Future<String?> getLastPlayedQuizType();

  /// Gets the last played category.
  Future<String?> getLastPlayedCategory();

  /// Sets the last played quiz type and category.
  Future<void> setLastPlayed({String? quizType, String? category});
}

/// SQLite implementation of [SettingsDataSource].
class SettingsDataSourceImpl implements SettingsDataSource {
  /// Creates a new [SettingsDataSourceImpl].
  SettingsDataSourceImpl({
    AppDatabase? database,
  }) : _database = database ?? AppDatabase.instance;

  final AppDatabase _database;

  @override
  Future<UserSettingsModel> getSettings() async {
    final results = await _database.query(
      userSettingsTable,
      where: '${UserSettingsColumns.id} = 1',
      limit: 1,
    );

    if (results.isEmpty) {
      return UserSettingsModel.defaults();
    }

    return UserSettingsModel.fromMap(results.first);
  }

  @override
  Future<void> updateSettings(UserSettingsModel settings) async {
    await _database.update(
      userSettingsTable,
      settings.toMap(),
      where: '${UserSettingsColumns.id} = 1',
    );
  }

  @override
  Future<void> updateSetting(String key, dynamic value) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.update(
      userSettingsTable,
      {
        key: value,
        UserSettingsColumns.updatedAt: now,
      },
      where: '${UserSettingsColumns.id} = 1',
    );
  }

  @override
  Future<void> resetSettings() async {
    final defaults = UserSettingsModel.defaults();
    await updateSettings(defaults);
  }

  // ===========================================================================
  // Sound Settings
  // ===========================================================================

  @override
  Future<bool> getSoundEnabled() async {
    final settings = await getSettings();
    return settings.soundEnabled;
  }

  @override
  Future<void> setSoundEnabled(bool enabled) async {
    await updateSetting(UserSettingsColumns.soundEnabled, enabled ? 1 : 0);
  }

  // ===========================================================================
  // Haptic Settings
  // ===========================================================================

  @override
  Future<bool> getHapticEnabled() async {
    final settings = await getSettings();
    return settings.hapticEnabled;
  }

  @override
  Future<void> setHapticEnabled(bool enabled) async {
    await updateSetting(UserSettingsColumns.hapticEnabled, enabled ? 1 : 0);
  }

  // ===========================================================================
  // Exit Confirmation Settings
  // ===========================================================================

  @override
  Future<bool> getExitConfirmationEnabled() async {
    final settings = await getSettings();
    return settings.exitConfirmationEnabled;
  }

  @override
  Future<void> setExitConfirmationEnabled(bool enabled) async {
    await updateSetting(
      UserSettingsColumns.exitConfirmationEnabled,
      enabled ? 1 : 0,
    );
  }

  // ===========================================================================
  // Theme Settings
  // ===========================================================================

  @override
  Future<AppThemeMode> getThemeMode() async {
    final settings = await getSettings();
    return settings.themeMode;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    await updateSetting(UserSettingsColumns.themeMode, mode.name);
  }

  // ===========================================================================
  // Language Settings
  // ===========================================================================

  @override
  Future<String> getLanguage() async {
    final settings = await getSettings();
    return settings.language;
  }

  @override
  Future<void> setLanguage(String language) async {
    await updateSetting(UserSettingsColumns.language, language);
  }

  // ===========================================================================
  // Hints Management
  // ===========================================================================

  @override
  Future<int> getHints5050Available() async {
    final settings = await getSettings();
    return settings.hints5050Available;
  }

  @override
  Future<void> setHints5050Available(int count) async {
    await updateSetting(UserSettingsColumns.hints5050Available, count);
  }

  @override
  Future<void> useHint5050() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.execute('''
      UPDATE $userSettingsTable SET
        ${UserSettingsColumns.hints5050Available} = MAX(0, ${UserSettingsColumns.hints5050Available} - 1),
        ${UserSettingsColumns.updatedAt} = ?
      WHERE ${UserSettingsColumns.id} = 1
    ''', [now]);
  }

  @override
  Future<int> getHintsSkipAvailable() async {
    final settings = await getSettings();
    return settings.hintsSkipAvailable;
  }

  @override
  Future<void> setHintsSkipAvailable(int count) async {
    await updateSetting(UserSettingsColumns.hintsSkipAvailable, count);
  }

  @override
  Future<void> useHintSkip() async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.execute('''
      UPDATE $userSettingsTable SET
        ${UserSettingsColumns.hintsSkipAvailable} = MAX(0, ${UserSettingsColumns.hintsSkipAvailable} - 1),
        ${UserSettingsColumns.updatedAt} = ?
      WHERE ${UserSettingsColumns.id} = 1
    ''', [now]);
  }

  @override
  Future<void> addHints({int fiftyFifty = 0, int skip = 0}) async {
    if (fiftyFifty == 0 && skip == 0) return;

    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.execute('''
      UPDATE $userSettingsTable SET
        ${UserSettingsColumns.hints5050Available} = ${UserSettingsColumns.hints5050Available} + ?,
        ${UserSettingsColumns.hintsSkipAvailable} = ${UserSettingsColumns.hintsSkipAvailable} + ?,
        ${UserSettingsColumns.updatedAt} = ?
      WHERE ${UserSettingsColumns.id} = 1
    ''', [fiftyFifty, skip, now]);
  }

  // ===========================================================================
  // Last Played
  // ===========================================================================

  @override
  Future<String?> getLastPlayedQuizType() async {
    final settings = await getSettings();
    return settings.lastPlayedQuizType;
  }

  @override
  Future<String?> getLastPlayedCategory() async {
    final settings = await getSettings();
    return settings.lastPlayedCategory;
  }

  @override
  Future<void> setLastPlayed({String? quizType, String? category}) async {
    final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _database.update(
      userSettingsTable,
      {
        UserSettingsColumns.lastPlayedQuizType: quizType,
        UserSettingsColumns.lastPlayedCategory: category,
        UserSettingsColumns.updatedAt: now,
      },
      where: '${UserSettingsColumns.id} = 1',
    );
  }
}
