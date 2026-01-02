import 'package:flags_quiz/daily_challenge/flags_daily_challenge_data_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('FlagsDailyChallengeDataProvider', () {
    late FlagsDailyChallengeDataProvider provider;

    setUp(() {
      provider = const FlagsDailyChallengeDataProvider();
    });

    group('createQuizConfig', () {
      test('creates config with correct quiz ID', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
          timeLimitSeconds: 30,
        );

        expect(config.quizId, 'daily_2024-01-15');
      });

      test('uses no hints for daily challenges', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
        );

        // noHints constructor creates HintConfig with empty initialHints
        expect(config.hintConfig.initialHints, isEmpty);
        expect(config.hintConfig.canEarnHints, false);
        expect(config.hintConfig.allowAdForHint, false);
      });

      test('uses timed mode with correct time limit', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
          timeLimitSeconds: 45,
        );

        expect(config.modeConfig, isA<TimedMode>());
        final timedMode = config.modeConfig as TimedMode;
        expect(timedMode.timePerQuestion, 45);
      });

      test('uses default 30 seconds when no time limit specified', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
        );

        final timedMode = config.modeConfig as TimedMode;
        expect(timedMode.timePerQuestion, 30);
      });

      test('disables skip option', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
        );

        final timedMode = config.modeConfig as TimedMode;
        expect(timedMode.allowSkip, false);
      });

      test('shows answer feedback', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
        );

        final timedMode = config.modeConfig as TimedMode;
        expect(timedMode.showAnswerFeedback, true);
      });

      test('uses timed scoring strategy', () {
        final config = provider.createQuizConfig(
          challengeId: 'daily_2024-01-15',
        );

        expect(config.scoringStrategy, isA<TimedScoring>());
      });
    });

    group('createStorageConfig', () {
      test('creates config with daily_challenge quiz type', () {
        final config = provider.createStorageConfig('eu');

        expect(config.quizType, 'daily_challenge');
      });

      test('creates config with correct category', () {
        final config = provider.createStorageConfig('eu');

        expect(config.quizCategory, 'eu');
      });

      test('sets quiz name to Daily Challenge', () {
        final config = provider.createStorageConfig('eu');

        expect(config.quizName, 'Daily Challenge');
      });

      test('is enabled', () {
        final config = provider.createStorageConfig('eu');

        expect(config.enabled, true);
      });
    });

    group('createLayoutConfig', () {
      test('returns ImageQuestionTextAnswersLayout', () {
        final config = provider.createLayoutConfig();

        expect(config, isA<ImageQuestionTextAnswersLayout>());
      });
    });
  });
}
