/// BLoC for managing settings screen state.
library;

import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart'
    show QuizSettings, SettingsService;

import 'settings_event.dart';
import 'settings_state.dart';

/// BLoC for managing settings screen state.
///
/// Handles loading, updating, and resetting settings.
/// Subscribes to [SettingsService] for real-time updates.
class SettingsBloc extends SingleSubscriptionBloc<SettingsState> {
  /// Creates a [SettingsBloc].
  SettingsBloc({
    required SettingsService settingsService,
  }) : _settingsService = settingsService;

  final SettingsService _settingsService;
  StreamSubscription<QuizSettings>? _settingsSubscription;

  /// Tracks the last loaded state for access to current data.
  SettingsLoaded? _lastLoadedState;

  @override
  SettingsState get initialState => const SettingsLoading();

  /// Returns the current settings, if loaded.
  QuizSettings? get settings => _lastLoadedState?.settings;

  /// Returns the package info, if loaded.
  PackageInfo? get packageInfo => _lastLoadedState?.packageInfo;

  /// Adds an event to the BLoC.
  void add(SettingsEvent event) {
    switch (event) {
      case LoadSettings():
        _handleLoad();
      case SettingsToggleSound():
        _handleToggleSound();
      case SettingsToggleMusic():
        _handleToggleMusic();
      case SettingsToggleHaptic():
        _handleToggleHaptic();
      case SettingsChangeTheme():
        _handleChangeTheme(event);
      case SettingsResetToDefaults():
        _handleResetToDefaults();
    }
  }

  @override
  void dispatchState(SettingsState state) {
    if (state is SettingsLoaded) {
      _lastLoadedState = state;
    } else if (state is SettingsLoading) {
      // Keep last loaded state for reference
    } else if (state is SettingsError) {
      _lastLoadedState = null;
    }
    super.dispatchState(state);
  }

  Future<void> _handleLoad() async {
    dispatchState(const SettingsLoading());

    try {
      // Subscribe to settings changes
      _settingsSubscription?.cancel();
      _settingsSubscription = _settingsService.settingsStream.listen(
        _onSettingsChanged,
      );

      // Get current settings
      final currentSettings = _settingsService.currentSettings;

      // Load package info
      PackageInfo? packageInfo;
      try {
        packageInfo = await PackageInfo.fromPlatform();
      } catch (_) {
        // Package info not available
      }

      dispatchState(SettingsState.loaded(
        settings: currentSettings,
        packageInfo: packageInfo,
      ));
    } catch (e) {
      dispatchState(SettingsState.error(
        message: 'Failed to load settings',
        error: e,
      ));
    }
  }

  void _onSettingsChanged(QuizSettings newSettings) {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(
      settings: newSettings,
      isSaving: false,
    ));
  }

  Future<void> _handleToggleSound() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(isSaving: true));

    try {
      await _settingsService.toggleSound();
      // State will be updated via stream listener
    } catch (e) {
      dispatchState(currentState.copyWith(isSaving: false));
    }
  }

  Future<void> _handleToggleMusic() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(isSaving: true));

    try {
      await _settingsService.toggleMusic();
      // State will be updated via stream listener
    } catch (e) {
      dispatchState(currentState.copyWith(isSaving: false));
    }
  }

  Future<void> _handleToggleHaptic() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(isSaving: true));

    try {
      await _settingsService.toggleHaptic();
      // State will be updated via stream listener
    } catch (e) {
      dispatchState(currentState.copyWith(isSaving: false));
    }
  }

  Future<void> _handleChangeTheme(SettingsChangeTheme event) async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(isSaving: true));

    try {
      await _settingsService.setThemeMode(event.theme);
      // State will be updated via stream listener
    } catch (e) {
      dispatchState(currentState.copyWith(isSaving: false));
    }
  }

  Future<void> _handleResetToDefaults() async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    dispatchState(currentState.copyWith(isSaving: true));

    try {
      await _settingsService.resetToDefaults();
      // State will be updated via stream listener
    } catch (e) {
      dispatchState(currentState.copyWith(isSaving: false));
    }
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }
}
