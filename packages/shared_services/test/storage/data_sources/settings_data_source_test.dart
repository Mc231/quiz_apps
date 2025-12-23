import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SettingsDataSource Interface', () {
    test('SettingsDataSourceImpl can be instantiated', () {
      expect(
        () => SettingsDataSourceImpl(),
        returnsNormally,
      );
    });
  });

  group('UserSettingsModel integration', () {
    test('UserSettingsModel.defaults creates valid default values', () {
      final settings = UserSettingsModel.defaults();

      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.exitConfirmationEnabled, true);
      expect(settings.showHints, true);
      expect(settings.themeMode, AppThemeMode.light);
      expect(settings.language, 'en');
      expect(settings.hints5050Available, 3);
      expect(settings.hintsSkipAvailable, 3);
      expect(settings.lastPlayedQuizType, isNull);
      expect(settings.lastPlayedCategory, isNull);
    });

    test('UserSettingsModel toMap and fromMap are symmetric', () {
      final now = DateTime.now();
      final settings = UserSettingsModel(
        soundEnabled: false,
        hapticEnabled: true,
        exitConfirmationEnabled: false,
        showHints: false,
        themeMode: AppThemeMode.dark,
        language: 'uk',
        hints5050Available: 5,
        hintsSkipAvailable: 10,
        lastPlayedQuizType: 'flags',
        lastPlayedCategory: 'europe',
        createdAt: now,
        updatedAt: now,
      );

      final map = settings.toMap();
      final restored = UserSettingsModel.fromMap(map);

      expect(restored.soundEnabled, settings.soundEnabled);
      expect(restored.hapticEnabled, settings.hapticEnabled);
      expect(restored.exitConfirmationEnabled, settings.exitConfirmationEnabled);
      expect(restored.showHints, settings.showHints);
      expect(restored.themeMode, settings.themeMode);
      expect(restored.language, settings.language);
      expect(restored.hints5050Available, settings.hints5050Available);
      expect(restored.hintsSkipAvailable, settings.hintsSkipAvailable);
      expect(restored.lastPlayedQuizType, settings.lastPlayedQuizType);
      expect(restored.lastPlayedCategory, settings.lastPlayedCategory);
    });

    test('UserSettingsModel copyWith updates specified fields', () {
      final settings = UserSettingsModel.defaults();
      final updated = settings.copyWith(
        soundEnabled: false,
        themeMode: AppThemeMode.dark,
        language: 'de',
      );

      expect(updated.soundEnabled, false);
      expect(updated.themeMode, AppThemeMode.dark);
      expect(updated.language, 'de');
      // Unchanged fields
      expect(updated.hapticEnabled, settings.hapticEnabled);
      expect(updated.hints5050Available, settings.hints5050Available);
    });

    test('UserSettingsModel fromMap handles all theme modes', () {
      for (final mode in AppThemeMode.values) {
        final map = UserSettingsModel.defaults().toMap();
        map['theme_mode'] = mode.name;
        final settings = UserSettingsModel.fromMap(map);
        expect(settings.themeMode, mode);
      }
    });

    test('UserSettingsModel fromMap handles unknown theme mode gracefully', () {
      final map = UserSettingsModel.defaults().toMap();
      map['theme_mode'] = 'unknown_mode';
      final settings = UserSettingsModel.fromMap(map);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('UserSettingsModel fromMap handles null theme mode', () {
      final map = UserSettingsModel.defaults().toMap();
      map['theme_mode'] = null;
      final settings = UserSettingsModel.fromMap(map);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('UserSettingsModel fromMap handles boolean as int', () {
      final now = DateTime.now();
      final map = <String, dynamic>{
        'id': 1,
        'sound_enabled': 1,
        'haptic_enabled': 0,
        'exit_confirmation_enabled': 1,
        'show_hints': 1,
        'theme_mode': 'system',
        'language': 'en',
        'hints_50_50_available': 3,
        'hints_skip_available': 3,
        'last_played_quiz_type': null,
        'last_played_category': null,
        'created_at': now.millisecondsSinceEpoch ~/ 1000,
        'updated_at': now.millisecondsSinceEpoch ~/ 1000,
      };

      final settings = UserSettingsModel.fromMap(map);

      expect(settings.soundEnabled, true);
      expect(settings.hapticEnabled, false);
      expect(settings.exitConfirmationEnabled, true);
    });

    test('UserSettingsModel totalHintsAvailable is correct', () {
      final settings = UserSettingsModel.defaults();
      expect(settings.totalHintsAvailable, 6); // 3 + 3
    });
  });

  group('AppThemeMode', () {
    test('all theme modes have correct names', () {
      expect(AppThemeMode.system.name, 'system');
      expect(AppThemeMode.light.name, 'light');
      expect(AppThemeMode.dark.name, 'dark');
    });
  });
}
