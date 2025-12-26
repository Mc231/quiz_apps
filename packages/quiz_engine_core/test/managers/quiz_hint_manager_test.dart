import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/business_logic/managers/quiz_hint_manager.dart';
import 'package:quiz_engine_core/src/model/config/hint_config.dart';
import 'package:quiz_engine_core/src/model/question.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';

/// A predictable random for testing.
class FakeRandom implements Random {
  @override
  bool nextBool() => true;

  @override
  double nextDouble() => 0.5;

  @override
  int nextInt(int max) => 0;
}

void main() {
  late QuizHintManager manager;

  // Test data
  final testEntry1 = QuestionEntry(type: TextQuestion('Answer 1'));
  final testEntry2 = QuestionEntry(type: TextQuestion('Answer 2'));
  final testEntry3 = QuestionEntry(type: TextQuestion('Answer 3'));
  final testEntry4 = QuestionEntry(type: TextQuestion('Answer 4'));

  Question createQuestion(QuestionEntry correctAnswer) {
    return Question(
      correctAnswer,
      [testEntry1, testEntry2, testEntry3, testEntry4],
    );
  }

  setUp(() {
    manager = QuizHintManager();
  });

  group('QuizHintManager initialization', () {
    test('should start uninitialized', () {
      expect(manager.isInitialized, isFalse);
      expect(manager.hintState, isNull);
      expect(manager.disabledOptions, isEmpty);
      expect(manager.hintsUsed5050, equals(0));
      expect(manager.hintsUsedSkip, equals(0));
    });

    test('should initialize from config', () {
      const config = HintConfig(
        initialHints: {
          HintType.fiftyFifty: 3,
          HintType.skip: 2,
        },
      );

      manager.initialize(config);

      expect(manager.isInitialized, isTrue);
      expect(manager.hintState, isNotNull);
      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(3));
      expect(manager.getRemainingCount(HintType.skip), equals(2));
    });

    test('should initialize with no hints config', () {
      const config = HintConfig.noHints();

      manager.initialize(config);

      expect(manager.isInitialized, isTrue);
      expect(manager.canUseHint(HintType.fiftyFifty), isFalse);
      expect(manager.canUseHint(HintType.skip), isFalse);
    });
  });

  group('QuizHintManager hint availability', () {
    setUp(() {
      manager.initialize(const HintConfig(
        initialHints: {
          HintType.fiftyFifty: 2,
          HintType.skip: 1,
        },
      ));
    });

    test('should report hint availability correctly', () {
      expect(manager.canUseHint(HintType.fiftyFifty), isTrue);
      expect(manager.canUseHint(HintType.skip), isTrue);
      expect(manager.canUseHint(HintType.revealLetter), isFalse);
    });

    test('should return false when not initialized', () {
      final uninitializedManager = QuizHintManager();
      expect(uninitializedManager.canUseHint(HintType.fiftyFifty), isFalse);
    });

    test('should return 0 remaining when not initialized', () {
      final uninitializedManager = QuizHintManager();
      expect(uninitializedManager.getRemainingCount(HintType.fiftyFifty), equals(0));
    });
  });

  group('QuizHintManager 50/50 hint', () {
    setUp(() {
      // Use FakeRandom for predictable test results
      manager = QuizHintManager(random: FakeRandom());
      manager.initialize(const HintConfig(
        initialHints: {
          HintType.fiftyFifty: 2,
        },
      ));
    });

    test('should disable 2 wrong options', () {
      final question = createQuestion(testEntry1);

      final disabled = manager.use5050Hint(question);

      expect(disabled.length, equals(2));
      expect(disabled.contains(testEntry1), isFalse); // Correct answer not disabled
      expect(manager.disabledOptions, equals(disabled));
    });

    test('should decrement hint count', () {
      final question = createQuestion(testEntry1);

      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(2));

      manager.use5050Hint(question);
      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(1));

      manager.use5050Hint(question);
      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(0));
    });

    test('should track usage count', () {
      final question = createQuestion(testEntry1);

      expect(manager.hintsUsed5050, equals(0));

      manager.use5050Hint(question);
      expect(manager.hintsUsed5050, equals(1));

      manager.use5050Hint(question);
      expect(manager.hintsUsed5050, equals(2));
    });

    test('should return empty set when hint not available', () {
      manager.initialize(const HintConfig(
        initialHints: {HintType.fiftyFifty: 0},
      ));
      final question = createQuestion(testEntry1);

      final disabled = manager.use5050Hint(question);

      expect(disabled, isEmpty);
      expect(manager.hintsUsed5050, equals(0));
    });

    test('should return empty set when less than 2 wrong options', () {
      // Question with only 1 wrong option
      final question = Question(testEntry1, [testEntry1, testEntry2]);

      final disabled = manager.use5050Hint(question);

      expect(disabled, isEmpty);
      // Hint should not be consumed
      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(2));
    });

    test('should notify state change', () {
      HintState? notifiedState;
      Set<QuestionEntry>? notifiedDisabled;

      manager = QuizHintManager(
        random: FakeRandom(),
        onHintStateChanged: ({required hintState, required disabledOptions}) {
          notifiedState = hintState;
          notifiedDisabled = disabledOptions;
        },
      );
      manager.initialize(const HintConfig(
        initialHints: {HintType.fiftyFifty: 1},
      ));

      final question = createQuestion(testEntry1);
      manager.use5050Hint(question);

      expect(notifiedState, isNotNull);
      expect(notifiedDisabled, isNotNull);
      expect(notifiedDisabled!.length, equals(2));
    });
  });

  group('QuizHintManager skip hint', () {
    setUp(() {
      manager.initialize(const HintConfig(
        initialHints: {HintType.skip: 2},
      ));
    });

    test('should use skip hint', () {
      expect(manager.useSkipHint(), isTrue);
      expect(manager.getRemainingCount(HintType.skip), equals(1));
    });

    test('should track skip usage count', () {
      expect(manager.hintsUsedSkip, equals(0));

      manager.useSkipHint();
      expect(manager.hintsUsedSkip, equals(1));

      manager.useSkipHint();
      expect(manager.hintsUsedSkip, equals(2));
    });

    test('should return false when hint not available', () {
      manager.useSkipHint();
      manager.useSkipHint();

      expect(manager.useSkipHint(), isFalse);
      expect(manager.hintsUsedSkip, equals(2)); // Not incremented
    });

    test('should notify state change', () {
      var notified = false;

      manager = QuizHintManager(
        onHintStateChanged: ({required hintState, required disabledOptions}) {
          notified = true;
        },
      );
      manager.initialize(const HintConfig(
        initialHints: {HintType.skip: 1},
      ));

      manager.useSkipHint();

      expect(notified, isTrue);
    });
  });

  group('QuizHintManager question transitions', () {
    setUp(() {
      manager = QuizHintManager(random: FakeRandom());
      manager.initialize(const HintConfig(
        initialHints: {HintType.fiftyFifty: 3},
      ));
    });

    test('should reset disabled options for new question', () {
      final question = createQuestion(testEntry1);
      manager.use5050Hint(question);

      expect(manager.disabledOptions, isNotEmpty);

      manager.resetForNewQuestion();

      expect(manager.disabledOptions, isEmpty);
    });

    test('should preserve hint counts after reset for new question', () {
      final question = createQuestion(testEntry1);
      manager.use5050Hint(question);

      manager.resetForNewQuestion();

      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(2));
      expect(manager.hintsUsed5050, equals(1));
    });
  });

  group('QuizHintManager hint rewards', () {
    setUp(() {
      manager.initialize(const HintConfig(
        initialHints: {HintType.fiftyFifty: 1},
      ));
    });

    test('should add hints', () {
      manager.addHint(HintType.fiftyFifty, 2);

      expect(manager.getRemainingCount(HintType.fiftyFifty), equals(3));
    });

    test('should add hints for new type', () {
      manager.addHint(HintType.skip, 3);

      expect(manager.getRemainingCount(HintType.skip), equals(3));
    });

    test('should notify when hints added', () {
      var notified = false;

      manager = QuizHintManager(
        onHintStateChanged: ({required hintState, required disabledOptions}) {
          notified = true;
        },
      );
      manager.initialize(const HintConfig(
        initialHints: {HintType.fiftyFifty: 1},
      ));

      manager.addHint(HintType.fiftyFifty, 1);

      expect(notified, isTrue);
    });
  });

  group('QuizHintManager reset', () {
    test('should reset all state', () {
      manager = QuizHintManager(random: FakeRandom());
      manager.initialize(const HintConfig(
        initialHints: {
          HintType.fiftyFifty: 3,
          HintType.skip: 2,
        },
      ));

      final question = createQuestion(testEntry1);
      manager.use5050Hint(question);
      manager.useSkipHint();

      manager.reset();

      expect(manager.isInitialized, isFalse);
      expect(manager.hintState, isNull);
      expect(manager.disabledOptions, isEmpty);
      expect(manager.hintsUsed5050, equals(0));
      expect(manager.hintsUsedSkip, equals(0));
    });
  });
}
