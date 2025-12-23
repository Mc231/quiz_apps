import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/quiz/quiz_video_widget.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

import '../test_helpers.dart';

void main() {
  group('QuizVideoWidget Tests', () {
    testWidgets('should display video widget', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('https://example.com/video.mp4'),
        otherOptions: {'id': 'video1'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(QuizVideoWidget), findsOneWidget);
    });

    testWidgets('should display with correct dimensions', (
      WidgetTester tester,
    ) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('https://example.com/video.mp4'),
        otherOptions: {'id': 'video2'},
      );
      const width = 400.0;
      const height = 400.0;

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
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

    testWidgets('should have loading indicator initially', (
      WidgetTester tester,
    ) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('https://example.com/video.mp4'),
        otherOptions: {'id': 'video3'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display thumbnail if provided during loading', (
      WidgetTester tester,
    ) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion(
          'https://example.com/video.mp4',
          thumbnailPath: 'assets/images/thumbnail.jpg',
        ),
        otherOptions: {'id': 'video4'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Thumbnail loading will show Image widget (might fail to load in test)
    });

    testWidgets('should have rounded corners', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('https://example.com/video.mp4'),
        otherOptions: {'id': 'video5'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
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
      expect(decoration.color, Colors.black);
    });

    testWidgets('should have ClipRRect for rounded corners', (
      WidgetTester tester,
    ) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('https://example.com/video.mp4'),
        otherOptions: {'id': 'video6'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      final clipRRect = tester.widget<ClipRRect>(find.byType(ClipRRect));
      expect(clipRRect.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('should handle network URL', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('https://example.com/video.mp4'),
        otherOptions: {'id': 'video7'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(QuizVideoWidget), findsOneWidget);
    });

    testWidgets('should handle asset path', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: VideoQuestion('assets/videos/test.mp4'),
        otherOptions: {'id': 'video8'},
      );

      // When
      await tester.pumpWidget(
        wrapWithLocalizations(
          Scaffold(
            body: QuizVideoWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 300,
              height: 300,
            ),
          ),
        ),
      );

      // Then
      expect(find.byType(QuizVideoWidget), findsOneWidget);
    });
  });
}
