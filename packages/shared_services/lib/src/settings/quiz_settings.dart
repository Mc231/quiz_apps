import 'package:flutter/material.dart';

/// Theme mode options for the quiz app
enum AppThemeMode {
  /// Use system theme setting
  system,

  /// Always use light theme
  light,

  /// Always use dark theme
  dark,
}

/// Immutable model holding all quiz application settings
///
/// This model represents all user preferences that can be configured
/// in the settings screen. It's designed to be immutable, with copyWith
/// for creating modified copies.
///
/// Note: `showAnswerFeedback` has been moved to per-category/per-mode
/// configuration in QuizCategory and QuizModeConfig.
///
/// Example:
/// ```dart
/// final settings = QuizSettings.defaultSettings();
/// final mutedSettings = settings.copyWith(soundEnabled: false);
/// ```
class QuizSettings {
  /// Whether sound effects are enabled
  final bool soundEnabled;

  /// Whether background music is enabled (if implemented)
  final bool musicEnabled;

  /// Whether haptic feedback is enabled
  final bool hapticEnabled;

  /// Selected theme mode (light/dark/system)
  final AppThemeMode themeMode;

  /// Preferred layout mode ID for Play tab quizzes.
  ///
  /// This is the ID of the layout mode option (e.g., 'standard', 'reverse', 'mixed')
  /// that the user prefers for quizzes started from the Play tab.
  /// If null, uses the default layout from the data provider.
  final String? preferredLayoutModeId;

  /// Preferred layout mode ID for Challenge quizzes.
  ///
  /// This is the ID of the layout mode option (e.g., 'standard', 'reverse', 'mixed')
  /// that the user prefers for challenge quizzes.
  /// If null, uses the default layout (first option).
  final String? preferredChallengeLayoutModeId;

  /// Creates a new QuizSettings instance
  const QuizSettings({
    required this.soundEnabled,
    required this.musicEnabled,
    required this.hapticEnabled,
    required this.themeMode,
    this.preferredLayoutModeId,
    this.preferredChallengeLayoutModeId,
  });

  /// Returns default settings with all features enabled
  factory QuizSettings.defaultSettings() {
    return const QuizSettings(
      soundEnabled: true,
      musicEnabled: true,
      hapticEnabled: true,
      themeMode: AppThemeMode.system,
    );
  }

  /// Creates a copy of this settings with the specified fields replaced
  QuizSettings copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? hapticEnabled,
    AppThemeMode? themeMode,
    String? preferredLayoutModeId,
    bool clearPreferredLayoutModeId = false,
    String? preferredChallengeLayoutModeId,
    bool clearPreferredChallengeLayoutModeId = false,
  }) {
    return QuizSettings(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
      themeMode: themeMode ?? this.themeMode,
      preferredLayoutModeId: clearPreferredLayoutModeId
          ? null
          : (preferredLayoutModeId ?? this.preferredLayoutModeId),
      preferredChallengeLayoutModeId: clearPreferredChallengeLayoutModeId
          ? null
          : (preferredChallengeLayoutModeId ?? this.preferredChallengeLayoutModeId),
    );
  }

  /// Converts settings to a Map for storage
  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'hapticEnabled': hapticEnabled,
      'themeMode': themeMode.name,
      if (preferredLayoutModeId != null)
        'preferredLayoutModeId': preferredLayoutModeId,
      if (preferredChallengeLayoutModeId != null)
        'preferredChallengeLayoutModeId': preferredChallengeLayoutModeId,
    };
  }

  /// Creates settings from a Map (from storage)
  factory QuizSettings.fromJson(Map<String, dynamic> json) {
    return QuizSettings(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      hapticEnabled: json['hapticEnabled'] as bool? ?? true,
      themeMode: _parseThemeMode(json['themeMode'] as String?),
      preferredLayoutModeId: json['preferredLayoutModeId'] as String?,
      preferredChallengeLayoutModeId: json['preferredChallengeLayoutModeId'] as String?,
    );
  }

  /// Parses theme mode string to enum
  static AppThemeMode _parseThemeMode(String? value) {
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

  /// Converts AppThemeMode to Flutter ThemeMode
  ThemeMode get flutterThemeMode {
    switch (themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is QuizSettings &&
        other.soundEnabled == soundEnabled &&
        other.musicEnabled == musicEnabled &&
        other.hapticEnabled == hapticEnabled &&
        other.themeMode == themeMode &&
        other.preferredLayoutModeId == preferredLayoutModeId &&
        other.preferredChallengeLayoutModeId == preferredChallengeLayoutModeId;
  }

  @override
  int get hashCode {
    return Object.hash(
      soundEnabled,
      musicEnabled,
      hapticEnabled,
      themeMode,
      preferredLayoutModeId,
      preferredChallengeLayoutModeId,
    );
  }

  @override
  String toString() {
    return 'QuizSettings('
        'soundEnabled: $soundEnabled, '
        'musicEnabled: $musicEnabled, '
        'hapticEnabled: $hapticEnabled, '
        'themeMode: $themeMode, '
        'preferredLayoutModeId: $preferredLayoutModeId, '
        'preferredChallengeLayoutModeId: $preferredChallengeLayoutModeId'
        ')';
  }
}
