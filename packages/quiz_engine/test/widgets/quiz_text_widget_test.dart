import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/quiz/quiz_text_widget.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizTextWidget Tests', () {
    testWidgets('should display text question content', (
      WidgetTester tester,
    ) async {
      // Given
      const testText = 'What is the capital of France?';
      final entry = QuestionEntry(
        type: TextQuestion(testText),
        otherOptions: {'id': 'test1'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizTextWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.text(testText), findsOneWidget);
      expect(find.byKey(Key('text_test1')), findsOneWidget);
    });

    testWidgets('should display with correct dimensions', (
      WidgetTester tester,
    ) async {
      // Given
      final entry = QuestionEntry(
        type: TextQuestion('Test question'),
        otherOptions: {'id': 'test2'},
      );
      const width = 400.0;
      const height = 400.0;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizTextWidget(
              key: Key('test_widget'),
              entry: entry,
              width: width,
              height: height,
            ),
          ),
        ),
      );

      // Then
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, width);
      expect(container.constraints?.maxHeight, height);
    });

    testWidgets('should have rounded corners and border', (
      WidgetTester tester,
    ) async {
      // Given
      final entry = QuestionEntry(
        type: TextQuestion('Test'),
        otherOptions: {'id': 'test3'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizTextWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.border, isNotNull);
    });

    testWidgets('should center text content', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: TextQuestion('Centered question'),
        otherOptions: {'id': 'test4'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizTextWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      final text = tester.widget<Text>(find.byType(Text).first);
      expect(text.textAlign, TextAlign.center);
    });

    testWidgets('should handle long text with scrolling', (
      WidgetTester tester,
    ) async {
      // Given
      final longText = 'This is a very long question ' * 20;
      final entry = QuestionEntry(
        type: TextQuestion(longText),
        otherOptions: {'id': 'test5'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizTextWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(find.text(longText), findsOneWidget);
    });
  });
}
