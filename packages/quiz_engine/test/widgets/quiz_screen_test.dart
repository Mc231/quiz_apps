import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine/src/quiz/quiz_screen.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

@GenerateNiceMocks([MockSpec<RandomItemPicker>()])
import 'quiz_screen_test.mocks.dart';

void main() {
  late RandomItemPicker randomItemPicker;
  late QuizBloc bloc;

  Future<List<QuestionEntry>> loadCountriesForContinent() async {
    return [
      QuestionEntry(
        type: ImageQuestion("assets/images/test1.png"),
        otherOptions: {"id": "123", "name": "Country 1"},
      ),
      QuestionEntry(
        type: ImageQuestion("assets/images/test2.png"),
        otherOptions: {"id": "1223", "name": "Country 2"},
      ),
    ];
  }

  setUp(() {
    randomItemPicker = MockRandomItemPicker();
    const configManager = ConfigManager(
      defaultConfig: QuizConfig(quizId: 'test_quiz'),
    );
    bloc = QuizBloc(
      () => loadCountriesForContinent(),
      randomItemPicker,
      analyticsService: NoOpQuizAnalyticsService(),
      configManager: configManager,
    );
  });

  /// Helper to wrap widgets with localization support for tests.
  Widget wrapWithLocalizationsForBloc(Widget child, QuizBloc bloc) {
    return MaterialApp(
      localizationsDelegates: const [
        QuizLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: BlocProvider(bloc: bloc, child: child),
    );
  }

  testWidgets('Question showing', (WidgetTester tester) async {
    // Given
    final country1 = QuestionEntry(
      type: ImageQuestion("assets/images/AD.png"),
      otherOptions: {"id": "12223", "name": "Andorra"},
    );
    final country2 = QuestionEntry(
      type: ImageQuestion("assets/images/BD.png"),
      otherOptions: {"id": "12224", "name": "Bangladesh"},
    );
    final countries = [country1, country2];
    final randomPickResult = RandomPickResult(countries.first, countries);
    // When
    when(randomItemPicker.pick()).thenReturn(randomPickResult);
    await tester.pumpWidget(
      wrapWithLocalizationsForBloc(
        QuizScreen(
          title: "Test",
          screenAnalyticsService: NoOpAnalyticsService(),
        ),
        bloc,
      ),
    );
    await tester.pump();
    await tester.pump();
    // Then
    final optionButtonFinder = find.byType(OptionButton);
    final imageFinder = find.byType(Image);
    expect(optionButtonFinder, findsNWidgets(countries.length));
    expect(imageFinder, findsOneWidget);
  });

  testWidgets('Quiz over shows results screen', (WidgetTester tester) async {
    // Given
    final countries = [
      QuestionEntry(
        type: ImageQuestion("assets/images/AD.png"),
        otherOptions: {"id": "123", "name": "Andorra"},
      ),
      QuestionEntry(
        type: ImageQuestion("assets/images/BD.png"),
        otherOptions: {"id": "1223", "name": "Bangladesh"},
      ),
    ];
    const configManager = ConfigManager(
      defaultConfig: QuizConfig(quizId: 'test_quiz_2'),
    );
    final bloc2 = QuizBloc(
      () => Future.value(countries),
      randomItemPicker,
      configManager: configManager,
      quizName: 'Test Quiz',
      analyticsService: NoOpQuizAnalyticsService(),
    );
    bloc2.currentQuestion = Question(countries.first, countries);
    // When
    when(randomItemPicker.pick()).thenReturn(null);
    await tester.pumpWidget(
      wrapWithLocalizationsForBloc(
        QuizScreen(
          title: "Test",
          screenAnalyticsService: NoOpAnalyticsService(),
        ),
        bloc2,
      ),
    );
    await tester.pump();
    await tester.pump();
    // Then
    // Wait for results screen to appear
    final quizResultsScreenFinder = find.byType(QuizResultsScreen);
    expect(quizResultsScreenFinder, findsOneWidget);
    // Find the Done button (ElevatedButton)
    final doneButtonFinder = find.byType(ElevatedButton);
    expect(doneButtonFinder, findsOneWidget);
  });
}
