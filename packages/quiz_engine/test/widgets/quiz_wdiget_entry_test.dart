import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  test('QuizWidgetEntry initializes correctly', () {
    const texts = QuizTexts(
      title: "Science Quiz",
      gameOverText: "Well Done!",
    );
    const defaultConfig = QuizConfig(quizId: 'science_quiz');

    final quizEntry = QuizWidgetEntry(
      texts: texts,
      dataProvider: () async => [],
      defaultConfig: defaultConfig,
    );

    expect(quizEntry.texts.title, "Science Quiz");
    expect(quizEntry.texts.gameOverText, "Well Done!");
    expect(quizEntry.dataProvider, isNotNull);
    expect(quizEntry.configManager.defaultConfig.quizId, 'science_quiz');
  });
}