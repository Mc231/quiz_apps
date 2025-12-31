import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Unit tests for resource button analytics events.
///
/// These tests verify that the analytics event classes are correctly structured
/// and can be created with the expected parameters. The integration with
/// QuizScreen callbacks is verified through code review and the implementation
/// in quiz_screen.dart which calls these events in button callbacks.
void main() {
  group('ResourceEvent.buttonTapped', () {
    test('creates event with correct parameters for fifty_fifty resource', () {
      final event = ResourceEvent.buttonTapped(
        quizId: 'test_quiz',
        resourceType: 'fifty_fifty',
        currentAmount: 2,
        isAvailable: true,
        context: 'quiz_screen',
      );

      expect(event.eventName, 'resource_button_tapped');
      expect(event.quizId, 'test_quiz');
      expect(event.parameters['resource_type'], 'fifty_fifty');
      expect(event.parameters['current_amount'], 2);
      expect(event.parameters['is_available'], 1); // true = 1
      expect(event.parameters['context'], 'quiz_screen');
    });

    test('creates event with correct parameters for skip resource', () {
      final event = ResourceEvent.buttonTapped(
        quizId: 'test_quiz',
        resourceType: 'skip',
        currentAmount: 1,
        isAvailable: true,
        context: 'quiz_screen',
      );

      expect(event.eventName, 'resource_button_tapped');
      expect(event.parameters['resource_type'], 'skip');
      expect(event.parameters['current_amount'], 1);
      expect(event.parameters['is_available'], 1);
    });

    test('creates event with correct parameters for lives resource', () {
      final event = ResourceEvent.buttonTapped(
        quizId: 'test_quiz',
        resourceType: 'lives',
        currentAmount: 3,
        isAvailable: true,
        context: 'quiz_screen',
      );

      expect(event.eventName, 'resource_button_tapped');
      expect(event.parameters['resource_type'], 'lives');
      expect(event.parameters['current_amount'], 3);
    });

    test('creates event with isAvailable=false for depleted resource', () {
      final event = ResourceEvent.buttonTapped(
        quizId: 'test_quiz',
        resourceType: 'fifty_fifty',
        currentAmount: 0,
        isAvailable: false,
        context: 'quiz_screen',
      );

      expect(event.parameters['current_amount'], 0);
      expect(event.parameters['is_available'], 0); // false = 0
    });
  });

  group('HintEvent.unavailableTapped', () {
    test('creates event with correct parameters for fifty_fifty hint', () {
      final event = HintEvent.unavailableTapped(
        quizId: 'test_quiz',
        questionId: 'q1',
        questionIndex: 0,
        hintType: 'fifty_fifty',
      );

      expect(event.eventName, 'hint_unavailable_tapped');
      expect(event.quizId, 'test_quiz');
      expect(event.parameters['question_id'], 'q1');
      expect(event.parameters['question_index'], 0);
      expect(event.parameters['hint_type'], 'fifty_fifty');
    });

    test('creates event with correct parameters for skip hint', () {
      final event = HintEvent.unavailableTapped(
        quizId: 'test_quiz',
        questionId: 'q5',
        questionIndex: 4,
        hintType: 'skip',
      );

      expect(event.eventName, 'hint_unavailable_tapped');
      expect(event.parameters['hint_type'], 'skip');
      expect(event.parameters['question_index'], 4);
    });

    test('includes optional totalHintsUsed when provided', () {
      final event = HintEvent.unavailableTapped(
        quizId: 'test_quiz',
        questionId: 'q1',
        questionIndex: 0,
        hintType: 'fifty_fifty',
        totalHintsUsed: 5,
      );

      expect(event.parameters['total_hints_used'], 5);
    });

    test('omits totalHintsUsed when not provided', () {
      final event = HintEvent.unavailableTapped(
        quizId: 'test_quiz',
        questionId: 'q1',
        questionIndex: 0,
        hintType: 'fifty_fifty',
      );

      expect(event.parameters.containsKey('total_hints_used'), false);
    });
  });

  group('Analytics event integration verification', () {
    test('ResourceEvent is sealed class with buttonTapped factory', () {
      // Verify the factory method exists and returns correct type
      final event = ResourceEvent.buttonTapped(
        quizId: 'test',
        resourceType: 'test',
        currentAmount: 0,
        isAvailable: false,
        context: 'test',
      );
      expect(event, isA<ResourceEvent>());
      expect(event, isA<ResourceButtonTappedEvent>());
    });

    test('HintEvent is sealed class with unavailableTapped factory', () {
      // Verify the factory method exists and returns correct type
      final event = HintEvent.unavailableTapped(
        quizId: 'test',
        questionId: 'test',
        questionIndex: 0,
        hintType: 'test',
      );
      expect(event, isA<HintEvent>());
      expect(event, isA<HintUnavailableTappedEvent>());
    });
  });
}