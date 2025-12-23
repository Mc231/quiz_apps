import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('StorageConfig', () {
    test('default constructor has correct defaults', () {
      const config = StorageConfig();

      expect(config.enabled, isTrue);
      expect(config.saveAnswersDuringQuiz, isTrue);
      expect(config.updateStatsRealtime, isFalse);
      expect(config.allowSessionRecovery, isTrue);
      expect(config.sessionRecoveryMaxAgeHours, equals(24));
      expect(config.quizType, isNull);
      expect(config.quizCategory, isNull);
      expect(config.quizName, isNull);
      expect(config.appVersion, equals('1.0.0'));
      expect(config.version, equals(1));
    });

    test('disabled config returns correct values', () {
      const config = StorageConfig.disabled;

      expect(config.enabled, isFalse);
    });

    test('defaultConfig is enabled', () {
      const config = StorageConfig.defaultConfig;

      expect(config.enabled, isTrue);
    });

    test('toMap produces correct map', () {
      const config = StorageConfig(
        enabled: true,
        saveAnswersDuringQuiz: false,
        updateStatsRealtime: true,
        allowSessionRecovery: false,
        sessionRecoveryMaxAgeHours: 12,
        quizType: 'flags',
        quizCategory: 'europe',
        quizName: 'European Flags',
        appVersion: '2.0.0',
      );

      final map = config.toMap();

      expect(map['enabled'], isTrue);
      expect(map['saveAnswersDuringQuiz'], isFalse);
      expect(map['updateStatsRealtime'], isTrue);
      expect(map['allowSessionRecovery'], isFalse);
      expect(map['sessionRecoveryMaxAgeHours'], equals(12));
      expect(map['quizType'], equals('flags'));
      expect(map['quizCategory'], equals('europe'));
      expect(map['quizName'], equals('European Flags'));
      expect(map['appVersion'], equals('2.0.0'));
      expect(map['version'], equals(1));
    });

    test('fromMap creates correct config', () {
      final map = {
        'enabled': false,
        'saveAnswersDuringQuiz': true,
        'updateStatsRealtime': false,
        'allowSessionRecovery': true,
        'sessionRecoveryMaxAgeHours': 48,
        'quizType': 'capitals',
        'quizCategory': 'asia',
        'quizName': 'Asian Capitals',
        'appVersion': '3.0.0',
        'version': 1,
      };

      final config = StorageConfig.fromMap(map);

      expect(config.enabled, isFalse);
      expect(config.saveAnswersDuringQuiz, isTrue);
      expect(config.updateStatsRealtime, isFalse);
      expect(config.allowSessionRecovery, isTrue);
      expect(config.sessionRecoveryMaxAgeHours, equals(48));
      expect(config.quizType, equals('capitals'));
      expect(config.quizCategory, equals('asia'));
      expect(config.quizName, equals('Asian Capitals'));
      expect(config.appVersion, equals('3.0.0'));
    });

    test('fromMap handles missing values', () {
      final config = StorageConfig.fromMap({});

      expect(config.enabled, isTrue);
      expect(config.saveAnswersDuringQuiz, isTrue);
      expect(config.updateStatsRealtime, isFalse);
      expect(config.allowSessionRecovery, isTrue);
      expect(config.sessionRecoveryMaxAgeHours, equals(24));
      expect(config.quizType, isNull);
      expect(config.quizCategory, isNull);
      expect(config.quizName, isNull);
      expect(config.appVersion, equals('1.0.0'));
    });

    test('copyWith creates correct copy', () {
      const original = StorageConfig(
        enabled: true,
        quizType: 'flags',
        appVersion: '1.0.0',
      );

      final copy = original.copyWith(
        enabled: false,
        quizName: 'New Name',
      );

      expect(copy.enabled, isFalse);
      expect(copy.quizType, equals('flags')); // Unchanged
      expect(copy.quizName, equals('New Name'));
      expect(copy.appVersion, equals('1.0.0')); // Unchanged
    });

    test('equality works correctly', () {
      const config1 = StorageConfig(
        enabled: true,
        quizType: 'flags',
        appVersion: '1.0.0',
      );

      const config2 = StorageConfig(
        enabled: true,
        quizType: 'flags',
        appVersion: '1.0.0',
      );

      const config3 = StorageConfig(
        enabled: false,
        quizType: 'flags',
        appVersion: '1.0.0',
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });

    test('hashCode is consistent', () {
      const config1 = StorageConfig(
        enabled: true,
        quizType: 'flags',
      );

      const config2 = StorageConfig(
        enabled: true,
        quizType: 'flags',
      );

      expect(config1.hashCode, equals(config2.hashCode));
    });

    test('toString returns readable string', () {
      const config = StorageConfig(
        enabled: true,
        quizType: 'flags',
        quizName: 'Flags Quiz',
      );

      final string = config.toString();

      expect(string, contains('StorageConfig'));
      expect(string, contains('enabled: true'));
      expect(string, contains('quizType: flags'));
      expect(string, contains('quizName: Flags Quiz'));
    });
  });

  group('QuizConfig with StorageConfig', () {
    test('includes storageConfig in toMap', () {
      const config = QuizConfig(
        quizId: 'test-quiz',
        storageConfig: StorageConfig(
          enabled: true,
          quizType: 'flags',
        ),
      );

      final map = config.toMap();

      expect(map['storageConfig'], isNotNull);
      expect(map['storageConfig']['enabled'], isTrue);
      expect(map['storageConfig']['quizType'], equals('flags'));
    });

    test('fromMap restores storageConfig', () {
      final map = {
        'quizId': 'test-quiz',
        'modeConfig': {'type': 'standard'},
        'scoringStrategy': {'type': 'simple'},
        'storageConfig': {
          'enabled': false,
          'quizType': 'capitals',
        },
      };

      final config = QuizConfig.fromMap(map);

      expect(config.storageConfig.enabled, isFalse);
      expect(config.storageConfig.quizType, equals('capitals'));
    });

    test('copyWith preserves storageConfig', () {
      const original = QuizConfig(
        quizId: 'test',
        storageConfig: StorageConfig(quizType: 'flags'),
      );

      final copy = original.copyWith(
        quizId: 'new-id',
      );

      expect(copy.storageConfig.quizType, equals('flags'));
    });

    test('copyWith can update storageConfig', () {
      const original = QuizConfig(
        quizId: 'test',
        storageConfig: StorageConfig(quizType: 'flags'),
      );

      final copy = original.copyWith(
        storageConfig: const StorageConfig(quizType: 'capitals'),
      );

      expect(copy.storageConfig.quizType, equals('capitals'));
    });
  });
}
