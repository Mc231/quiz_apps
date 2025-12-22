import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../test_helpers.dart';

void main() {
  test('QuizWidgetEntry initializes correctly', () {
    const defaultConfig = QuizConfig(quizId: 'science_quiz');

    final quizEntry = QuizWidgetEntry(
      texts: testQuizTexts,
      dataProvider: () async => [],
      defaultConfig: defaultConfig,
    );

    expect(quizEntry.texts.title, "Test Quiz");
    expect(quizEntry.texts.gameOverText, "Game Over");
    expect(quizEntry.dataProvider, isNotNull);
    expect(quizEntry.configManager.defaultConfig.quizId, 'science_quiz');
  });
}
