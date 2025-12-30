import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('SettingsEvent', () {
    group('SettingsChangedEvent', () {
      test('creates with correct event name', () {
        const event = SettingsChangedEvent(
          settingName: 'difficulty',
          oldValue: 'easy',
          newValue: 'hard',
        );

        expect(event.eventName, equals('settings_changed'));
      });

      test('includes all required parameters', () {
        const event = SettingsChangedEvent(
          settingName: 'language',
          oldValue: 'en',
          newValue: 'es',
        );

        expect(event.parameters, {
          'setting_name': 'language',
          'old_value': 'en',
          'new_value': 'es',
        });
      });

      test('includes optional category when provided', () {
        const event = SettingsChangedEvent(
          settingName: 'volume',
          oldValue: '50',
          newValue: '75',
          settingCategory: 'audio',
        );

        expect(event.parameters['setting_category'], equals('audio'));
      });

      test('factory constructor works', () {
        final event = SettingsEvent.changed(
          settingName: 'notifications',
          oldValue: 'off',
          newValue: 'on',
        );

        expect(event, isA<SettingsChangedEvent>());
      });
    });

    group('SoundEffectsToggledEvent', () {
      test('creates with correct event name', () {
        const event = SoundEffectsToggledEvent(
          enabled: true,
          source: 'settings_screen',
        );

        expect(event.eventName, equals('sound_effects_toggled'));
      });

      test('includes all parameters', () {
        const event = SoundEffectsToggledEvent(
          enabled: false,
          source: 'quick_settings',
        );

        expect(event.parameters, {
          'enabled': 0,
          'source': 'quick_settings',
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.soundEffectsToggled(
          enabled: true,
          source: 'onboarding',
        );

        expect(event, isA<SoundEffectsToggledEvent>());
      });
    });

    group('HapticFeedbackToggledEvent', () {
      test('creates with correct event name', () {
        const event = HapticFeedbackToggledEvent(
          enabled: true,
          source: 'settings_screen',
        );

        expect(event.eventName, equals('haptic_feedback_toggled'));
      });

      test('includes all parameters', () {
        const event = HapticFeedbackToggledEvent(
          enabled: false,
          source: 'accessibility_menu',
        );

        expect(event.parameters, {
          'enabled': 0,
          'source': 'accessibility_menu',
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.hapticFeedbackToggled(
          enabled: false,
          source: 'settings',
        );

        expect(event, isA<HapticFeedbackToggledEvent>());
      });
    });

    group('ThemeChangedEvent', () {
      test('creates with correct event name', () {
        const event = ThemeChangedEvent(
          newTheme: 'dark',
          previousTheme: 'light',
          source: 'settings_screen',
        );

        expect(event.eventName, equals('theme_changed'));
      });

      test('includes all parameters', () {
        const event = ThemeChangedEvent(
          newTheme: 'system',
          previousTheme: 'dark',
          source: 'quick_toggle',
        );

        expect(event.parameters, {
          'new_theme': 'system',
          'previous_theme': 'dark',
          'source': 'quick_toggle',
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.themeChanged(
          newTheme: 'light',
          previousTheme: 'system',
          source: 'app_bar',
        );

        expect(event, isA<ThemeChangedEvent>());
      });
    });

    group('AnswerFeedbackToggledEvent', () {
      test('creates with correct event name', () {
        const event = AnswerFeedbackToggledEvent(
          enabled: true,
          source: 'settings_screen',
        );

        expect(event.eventName, equals('answer_feedback_toggled'));
      });

      test('includes all parameters', () {
        const event = AnswerFeedbackToggledEvent(
          enabled: false,
          source: 'quiz_preferences',
        );

        expect(event.parameters, {
          'enabled': 0,
          'source': 'quiz_preferences',
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.answerFeedbackToggled(
          enabled: true,
          source: 'settings',
        );

        expect(event, isA<AnswerFeedbackToggledEvent>());
      });
    });

    group('ResetConfirmedEvent', () {
      test('creates with correct event name', () {
        const event = ResetConfirmedEvent(
          resetType: 'full',
          sessionsDeleted: 100,
          achievementsReset: 25,
        );

        expect(event.eventName, equals('reset_confirmed'));
      });

      test('includes all parameters', () {
        const event = ResetConfirmedEvent(
          resetType: 'statistics_only',
          sessionsDeleted: 50,
          achievementsReset: 0,
        );

        expect(event.parameters, {
          'reset_type': 'statistics_only',
          'sessions_deleted': 50,
          'achievements_reset': 0,
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.resetConfirmed(
          resetType: 'achievements_only',
          sessionsDeleted: 0,
          achievementsReset: 30,
        );

        expect(event, isA<ResetConfirmedEvent>());
      });
    });

    group('PrivacyPolicyViewedEvent', () {
      test('creates with correct event name', () {
        const event = PrivacyPolicyViewedEvent(
          source: 'settings_screen',
        );

        expect(event.eventName, equals('privacy_policy_viewed'));
      });

      test('includes source parameter', () {
        const event = PrivacyPolicyViewedEvent(
          source: 'onboarding',
        );

        expect(event.parameters, {
          'source': 'onboarding',
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.privacyPolicyViewed(
          source: 'about_dialog',
        );

        expect(event, isA<PrivacyPolicyViewedEvent>());
      });
    });

    group('TermsOfServiceViewedEvent', () {
      test('creates with correct event name', () {
        const event = TermsOfServiceViewedEvent(
          source: 'settings_screen',
        );

        expect(event.eventName, equals('terms_of_service_viewed'));
      });

      test('includes source parameter', () {
        const event = TermsOfServiceViewedEvent(
          source: 'registration',
        );

        expect(event.parameters, {
          'source': 'registration',
        });
      });

      test('factory constructor works', () {
        final event = SettingsEvent.termsOfServiceViewed(
          source: 'footer_link',
        );

        expect(event, isA<TermsOfServiceViewedEvent>());
      });
    });
  });

  group('SettingsEvent base class', () {
    test('all settings events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const SettingsChangedEvent(
          settingName: 'test',
          oldValue: 'a',
          newValue: 'b',
        ),
        const SoundEffectsToggledEvent(
          enabled: true,
          source: 'test',
        ),
        const HapticFeedbackToggledEvent(
          enabled: false,
          source: 'test',
        ),
        const ThemeChangedEvent(
          newTheme: 'dark',
          previousTheme: 'light',
          source: 'test',
        ),
        const PrivacyPolicyViewedEvent(source: 'test'),
        const TermsOfServiceViewedEvent(source: 'test'),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });
  });
}
