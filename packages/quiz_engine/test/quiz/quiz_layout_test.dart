import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine/src/quiz/quiz_answers_widget.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../test_helpers.dart';

void main() {
  final defaultSizingInfo = SizingInformation(
    deviceScreenType: DeviceScreenType.mobile,
    screenSize: const Size(400, 800),
    localWidgetSize: const Size(400, 600),
    refinedSize: RefinedSize.normal,
  );

  QuestionEntry createImageEntry(String id, String name, String imagePath) {
    return QuestionEntry(
      type: ImageQuestion(imagePath),
      otherOptions: {'id': id, 'name': name, 'imagePath': imagePath},
    );
  }

  Question createQuestion({
    required QuestionEntry answer,
    required List<QuestionEntry> options,
  }) {
    return Question(answer, options);
  }

  group('QuizLayout', () {
    testWidgets('renders with default layout (ImageQuestionTextAnswers)',
        (tester) async {
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final options = [
        answer,
        createImageEntry('germany', 'Germany', 'assets/flags/de.png'),
        createImageEntry('italy', 'Italy', 'assets/flags/it.png'),
        createImageEntry('spain', 'Spain', 'assets/flags/es.png'),
      ];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(question, 1, 10);

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (_) {},
          ),
        ),
      );

      // Should show QuizImageWidget for question
      expect(find.byType(QuizImageWidget), findsOneWidget);

      // Should show QuizAnswersWidget (text answers) by default
      expect(find.byType(QuizAnswersWidget), findsOneWidget);
    });

    testWidgets('renders with TextQuestionImageAnswers layout', (tester) async {
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final options = [
        answer,
        createImageEntry('germany', 'Germany', 'assets/flags/de.png'),
        createImageEntry('italy', 'Italy', 'assets/flags/it.png'),
        createImageEntry('spain', 'Spain', 'assets/flags/es.png'),
      ];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(
        question,
        1,
        10,
        resolvedLayout: TextQuestionImageAnswersLayout(
          questionTemplate: 'Select the flag of {name}',
        ),
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (_) {},
            layoutConfig: TextQuestionImageAnswersLayout(
              questionTemplate: 'Select the flag of {name}',
            ),
          ),
        ),
      );

      // Should show QuizTextWidget for question
      expect(find.byType(QuizTextWidget), findsOneWidget);

      // Should show QuizImageAnswersWidget for answers
      expect(find.byType(QuizImageAnswersWidget), findsOneWidget);
    });

    testWidgets('performs template substitution for text questions',
        (tester) async {
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final options = [
        answer,
        createImageEntry('germany', 'Germany', 'assets/flags/de.png'),
      ];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(question, 1, 10);

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (_) {},
            layoutConfig: TextQuestionImageAnswersLayout(
              questionTemplate: 'Select the flag of {name}',
            ),
          ),
        ),
      );

      // Should substitute {name} with the correct answer's name
      expect(find.text('Select the flag of France'), findsOneWidget);
    });

    testWidgets('uses default layout when layoutConfig is null',
        (tester) async {
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final options = [
        answer,
        createImageEntry('germany', 'Germany', 'assets/flags/de.png'),
      ];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(question, 1, 10);

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (_) {},
            layoutConfig: null, // No layout config
          ),
        ),
      );

      // Should use default ImageQuestionTextAnswersLayout
      expect(find.byType(QuizImageWidget), findsOneWidget);
      expect(find.byType(QuizAnswersWidget), findsOneWidget);
    });

    testWidgets('displays progress correctly', (tester) async {
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final options = [answer];
      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(question, 5, 20);

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (_) {},
          ),
        ),
      );

      expect(find.text('5 / 20'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('calls processAnswer when answer is selected', (tester) async {
      QuestionEntry? selectedAnswer;
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final options = [
        answer,
        createImageEntry('germany', 'Germany', 'assets/flags/de.png'),
      ];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(question, 1, 10);

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (entry) {
              selectedAnswer = entry;
            },
          ),
        ),
      );

      // Tap on an answer option
      await tester.tap(find.text('France'));
      await tester.pumpAndSettle();

      expect(selectedAnswer, equals(answer));
    });

    testWidgets('respects disabled options', (tester) async {
      QuestionEntry? selectedAnswer;
      final answer =
          createImageEntry('france', 'France', 'assets/flags/fr.png');
      final disabledOption =
          createImageEntry('germany', 'Germany', 'assets/flags/de.png');
      final options = [answer, disabledOption];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(
        question,
        1,
        10,
        disabledOptions: {disabledOption},
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (entry) {
              selectedAnswer = entry;
            },
          ),
        ),
      );

      // Try to tap on disabled option
      await tester.tap(find.text('Germany'));
      await tester.pumpAndSettle();

      // Should not trigger callback for disabled options
      expect(selectedAnswer, isNull);
    });
  });

  group('QuizLayout with TextQuestionTextAnswersLayout', () {
    testWidgets('renders text question with text answers', (tester) async {
      final answer = QuestionEntry(
        type: TextQuestion('What is the capital of France?'),
        otherOptions: {'id': 'paris', 'name': 'Paris'},
      );
      final options = [
        answer,
        QuestionEntry(
          type: TextQuestion('Berlin'),
          otherOptions: {'id': 'berlin', 'name': 'Berlin'},
        ),
      ];

      final question = createQuestion(answer: answer, options: options);
      final state = QuestionState(question, 1, 10);

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizLayout(
            questionState: state,
            information: defaultSizingInfo,
            processAnswer: (_) {},
            layoutConfig: const TextQuestionTextAnswersLayout(),
          ),
        ),
      );

      // Should show QuizTextWidget for question
      expect(find.byType(QuizTextWidget), findsOneWidget);

      // Should show QuizAnswersWidget (text answers)
      expect(find.byType(QuizAnswersWidget), findsOneWidget);
    });
  });
}
