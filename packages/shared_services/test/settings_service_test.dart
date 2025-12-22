import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsService', () {
    late SettingsService settingsService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      settingsService = SettingsService();
    });

    tearDown(() {
      settingsService.dispose();
    });

    test('initialize loads default settings when none are stored', () async {
      await settingsService.initialize();

      expect(settingsService.currentSettings.soundEnabled, true);
      expect(settingsService.currentSettings.musicEnabled, true);
      expect(settingsService.currentSettings.hapticEnabled, true);
      expect(settingsService.currentSettings.showAnswerFeedback, true);
      expect(settingsService.currentSettings.themeMode, AppThemeMode.system);
    });

    test('initialize loads stored settings', () async {
      SharedPreferences.setMockInitialValues({
        'quiz_settings':
            '{"soundEnabled":false,"musicEnabled":false,"hapticEnabled":true,"showAnswerFeedback":false,"themeMode":"dark"}',
      });

      await settingsService.initialize();

      expect(settingsService.currentSettings.soundEnabled, false);
      expect(settingsService.currentSettings.musicEnabled, false);
      expect(settingsService.currentSettings.hapticEnabled, true);
      expect(settingsService.currentSettings.showAnswerFeedback, false);
      expect(settingsService.currentSettings.themeMode, AppThemeMode.dark);
    });

    test('updateSettings persists and notifies changes', () async {
      await settingsService.initialize();

      final newSettings = QuizSettings(
        soundEnabled: false,
        musicEnabled: true,
        hapticEnabled: false,
        showAnswerFeedback: true,
        themeMode: AppThemeMode.light,
      );

      // Listen to settings stream
      final streamFuture = settingsService.settingsStream.first;

      await settingsService.updateSettings(newSettings);

      expect(settingsService.currentSettings, newSettings);

      // Verify stream emits new settings
      final emittedSettings = await streamFuture;
      expect(emittedSettings, newSettings);
    });

    test('toggleSound toggles sound enabled state', () async {
      await settingsService.initialize();

      final initialState = settingsService.currentSettings.soundEnabled;
      final newState = await settingsService.toggleSound();

      expect(newState, !initialState);
      expect(settingsService.currentSettings.soundEnabled, newState);
    });

    test('toggleMusic toggles music enabled state', () async {
      await settingsService.initialize();

      final initialState = settingsService.currentSettings.musicEnabled;
      final newState = await settingsService.toggleMusic();

      expect(newState, !initialState);
      expect(settingsService.currentSettings.musicEnabled, newState);
    });

    test('toggleHaptic toggles haptic enabled state', () async {
      await settingsService.initialize();

      final initialState = settingsService.currentSettings.hapticEnabled;
      final newState = await settingsService.toggleHaptic();

      expect(newState, !initialState);
      expect(settingsService.currentSettings.hapticEnabled, newState);
    });

    test('toggleAnswerFeedback toggles answer feedback state', () async {
      await settingsService.initialize();

      final initialState = settingsService.currentSettings.showAnswerFeedback;
      final newState = await settingsService.toggleAnswerFeedback();

      expect(newState, !initialState);
      expect(settingsService.currentSettings.showAnswerFeedback, newState);
    });

    test('setThemeMode updates theme mode', () async {
      await settingsService.initialize();

      await settingsService.setThemeMode(AppThemeMode.dark);
      expect(settingsService.currentSettings.themeMode, AppThemeMode.dark);

      await settingsService.setThemeMode(AppThemeMode.light);
      expect(settingsService.currentSettings.themeMode, AppThemeMode.light);

      await settingsService.setThemeMode(AppThemeMode.system);
      expect(settingsService.currentSettings.themeMode, AppThemeMode.system);
    });

    test('resetToDefaults restores default settings', () async {
      await settingsService.initialize();

      // Modify settings
      await settingsService.updateSettings(
        QuizSettings(
          soundEnabled: false,
          musicEnabled: false,
          hapticEnabled: false,
          showAnswerFeedback: false,
          themeMode: AppThemeMode.dark,
        ),
      );

      // Reset to defaults
      final defaultSettings = await settingsService.resetToDefaults();

      expect(defaultSettings, QuizSettings.defaultSettings());
      expect(settingsService.currentSettings, QuizSettings.defaultSettings());
    });

    test('settingsStream emits initial settings on initialize', () async {
      final streamFuture = settingsService.settingsStream.first;

      await settingsService.initialize();

      final emittedSettings = await streamFuture;
      expect(emittedSettings, settingsService.currentSettings);
    });

    test(
      'throws StateError when operations called before initialize',
      () async {
        expect(
          () => settingsService.updateSettings(QuizSettings.defaultSettings()),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('handles corrupted stored data gracefully', () async {
      SharedPreferences.setMockInitialValues({'quiz_settings': 'invalid json'});

      await settingsService.initialize();

      // Should fall back to defaults when parsing fails
      expect(settingsService.currentSettings, QuizSettings.defaultSettings());
    });
  });
}
