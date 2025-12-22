import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

@GenerateNiceMocks([MockSpec<RandomItemPicker>()])
import 'quiz_bloc_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuizBloc bloc;
  late RandomItemPicker randomItemPicker;
  late Future<List<QuestionEntry>> Function() mockDataProvider;

  // Mock QuestionEntry objects with the correct QuestionType
  List<QuestionEntry> mockItems = [
    QuestionEntry(
      type: TextQuestion("What is the capital of France?"),
      otherOptions: {"difficulty": "easy"},
    ),
    QuestionEntry(
      type: TextQuestion("Solve: 2 + 2"),
      otherOptions: {"difficulty": "medium"},
    ),
    QuestionEntry(
      type: ImageQuestion("assets/images/flag.png"),
      otherOptions: {"hint": "Find the flag!"},
    ),
    QuestionEntry(
      type: TextQuestion("Who wrote Hamlet?"),
      otherOptions: {"difficulty": "hard"},
    ),
    QuestionEntry(
      type: ImageQuestion("assets/images/dog.png"),
      otherOptions: {"hint": "What animal is this?"},
    ),
  ];

  setUp(() {
    randomItemPicker = MockRandomItemPicker();

    // Mock data provider function
    mockDataProvider = () async => mockItems;

    const configManager = ConfigManager(
      defaultConfig: QuizConfig(
        quizId: 'test_quiz',
        uiBehaviorConfig: UIBehaviorConfig.noFeedback(),
      ),
    );
    bloc = QuizBloc(
      mockDataProvider,
      randomItemPicker,
      filter: (entry) => true,
      configManager: configManager,
    );
  });

  tearDown(() {
    bloc.dispose();
  });

  test(
    'performInitialLoad() loads and filters data, updates picker, and picks a question',
    () async {
      // Given: Mock item picker returns a valid question
      when(
        randomItemPicker.pick(),
      ).thenReturn(RandomPickResult(mockItems.first, mockItems));

      // When
      await bloc.performInitialLoad();

      // Then
      expect(bloc.currentQuestion, isNotNull);
    },
  );

  test('init standard', () {
    const configManager = ConfigManager(
      defaultConfig: QuizConfig(quizId: 'test_init'),
    );
    final result = QuizBloc(
      mockDataProvider,
      randomItemPicker,
      filter: (entry) => true,
      configManager: configManager,
    );
    expect(result, isNotNull);
  });

  test('initial state is correct', () {
    expect(bloc.initialState, isInstanceOf<LoadingState>());
  });

  test('process answer', () async {
    // Initialize config first
    when(
      randomItemPicker.pick(),
    ).thenReturn(RandomPickResult(mockItems.first, mockItems));
    await bloc.performInitialLoad();

    final question = QuestionEntry(
      type: TextQuestion("What is the capital of France?"),
      otherOptions: {"difficulty": "easy"},
    );
    bloc.currentQuestion = Question.fromRandomResult(
      RandomPickResult(question, mockItems),
    );

    // Mock the next random pick
    when(
      randomItemPicker.pick(),
    ).thenReturn(RandomPickResult(mockItems[1], mockItems));

    // Start listening BEFORE calling processAnswer (required for broadcast streams)
    final streamFuture = expectLater(
      bloc.stream,
      emitsInOrder([isInstanceOf<QuestionState>()]),
    );

    await bloc.processAnswer(question);

    await streamFuture;
  });

  test('process game over', () async {
    // Initialize config first
    when(
      randomItemPicker.pick(),
    ).thenReturn(RandomPickResult(mockItems.first, mockItems));
    await bloc.performInitialLoad();

    final expectedScore = '1 / ${mockItems.length}';

    bloc.gameOverCallback = (score) {
      expect(score, equals(expectedScore));
    };

    // Ensure a valid question is set before answering
    bloc.currentQuestion = Question.fromRandomResult(
      RandomPickResult(mockItems.first, mockItems),
    );

    // Mock game over condition
    when(randomItemPicker.pick()).thenReturn(null);

    await bloc.processAnswer(mockItems.first);
  });

  group('Endless Mode Tests', () {
    late QuizBloc endlessBloc;
    late RandomItemPicker endlessItemPicker;
    late List<QuestionEntry> endlessItems;

    setUp(() {
      // Create test items
      endlessItems = [
        QuestionEntry(
          type: TextQuestion("Question 1"),
          otherOptions: {"id": "q1"},
        ),
        QuestionEntry(
          type: TextQuestion("Question 2"),
          otherOptions: {"id": "q2"},
        ),
        QuestionEntry(
          type: TextQuestion("Question 3"),
          otherOptions: {"id": "q3"},
        ),
      ];

      // Use real RandomItemPicker for endless mode tests
      endlessItemPicker = RandomItemPicker([], 4);

      const configManager = ConfigManager(
        defaultConfig: QuizConfig(
          quizId: 'endless_test',
          modeConfig: EndlessMode(),
          uiBehaviorConfig: UIBehaviorConfig.noFeedback(),
        ),
      );

      endlessBloc = QuizBloc(
        () async => endlessItems,
        endlessItemPicker,
        configManager: configManager,
      );
    });

    tearDown(() {
      endlessBloc.dispose();
    });

    test('should replenish questions when exhausted in endless mode', () async {
      // Initialize the quiz
      await endlessBloc.performInitialLoad();

      // Track initial items count
      final _ = endlessItemPicker.items.length;

      // Answer all questions correctly to exhaust the pool
      while (endlessItemPicker.items.isNotEmpty) {
        final currentAnswer = endlessBloc.currentQuestion.answer;
        await endlessBloc.processAnswer(currentAnswer);
      }

      // Items should be empty now
      expect(endlessItemPicker.items.isEmpty, true);

      // Answer one more question - this should trigger replenishment
      final currentAnswer = endlessBloc.currentQuestion.answer;
      await endlessBloc.processAnswer(currentAnswer);

      // After replenishment, we should have questions again
      // (The items list might be smaller because we just picked one)
      expect(endlessBloc.currentQuestion, isNotNull);
    });

    test('should end game on first wrong answer in endless mode', () async {
      // Initialize the quiz
      await endlessBloc.performInitialLoad();

      bool gameOverCalled = false;
      endlessBloc.gameOverCallback = (result) {
        gameOverCalled = true;
      };

      // Get the correct answer
      final correctAnswer = endlessBloc.currentQuestion.answer;

      // Find a wrong answer (any option that isn't the correct answer)
      final wrongAnswer = endlessBloc.currentQuestion.options.firstWhere(
        (option) => option != correctAnswer,
      );

      // Answer with wrong answer
      await endlessBloc.processAnswer(wrongAnswer);

      // Game should be over
      expect(gameOverCalled, true);
    });

    test(
      'should continue infinitely with correct answers in endless mode',
      () async {
        // Initialize the quiz
        await endlessBloc.performInitialLoad();

        bool gameOverCalled = false;
        endlessBloc.gameOverCallback = (result) {
          gameOverCalled = true;
        };

        // Answer correctly many times (more than the initial question count)
        final timesToAnswer = endlessItems.length * 3;
        for (int i = 0; i < timesToAnswer; i++) {
          final correctAnswer = endlessBloc.currentQuestion.answer;
          await endlessBloc.processAnswer(correctAnswer);

          // Game should never be over when answering correctly
          expect(gameOverCalled, false);
        }

        // Should still have a valid question after many rounds
        expect(endlessBloc.currentQuestion, isNotNull);
      },
    );
  });
}
