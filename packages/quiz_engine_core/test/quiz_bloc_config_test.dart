import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizBloc Configuration', () {
    late List<QuestionEntry> testData;

    setUp(() {
      testData = [
        QuestionEntry(
          type: TextQuestion('Question 1'),
          otherOptions: const {'id': '1', 'name': 'Test 1'},
        ),
        QuestionEntry(
          type: TextQuestion('Question 2'),
          otherOptions: const {'id': '2', 'name': 'Test 2'},
        ),
        QuestionEntry(
          type: TextQuestion('Question 3'),
          otherOptions: const {'id': '3', 'name': 'Test 3'},
        ),
        QuestionEntry(
          type: TextQuestion('Question 4'),
          otherOptions: const {'id': '4', 'name': 'Test 4'},
        ),
        QuestionEntry(
          type: TextQuestion('Question 5'),
          otherOptions: const {'id': '5', 'name': 'Test 5'},
        ),
      ];
    });

    test('QuizBloc accepts ConfigManager with defaultConfig', () {
      const defaultConfig = QuizConfig(quizId: 'test_quiz');
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      // Verify configManager is set
      expect(bloc.configManager, equals(configManager));
      expect(bloc.configManager.defaultConfig.quizId, 'test_quiz');

      bloc.dispose();
    });

    test('QuizBloc ConfigManager contains correct defaultConfig', () {
      const defaultConfig = QuizConfig(quizId: 'custom_quiz');
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.quizId, 'custom_quiz');
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with custom mode', () {
      const defaultConfig = QuizConfig(
        quizId: 'timed_quiz',
        modeConfig: QuizModeConfig.timed(timePerQuestion: 30),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.quizId, 'timed_quiz');
      expect(bloc.configManager.defaultConfig.modeConfig.mode, QuizMode.timed);
      expect(bloc.configManager.defaultConfig.modeConfig.timePerQuestion, 30);
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with custom scoring strategy', () {
      const defaultConfig = QuizConfig(
        quizId: 'custom_quiz',
        scoringStrategy: TimedScoring(
          basePointsPerQuestion: 200,
          bonusPerSecondSaved: 10,
        ),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.scoringStrategy, isA<TimedScoring>());
      final strategy = bloc.configManager.defaultConfig.scoringStrategy as TimedScoring;
      expect(strategy.basePointsPerQuestion, 200);
      expect(strategy.bonusPerSecondSaved, 10);
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with UI behavior config', () {
      const defaultConfig = QuizConfig(
        quizId: 'ui_quiz',
        uiBehaviorConfig: UIBehaviorConfig(
          showAnswerFeedback: false,
          answerFeedbackDuration: 2000,
          playSounds: false,
          hapticFeedback: false,
        ),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.uiBehaviorConfig.showAnswerFeedback, false);
      expect(bloc.configManager.defaultConfig.uiBehaviorConfig.answerFeedbackDuration, 2000);
      expect(bloc.configManager.defaultConfig.uiBehaviorConfig.playSounds, false);
      expect(bloc.configManager.defaultConfig.uiBehaviorConfig.hapticFeedback, false);
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with hint config', () {
      const defaultConfig = QuizConfig(
        quizId: 'hint_quiz',
        hintConfig: HintConfig(
          initialHints: {
            HintType.fiftyFifty: 5,
            HintType.skip: 3,
          },
          canEarnHints: false,
        ),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.hintConfig.initialHints[HintType.fiftyFifty], 5);
      expect(bloc.configManager.defaultConfig.hintConfig.initialHints[HintType.skip], 3);
      expect(bloc.configManager.defaultConfig.hintConfig.canEarnHints, false);
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with question config', () {
      const defaultConfig = QuizConfig(
        quizId: 'question_quiz',
        questionConfig: QuestionConfig(
          optionCount: 6,
          shuffleQuestions: false,
          shuffleOptions: false,
        ),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.questionConfig.optionCount, 6);
      expect(bloc.configManager.defaultConfig.questionConfig.shuffleQuestions, false);
      expect(bloc.configManager.defaultConfig.questionConfig.shuffleOptions, false);
      bloc.dispose();
    });

    test('QuizBloc initializes with LoadingState and null config', () {
      const defaultConfig = QuizConfig(quizId: 'test_init');
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager,
      );

      expect(bloc.initialState, isA<LoadingState>());
      // Config is null before performInitialLoad
      expect(bloc.config, isNull);
      // But configManager has the defaultConfig
      expect(bloc.configManager.defaultConfig.quizId, 'test_init');

      bloc.dispose();
    });
  });
}