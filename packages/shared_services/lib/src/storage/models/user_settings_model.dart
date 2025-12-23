/// User settings data model for database persistence.
library;

import '../../settings/quiz_settings.dart';
import '../database/tables/settings_table.dart';

export '../../settings/quiz_settings.dart' show AppThemeMode;

/// Parses AppThemeMode from string value.
AppThemeMode _parseThemeMode(String? value) {
  switch (value) {
    case 'light':
      return AppThemeMode.light;
    case 'dark':
      return AppThemeMode.dark;
    case 'system':
    default:
      return AppThemeMode.system;
  }
}

/// User settings and preferences stored in the database.
class UserSettingsModel {
  /// Creates a new [UserSettingsModel].
  const UserSettingsModel({
    this.soundEnabled = true,
    this.hapticEnabled = true,
    this.exitConfirmationEnabled = true,
    this.showHints = true,
    this.themeMode = AppThemeMode.light,
    this.language = 'en',
    this.hints5050Available = 3,
    this.hintsSkipAvailable = 3,
    this.lastPlayedQuizType,
    this.lastPlayedCategory,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Whether sound effects are enabled.
  final bool soundEnabled;

  /// Whether haptic feedback is enabled.
  final bool hapticEnabled;

  /// Whether to show exit confirmation dialog.
  final bool exitConfirmationEnabled;

  /// Whether to show hints during quiz.
  final bool showHints;

  /// The app theme mode.
  final AppThemeMode themeMode;

  /// The app language code.
  final String language;

  /// Number of 50/50 hints available.
  final int hints5050Available;

  /// Number of skip hints available.
  final int hintsSkipAvailable;

  /// Last played quiz type.
  final String? lastPlayedQuizType;

  /// Last played category.
  final String? lastPlayedCategory;

  /// When this record was created.
  final DateTime createdAt;

  /// When this record was last updated.
  final DateTime updatedAt;

  /// Total hints available (50/50 + skip).
  int get totalHintsAvailable => hints5050Available + hintsSkipAvailable;

  /// Creates default settings for a new user.
  factory UserSettingsModel.defaults() {
    final now = DateTime.now();
    return UserSettingsModel(
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a [UserSettingsModel] from a database map.
  factory UserSettingsModel.fromMap(Map<String, dynamic> map) {
    return UserSettingsModel(
      soundEnabled: (map[UserSettingsColumns.soundEnabled] as int?) == 1,
      hapticEnabled: (map[UserSettingsColumns.hapticEnabled] as int?) == 1,
      exitConfirmationEnabled:
          (map[UserSettingsColumns.exitConfirmationEnabled] as int?) == 1,
      showHints: (map[UserSettingsColumns.showHints] as int?) == 1,
      themeMode: _parseThemeMode(
        map[UserSettingsColumns.themeMode] as String?,
      ),
      language:
          (map[UserSettingsColumns.language] as String?) ?? 'en',
      hints5050Available:
          (map[UserSettingsColumns.hints5050Available] as int?) ?? 3,
      hintsSkipAvailable:
          (map[UserSettingsColumns.hintsSkipAvailable] as int?) ?? 3,
      lastPlayedQuizType:
          map[UserSettingsColumns.lastPlayedQuizType] as String?,
      lastPlayedCategory:
          map[UserSettingsColumns.lastPlayedCategory] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (map[UserSettingsColumns.createdAt] as int) * 1000,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (map[UserSettingsColumns.updatedAt] as int) * 1000,
      ),
    );
  }

  /// Converts this [UserSettingsModel] to a database map.
  Map<String, dynamic> toMap() {
    return {
      UserSettingsColumns.id: 1,
      UserSettingsColumns.soundEnabled: soundEnabled ? 1 : 0,
      UserSettingsColumns.hapticEnabled: hapticEnabled ? 1 : 0,
      UserSettingsColumns.exitConfirmationEnabled:
          exitConfirmationEnabled ? 1 : 0,
      UserSettingsColumns.showHints: showHints ? 1 : 0,
      UserSettingsColumns.themeMode: themeMode.name,
      UserSettingsColumns.language: language,
      UserSettingsColumns.hints5050Available: hints5050Available,
      UserSettingsColumns.hintsSkipAvailable: hintsSkipAvailable,
      UserSettingsColumns.lastPlayedQuizType: lastPlayedQuizType,
      UserSettingsColumns.lastPlayedCategory: lastPlayedCategory,
      UserSettingsColumns.createdAt: createdAt.millisecondsSinceEpoch ~/ 1000,
      UserSettingsColumns.updatedAt: updatedAt.millisecondsSinceEpoch ~/ 1000,
    };
  }

  /// Creates a copy of this [UserSettingsModel] with the given fields replaced.
  UserSettingsModel copyWith({
    bool? soundEnabled,
    bool? hapticEnabled,
    bool? exitConfirmationEnabled,
    bool? showHints,
    AppThemeMode? themeMode,
    String? language,
    int? hints5050Available,
    int? hintsSkipAvailable,
    String? lastPlayedQuizType,
    String? lastPlayedCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettingsModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      exitConfirmationEnabled:
          exitConfirmationEnabled ?? this.exitConfirmationEnabled,
      showHints: showHints ?? this.showHints,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      hints5050Available: hints5050Available ?? this.hints5050Available,
      hintsSkipAvailable: hintsSkipAvailable ?? this.hintsSkipAvailable,
      lastPlayedQuizType: lastPlayedQuizType ?? this.lastPlayedQuizType,
      lastPlayedCategory: lastPlayedCategory ?? this.lastPlayedCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserSettingsModel(sound: $soundEnabled, haptic: $hapticEnabled, theme: ${themeMode.name})';
  }
}
