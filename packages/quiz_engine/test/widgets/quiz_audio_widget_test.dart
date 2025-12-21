import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/quiz/quiz_audio_widget.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizAudioWidget Tests', () {
    testWidgets('should display audio player controls', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: AudioQuestion('assets/audio/test.mp3'),
        otherOptions: {'id': 'audio1'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizAudioWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 400,
              height: 400,
            ),
          ),
        ),
      );
      await tester.pump();

      // Then
      expect(find.byType(QuizAudioWidget), findsOneWidget);
      expect(find.byIcon(Icons.headphones), findsOneWidget);
    });

    testWidgets('should display with correct dimensions', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: AudioQuestion('assets/audio/test.mp3'),
        otherOptions: {'id': 'audio2'},
      );
      const width = 400.0;
      const height = 400.0;

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizAudioWidget(
              key: Key('test_widget'),
              entry: entry,
              width: width,
              height: height,
            ),
          ),
        ),
      );
      await tester.pump();

      // Then
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect(container.constraints?.maxWidth, width);
      expect(container.constraints?.maxHeight, height);
    });

    testWidgets('should have play button initially', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: AudioQuestion('assets/audio/test.mp3'),
        otherOptions: {'id': 'audio3'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizAudioWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 400,
              height: 400,
            ),
          ),
        ),
      );
      await tester.pump();

      // Then
      expect(find.byKey(Key('audio_button_audio3')), findsOneWidget);
      final icon = tester.widget<Icon>(find.byKey(Key('audio_button_audio3')));
      expect(icon.icon, Icons.play_arrow);
    });

    testWidgets('should have circular progress indicator', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: AudioQuestion('assets/audio/test.mp3'),
        otherOptions: {'id': 'audio4'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizAudioWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 400,
              height: 400,
            ),
          ),
        ),
      );
      await tester.pump();

      // Then
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display time format', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: AudioQuestion('assets/audio/test.mp3'),
        otherOptions: {'id': 'audio5'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizAudioWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 400,
              height: 400,
            ),
          ),
        ),
      );
      await tester.pump();

      // Then - should find time display format
      expect(find.textContaining(':'), findsAtLeastNWidgets(1));
      expect(find.textContaining(' / '), findsOneWidget);
    });

    testWidgets('should have rounded corners', (WidgetTester tester) async {
      // Given
      final entry = QuestionEntry(
        type: AudioQuestion('assets/audio/test.mp3'),
        otherOptions: {'id': 'audio6'},
      );

      // When
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuizAudioWidget(
              key: Key('test_widget'),
              entry: entry,
              width: 400,
              height: 400,
            ),
          ),
        ),
      );
      await tester.pump();

      // Then
      final container = tester.widget<Container>(
        find.byType(Container).first,
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
      expect(decoration.border, isNotNull);
    });
  });
}
