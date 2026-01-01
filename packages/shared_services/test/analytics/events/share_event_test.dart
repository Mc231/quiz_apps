import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ShareEvent', () {
    group('shareInitiated', () {
      test('creates event with required parameters', () {
        final event = ShareEvent.initiated(
          contentType: 'quiz_result',
          sourceScreen: 'results_screen',
        );

        expect(event.eventName, 'share_initiated');
        expect(event.parameters['content_type'], 'quiz_result');
        expect(event.parameters['source_screen'], 'results_screen');
        expect(event.parameters.containsKey('category_id'), false);
        expect(event.parameters.containsKey('category_name'), false);
      });

      test('creates event with optional parameters', () {
        final event = ShareEvent.initiated(
          contentType: 'quiz_result',
          sourceScreen: 'results_screen',
          categoryId: 'europe',
          categoryName: 'European Flags',
        );

        expect(event.parameters['category_id'], 'europe');
        expect(event.parameters['category_name'], 'European Flags');
      });
    });

    group('shareTypeSelected', () {
      test('creates event with all parameters', () {
        final event = ShareEvent.typeSelected(
          shareType: 'image',
          contentType: 'quiz_result',
          sourceScreen: 'results_screen',
        );

        expect(event.eventName, 'share_type_selected');
        expect(event.parameters['share_type'], 'image');
        expect(event.parameters['content_type'], 'quiz_result');
        expect(event.parameters['source_screen'], 'results_screen');
      });
    });

    group('shareCompleted', () {
      test('creates event with required parameters', () {
        final event = ShareEvent.completed(
          shareType: 'text',
          contentType: 'achievement',
          sourceScreen: 'achievement_notification',
        );

        expect(event.eventName, 'share_completed');
        expect(event.parameters['share_type'], 'text');
        expect(event.parameters['content_type'], 'achievement');
        expect(event.parameters['source_screen'], 'achievement_notification');
        expect(event.parameters.containsKey('shared_to'), false);
      });

      test('creates event with sharedTo parameter', () {
        final event = ShareEvent.completed(
          shareType: 'image',
          contentType: 'quiz_result',
          sourceScreen: 'results_screen',
          sharedTo: 'twitter',
        );

        expect(event.parameters['shared_to'], 'twitter');
      });
    });

    group('shareCancelled', () {
      test('creates event with all parameters', () {
        final event = ShareEvent.cancelled(
          shareType: 'image',
          contentType: 'quiz_result',
          sourceScreen: 'session_detail',
        );

        expect(event.eventName, 'share_cancelled');
        expect(event.parameters['share_type'], 'image');
        expect(event.parameters['content_type'], 'quiz_result');
        expect(event.parameters['source_screen'], 'session_detail');
      });
    });

    group('shareFailed', () {
      test('creates event with all parameters', () {
        final event = ShareEvent.failed(
          shareType: 'image',
          contentType: 'quiz_result',
          sourceScreen: 'results_screen',
          errorMessage: 'No sharing apps available',
        );

        expect(event.eventName, 'share_failed');
        expect(event.parameters['share_type'], 'image');
        expect(event.parameters['content_type'], 'quiz_result');
        expect(event.parameters['source_screen'], 'results_screen');
        expect(event.parameters['error_message'], 'No sharing apps available');
      });
    });
  });
}
