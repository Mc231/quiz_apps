import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/bloc/settings/settings_bloc.dart';
import 'package:quiz_engine/src/bloc/settings/settings_event.dart'
    as bloc_event;
import 'package:quiz_engine/src/bloc/settings/settings_state.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of [SettingsService] for testing.
class MockSettingsService implements SettingsService {
  MockSettingsService({
    QuizSettings? initialSettings,
  }) : _currentSettings = initialSettings ?? QuizSettings.defaultSettings();

  QuizSettings _currentSettings;
  final _controller = StreamController<QuizSettings>.broadcast();

  int toggleSoundCount = 0;
  int toggleMusicCount = 0;
  int toggleHapticCount = 0;
  int setThemeModeCount = 0;
  int resetToDefaultsCount = 0;
  int updateSettingsCount = 0;

  @override
  QuizSettings get currentSettings => _currentSettings;

  @override
  Stream<QuizSettings> get settingsStream => _controller.stream;

  @override
  Future<void> initialize() async {
    // No-op for mock
  }

  @override
  Future<bool> toggleSound() async {
    toggleSoundCount++;
    _currentSettings = _currentSettings.copyWith(
      soundEnabled: !_currentSettings.soundEnabled,
    );
    _controller.add(_currentSettings);
    return _currentSettings.soundEnabled;
  }

  @override
  Future<bool> toggleMusic() async {
    toggleMusicCount++;
    _currentSettings = _currentSettings.copyWith(
      musicEnabled: !_currentSettings.musicEnabled,
    );
    _controller.add(_currentSettings);
    return _currentSettings.musicEnabled;
  }

  @override
  Future<bool> toggleHaptic() async {
    toggleHapticCount++;
    _currentSettings = _currentSettings.copyWith(
      hapticEnabled: !_currentSettings.hapticEnabled,
    );
    _controller.add(_currentSettings);
    return _currentSettings.hapticEnabled;
  }

  @override
  Future<void> setThemeMode(AppThemeMode mode) async {
    setThemeModeCount++;
    _currentSettings = _currentSettings.copyWith(themeMode: mode);
    _controller.add(_currentSettings);
  }

  @override
  Future<QuizSettings> resetToDefaults() async {
    resetToDefaultsCount++;
    _currentSettings = QuizSettings.defaultSettings();
    _controller.add(_currentSettings);
    return _currentSettings;
  }

