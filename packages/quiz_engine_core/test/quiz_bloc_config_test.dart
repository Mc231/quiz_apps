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
        analyticsService: NoOpQuizAnalyticsService(),
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
        analyticsService: NoOpQuizAnalyticsService(),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.quizId, 'custom_quiz');
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with custom mode', () {
      final defaultConfig = QuizConfig(
        quizId: 'timed_quiz',
        modeConfig: QuizModeConfig.timed( timePerQuestion: 30),
      );
      final configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        analyticsService: NoOpQuizAnalyticsService(),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.quizId, 'timed_quiz');
      expect(bloc.configManager.defaultConfig.modeConfig, isA<TimedMode>());
      final timedMode =
          bloc.configManager.defaultConfig.modeConfig as TimedMode;
      expect(timedMode.timePerQuestion, 30);
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
        analyticsService: NoOpQuizAnalyticsService(),
        configManager: configManager,
      );

      expect(
        bloc.configManager.defaultConfig.scoringStrategy,
        isA<TimedScoring>(),
      );
      final strategy =
          bloc.configManager.defaultConfig.scoringStrategy as TimedScoring;
      expect(strategy.basePointsPerQuestion, 200);
      expect(strategy.bonusPerSecondSaved, 10);
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with UI behavior config', () {
      const defaultConfig = QuizConfig(
        quizId: 'ui_quiz',
        uiBehaviorConfig: UIBehaviorConfig(
          answerFeedbackDuration: 2000,
          playSounds: false,
          hapticFeedback: false,
        ),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        configManager: configManager, analyticsService: NoOpQuizAnalyticsService(),
      );

      expect(
        bloc
            .configManager
            .defaultConfig
            .uiBehaviorConfig
            .answerFeedbackDuration,
        2000,
      );
      expect(
        bloc.configManager.defaultConfig.uiBehaviorConfig.playSounds,
        false,
      );
      expect(
        bloc.configManager.defaultConfig.uiBehaviorConfig.hapticFeedback,
        false,
      );
      bloc.dispose();
    });

    test('ConfigManager holds QuizConfig with hint config', () {
      const defaultConfig = QuizConfig(
        quizId: 'hint_quiz',
        hintConfig: HintConfig(
          initialHints: {HintType.fiftyFifty: 5, HintType.skip: 3},
          canEarnHints: false,
        ),
      );
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final bloc = QuizBloc(
        () async => testData,
        RandomItemPicker(testData),
        analyticsService: NoOpQuizAnalyticsService(),
        configManager: configManager,
      );

      expect(
        bloc.configManager.defaultConfig.hintConfig.initialHints[HintType
            .fiftyFifty],
        5,
      );
      expect(
        bloc.configManager.defaultConfig.hintConfig.initialHints[HintType.skip],
        3,
      );
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
        analyticsService: NoOpQuizAnalyticsService(),
        configManager: configManager,
      );

      expect(bloc.configManager.defaultConfig.questionConfig.optionCount, 6);
      expect(
        bloc.configManager.defaultConfig.questionConfig.shuffleQuestions,
        false,
      );
      expect(
        bloc.configManager.defaultConfig.questionConfig.shuffleOptions,
        false,
      );
      bloc.dispose();
    });

    test(
      'QuizBloc initializes with LoadingState and configManager available',
      () {
        const defaultConfig = QuizConfig(quizId: 'test_init');
        const configManager = ConfigManager(defaultConfig: defaultConfig);

        final bloc = QuizBloc(
          () async => testData,
          RandomItemPicker(testData),
          analyticsService: NoOpQuizAnalyticsService(),
          configManager: configManager,
        );

        expect(bloc.initialState, isA<LoadingState>());
        // Config is initialized during performInitialLoad(), not before
        // But configManager always has the defaultConfig available
        expect(bloc.configManager.defaultConfig.quizId, 'test_init');

        bloc.dispose();
      },
    );
  });

  group('ConfigManager Settings Integration', () {
    test('ConfigManager without settings returns default config', () async {
      const defaultConfig = QuizConfig(quizId: 'test_quiz');
      const configManager = ConfigManager(defaultConfig: defaultConfig);

      final config = await configManager.getConfig(source: const DefaultSource());

      expect(config.quizId, 'test_quiz');
      expect(config.uiBehaviorConfig.playSounds, true);
      expect(config.uiBehaviorConfig.hapticFeedback, true);
      expect(config.modeConfig.answerFeedbackConfig is AlwaysFeedbackConfig, isTrue);
    });

    test('ConfigManager with settings applies settings to config', () async {
      const defaultConfig = QuizConfig(quizId: 'test_quiz');
      final configManager = ConfigManager(
        defaultConfig: defaultConfig,
        getSettings: () => {
          'soundEnabled': false,
          'hapticEnabled': false,
          'showAnswerFeedback': false,
        },
      );

      final config = await configManager.getConfig(source: const DefaultSource());

      expect(config.quizId, 'test_quiz');
      expect(config.uiBehaviorConfig.playSounds, false);
      expect(config.uiBehaviorConfig.hapticFeedback, false);
      expect(config.modeConfig.answerFeedbackConfig is NoFeedbackConfig, isTrue);
    });

    test('ConfigManager preserves non-settings UI behavior fields', () async {
      const defaultConfig = QuizConfig(
        quizId: 'test_quiz',
        uiBehaviorConfig: UIBehaviorConfig(
          answerFeedbackDuration: 2500,
          showExitConfirmation: false,
        ),
      );
      final configManager = ConfigManager(
        defaultConfig: defaultConfig,
        getSettings: () => {
          'soundEnabled': false,
          'hapticEnabled': true,
          'showAnswerFeedback': false,
        },
      );

      final config = await configManager.getConfig(source: const DefaultSource());

      // Settings applied
      expect(config.uiBehaviorConfig.playSounds, false);
      expect(config.uiBehaviorConfig.hapticFeedback, true);
      expect(config.modeConfig.answerFeedbackConfig is NoFeedbackConfig, isTrue);

      // Preserved from defaultConfig
      expect(config.uiBehaviorConfig.answerFeedbackDuration, 2500);
      expect(config.uiBehaviorConfig.showExitConfirmation, false);
    });

    test('ConfigManager preserves all non-UI config fields', () async {
      final defaultConfig = QuizConfig(
        quizId: 'test_quiz',
        modeConfig: QuizModeConfig.timed( timePerQuestion: 15),
        hintConfig: HintConfig.noHints(),
        scoringStrategy: const TimedScoring(
          basePointsPerQuestion: 100,
          bonusPerSecondSaved: 5,
        ),
      );
      final configManager = ConfigManager(
        defaultConfig: defaultConfig,
        getSettings: () => {
          'soundEnabled': false,
          'hapticEnabled': false,
          'showAnswerFeedback': true,
        },
      );

      final config = await configManager.getConfig(source: const DefaultSource());

      // Mode config preserved
      expect(config.modeConfig, isA<TimedMode>());
      expect((config.modeConfig as TimedMode).timePerQuestion, 15);

      // Hint config preserved
      expect(config.hintConfig.initialHints.isEmpty, true);

      // Scoring strategy preserved
      expect(config.scoringStrategy, isA<TimedScoring>());
      expect((config.scoringStrategy as TimedScoring).basePointsPerQuestion, 100);
    });

    test('ConfigManager handles missing settings gracefully', () async {
      const defaultConfig = QuizConfig(quizId: 'test_quiz');
      final configManager = ConfigManager(
        defaultConfig: defaultConfig,
        getSettings: () => {
          'soundEnabled': false,
          // Missing hapticEnabled and showAnswerFeedback
        },
      );

      final config = await configManager.getConfig(source: const DefaultSource());

      expect(config.uiBehaviorConfig.playSounds, false);
      expect(config.uiBehaviorConfig.hapticFeedback, true); // Default
      expect(config.modeConfig.answerFeedbackConfig is AlwaysFeedbackConfig, isTrue); // Default from modeConfig
    });

    test('ConfigManager settings reflect real-time changes', () async {
      const defaultConfig = QuizConfig(quizId: 'test_quiz');
      var soundEnabled = true;

      final configManager = ConfigManager(
        defaultConfig: defaultConfig,
        getSettings: () => {
          'soundEnabled': soundEnabled,
          'hapticEnabled': true,
          'showAnswerFeedback': true,
        },
      );

      // First call
      var config = await configManager.getConfig(source: const DefaultSource());
      expect(config.uiBehaviorConfig.playSounds, true);

      // Change setting
      soundEnabled = false;

      // Second call reflects change
      config = await configManager.getConfig(source: const DefaultSource());
      expect(config.uiBehaviorConfig.playSounds, false);
    });
  });
}
