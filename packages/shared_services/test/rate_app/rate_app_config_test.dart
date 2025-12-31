import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('RateAppConfig', () {
    test('default constructor has expected defaults', () {
      const config = RateAppConfig();

      expect(config.isEnabled, isTrue);
      expect(config.minCompletedQuizzes, 5);
      expect(config.minDaysSinceInstall, 7);
      expect(config.minScorePercentage, 70);
      expect(config.cooldownDays, 90);
      expect(config.maxLifetimePrompts, 5);
      expect(config.maxDeclines, 3);
      expect(config.useLoveDialog, isTrue);
      expect(config.feedbackEmail, isNull);
    });

    test('disabled constructor creates disabled config', () {
      const config = RateAppConfig.disabled();

      expect(config.isEnabled, isFalse);
      expect(config.minCompletedQuizzes, 0);
      expect(config.minDaysSinceInstall, 0);
      expect(config.minScorePercentage, 0);
      expect(config.cooldownDays, 0);
      expect(config.maxLifetimePrompts, 0);
      expect(config.maxDeclines, 0);
      expect(config.useLoveDialog, isFalse);
      expect(config.feedbackEmail, isNull);
    });

    test('test constructor has relaxed requirements', () {
      const config = RateAppConfig.test();

      expect(config.isEnabled, isTrue);
      expect(config.minCompletedQuizzes, 1);
      expect(config.minDaysSinceInstall, 0);
      expect(config.minScorePercentage, 0);
      expect(config.cooldownDays, 0);
      expect(config.maxLifetimePrompts, 100);
      expect(config.maxDeclines, 100);
      expect(config.useLoveDialog, isTrue);
      expect(config.feedbackEmail, 'test@example.com');
    });

    test('copyWith creates modified copy', () {
      const original = RateAppConfig();
      final modified = original.copyWith(
        isEnabled: false,
        minCompletedQuizzes: 10,
        feedbackEmail: 'support@app.com',
      );

      expect(modified.isEnabled, isFalse);
      expect(modified.minCompletedQuizzes, 10);
      expect(modified.feedbackEmail, 'support@app.com');

      // Unmodified fields remain the same
      expect(modified.minDaysSinceInstall, original.minDaysSinceInstall);
      expect(modified.minScorePercentage, original.minScorePercentage);
      expect(modified.cooldownDays, original.cooldownDays);
      expect(modified.maxLifetimePrompts, original.maxLifetimePrompts);
      expect(modified.maxDeclines, original.maxDeclines);
      expect(modified.useLoveDialog, original.useLoveDialog);
    });

    test('equality works correctly', () {
      const config1 = RateAppConfig();
      const config2 = RateAppConfig();
      const config3 = RateAppConfig(minCompletedQuizzes: 10);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('hashCode is consistent with equality', () {
      const config1 = RateAppConfig();
      const config2 = RateAppConfig();

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('toString contains all fields', () {
      const config = RateAppConfig(
        isEnabled: true,
        minCompletedQuizzes: 5,
        feedbackEmail: 'test@test.com',
      );

      final str = config.toString();
      expect(str, contains('isEnabled: true'));
      expect(str, contains('minCompletedQuizzes: 5'));
      expect(str, contains('feedbackEmail: test@test.com'));
    });
  });
}
