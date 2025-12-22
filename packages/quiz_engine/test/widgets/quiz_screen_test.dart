import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine/src/quiz/quiz_screen.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../test_helpers.dart';

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
      configManager: configManager,
    );
  });

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
      MaterialApp(
        home: BlocProvider(
          bloc: bloc,
          child: QuizScreen(
            title: "Test",
            gameOverTitle: "Game Over",
            texts: testQuizTexts,
          ),
        ),
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

  testWidgets('Quiz over dialog', (WidgetTester tester) async {
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
    );
    bloc2.currentQuestion = Question(countries.first, countries);
    // When
    when(randomItemPicker.pick()).thenReturn(null);
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider(
          bloc: bloc2,
          child: QuizScreen(
            title: "Test",
            gameOverTitle: "Game Over",
            texts: testQuizTexts,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    // Then
    // Wait for game over dialog
    final alertDialogFinder = find.byType(AlertDialog);
    expect(alertDialogFinder, findsOneWidget);
    // Tap alert button
    final alertButtonFinder = find.byType(TextButton);
    expect(alertButtonFinder, findsOneWidget);
    await tester.tap(alertButtonFinder);
    await tester.pump();
    // Check that alert disappear
    final alertDisappearFinder = find.byType(AlertDialog);
    expect(alertDisappearFinder, findsNothing);
  });
}
