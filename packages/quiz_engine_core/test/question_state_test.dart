import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  test('init question state', () {
    // Given
    final entry = QuestionEntry(type: QuestionType.text("A"), otherOptions: {});
    final expectedQuestion = Question(entry, [entry]);
    final expectedProgress = 0;
    final expectedTotal = expectedQuestion.options.length;
    // When
    final state = QuestionState(
      expectedQuestion,
      expectedProgress,
      expectedTotal,
    );
    expect(state.question, equals(expectedQuestion));
    expect(state.progress, equals(expectedProgress));
    expect(state.total, equals(expectedTotal));
    expect(
      state.percentageProgress,
      equals((state.progress / state.total).toDouble()),
    );
  });
}
