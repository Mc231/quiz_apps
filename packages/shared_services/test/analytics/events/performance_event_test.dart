import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('PerformanceEvent', () {
    // ============ App Lifecycle Events ============

    group('AppLaunchEvent', () {
      test('creates with correct event name', () {
        const event = AppLaunchEvent(
          coldStartDuration: Duration(milliseconds: 1500),
          isFirstLaunch: false,
        );

        expect(event.eventName, equals('app_launch'));
      });

      test('includes all required parameters', () {
        const event = AppLaunchEvent(
          coldStartDuration: Duration(milliseconds: 2000),
          isFirstLaunch: true,
        );

        expect(event.parameters, {
          'cold_start_duration_ms': 2000,
          'is_first_launch': 1,
        });
      });

      test('includes optional parameters', () {
        const event = AppLaunchEvent(
          coldStartDuration: Duration(seconds: 3),
          isFirstLaunch: false,
          launchType: 'deep_link',
          previousVersion: '1.0.0',
        );

        expect(event.parameters['launch_type'], equals('deep_link'));
        expect(event.parameters['previous_version'], equals('1.0.0'));
      });

      test('factory constructor works', () {
        final event = PerformanceEvent.appLaunch(
          coldStartDuration: const Duration(milliseconds: 1200),
          isFirstLaunch: true,
        );

        expect(event, isA<AppLaunchEvent>());
      });
    });

    group('SessionStartEvent', () {
      test('creates with correct event name', () {
        final event = SessionStartEvent(
          sessionId: 'session_123',
          startTime: DateTime(2024, 1, 15, 10, 30),
        );

        expect(event.eventName, equals('session_start'));
      });

      test('includes all required parameters', () {
        final startTime = DateTime(2024, 1, 15, 10, 30);
        final event = SessionStartEvent(
          sessionId: 'session_456',
          startTime: startTime,
        );

        expect(event.parameters, {
          'session_id': 'session_456',
          'start_time': startTime.toIso8601String(),
        });
      });

      test('includes optional parameters', () {
        final event = SessionStartEvent(
          sessionId: 'session_789',
          startTime: DateTime(2024, 1, 15, 14, 0),
          entryPoint: 'notification',
          deviceInfo: {'os': 'iOS', 'version': '17.0'},
        );

        expect(event.parameters['entry_point'], equals('notification'));
        expect(event.parameters['device_info'], {
          'os': 'iOS',
          'version': '17.0',
        });
      });

      test('factory constructor works', () {
        final event = PerformanceEvent.sessionStart(
          sessionId: 'session_test',
          startTime: DateTime.now(),
        );

        expect(event, isA<SessionStartEvent>());
      });
    });

    group('SessionEndEvent', () {
      test('creates with correct event name', () {
        const event = SessionEndEvent(
          sessionId: 'session_123',
          sessionDuration: Duration(minutes: 30),
          screenViewCount: 10,
          interactionCount: 50,
        );

        expect(event.eventName, equals('session_end'));
      });

      test('includes all required parameters', () {
        const event = SessionEndEvent(
          sessionId: 'session_456',
          sessionDuration: Duration(minutes: 15, seconds: 30),
          screenViewCount: 5,
          interactionCount: 25,
        );

        expect(event.parameters, {
          'session_id': 'session_456',
          'session_duration_ms': 930000,
          'screen_view_count': 5,
          'interaction_count': 25,
        });
      });

      test('includes optional exit reason', () {
        const event = SessionEndEvent(
          sessionId: 'session_789',
          sessionDuration: Duration(hours: 1),
          screenViewCount: 20,
          interactionCount: 100,
          exitReason: 'app_backgrounded',
        );

        expect(event.parameters['exit_reason'], equals('app_backgrounded'));
      });

      test('factory constructor works', () {
        final event = PerformanceEvent.sessionEnd(
          sessionId: 'session_test',
          sessionDuration: const Duration(minutes: 10),
          screenViewCount: 8,
          interactionCount: 40,
        );

        expect(event, isA<SessionEndEvent>());
      });
    });

    // ============ Rendering Events ============

    group('ScreenRenderEvent', () {
      test('creates with correct event name', () {
        const event = ScreenRenderEvent(
          screenName: 'quiz_screen',
          renderDuration: Duration(milliseconds: 150),
          isInitialRender: true,
        );

        expect(event.eventName, equals('screen_render'));
      });

      test('includes all required parameters', () {
        const event = ScreenRenderEvent(
          screenName: 'home_screen',
          renderDuration: Duration(milliseconds: 200),
          isInitialRender: false,
        );

        expect(event.parameters, {
          'screen_name': 'home_screen',
          'render_duration_ms': 200,
          'is_initial_render': 0,
        });
      });

      test('includes optional parameters', () {
        const event = ScreenRenderEvent(
          screenName: 'settings_screen',
          renderDuration: Duration(milliseconds: 300),
          isInitialRender: true,
          widgetCount: 45,
          dataLoadDuration: Duration(milliseconds: 100),
        );

        expect(event.parameters['widget_count'], equals(45));
        expect(event.parameters['data_load_duration_ms'], equals(100));
      });

      test('factory constructor works', () {
        final event = PerformanceEvent.screenRender(
          screenName: 'test_screen',
          renderDuration: const Duration(milliseconds: 50),
          isInitialRender: true,
        );

        expect(event, isA<ScreenRenderEvent>());
      });
    });

    // ============ Database Events ============

    group('DatabaseQueryEvent', () {
      test('creates with correct event name', () {
        const event = DatabaseQueryEvent(
          queryType: 'SELECT',
          tableName: 'quiz_sessions',
          queryDuration: Duration(milliseconds: 50),
          resultCount: 10,
        );

        expect(event.eventName, equals('database_query'));
      });

      test('includes all required parameters', () {
        const event = DatabaseQueryEvent(
          queryType: 'INSERT',
          tableName: 'achievements',
          queryDuration: Duration(milliseconds: 25),
          resultCount: 1,
        );

        expect(event.parameters, {
          'query_type': 'INSERT',
          'table_name': 'achievements',
          'query_duration_ms': 25,
          'result_count': 1,
        });
      });

      test('includes optional parameters', () {
        const event = DatabaseQueryEvent(
          queryType: 'SELECT',
          tableName: 'user_settings',
          queryDuration: Duration(milliseconds: 15),
          resultCount: 1,
          usedIndex: true,
          querySize: 256,
        );

        expect(event.parameters['used_index'], equals(1));
        expect(event.parameters['query_size'], equals(256));
      });

      test('factory constructor works', () {
        final event = PerformanceEvent.databaseQuery(
          queryType: 'UPDATE',
          tableName: 'scores',
          queryDuration: const Duration(milliseconds: 30),
          resultCount: 1,
        );

        expect(event, isA<DatabaseQueryEvent>());
      });
    });
  });

  group('PerformanceEvent base class', () {
    test('all performance events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const AppLaunchEvent(
          coldStartDuration: Duration(seconds: 1),
          isFirstLaunch: false,
        ),
        SessionStartEvent(
          sessionId: 'test',
          startTime: DateTime.now(),
        ),
        const SessionEndEvent(
          sessionId: 'test',
          sessionDuration: Duration(minutes: 5),
          screenViewCount: 3,
          interactionCount: 15,
        ),
        const ScreenRenderEvent(
          screenName: 'test',
          renderDuration: Duration(milliseconds: 100),
          isInitialRender: true,
        ),
        const DatabaseQueryEvent(
          queryType: 'SELECT',
          tableName: 'test',
          queryDuration: Duration(milliseconds: 10),
          resultCount: 5,
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