  @override
  Future<void> updateSettings(QuizSettings newSettings) async {
    updateSettingsCount++;
    _currentSettings = newSettings;
    _controller.add(_currentSettings);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  group('SettingsBloc', () {
    late MockSettingsService mockService;
    late SettingsBloc bloc;

    setUp(() {
      mockService = MockSettingsService();
      bloc = SettingsBloc(settingsService: mockService);
    });

    tearDown(() {
      bloc.dispose();
      mockService.dispose();
    });

    group('initialization', () {
      test('initial state is SettingsLoading', () {
        expect(bloc.initialState, isA<SettingsLoading>());
      });

      test('settings getter returns null when not loaded', () {
        expect(bloc.settings, isNull);
      });

      test('packageInfo getter returns null when not loaded', () {
        expect(bloc.packageInfo, isNull);
      });
    });

    group('LoadSettings event', () {
      test('emits SettingsLoaded after loading', () async {
        bloc.add(bloc_event.SettingsEvent.load());

        // Wait for loaded state
        final loadedState =
            await bloc.stream.firstWhere((s) => s is SettingsLoaded);

        expect(loadedState, isA<SettingsLoaded>());
      });

      test('loaded state contains current settings from service', () async {
        bloc.add(bloc_event.SettingsEvent.load());

        final loadedState = await bloc.stream
            .firstWhere((s) => s is SettingsLoaded) as SettingsLoaded;

        expect(loadedState.settings.soundEnabled, isTrue);
        expect(loadedState.settings.musicEnabled, isTrue);
        expect(loadedState.settings.hapticEnabled, isTrue);
        expect(loadedState.settings.themeMode, equals(AppThemeMode.system));
      });

      test('settings getter returns value after load', () async {
        bloc.add(bloc_event.SettingsEvent.load());

        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        expect(bloc.settings, isNotNull);
        expect(bloc.settings!.soundEnabled, isTrue);
      });
    });

    group('SettingsToggleSound event', () {
      test('calls toggleSound on settings service', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        bloc.add(bloc_event.SettingsEvent.toggleSound());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.toggleSoundCount, equals(1));
      });

      test('updates state with toggled sound value', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        // Initial state has sound enabled
        expect(bloc.settings!.soundEnabled, isTrue);

        bloc.add(bloc_event.SettingsEvent.toggleSound());

        await expectLater(
          bloc.stream,
          emits(predicate<SettingsLoaded>((state) {
            return state.settings.soundEnabled == false;
          })),
        );
      });

      test('does nothing when not loaded', () async {
        bloc.add(bloc_event.SettingsEvent.toggleSound());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.toggleSoundCount, equals(0));
      });
    });

    group('SettingsToggleMusic event', () {
      test('calls toggleMusic on settings service', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        bloc.add(bloc_event.SettingsEvent.toggleMusic());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.toggleMusicCount, equals(1));
      });

      test('updates state with toggled music value', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        expect(bloc.settings!.musicEnabled, isTrue);

        bloc.add(bloc_event.SettingsEvent.toggleMusic());

        await expectLater(
          bloc.stream,
          emits(predicate<SettingsLoaded>((state) {
            return state.settings.musicEnabled == false;
          })),
        );
      });

      test('does nothing when not loaded', () async {
        bloc.add(bloc_event.SettingsEvent.toggleMusic());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.toggleMusicCount, equals(0));
      });
    });

    group('SettingsToggleHaptic event', () {
      test('calls toggleHaptic on settings service', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        bloc.add(bloc_event.SettingsEvent.toggleHaptic());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.toggleHapticCount, equals(1));
      });

      test('updates state with toggled haptic value', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        expect(bloc.settings!.hapticEnabled, isTrue);

        bloc.add(bloc_event.SettingsEvent.toggleHaptic());

        await expectLater(
          bloc.stream,
          emits(predicate<SettingsLoaded>((state) {
            return state.settings.hapticEnabled == false;
          })),
        );
      });

      test('does nothing when not loaded', () async {
        bloc.add(bloc_event.SettingsEvent.toggleHaptic());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.toggleHapticCount, equals(0));
      });
    });

    group('SettingsChangeTheme event', () {
      test('calls setThemeMode on settings service', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        bloc.add(bloc_event.SettingsEvent.changeTheme(AppThemeMode.dark));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.setThemeModeCount, equals(1));
      });

      test('updates state with new theme', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        expect(bloc.settings!.themeMode, equals(AppThemeMode.system));

        bloc.add(bloc_event.SettingsEvent.changeTheme(AppThemeMode.dark));

        await expectLater(
          bloc.stream,
          emits(predicate<SettingsLoaded>((state) {
            return state.settings.themeMode == AppThemeMode.dark;
          })),
        );
      });

      test('does nothing when not loaded', () async {
        bloc.add(bloc_event.SettingsEvent.changeTheme(AppThemeMode.dark));
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.setThemeModeCount, equals(0));
      });
    });

    group('SettingsResetToDefaults event', () {
      test('calls resetToDefaults on settings service', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        bloc.add(bloc_event.SettingsEvent.resetToDefaults());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.resetToDefaultsCount, equals(1));
      });

      test('updates state with default settings', () async {
        // Start with non-default settings
        mockService = MockSettingsService(
          initialSettings: const QuizSettings(
            soundEnabled: false,
            musicEnabled: false,
            hapticEnabled: false,
            themeMode: AppThemeMode.dark,
          ),
        );
        bloc = SettingsBloc(settingsService: mockService);

        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        expect(bloc.settings!.soundEnabled, isFalse);
        expect(bloc.settings!.themeMode, equals(AppThemeMode.dark));

        bloc.add(bloc_event.SettingsEvent.resetToDefaults());

        await expectLater(
          bloc.stream,
          emits(predicate<SettingsLoaded>((state) {
            return state.settings.soundEnabled == true &&
                state.settings.musicEnabled == true &&
                state.settings.hapticEnabled == true &&
                state.settings.themeMode == AppThemeMode.system;
          })),
        );
      });

      test('does nothing when not loaded', () async {
        bloc.add(bloc_event.SettingsEvent.resetToDefaults());
        await Future.delayed(const Duration(milliseconds: 50));

        expect(mockService.resetToDefaultsCount, equals(0));
      });
    });

    group('isSaving state', () {
      test('sets isSaving to true before toggle operation', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        // Capture states during toggle
        final states = <SettingsState>[];
        bloc.stream.listen(states.add);

        bloc.add(bloc_event.SettingsEvent.toggleSound());
        await Future.delayed(const Duration(milliseconds: 100));

        // Should have at least one state with isSaving=true
        expect(
          states.any(
            (s) => s is SettingsLoaded && s.isSaving == true,
          ),
          isTrue,
        );

        // Final state should have isSaving=false
        expect(
          states.last,
          predicate<SettingsLoaded>((state) => state.isSaving == false),
        );
      });
    });

    group('stream subscription', () {
      test('updates state when settings service emits', () async {
        bloc.add(bloc_event.SettingsEvent.load());
        await bloc.stream.firstWhere((state) => state is SettingsLoaded);

        // External update via service
        mockService.toggleSound();

        await expectLater(
          bloc.stream,
          emits(predicate<SettingsLoaded>((state) {
            return state.settings.soundEnabled == false;
          })),
        );
      });
    });
  });

  group('SettingsState', () {
    test('SettingsLoading equality', () {
      const loading1 = SettingsLoading();
      const loading2 = SettingsLoading();

      expect(loading1, equals(loading2));
    });

    test('SettingsLoaded equality', () {
      final loaded1 = SettingsLoaded(
        settings: QuizSettings.defaultSettings(),
      );
      final loaded2 = SettingsLoaded(
        settings: QuizSettings.defaultSettings(),
      );
      final loaded3 = SettingsLoaded(
        settings: const QuizSettings(
          soundEnabled: false,
          musicEnabled: true,
          hapticEnabled: true,
          themeMode: AppThemeMode.system,
        ),
      );

      expect(loaded1, equals(loaded2));
      expect(loaded1, isNot(equals(loaded3)));
    });

    test('SettingsLoaded copyWith creates correct copy', () {
      final original = SettingsLoaded(
        settings: QuizSettings.defaultSettings(),
        isSaving: false,
      );

      final copied = original.copyWith(isSaving: true);

      expect(copied.settings, equals(original.settings));
      expect(copied.isSaving, isTrue);
    });

    test('SettingsLoaded copyWith with new settings', () {
      final original = SettingsLoaded(
        settings: QuizSettings.defaultSettings(),
      );

      final newSettings = const QuizSettings(
        soundEnabled: false,
        musicEnabled: false,
        hapticEnabled: false,
        themeMode: AppThemeMode.dark,
      );

      final copied = original.copyWith(settings: newSettings);

      expect(copied.settings.soundEnabled, isFalse);
      expect(copied.settings.themeMode, equals(AppThemeMode.dark));
    });

    test('SettingsError equality', () {
      const error1 = SettingsError(message: 'Error 1');
      const error2 = SettingsError(message: 'Error 1');
      const error3 = SettingsError(message: 'Error 2');

      expect(error1, equals(error2));
      expect(error1, isNot(equals(error3)));
    });

    test('SettingsError with underlying error', () {
      final exception = Exception('Test exception');
      final error = SettingsError(message: 'Error', error: exception);

      expect(error.error, equals(exception));
    });

    test('factory constructors create correct types', () {
      expect(SettingsState.loading(), isA<SettingsLoading>());
      expect(
        SettingsState.loaded(settings: QuizSettings.defaultSettings()),
        isA<SettingsLoaded>(),
      );
      expect(
        SettingsState.error(message: 'Error'),
        isA<SettingsError>(),
      );
    });
  });

  group('SettingsEvent', () {
    test('LoadSettings equality', () {
      const load1 = bloc_event.LoadSettings();
      const load2 = bloc_event.LoadSettings();

      expect(load1.hashCode, equals(load2.hashCode));
    });

    test('SettingsToggleSound equality', () {
      const toggle1 = bloc_event.SettingsToggleSound();
      const toggle2 = bloc_event.SettingsToggleSound();

      expect(toggle1.hashCode, equals(toggle2.hashCode));
    });

    test('SettingsToggleMusic equality', () {
      const toggle1 = bloc_event.SettingsToggleMusic();
      const toggle2 = bloc_event.SettingsToggleMusic();

      expect(toggle1.hashCode, equals(toggle2.hashCode));
    });

    test('SettingsToggleHaptic equality', () {
      const toggle1 = bloc_event.SettingsToggleHaptic();
      const toggle2 = bloc_event.SettingsToggleHaptic();

      expect(toggle1.hashCode, equals(toggle2.hashCode));
    });

    test('SettingsChangeTheme equality', () {
      const change1 = bloc_event.SettingsChangeTheme(AppThemeMode.dark);
      const change2 = bloc_event.SettingsChangeTheme(AppThemeMode.dark);
      const change3 = bloc_event.SettingsChangeTheme(AppThemeMode.light);

      expect(change1, equals(change2));
      expect(change1.hashCode, equals(change2.hashCode));
      expect(change1, isNot(equals(change3)));
    });

    test('SettingsResetToDefaults equality', () {
      const reset1 = bloc_event.SettingsResetToDefaults();
      const reset2 = bloc_event.SettingsResetToDefaults();

      expect(reset1.hashCode, equals(reset2.hashCode));
    });

    test('factory constructors create correct types', () {
      expect(
        bloc_event.SettingsEvent.load(),
        isA<bloc_event.LoadSettings>(),
      );
      expect(
        bloc_event.SettingsEvent.toggleSound(),
        isA<bloc_event.SettingsToggleSound>(),
      );
      expect(
        bloc_event.SettingsEvent.toggleMusic(),
        isA<bloc_event.SettingsToggleMusic>(),
      );
      expect(
        bloc_event.SettingsEvent.toggleHaptic(),
        isA<bloc_event.SettingsToggleHaptic>(),
      );
      expect(
        bloc_event.SettingsEvent.changeTheme(AppThemeMode.dark),
        isA<bloc_event.SettingsChangeTheme>(),
      );
      expect(
        bloc_event.SettingsEvent.resetToDefaults(),
        isA<bloc_event.SettingsResetToDefaults>(),
      );
    });
  });
}
