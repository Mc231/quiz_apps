import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ErrorEvent', () {
    // ============ Data Error Events ============

    group('DataLoadFailedEvent', () {
      test('creates with correct event name', () {
        const event = DataLoadFailedEvent(
          dataType: 'quiz_sessions',
          errorCode: 'DB_ERROR',
          errorMessage: 'Failed to load data',
        );

        expect(event.eventName, equals('data_load_failed'));
      });

      test('includes all required parameters', () {
        const event = DataLoadFailedEvent(
          dataType: 'achievements',
          errorCode: 'PARSE_ERROR',
          errorMessage: 'Invalid JSON format',
        );

        expect(event.parameters, {
          'data_type': 'achievements',
          'error_code': 'PARSE_ERROR',
          'error_message': 'Invalid JSON format',
        });
      });

      test('includes optional parameters', () {
        const event = DataLoadFailedEvent(
          dataType: 'user_settings',
          errorCode: 'NOT_FOUND',
          errorMessage: 'Data not found',
          source: 'local_storage',
          retryCount: 3,
        );

        expect(event.parameters['source'], equals('local_storage'));
        expect(event.parameters['retry_count'], equals(3));
      });

      test('factory constructor works', () {
        final event = ErrorEvent.dataLoadFailed(
          dataType: 'categories',
          errorCode: 'TIMEOUT',
          errorMessage: 'Request timed out',
        );

        expect(event, isA<DataLoadFailedEvent>());
      });
    });

    group('SaveFailedEvent', () {
      test('creates with correct event name', () {
        const event = SaveFailedEvent(
          dataType: 'quiz_session',
          errorCode: 'DISK_FULL',
          errorMessage: 'No space left on device',
        );

        expect(event.eventName, equals('save_failed'));
      });

      test('includes all required parameters', () {
        const event = SaveFailedEvent(
          dataType: 'user_progress',
          errorCode: 'WRITE_ERROR',
          errorMessage: 'Could not write to database',
        );

        expect(event.parameters, {
          'data_type': 'user_progress',
          'error_code': 'WRITE_ERROR',
          'error_message': 'Could not write to database',
        });
      });

      test('includes optional parameters', () {
        const event = SaveFailedEvent(
          dataType: 'settings',
          errorCode: 'VALIDATION_ERROR',
          errorMessage: 'Invalid data format',
          operation: 'update',
          dataSize: 1024,
        );

        expect(event.parameters['operation'], equals('update'));
        expect(event.parameters['data_size'], equals(1024));
      });

      test('factory constructor works', () {
        final event = ErrorEvent.saveFailed(
          dataType: 'score',
          errorCode: 'DB_LOCKED',
          errorMessage: 'Database is locked',
        );

        expect(event, isA<SaveFailedEvent>());
      });
    });

    // ============ User Action Events ============

    group('RetryTappedEvent', () {
      test('creates with correct event name', () {
        const event = RetryTappedEvent(
          errorType: 'network',
          context: 'quiz_load',
          attemptNumber: 1,
        );

        expect(event.eventName, equals('retry_tapped'));
      });

      test('includes all required parameters', () {
        const event = RetryTappedEvent(
          errorType: 'data_load',
          context: 'session_history',
          attemptNumber: 2,
        );

        expect(event.parameters, {
          'error_type': 'data_load',
          'context': 'session_history',
          'attempt_number': 2,
        });
      });

      test('includes optional time since error', () {
        const event = RetryTappedEvent(
          errorType: 'save',
          context: 'settings_save',
          attemptNumber: 3,
          timeSinceError: Duration(seconds: 30),
        );

        expect(event.parameters['time_since_error_ms'], equals(30000));
      });

      test('factory constructor works', () {
        final event = ErrorEvent.retryTapped(
          errorType: 'network',
          context: 'api_call',
          attemptNumber: 1,
        );

        expect(event, isA<RetryTappedEvent>());
      });
    });

    // ============ App Error Events ============

    group('AppCrashEvent', () {
      test('creates with correct event name', () {
        const event = AppCrashEvent(
          crashType: 'flutter_error',
          errorMessage: 'Null check operator used on a null value',
        );

        expect(event.eventName, equals('app_crash'));
      });

      test('includes all required parameters', () {
        const event = AppCrashEvent(
          crashType: 'native_crash',
          errorMessage: 'SIGSEGV',
        );

        expect(event.parameters, {
          'crash_type': 'native_crash',
          'error_message': 'SIGSEGV',
        });
      });

      test('includes optional parameters', () {
        const event = AppCrashEvent(
          crashType: 'unhandled_exception',
          errorMessage: 'RangeError: Index out of range',
          stackTrace: 'at Widget.build() line 42',
          screenName: 'quiz_screen',
          additionalData: {'quiz_id': 'quiz_123', 'question_index': 5},
        );

        expect(event.parameters['stack_trace'], equals('at Widget.build() line 42'));
        expect(event.parameters['screen_name'], equals('quiz_screen'));
        expect(event.parameters['quiz_id'], equals('quiz_123'));
        expect(event.parameters['question_index'], equals(5));
      });

      test('factory constructor works', () {
        final event = ErrorEvent.appCrash(
          crashType: 'platform_exception',
          errorMessage: 'PlatformException(error, message)',
        );

        expect(event, isA<AppCrashEvent>());
      });
    });

    group('FeatureFailureEvent', () {
      test('creates with correct event name', () {
        const event = FeatureFailureEvent(
          featureName: 'quiz_engine',
          errorCode: 'INIT_FAILED',
          errorMessage: 'Failed to initialize quiz engine',
        );

        expect(event.eventName, equals('feature_failure'));
      });

      test('includes all required parameters', () {
        const event = FeatureFailureEvent(
          featureName: 'analytics',
          errorCode: 'CONFIG_ERROR',
          errorMessage: 'Invalid analytics configuration',
        );

        expect(event.parameters, {
          'feature_name': 'analytics',
          'error_code': 'CONFIG_ERROR',
          'error_message': 'Invalid analytics configuration',
        });
      });

      test('includes optional parameters', () {
        const event = FeatureFailureEvent(
          featureName: 'iap',
          errorCode: 'STORE_ERROR',
          errorMessage: 'Store connection failed',
          userAction: 'purchase_tapped',
          wasRecoverable: true,
        );

        expect(event.parameters['user_action'], equals('purchase_tapped'));
        expect(event.parameters['was_recoverable'], equals(1));
      });

      test('factory constructor works', () {
        final event = ErrorEvent.featureFailure(
          featureName: 'ads',
          errorCode: 'LOAD_FAILED',
          errorMessage: 'Ad load failed',
        );

        expect(event, isA<FeatureFailureEvent>());
      });
    });

    // ============ Network Error Events ============

    group('NetworkErrorEvent', () {
      test('creates with correct event name', () {
        const event = NetworkErrorEvent(
          endpoint: '/api/quizzes',
          statusCode: 500,
          errorMessage: 'Internal Server Error',
          requestDuration: Duration(seconds: 5),
        );

        expect(event.eventName, equals('network_error'));
      });

      test('includes all required parameters', () {
        const event = NetworkErrorEvent(
          endpoint: '/api/scores',
          statusCode: 404,
          errorMessage: 'Not Found',
          requestDuration: Duration(milliseconds: 1500),
        );

        expect(event.parameters, {
          'endpoint': '/api/scores',
          'status_code': 404,
          'error_message': 'Not Found',
          'request_duration_ms': 1500,
        });
      });

      test('includes optional parameters', () {
        const event = NetworkErrorEvent(
          endpoint: '/api/upload',
          statusCode: 503,
          errorMessage: 'Service Unavailable',
          requestDuration: Duration(seconds: 30),
          requestMethod: 'POST',
          retryCount: 2,
        );

        expect(event.parameters['request_method'], equals('POST'));
        expect(event.parameters['retry_count'], equals(2));
      });

      test('factory constructor works', () {
        final event = ErrorEvent.network(
          endpoint: '/api/data',
          statusCode: 401,
          errorMessage: 'Unauthorized',
          requestDuration: const Duration(milliseconds: 500),
        );

        expect(event, isA<NetworkErrorEvent>());
      });
    });
  });

  group('ErrorEvent base class', () {
    test('all error events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const DataLoadFailedEvent(
          dataType: 'test',
          errorCode: 'TEST',
          errorMessage: 'Test error',
        ),
        const SaveFailedEvent(
          dataType: 'test',
          errorCode: 'TEST',
          errorMessage: 'Test error',
        ),
        const RetryTappedEvent(
          errorType: 'test',
          context: 'test',
          attemptNumber: 1,
        ),
        const AppCrashEvent(
          crashType: 'test',
          errorMessage: 'Test error',
        ),
        const FeatureFailureEvent(
          featureName: 'test',
          errorCode: 'TEST',
          errorMessage: 'Test error',
        ),
        const NetworkErrorEvent(
          endpoint: '/test',
          statusCode: 500,
          errorMessage: 'Test error',
          requestDuration: Duration(seconds: 1),
        ),
      ];

      for (final event in events) {
        expect(event, isA<AnalyticsEvent>());
        expect(event.eventName, isNotEmpty);
        expect(event.parameters, isA<Map<String, dynamic>>());
      }
    });
  });
}
