import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  test('QuizWidgetEntry initializes correctly', () {
    final quizEntry = QuizWidgetEntry(
      title: "Science Quiz",
      gameOverText: "Well Done!",
      dataProvider: () async => [],
    );

    expect(quizEntry.title, "Science Quiz");
    expect(quizEntry.gameOverText, "Well Done!");
    expect(quizEntry.dataProvider, isNotNull);
  });
}