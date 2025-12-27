import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/analytics/analytics_lifecycle_observer.dart';
import 'package:shared_services/shared_services.dart';

// Mock Analytics Service
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> loggedEvents = [];
  final List<({String screenName, String? screenClass})> screenViews = [];
  final List<({String name, String? value})> userProperties = [];
  String? userId;
  bool _enabled = true;

  @override
  bool get isEnabled => _enabled;

  @override
  Future<void> initialize() async {}

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    loggedEvents.add(event);
  }

  @override
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    screenViews.add((screenName: screenName, screenClass: screenClass));
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    userProperties.add((name: name, value: value));
  }

  @override
  Future<void> setUserId(String? id) async {
    userId = id;
  }

  @override
  Future<void> resetAnalyticsData() async {
    loggedEvents.clear();
    screenViews.clear();
    userProperties.clear();
    userId = null;
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    _enabled = enabled;
  }

  @override
  void dispose() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsLifecycleObserver', () {
    late MockAnalyticsService mockAnalyticsService;
    late AnalyticsLifecycleObserver observer;

    setUp(() {
      mockAnalyticsService = MockAnalyticsService();
      observer = AnalyticsLifecycleObserver(
        analyticsService: mockAnalyticsService,
      );
    });

    tearDown(() {
      observer.dispose();
    });

    group('initialization', () {
      test('initializes without error', () {
        expect(() => observer.initialize(), returnsNormally);
      });

      test('can be disposed without error', () {
        observer.initialize();
        expect(() => observer.dispose(), returnsNormally);
      });

      test('does not have active session initially', () {
        expect(observer.hasActiveSession, isFalse);
        expect(observer.currentSessionId, isNull);
      });
    });

    group('app launch tracking', () {
      test('tracks app launch event with cold start duration', () async {
        final startTime = DateTime.now().subtract(const Duration(seconds: 2));

        await observer.trackAppLaunch(
          startTime: startTime,
          isFirstLaunch: true,
        );

        expect(mockAnalyticsService.loggedEvents, hasLength(2));

        // First event should be app_launch
        final appLaunchEvent =
            mockAnalyticsService.loggedEvents.first as AppLaunchEvent;
        expect(appLaunchEvent.eventName, 'app_launch');
        expect(appLaunchEvent.isFirstLaunch, isTrue);
        expect(
          appLaunchEvent.coldStartDuration.inSeconds,
          greaterThanOrEqualTo(2),
        );
      });

      test('tracks app launch with previous version on upgrade', () async {
        final startTime = DateTime.now();

        await observer.trackAppLaunch(
          startTime: startTime,
          isFirstLaunch: false,
          previousVersion: '1.0.0',
        );

        final appLaunchEvent =
            mockAnalyticsService.loggedEvents.first as AppLaunchEvent;
        expect(appLaunchEvent.previousVersion, '1.0.0');
        expect(appLaunchEvent.isFirstLaunch, isFalse);
      });

      test('starts new session after app launch', () async {
        final startTime = DateTime.now();

        await observer.trackAppLaunch(
          startTime: startTime,
          isFirstLaunch: true,
        );

        expect(observer.hasActiveSession, isTrue);
        expect(observer.currentSessionId, isNotNull);

        // Second event should be session_start
        final sessionStartEvent =
            mockAnalyticsService.loggedEvents[1] as SessionStartEvent;
        expect(sessionStartEvent.eventName, 'session_start');
        expect(sessionStartEvent.entryPoint, 'app_launch');
      });
    });

    group('session tracking', () {
      test('starts new session with unique ID', () async {
        await observer.startNewSession(entryPoint: 'test');

        expect(observer.hasActiveSession, isTrue);
        expect(observer.currentSessionId, isNotNull);
        expect(observer.currentSessionId!.isNotEmpty, isTrue);
      });

      test('generates unique session IDs', () async {
        await observer.startNewSession(entryPoint: 'test1');
        final firstId = observer.currentSessionId;

        await observer.startNewSession(entryPoint: 'test2');
        final secondId = observer.currentSessionId;

        expect(firstId, isNot(equals(secondId)));
      });

      test('logs session start event with entry point', () async {
        await observer.startNewSession(entryPoint: 'deep_link');

        final sessionEvent =
            mockAnalyticsService.loggedEvents.last as SessionStartEvent;
        expect(sessionEvent.eventName, 'session_start');
        expect(sessionEvent.entryPoint, 'deep_link');
        expect(sessionEvent.sessionId, observer.currentSessionId);
      });

      test('logs session end event when starting new session', () async {
        await observer.startNewSession(entryPoint: 'first');
        final firstSessionId = observer.currentSessionId;

        // Wait a bit to accumulate session time
        await Future<void>.delayed(const Duration(milliseconds: 10));

        await observer.startNewSession(entryPoint: 'second');

        // Should have 3 events: start, end, start
        expect(mockAnalyticsService.loggedEvents.length, 3);

        final sessionEndEvent =
            mockAnalyticsService.loggedEvents[1] as SessionEndEvent;
        expect(sessionEndEvent.eventName, 'session_end');
        expect(sessionEndEvent.sessionId, firstSessionId);
        expect(sessionEndEvent.exitReason, 'new_session');
      });

      test('tracks screen view count', () async {
        await observer.startNewSession(entryPoint: 'test');

        observer.incrementScreenViews();
        observer.incrementScreenViews();
        observer.incrementScreenViews();

        await observer.startNewSession(entryPoint: 'new');

        final sessionEndEvent =
            mockAnalyticsService.loggedEvents[1] as SessionEndEvent;
        expect(sessionEndEvent.screenViewCount, 3);
      });

      test('tracks interaction count', () async {
        await observer.startNewSession(entryPoint: 'test');

        observer.incrementInteractions();
        observer.incrementInteractions();

        await observer.startNewSession(entryPoint: 'new');

        final sessionEndEvent =
            mockAnalyticsService.loggedEvents[1] as SessionEndEvent;
        expect(sessionEndEvent.interactionCount, 2);
      });

      test('onSessionStart callback is invoked', () async {
        String? receivedSessionId;
        final callbackObserver = AnalyticsLifecycleObserver(
          analyticsService: mockAnalyticsService,
          onSessionStart: (sessionId) {
            receivedSessionId = sessionId;
          },
        );

        await callbackObserver.startNewSession(entryPoint: 'test');

        expect(receivedSessionId, isNotNull);
        expect(receivedSessionId, callbackObserver.currentSessionId);

        callbackObserver.dispose();
      });

      test('onSessionEnd callback is invoked', () async {
        String? endedSessionId;
        Duration? sessionDuration;
        final callbackObserver = AnalyticsLifecycleObserver(
          analyticsService: mockAnalyticsService,
          onSessionEnd: (sessionId, duration) {
            endedSessionId = sessionId;
            sessionDuration = duration;
          },
        );

        await callbackObserver.startNewSession(entryPoint: 'first');
        final firstId = callbackObserver.currentSessionId;
        await callbackObserver.startNewSession(entryPoint: 'second');

        expect(endedSessionId, firstId);
        expect(sessionDuration, isNotNull);

        callbackObserver.dispose();
      });
    });

    group('anonymous user ID', () {
      test('generateAnonymousUserId creates valid UUID format', () {
        final userId = AnalyticsLifecycleObserver.generateAnonymousUserId();

        expect(userId, startsWith('anon_'));
        expect(userId.length, 41); // 'anon_' + UUID format (36 chars)

        // Check UUID-like format
        final uuidPart = userId.substring(5);
        final parts = uuidPart.split('-');
        expect(parts.length, 5);
        expect(parts[0].length, 8);
        expect(parts[1].length, 4);
        expect(parts[2].length, 4);
        expect(parts[2][0], '4'); // Version 4
        expect(parts[3].length, 4);
        expect(['8', '9', 'a', 'b'].contains(parts[3][0]), isTrue); // Variant
        expect(parts[4].length, 12);
      });

      test('generateAnonymousUserId creates unique IDs', () {
        final ids = <String>{};
        for (var i = 0; i < 100; i++) {
          ids.add(AnalyticsLifecycleObserver.generateAnonymousUserId());
        }
        expect(ids.length, 100);
      });

      test('getOrCreateAnonymousUserId creates new ID if not exists', () async {
        String? storedId;
        final newId = await observer.getOrCreateAnonymousUserId(
          storageProvider: (key) async => null,
          storageSetter: (key, value) async {
            storedId = value;
          },
        );

        expect(newId, startsWith('anon_'));
        expect(storedId, newId);
        expect(mockAnalyticsService.userId, newId);
      });

      test('getOrCreateAnonymousUserId returns existing ID', () async {
        const existingId = 'anon_existing-1234-5678-9abc-def012345678';

        final returnedId = await observer.getOrCreateAnonymousUserId(
          storageProvider: (key) async => existingId,
          storageSetter: (key, value) async {},
        );

        expect(returnedId, existingId);
      });

      test('setAnonymousUserId sets user ID on analytics service', () async {
        const userId = 'anon_test-1234-5678-9abc-def012345678';

        await observer.setAnonymousUserId(userId);

        expect(mockAnalyticsService.userId, userId);
      });

      test('clearAnonymousUserId removes user ID', () async {
        String? removedKey;

        await observer.setAnonymousUserId('test_id');
        await observer.clearAnonymousUserId(
          storageRemover: (key) async {
            removedKey = key;
          },
        );

        expect(removedKey, 'anonymous_user_id');
        expect(mockAnalyticsService.userId, isNull);
      });
    });

    group('user properties after quiz', () {
      test('updateUserPropertiesAfterQuiz sets quiz properties', () async {
        await observer.updateUserPropertiesAfterQuiz(
          totalQuizzesTaken: 10,
          totalCorrectAnswers: 85,
          averageScore: 85.5,
          bestStreak: 12,
          totalPoints: 1500,
          favoriteCategory: 'geography',
          preferredQuizMode: 'timed',
        );

        expect(mockAnalyticsService.userProperties, hasLength(7));

        expect(
          mockAnalyticsService.userProperties
              .where((p) => p.name == 'total_quizzes_taken' && p.value == '10'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties.where(
              (p) => p.name == 'total_correct_answers' && p.value == '85'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties
              .where((p) => p.name == 'average_score' && p.value == '85.5'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties
              .where((p) => p.name == 'best_streak' && p.value == '12'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties
              .where((p) => p.name == 'total_points' && p.value == '1500'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties.where(
              (p) => p.name == 'favorite_category' && p.value == 'geography'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties.where(
              (p) => p.name == 'preferred_quiz_mode' && p.value == 'timed'),
          hasLength(1),
        );
      });

      test('updateUserPropertiesAfterQuiz only sets provided properties',
          () async {
        await observer.updateUserPropertiesAfterQuiz(
          totalQuizzesTaken: 5,
        );

        expect(mockAnalyticsService.userProperties, hasLength(1));
        expect(
          mockAnalyticsService.userProperties.first.name,
          'total_quizzes_taken',
        );
      });

      test('updateAchievementProperties sets achievement count', () async {
        await observer.updateAchievementProperties(achievementsUnlocked: 15);

        expect(mockAnalyticsService.userProperties, hasLength(1));
        expect(
          mockAnalyticsService.userProperties.first.name,
          'achievements_unlocked',
        );
        expect(mockAnalyticsService.userProperties.first.value, '15');
      });

      test('updateSettingsProperties sets sound and haptic settings',
          () async {
        await observer.updateSettingsProperties(
          soundEffectsEnabled: true,
          hapticFeedbackEnabled: false,
        );

        expect(mockAnalyticsService.userProperties, hasLength(2));
        expect(
          mockAnalyticsService.userProperties
              .where((p) => p.name == 'sound_effects_enabled' && p.value == 'true'),
          hasLength(1),
        );
        expect(
          mockAnalyticsService.userProperties.where(
              (p) => p.name == 'haptic_feedback_enabled' && p.value == 'false'),
          hasLength(1),
        );
      });

      test('updatePremiumStatus sets premium user property', () async {
        await observer.updatePremiumStatus(isPremium: true);

        expect(mockAnalyticsService.userProperties, hasLength(1));
        expect(
          mockAnalyticsService.userProperties.first.name,
          'is_premium_user',
        );
        expect(mockAnalyticsService.userProperties.first.value, 'true');
      });

      test('updateAppVersion sets app version property', () async {
        await observer.updateAppVersion(version: '2.1.0');

        expect(mockAnalyticsService.userProperties, hasLength(1));
        expect(
          mockAnalyticsService.userProperties.first.name,
          'app_version',
        );
        expect(mockAnalyticsService.userProperties.first.value, '2.1.0');
      });

      test('updateFirstOpenDate sets first open date property', () async {
        final date = DateTime(2024, 1, 15);

        await observer.updateFirstOpenDate(date: date);

        expect(mockAnalyticsService.userProperties, hasLength(1));
        expect(
          mockAnalyticsService.userProperties.first.name,
          'first_open_date',
        );
        expect(mockAnalyticsService.userProperties.first.value, '2024-01-15');
      });

      test('updateDaysActive sets days active property', () async {
        await observer.updateDaysActive(daysActive: 30);

        expect(mockAnalyticsService.userProperties, hasLength(1));
        expect(
          mockAnalyticsService.userProperties.first.name,
          'days_active',
        );
        expect(mockAnalyticsService.userProperties.first.value, '30');
      });
    });

    group('session duration', () {
      test('currentSessionDuration returns duration when session active',
          () async {
        await observer.startNewSession(entryPoint: 'test');

        // Wait a bit
        await Future<void>.delayed(const Duration(milliseconds: 50));

        final duration = observer.currentSessionDuration;
        expect(duration, isNotNull);
        expect(duration!.inMilliseconds, greaterThanOrEqualTo(50));
      });

      test('currentSessionDuration returns null when no session', () {
        expect(observer.currentSessionDuration, isNull);
      });
    });
  });

  group('AnalyticsServiceLifecycleExtension', () {
    test('createLifecycleObserver creates observer with correct parameters',
        () {
      final mockService = MockAnalyticsService();

      final observer = mockService.createLifecycleObserver(
        sessionTimeoutDuration: const Duration(minutes: 15),
      );

      expect(observer.analyticsService, mockService);
      expect(observer.sessionTimeoutDuration, const Duration(minutes: 15));

      observer.dispose();
    });
  });

  group('AnalyticsLifecycleProvider', () {
    testWidgets('provides observer to descendants', (tester) async {
      final mockService = MockAnalyticsService();
      final observer = AnalyticsLifecycleObserver(
        analyticsService: mockService,
      );

      AnalyticsLifecycleObserver? capturedObserver;

      await tester.pumpWidget(
        AnalyticsLifecycleProvider(
          observer: observer,
          child: Builder(
            builder: (context) {
              capturedObserver = AnalyticsLifecycleProvider.of(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(capturedObserver, observer);

      observer.dispose();
    });

    testWidgets('maybeOf returns null when no provider', (tester) async {
      AnalyticsLifecycleObserver? capturedObserver;

      await tester.pumpWidget(
        Builder(
          builder: (context) {
            capturedObserver = AnalyticsLifecycleProvider.maybeOf(context);
            return const SizedBox();
          },
        ),
      );

      expect(capturedObserver, isNull);
    });

    testWidgets('updateShouldNotify returns true when observer changes',
        (tester) async {
      final mockService = MockAnalyticsService();
      final observer1 = AnalyticsLifecycleObserver(
        analyticsService: mockService,
      );
      final observer2 = AnalyticsLifecycleObserver(
        analyticsService: mockService,
      );

      final widget1 = AnalyticsLifecycleProvider(
        observer: observer1,
        child: const SizedBox(),
      );

      final widget2 = AnalyticsLifecycleProvider(
        observer: observer2,
        child: const SizedBox(),
      );

      expect(widget2.updateShouldNotify(widget1), isTrue);

      observer1.dispose();
      observer2.dispose();
    });
  });
}
