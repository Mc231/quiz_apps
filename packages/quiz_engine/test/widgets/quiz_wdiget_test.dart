import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine/src/quiz/quiz_screen.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../test_helpers.dart';

void main() {
  testWidgets('QuizWidget initializes correctly and displays QuizScreen', (
    WidgetTester tester,
  ) async {
    // Mock data provider response
    final mockQuestions = [
      QuestionEntry(
        type: TextQuestion("What is the capital of France?"),
        otherOptions: {"id": "123", "image": "assets/images/AD.png"},
      ),
      QuestionEntry(
        type: TextQuestion("What is the currency of Japan?"),
        otherOptions: {"id": "123", "image": "assets/images/AD.png"},
      ),
    ];

    // Create config
    const defaultConfig = QuizConfig(quizId: 'test_quiz');

    // Create QuizWidgetEntry
    final quizEntry = QuizWidgetEntry.withDefaultConfig(
      title: testQuizTitle,
      dataProvider: () => Future.value(mockQuestions),
      defaultConfig: defaultConfig,
    );

    // Pump the widget into the test environment with localization support
    await tester.pumpWidget(
      wrapWithLocalizations(QuizWidget(quizEntry: quizEntry)),
    );

    await tester.pump(); // Allow async actions to complete

    // Check if QuizScreen is displayed
    expect(find.byType(QuizScreen), findsOneWidget);
    expect(find.text("Test Quiz"), findsOneWidget);
  });
}
