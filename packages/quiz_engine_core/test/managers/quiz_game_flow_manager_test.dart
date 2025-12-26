import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/business_logic/managers/quiz_game_flow_manager.dart';
import 'package:quiz_engine_core/src/model/config/quiz_mode_config.dart';
import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';
import 'package:quiz_engine_core/src/random_item_picker.dart';

void main() {
  late QuizGameFlowManager manager;
  late RandomItemPicker picker;

  // Test data
  final testEntry1 = QuestionEntry(type: TextQuestion('Answer 1'));
  final testEntry2 = QuestionEntry(type: TextQuestion('Answer 2'));
  final testEntry3 = QuestionEntry(type: TextQuestion('Answer 3'));
  final testEntry4 = QuestionEntry(type: TextQuestion('Answer 4'));
  final testEntry5 = QuestionEntry(type: TextQuestion('Answer 5'));

  List<QuestionEntry> createTestItems() {
    return [testEntry1, testEntry2, testEntry3, testEntry4, testEntry5];
  }

  setUp(() {
    picker = RandomItemPicker([]);
    manager = QuizGameFlowManager(randomItemPicker: picker);
  });

  group('QuizGameFlowManager initialization', () {
    test('should start uninitialized', () {
      expect(manager.isInitialized, isFalse);
      expect(manager.currentQuestion, isNull);
      expect(manager.totalCount, equals(0));
    });

    test('should initialize with items', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      expect(manager.isInitialized, isTrue);
      expect(manager.totalCount, equals(5));
      expect(manager.hasMoreQuestions, isTrue);
    });

    test('should apply filter during initialization', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
        filter: (item) => item != testEntry1 && item != testEntry2,
      );

      expect(manager.totalCount, equals(3));
    });
  });

  group('QuizGameFlowManager question picking', () {
    setUp(() {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );
    });

    test('should pick a question', () {
      final question = manager.pickNextQuestion();

      expect(question, isNotNull);
      expect(manager.currentQuestion, equals(question));
    });

    test('should call onNewQuestion callback', () {
      Question? callbackQuestion;
      manager = QuizGameFlowManager(
        randomItemPicker: picker,
        onNewQuestion: (q) => callbackQuestion = q,
      );
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      manager.pickNextQuestion();

      expect(callbackQuestion, isNotNull);
    });

    test('should return null when out of questions', () {
      // Pick all questions
      for (var i = 0; i < 5; i++) {
        manager.pickNextQuestion();
      }

      final question = manager.pickNextQuestion();

      expect(question, isNull);
    });

    test('should call onGameOver when out of questions', () {
      var gameOverCalled = false;
      manager = QuizGameFlowManager(
        randomItemPicker: picker,
        onGameOver: () => gameOverCalled = true,
      );
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      // Pick all questions
      for (var i = 0; i < 5; i++) {
        manager.pickNextQuestion();
      }

      // Try to pick one more
      manager.pickNextQuestion();

      expect(gameOverCalled, isTrue);
    });
  });

  group('QuizGameFlowManager game over detection', () {
    setUp(() {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );
    });

    test('should detect game over when out of lives', () {
      var gameOverCalled = false;
      manager = QuizGameFlowManager(
        randomItemPicker: picker,
        onGameOver: () => gameOverCalled = true,
      );
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      final question = manager.pickNextQuestion(remainingLives: 0);

      expect(question, isNull);
      expect(gameOverCalled, isTrue);
    });

    test('should detect game over when time expired', () {
      var gameOverCalled = false;
      manager = QuizGameFlowManager(
        randomItemPicker: picker,
        onGameOver: () => gameOverCalled = true,
      );
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      final question = manager.pickNextQuestion(totalTimeRemaining: 0);

      expect(question, isNull);
      expect(gameOverCalled, isTrue);
    });

    test('should continue when lives and time are positive', () {
      final question = manager.pickNextQuestion(
        remainingLives: 2,
        totalTimeRemaining: 60,
      );

      expect(question, isNotNull);
    });
  });

  group('QuizGameFlowManager wouldBeGameOver', () {
    test('should predict game over when no items', () {
      manager.initialize(
        items: [],
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      expect(manager.wouldBeGameOver(), isTrue);
    });

    test('should predict game over when out of lives', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      expect(manager.wouldBeGameOver(remainingLives: 0), isTrue);
    });

    test('should predict game over when time expired', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );

      expect(manager.wouldBeGameOver(totalTimeRemaining: 0), isTrue);
    });

    test('should not predict game over in endless mode with no items', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const EndlessMode(showAnswerFeedback: true),
      );

      // Exhaust items
      for (var i = 0; i < 5; i++) {
        manager.pickNextQuestion();
      }

      // Should not be game over - endless mode replenishes
      expect(manager.wouldBeGameOver(), isFalse);
    });

    test('should predict game over in endless mode when out of lives', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const EndlessMode(showAnswerFeedback: true),
      );

      expect(manager.wouldBeGameOver(remainingLives: 0), isTrue);
    });
  });

  group('QuizGameFlowManager endless mode', () {
    test('should replenish questions in endless mode', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const EndlessMode(showAnswerFeedback: true),
      );

      // Pick all 5 questions
      for (var i = 0; i < 5; i++) {
        final q = manager.pickNextQuestion();
        expect(q, isNotNull);
      }

      // Should still be able to pick more (replenished)
      final question = manager.pickNextQuestion();
      expect(question, isNotNull);
    });
  });

  group('QuizGameFlowManager reset', () {
    test('should reset all state', () {
      manager.initialize(
        items: createTestItems(),
        modeConfig: const StandardMode(showAnswerFeedback: true),
      );
      manager.pickNextQuestion();

      manager.reset();

      expect(manager.isInitialized, isFalse);
      expect(manager.currentQuestion, isNull);
      expect(manager.totalCount, equals(0));
      expect(manager.hasMoreQuestions, isFalse);
    });
  });
}
