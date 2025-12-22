import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/quiz/quiz_answers_widget.dart';
import 'package:quiz_engine/src/quiz/quiz_image_widget.dart';
import 'package:quiz_engine/src/quiz/quiz_layout.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:mockito/mockito.dart';

class MockQuizBloc extends Mock implements QuizBloc {}

void main() {
  group('GameLayout', () {
    QuestionEntry mockCountry = QuestionEntry(
      type: ImageQuestion("assets/images/AD.png"),
      otherOptions: {"id": "123", "name": "Andorra"},
    );
    QuestionState mockQuestionState = QuestionState(
      Question(mockCountry, [mockCountry]),
      1,
      1,
    );

    testWidgets('displays correctly in landscape orientation', (
      WidgetTester tester,
    ) async {
      final sizingInformation = SizingInformation(
        deviceScreenType: DeviceScreenType.mobile,
        refinedSize: RefinedSize.normal,
        screenSize: Size(800, 600),
        localWidgetSize: Size(800, 600),
      );

      final mockBloc = MockQuizBloc();

      await tester.pumpWidget(
        MaterialApp(
          home: QuizLayout(
            questionState: mockQuestionState,
            information: sizingInformation,
            processAnswer: (_) {},
            quizBloc: mockBloc,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(QuizImageWidget), findsOneWidget);
      expect(find.byType(QuizAnswersWidget), findsOneWidget);
    });
  });
}
