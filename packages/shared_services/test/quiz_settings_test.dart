import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('QuizSettings', () {
    test('defaultSettings creates settings with all features enabled', () {
      final settings = QuizSettings.defaultSettings();

      expect(settings.soundEnabled, true);
      expect(settings.musicEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('copyWith creates new instance with modified fields', () {
      final original = QuizSettings.defaultSettings();
      final modified = original.copyWith(
        soundEnabled: false,
        themeMode: AppThemeMode.dark,
      );

      expect(modified.soundEnabled, false);
      expect(modified.musicEnabled, true); // unchanged
      expect(modified.hapticEnabled, true); // unchanged
      expect(modified.themeMode, AppThemeMode.dark);
    });

    test('toJson serializes settings correctly', () {
      final settings = QuizSettings(
        soundEnabled: false,
        musicEnabled: true,
        hapticEnabled: false,
        themeMode: AppThemeMode.dark,
      );

      final json = settings.toJson();

      expect(json['soundEnabled'], false);
      expect(json['musicEnabled'], true);
      expect(json['hapticEnabled'], false);
      expect(json['themeMode'], 'dark');
    });

    test('fromJson deserializes settings correctly', () {
      final json = {
        'soundEnabled': false,
        'musicEnabled': true,
        'hapticEnabled': false,
        'themeMode': 'dark',
      };

      final settings = QuizSettings.fromJson(json);

      expect(settings.soundEnabled, false);
      expect(settings.musicEnabled, true);
      expect(settings.hapticEnabled, false);
      expect(settings.themeMode, AppThemeMode.dark);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};
      final settings = QuizSettings.fromJson(json);

      expect(settings.soundEnabled, true);
      expect(settings.musicEnabled, true);
      expect(settings.hapticEnabled, true);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('fromJson handles invalid theme mode with default', () {
      final json = {
        'soundEnabled': true,
        'musicEnabled': true,
        'hapticEnabled': true,
        'themeMode': 'invalid',
      };

      final settings = QuizSettings.fromJson(json);
      expect(settings.themeMode, AppThemeMode.system);
    });

    test('equality works correctly', () {
      final settings1 = QuizSettings.defaultSettings();
      final settings2 = QuizSettings.defaultSettings();
      final settings3 = settings1.copyWith(soundEnabled: false);

      expect(settings1, settings2);
      expect(settings1, isNot(settings3));
    });

    test('hashCode is consistent with equality', () {
      final settings1 = QuizSettings.defaultSettings();
      final settings2 = QuizSettings.defaultSettings();

      expect(settings1.hashCode, settings2.hashCode);
    });

    test('toString returns meaningful representation', () {
      final settings = QuizSettings.defaultSettings();
      final string = settings.toString();

      expect(string, contains('QuizSettings'));
      expect(string, contains('soundEnabled: true'));
      expect(string, contains('musicEnabled: true'));
    });
  });

  group('AppThemeMode', () {
    test('flutterThemeMode converts correctly', () {
      final lightSettings = QuizSettings.defaultSettings().copyWith(
        themeMode: AppThemeMode.light,
      );
      final darkSettings = QuizSettings.defaultSettings().copyWith(
        themeMode: AppThemeMode.dark,
      );
      final systemSettings = QuizSettings.defaultSettings().copyWith(
        themeMode: AppThemeMode.system,
      );

      expect(lightSettings.flutterThemeMode, ThemeMode.light);
      expect(darkSettings.flutterThemeMode, ThemeMode.dark);
      expect(systemSettings.flutterThemeMode, ThemeMode.system);
    });
  });
}
