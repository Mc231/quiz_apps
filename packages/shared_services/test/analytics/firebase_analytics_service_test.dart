import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:shared_services/shared_services.dart';

import 'firebase_analytics_service_test.mocks.dart';

@GenerateMocks([FirebaseAnalytics])
void main() {
  late MockFirebaseAnalytics mockAnalytics;
  late FirebaseAnalyticsService service;

  setUp(() {
    mockAnalytics = MockFirebaseAnalytics();
    service = FirebaseAnalyticsService(
      firebaseAnalytics: mockAnalytics,
      enableDebugLogging: false,
    );

    // Default mock behavior
    when(mockAnalytics.setDefaultEventParameters(any))
        .thenAnswer((_) async {});
  });

  tearDown(() {
    service.dispose();
  });

  group('FirebaseAnalyticsService', () {
    group('initialization', () {
      test('initializes successfully', () async {
        await service.initialize();

        expect(service.isInitialized, isTrue);
        expect(service.isEnabled, isTrue);
        verify(mockAnalytics.setDefaultEventParameters(any)).called(1);
      });

      test('isEnabled returns false before initialization', () {
        expect(service.isEnabled, isFalse);
        expect(service.isInitialized, isFalse);
      });

      test('handles initialization errors gracefully', () async {
        when(mockAnalytics.setDefaultEventParameters(any))
            .thenThrow(Exception('Firebase not initialized'));

        // Should not throw
        await service.initialize();

        // Service should still be marked as initialized
        expect(service.isInitialized, isTrue);
      });
    });

    group('logEvent', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async {});
      });

      test('logs event with correct name', () async {
        final event = QuizEvent.started(
          quizId: 'quiz-123',
          quizName: 'Flags Quiz',
          categoryId: 'flags',
          categoryName: 'Flags',
          mode: 'standard',
          totalQuestions: 10,
        );

        await service.logEvent(event);

        verify(mockAnalytics.logEvent(
          name: 'quiz_started',
          parameters: argThat(isNotNull, named: 'parameters'),
        )).called(1);
      });

      test('logs event with sanitized parameters', () async {
        final event = QuestionEvent.answered(
          quizId: 'quiz-123',
          questionId: 'q-1',
          questionIndex: 0,
          selectedAnswer: 'France',
          correctAnswer: 'France',
          isCorrect: true,
          responseTime: const Duration(seconds: 5),
        );

        await service.logEvent(event);

        verify(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: argThat(
            allOf(
              containsPair('question_id', 'q-1'),
              containsPair('question_index', 0),
              containsPair('selected_answer', 'France'),
              containsPair('is_correct', true),
              containsPair('response_time_ms', 5000),
            ),
            named: 'parameters',
          ),
        )).called(1);
      });

      test('does not log when disabled', () async {
        when(mockAnalytics.setAnalyticsCollectionEnabled(false))
            .thenAnswer((_) async {});

        await service.setAnalyticsCollectionEnabled(false);

        final event = QuizEvent.started(
          quizId: 'quiz-123',
          quizName: 'Flags Quiz',
          categoryId: 'flags',
          categoryName: 'Flags',
          mode: 'standard',
          totalQuestions: 10,
        );

        await service.logEvent(event);

        verifyNever(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        ));
      });

      test('handles log event errors gracefully', () async {
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenThrow(Exception('Network error'));

        final event = QuizEvent.started(
          quizId: 'quiz-123',
          quizName: 'Flags Quiz',
          categoryId: 'flags',
          categoryName: 'Flags',
          mode: 'standard',
          totalQuestions: 10,
        );

        // Should not throw
        await service.logEvent(event);
      });
    });

    group('setCurrentScreen', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.logScreenView(
          screenName: anyNamed('screenName'),
          screenClass: anyNamed('screenClass'),
        )).thenAnswer((_) async {});
      });

      test('logs screen view', () async {
        await service.setCurrentScreen(
          screenName: 'QuizScreen',
          screenClass: 'QuizScreen',
        );

        verify(mockAnalytics.logScreenView(
          screenName: 'QuizScreen',
          screenClass: 'QuizScreen',
        )).called(1);
      });

      test('logs screen view without class', () async {
        await service.setCurrentScreen(screenName: 'HomeScreen');

        verify(mockAnalytics.logScreenView(
          screenName: 'HomeScreen',
          screenClass: null,
        )).called(1);
      });
    });

    group('setUserProperty', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.setUserProperty(
          name: anyNamed('name'),
          value: anyNamed('value'),
        )).thenAnswer((_) async {});
      });

      test('sets user property', () async {
        await service.setUserProperty(
          name: AnalyticsUserProperties.totalQuizzesTaken,
          value: '42',
        );

        verify(mockAnalytics.setUserProperty(
          name: 'total_quizzes_taken',
          value: '42',
        )).called(1);
      });

      test('clears user property with null value', () async {
        await service.setUserProperty(
          name: AnalyticsUserProperties.favoriteCategory,
          value: null,
        );

        verify(mockAnalytics.setUserProperty(
          name: 'favorite_category',
          value: null,
        )).called(1);
      });
    });

    group('setUserId', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.setUserId(id: anyNamed('id')))
            .thenAnswer((_) async {});
      });

      test('sets user ID', () async {
        await service.setUserId('user-123');

        verify(mockAnalytics.setUserId(id: 'user-123')).called(1);
      });

      test('clears user ID with null', () async {
        await service.setUserId(null);

        verify(mockAnalytics.setUserId(id: null)).called(1);
      });
    });

    group('resetAnalyticsData', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.resetAnalyticsData()).thenAnswer((_) async {});
      });

      test('resets analytics data', () async {
        await service.resetAnalyticsData();

        verify(mockAnalytics.resetAnalyticsData()).called(1);
      });
    });

    group('setAnalyticsCollectionEnabled', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.setAnalyticsCollectionEnabled(any))
            .thenAnswer((_) async {});
      });

      test('enables analytics collection', () async {
        await service.setAnalyticsCollectionEnabled(true);

        verify(mockAnalytics.setAnalyticsCollectionEnabled(true)).called(1);
        expect(service.isEnabled, isTrue);
      });

      test('disables analytics collection', () async {
        await service.setAnalyticsCollectionEnabled(false);

        verify(mockAnalytics.setAnalyticsCollectionEnabled(false)).called(1);
        expect(service.isEnabled, isFalse);
      });
    });

    group('dispose', () {
      test('marks service as not initialized', () async {
        await service.initialize();
        expect(service.isInitialized, isTrue);

        service.dispose();

        expect(service.isInitialized, isFalse);
        expect(service.isEnabled, isFalse);
      });
    });

    group('observer', () {
      test('returns FirebaseAnalyticsObserver', () {
        final observer = service.observer;

        expect(observer, isA<FirebaseAnalyticsObserver>());
      });
    });

    group('event name sanitization', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async {});
      });

      test('converts event name to lowercase', () async {
        // Using a mock event with uppercase name
        const event = _TestEvent(
          eventName: 'TEST_EVENT_NAME',
          parameters: {},
        );

        await service.logEvent(event);

        verify(mockAnalytics.logEvent(
          name: 'test_event_name',
          parameters: anyNamed('parameters'),
        )).called(1);
      });

      test('truncates long event names to 40 characters', () async {
        const event = _TestEvent(
          eventName: 'this_is_a_very_long_event_name_that_exceeds_forty_characters',
          parameters: {},
        );

        await service.logEvent(event);

        final captured = verify(mockAnalytics.logEvent(
          name: captureAnyNamed('name'),
          parameters: anyNamed('parameters'),
        )).captured;

        expect((captured.first as String).length, lessThanOrEqualTo(40));
      });
    });

    group('parameter sanitization', () {
      setUp(() async {
        await service.initialize();
        when(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: anyNamed('parameters'),
        )).thenAnswer((_) async {});
      });

      test('truncates long string values to 100 characters', () async {
        final longString = 'a' * 150;
        final event = _TestEvent(
          eventName: 'test_event',
          parameters: {'long_value': longString},
        );

        await service.logEvent(event);

        final captured = verify(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: captureAnyNamed('parameters'),
        )).captured;

        final params = captured.first as Map<String, Object>;
        expect((params['long_value'] as String).length, equals(100));
      });

      test('preserves int values', () async {
        const event = _TestEvent(
          eventName: 'test_event',
          parameters: {'count': 42},
        );

        await service.logEvent(event);

        verify(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: argThat(
            containsPair('count', 42),
            named: 'parameters',
          ),
        )).called(1);
      });

      test('preserves double values', () async {
        const event = _TestEvent(
          eventName: 'test_event',
          parameters: {'score': 98.5},
        );

        await service.logEvent(event);

        verify(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: argThat(
            containsPair('score', 98.5),
            named: 'parameters',
          ),
        )).called(1);
      });

      test('preserves int values for boolean parameters', () async {
        const event = _TestEvent(
          eventName: 'test_event',
          parameters: {'is_correct': 1},
        );

        await service.logEvent(event);

        verify(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: argThat(
            containsPair('is_correct', 1),
            named: 'parameters',
          ),
        )).called(1);
      });

      test('limits parameters to 25', () async {
        final manyParams = <String, dynamic>{};
        for (var i = 0; i < 30; i++) {
          manyParams['param_$i'] = 'value_$i';
        }

        final event = _TestEvent(
          eventName: 'test_event',
          parameters: manyParams,
        );

        await service.logEvent(event);

        final captured = verify(mockAnalytics.logEvent(
          name: anyNamed('name'),
          parameters: captureAnyNamed('parameters'),
        )).captured;

        final params = captured.first as Map<String, Object>;
        expect(params.length, lessThanOrEqualTo(25));
      });
    });

    group('Firebase standard events', () {
      setUp(() async {
        await service.initialize();
      });

      test('logAppOpen calls Firebase logAppOpen', () async {
        when(mockAnalytics.logAppOpen()).thenAnswer((_) async {});

        await service.logAppOpen();

        verify(mockAnalytics.logAppOpen()).called(1);
      });

      test('logTutorialBegin calls Firebase logTutorialBegin', () async {
        when(mockAnalytics.logTutorialBegin()).thenAnswer((_) async {});

        await service.logTutorialBegin();

        verify(mockAnalytics.logTutorialBegin()).called(1);
      });

      test('logTutorialComplete calls Firebase logTutorialComplete', () async {
        when(mockAnalytics.logTutorialComplete()).thenAnswer((_) async {});

        await service.logTutorialComplete();

        verify(mockAnalytics.logTutorialComplete()).called(1);
      });

      test('logUnlockAchievement calls Firebase logUnlockAchievement',
          () async {
        when(mockAnalytics.logUnlockAchievement(id: anyNamed('id')))
            .thenAnswer((_) async {});

        await service.logUnlockAchievement(achievementId: 'first_quiz');

        verify(mockAnalytics.logUnlockAchievement(id: 'first_quiz')).called(1);
      });

      test('logLevelUp calls Firebase logLevelUp', () async {
        when(mockAnalytics.logLevelUp(
          level: anyNamed('level'),
          character: anyNamed('character'),
        )).thenAnswer((_) async {});

        await service.logLevelUp(level: 5);

        verify(mockAnalytics.logLevelUp(level: 5, character: null)).called(1);
      });

      test('logPostScore calls Firebase logPostScore', () async {
        when(mockAnalytics.logPostScore(
          score: anyNamed('score'),
          level: anyNamed('level'),
          character: anyNamed('character'),
        )).thenAnswer((_) async {});

        await service.logPostScore(score: 100);

        verify(mockAnalytics.logPostScore(
          score: 100,
          level: null,
          character: null,
        )).called(1);
      });

      test('logShare calls Firebase logShare', () async {
        when(mockAnalytics.logShare(
          contentType: anyNamed('contentType'),
          itemId: anyNamed('itemId'),
          method: anyNamed('method'),
        )).thenAnswer((_) async {});

        await service.logShare(
          contentType: 'quiz_result',
          itemId: 'quiz-123',
          method: 'twitter',
        );

        verify(mockAnalytics.logShare(
          contentType: 'quiz_result',
          itemId: 'quiz-123',
          method: 'twitter',
        )).called(1);
      });

      test('logPurchase calls Firebase logPurchase', () async {
        when(mockAnalytics.logPurchase(
          currency: anyNamed('currency'),
          value: anyNamed('value'),
          transactionId: anyNamed('transactionId'),
          coupon: anyNamed('coupon'),
          items: anyNamed('items'),
        )).thenAnswer((_) async {});

        await service.logPurchase(
          currency: 'USD',
          value: 4.99,
          transactionId: 'txn-123',
        );

        verify(mockAnalytics.logPurchase(
          currency: 'USD',
          value: 4.99,
          transactionId: 'txn-123',
          coupon: null,
          items: null,
        )).called(1);
      });
    });

    group('Firebase-specific methods', () {
      setUp(() async {
        await service.initialize();
      });

      test('setConsent calls Firebase setConsent', () async {
        when(mockAnalytics.setConsent(
          adStorageConsentGranted: anyNamed('adStorageConsentGranted'),
          analyticsStorageConsentGranted:
              anyNamed('analyticsStorageConsentGranted'),
          adUserDataConsentGranted: anyNamed('adUserDataConsentGranted'),
        )).thenAnswer((_) async {});

        await service.setConsent(
          adStorageConsentGranted: true,
          analyticsStorageConsentGranted: true,
        );

        verify(mockAnalytics.setConsent(
          adStorageConsentGranted: true,
          analyticsStorageConsentGranted: true,
          adUserDataConsentGranted: null,
        )).called(1);
      });

      test('setSessionTimeoutDuration calls Firebase setSessionTimeoutDuration',
          () async {
        when(mockAnalytics.setSessionTimeoutDuration(any))
            .thenAnswer((_) async {});

        await service.setSessionTimeoutDuration(const Duration(minutes: 45));

        verify(mockAnalytics
                .setSessionTimeoutDuration(const Duration(minutes: 45)))
            .called(1);
      });

      test('getAppInstanceId returns app instance ID', () async {
        when(mockAnalytics.appInstanceId)
            .thenAnswer((_) async => 'test-instance-id');

        final result = await service.getAppInstanceId();

        expect(result, equals('test-instance-id'));
      });

      test('getAppInstanceId returns null on error', () async {
        when(mockAnalytics.appInstanceId)
            .thenThrow(Exception('Not available'));

        final result = await service.getAppInstanceId();

        expect(result, isNull);
      });
    });
  });
}

/// Test event class for testing event sanitization.
class _TestEvent extends AnalyticsEvent {
  const _TestEvent({
    required this.eventName,
    required this.parameters,
  });

  @override
  final String eventName;

  @override
  final Map<String, dynamic> parameters;
}
