/// Event classes for the Settings BLoC.
library;

import 'package:shared_services/shared_services.dart' show AppThemeMode;

/// Sealed class representing all possible events for settings screen.
sealed class SettingsEvent {
  /// Creates a [SettingsEvent].
  const SettingsEvent();

  /// Creates a load event to initialize settings.
  factory SettingsEvent.load() = LoadSettings;

  /// Creates an event to toggle sound effects.
  factory SettingsEvent.toggleSound() = SettingsToggleSound;

  /// Creates an event to toggle background music.
  factory SettingsEvent.toggleMusic() = SettingsToggleMusic;

  /// Creates an event to toggle haptic feedback.
  factory SettingsEvent.toggleHaptic() = SettingsToggleHaptic;

  /// Creates an event to change the theme.
  factory SettingsEvent.changeTheme(AppThemeMode theme) = SettingsChangeTheme;

  /// Creates an event to reset settings to defaults.
  factory SettingsEvent.resetToDefaults() = SettingsResetToDefaults;
}

/// Event to load settings.
class LoadSettings extends SettingsEvent {
  /// Creates a [LoadSettings].
  const LoadSettings();
}

/// Event to toggle sound effects.
class SettingsToggleSound extends SettingsEvent {
  /// Creates a [SettingsToggleSound].
  const SettingsToggleSound();
}

/// Event to toggle background music.
class SettingsToggleMusic extends SettingsEvent {
  /// Creates a [SettingsToggleMusic].
  const SettingsToggleMusic();
}

/// Event to toggle haptic feedback.
class SettingsToggleHaptic extends SettingsEvent {
  /// Creates a [SettingsToggleHaptic].
  const SettingsToggleHaptic();
}

/// Event to change the theme.
class SettingsChangeTheme extends SettingsEvent {
  /// Creates a [SettingsChangeTheme].
  const SettingsChangeTheme(this.theme);

  /// The new theme to apply.
  final AppThemeMode theme;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsChangeTheme && other.theme == theme;
  }

  @override
  int get hashCode => theme.hashCode;
}

/// Event to reset settings to defaults.
class SettingsResetToDefaults extends SettingsEvent {
  /// Creates a [SettingsResetToDefaults].
  const SettingsResetToDefaults();
}
