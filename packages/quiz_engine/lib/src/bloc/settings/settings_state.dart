/// State classes for the Settings BLoC.
library;

import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_services/shared_services.dart' show QuizSettings;

/// Sealed class representing all possible states for settings screen.
sealed class SettingsState {
  /// Creates a [SettingsState].
  const SettingsState();

  /// Creates a loading state.
  factory SettingsState.loading() = SettingsLoading;

  /// Creates a loaded state with settings data.
  factory SettingsState.loaded({
    required QuizSettings settings,
    PackageInfo? packageInfo,
    bool isSaving,
  }) = SettingsLoaded;

  /// Creates an error state.
  factory SettingsState.error({
    required String message,
    Object? error,
  }) = SettingsError;
}

/// State when settings are loading.
class SettingsLoading extends SettingsState {
  /// Creates a [SettingsLoading].
  const SettingsLoading();
}

/// State when settings are loaded.
class SettingsLoaded extends SettingsState {
  /// Creates a [SettingsLoaded].
  const SettingsLoaded({
    required this.settings,
    this.packageInfo,
    this.isSaving = false,
  });

  /// The current settings.
  final QuizSettings settings;

  /// Package info for version display.
  final PackageInfo? packageInfo;

  /// Whether a save operation is in progress.
  final bool isSaving;

  /// Creates a copy with updated values.
  SettingsLoaded copyWith({
    QuizSettings? settings,
    PackageInfo? packageInfo,
    bool? isSaving,
    bool clearPackageInfo = false,
  }) {
    return SettingsLoaded(
      settings: settings ?? this.settings,
      packageInfo:
          clearPackageInfo ? null : (packageInfo ?? this.packageInfo),
      isSaving: isSaving ?? this.isSaving,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsLoaded &&
        other.settings == settings &&
        other.packageInfo == packageInfo &&
        other.isSaving == isSaving;
  }

  @override
  int get hashCode => Object.hash(settings, packageInfo, isSaving);
}

/// State when there's an error loading settings.
class SettingsError extends SettingsState {
  /// Creates a [SettingsError].
  const SettingsError({
    required this.message,
    this.error,
  });

  /// The error message to display.
  final String message;

  /// The underlying error, if any.
  final Object? error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettingsError &&
        other.message == message &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(message, error);
}
