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
}
