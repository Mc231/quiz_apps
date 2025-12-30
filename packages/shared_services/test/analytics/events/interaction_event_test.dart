import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('InteractionEvent', () {
    group('CategorySelectedEvent', () {
      test('creates with correct event name', () {
        const event = CategorySelectedEvent(
          categoryId: 'europe',
          categoryName: 'Europe',
          categoryIndex: 0,
        );

        expect(event.eventName, equals('category_selected'));
      });

      test('includes all required parameters', () {
        const event = CategorySelectedEvent(
          categoryId: 'europe',
          categoryName: 'Europe',
          categoryIndex: 2,
        );

        expect(event.parameters, {
          'category_id': 'europe',
          'category_name': 'Europe',
          'category_index': 2,
        });
      });

      test('includes optional parent category when provided', () {
        const event = CategorySelectedEvent(
          categoryId: 'france',
          categoryName: 'France',
          categoryIndex: 5,
          parentCategoryId: 'europe',
        );

        expect(event.parameters['parent_category_id'], equals('europe'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.categorySelected(
          categoryId: 'asia',
          categoryName: 'Asia',
          categoryIndex: 1,
        );

        expect(event, isA<CategorySelectedEvent>());
      });
    });

    group('TabSelectedEvent', () {
      test('creates with correct event name', () {
        const event = TabSelectedEvent(
          tabId: 'play',
          tabName: 'Play',
          tabIndex: 0,
        );

        expect(event.eventName, equals('tab_selected'));
      });

      test('includes optional previous tab when provided', () {
        const event = TabSelectedEvent(
          tabId: 'history',
          tabName: 'History',
          tabIndex: 1,
          previousTabId: 'play',
        );

        expect(event.parameters['previous_tab_id'], equals('play'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.tabSelected(
          tabId: 'settings',
          tabName: 'Settings',
          tabIndex: 3,
        );

        expect(event, isA<TabSelectedEvent>());
      });
    });

    group('SessionViewedEvent', () {
      test('creates with correct event name', () {
        const event = SessionViewedEvent(
          sessionId: 'session-123',
          quizName: 'European Flags',
          scorePercentage: 85.0,
          daysAgo: 3,
        );

        expect(event.eventName, equals('session_viewed'));
      });

      test('includes all parameters', () {
        const event = SessionViewedEvent(
          sessionId: 'session-456',
          quizName: 'World Flags',
          scorePercentage: 92.5,
          daysAgo: 1,
        );

        expect(event.parameters, {
          'session_id': 'session-456',
          'quiz_name': 'World Flags',
          'score_percentage': 92.5,
          'days_ago': 1,
        });
      });

      test('factory constructor works', () {
        final event = InteractionEvent.sessionViewed(
          sessionId: 'session-789',
          quizName: 'Asian Flags',
          scorePercentage: 78.0,
          daysAgo: 7,
        );

        expect(event, isA<SessionViewedEvent>());
      });
    });

    group('SessionDeletedEvent', () {
      test('creates with correct event name', () {
        const event = SessionDeletedEvent(
          sessionId: 'session-123',
          quizName: 'European Flags',
          daysAgo: 5,
        );

        expect(event.eventName, equals('session_deleted'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.sessionDeleted(
          sessionId: 'session-456',
          quizName: 'World Flags',
          daysAgo: 10,
        );

        expect(event, isA<SessionDeletedEvent>());
      });
    });

    group('ViewAllSessionsEvent', () {
      test('creates with correct event name', () {
        const event = ViewAllSessionsEvent(
          totalSessions: 25,
          source: 'home_screen',
        );

        expect(event.eventName, equals('view_all_sessions'));
      });

      test('includes all parameters', () {
        const event = ViewAllSessionsEvent(
          totalSessions: 50,
          source: 'statistics_screen',
        );

        expect(event.parameters, {
          'total_sessions': 50,
          'source': 'statistics_screen',
        });
      });

      test('factory constructor works', () {
        final event = InteractionEvent.viewAllSessions(
          totalSessions: 100,
          source: 'widget',
        );

        expect(event, isA<ViewAllSessionsEvent>());
      });
    });

    group('ExitDialogShownEvent', () {
      test('creates with correct event name', () {
        const event = ExitDialogShownEvent(
          quizId: 'quiz-123',
          questionsAnswered: 5,
          totalQuestions: 20,
        );

        expect(event.eventName, equals('exit_dialog_shown'));
      });

      test('calculates completion percentage', () {
        const event = ExitDialogShownEvent(
          quizId: 'quiz-123',
          questionsAnswered: 10,
          totalQuestions: 20,
        );

        expect(event.parameters['completion_percentage'], equals('50.0'));
      });

      test('handles zero total questions', () {
        const event = ExitDialogShownEvent(
          quizId: 'quiz-123',
          questionsAnswered: 0,
          totalQuestions: 0,
        );

        expect(event.parameters['completion_percentage'], equals('0.0'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.exitDialogShown(
          quizId: 'quiz-456',
          questionsAnswered: 8,
          totalQuestions: 25,
        );

        expect(event, isA<ExitDialogShownEvent>());
      });
    });

    group('ExitDialogConfirmedEvent', () {
      test('creates with correct event name', () {
        const event = ExitDialogConfirmedEvent(
          quizId: 'quiz-123',
          questionsAnswered: 5,
          totalQuestions: 20,
          timeSpent: Duration(minutes: 3),
        );

        expect(event.eventName, equals('exit_dialog_confirmed'));
      });

      test('includes time spent in seconds', () {
        const event = ExitDialogConfirmedEvent(
          quizId: 'quiz-123',
          questionsAnswered: 10,
          totalQuestions: 20,
          timeSpent: Duration(minutes: 5, seconds: 30),
        );

        expect(event.parameters['time_spent_seconds'], equals(330));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.exitDialogConfirmed(
          quizId: 'quiz-789',
          questionsAnswered: 15,
          totalQuestions: 30,
          timeSpent: const Duration(minutes: 8),
        );

        expect(event, isA<ExitDialogConfirmedEvent>());
      });
    });

    group('ExitDialogCancelledEvent', () {
      test('creates with correct event name', () {
        const event = ExitDialogCancelledEvent(
          quizId: 'quiz-123',
          questionsAnswered: 5,
          totalQuestions: 20,
        );

        expect(event.eventName, equals('exit_dialog_cancelled'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.exitDialogCancelled(
          quizId: 'quiz-456',
          questionsAnswered: 12,
          totalQuestions: 25,
        );

        expect(event, isA<ExitDialogCancelledEvent>());
      });
    });

    group('DataExportInitiatedEvent', () {
      test('creates with correct event name', () {
        const event = DataExportInitiatedEvent(
          exportFormat: 'json',
          sessionCount: 50,
        );

        expect(event.eventName, equals('data_export_initiated'));
      });

      test('includes optional date range when provided', () {
        const event = DataExportInitiatedEvent(
          exportFormat: 'csv',
          sessionCount: 100,
          dateRange: 'last_30_days',
        );

        expect(event.parameters['date_range'], equals('last_30_days'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.dataExportInitiated(
          exportFormat: 'pdf',
          sessionCount: 25,
        );

        expect(event, isA<DataExportInitiatedEvent>());
      });
    });

    group('DataExportCompletedEvent', () {
      test('creates with correct event name', () {
        const event = DataExportCompletedEvent(
          exportFormat: 'json',
          sessionCount: 50,
          fileSizeBytes: 102400,
          exportDuration: Duration(seconds: 5),
          success: true,
        );

        expect(event.eventName, equals('data_export_completed'));
      });

      test('includes error message on failure', () {
        const event = DataExportCompletedEvent(
          exportFormat: 'csv',
          sessionCount: 100,
          fileSizeBytes: 0,
          exportDuration: Duration(seconds: 2),
          success: false,
          errorMessage: 'Disk full',
        );

        expect(event.parameters['success'], equals(0));
        expect(event.parameters['error_message'], equals('Disk full'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.dataExportCompleted(
          exportFormat: 'json',
          sessionCount: 75,
          fileSizeBytes: 204800,
          exportDuration: const Duration(seconds: 8),
          success: true,
        );

        expect(event, isA<DataExportCompletedEvent>());
      });
    });

    group('PullToRefreshEvent', () {
      test('creates with correct event name', () {
        const event = PullToRefreshEvent(
          screenName: 'history',
          refreshDuration: Duration(milliseconds: 1500),
          success: true,
        );

        expect(event.eventName, equals('pull_to_refresh'));
      });

      test('includes refresh duration in milliseconds', () {
        const event = PullToRefreshEvent(
          screenName: 'statistics',
          refreshDuration: Duration(seconds: 2),
          success: true,
        );

        expect(event.parameters['refresh_duration_ms'], equals(2000));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.pullToRefresh(
          screenName: 'leaderboard',
          refreshDuration: const Duration(milliseconds: 800),
          success: false,
        );

        expect(event, isA<PullToRefreshEvent>());
      });
    });

    group('LeaderboardViewedEvent', () {
      test('creates with correct event name', () {
        const event = LeaderboardViewedEvent(
          leaderboardType: 'global',
          userRank: 42,
          totalEntries: 1000,
        );

        expect(event.eventName, equals('leaderboard_viewed'));
      });

      test('includes optional category when provided', () {
        const event = LeaderboardViewedEvent(
          leaderboardType: 'category',
          userRank: 5,
          totalEntries: 100,
          categoryId: 'europe',
        );

        expect(event.parameters['category_id'], equals('europe'));
      });

      test('factory constructor works', () {
        final event = InteractionEvent.leaderboardViewed(
          leaderboardType: 'weekly',
          userRank: 15,
          totalEntries: 500,
        );

        expect(event, isA<LeaderboardViewedEvent>());
      });
    });
  });

  group('InteractionEvent base class', () {
    test('all interaction events are AnalyticsEvent', () {
      final events = <AnalyticsEvent>[
        const CategorySelectedEvent(
          categoryId: 'cat1',
          categoryName: 'Category',
          categoryIndex: 0,
        ),
        const TabSelectedEvent(
          tabId: 'tab1',
          tabName: 'Tab',
          tabIndex: 0,
        ),
        const SessionViewedEvent(
          sessionId: 'session1',
          quizName: 'Quiz',
          scorePercentage: 80.0,
          daysAgo: 1,
        ),
        const PullToRefreshEvent(
          screenName: 'home',
          refreshDuration: Duration(seconds: 1),
          success: true,
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
