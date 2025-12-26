import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ConsoleAnalyticsService', () {
    late ConsoleAnalyticsService service;

    setUp(() {
      service = ConsoleAnalyticsService(enableLogging: false);
    });

    tearDown(() {
      service.dispose();
    });

    group('initialization', () {
      test('starts disabled before initialize', () {
        expect(service.isEnabled, isFalse);
        expect(service.isInitialized, isFalse);
      });

      test('becomes enabled after initialize', () async {
        await service.initialize();

        expect(service.isEnabled, isTrue);
        expect(service.isInitialized, isTrue);
      });
    });

    group('logEvent', () {
      setUp(() async {
        await service.initialize();
      });

      test('logs event to loggedEvents list', () async {
        const event = HomeScreenView(activeTab: 'play');

        await service.logEvent(event);

        expect(service.loggedEvents, hasLength(1));
        expect(service.loggedEvents.first, equals(event));
      });

      test('does not log when disabled', () async {
        await service.setAnalyticsCollectionEnabled(false);
        const event = HomeScreenView(activeTab: 'play');

        await service.logEvent(event);

        expect(service.loggedEvents, isEmpty);
      });

      test('logs multiple events in order', () async {
        const event1 = HomeScreenView(activeTab: 'play');
        const event2 = PlayScreenView(categoryCount: 5);
        const event3 = SettingsScreenView();

        await service.logEvent(event1);
        await service.logEvent(event2);
        await service.logEvent(event3);

        expect(service.loggedEvents, hasLength(3));
        expect(service.loggedEvents[0], equals(event1));
        expect(service.loggedEvents[1], equals(event2));
        expect(service.loggedEvents[2], equals(event3));
      });
    });

    group('setCurrentScreen', () {
      setUp(() async {
        await service.initialize();
      });

      test('logs screen to loggedScreens list', () async {
        await service.setCurrentScreen(
          screenName: 'home',
          screenClass: 'HomeScreen',
        );

        expect(service.loggedScreens, hasLength(1));
        expect(service.loggedScreens.first.screenName, equals('home'));
        expect(service.loggedScreens.first.screenClass, equals('HomeScreen'));
      });

      test('handles null screenClass', () async {
        await service.setCurrentScreen(screenName: 'settings');

        expect(service.loggedScreens, hasLength(1));
        expect(service.loggedScreens.first.screenClass, isNull);
      });

      test('does not log when disabled', () async {
        await service.setAnalyticsCollectionEnabled(false);

        await service.setCurrentScreen(screenName: 'home');

        expect(service.loggedScreens, isEmpty);
      });
    });

    group('setUserProperty', () {
      setUp(() async {
        await service.initialize();
      });

      test('stores user property', () async {
        await service.setUserProperty(
          name: 'favorite_category',
          value: 'europe',
        );

        expect(service.userProperties['favorite_category'], equals('europe'));
      });

      test('clears property with null value', () async {
        await service.setUserProperty(
          name: 'favorite_category',
          value: 'europe',
        );
        await service.setUserProperty(
          name: 'favorite_category',
          value: null,
        );

        expect(service.userProperties['favorite_category'], isNull);
      });

      test('does not store when disabled', () async {
        await service.setAnalyticsCollectionEnabled(false);

        await service.setUserProperty(
          name: 'favorite_category',
          value: 'europe',
        );

        expect(service.userProperties, isEmpty);
      });
    });

    group('setUserId', () {
      setUp(() async {
        await service.initialize();
      });

      test('stores user ID', () async {
        await service.setUserId('user-123');

        expect(service.userId, equals('user-123'));
      });

      test('clears user ID with null', () async {
        await service.setUserId('user-123');
        await service.setUserId(null);

        expect(service.userId, isNull);
      });

      test('does not store when disabled', () async {
        await service.setAnalyticsCollectionEnabled(false);

        await service.setUserId('user-123');

        expect(service.userId, isNull);
      });
    });

    group('resetAnalyticsData', () {
      setUp(() async {
        await service.initialize();
      });

      test('clears all data', () async {
        await service.setUserId('user-123');
        await service.setUserProperty(name: 'prop', value: 'value');
        await service.logEvent(const HomeScreenView(activeTab: 'play'));
        await service.setCurrentScreen(screenName: 'home');

        await service.resetAnalyticsData();

        expect(service.userId, isNull);
        expect(service.userProperties, isEmpty);
        expect(service.loggedEvents, isEmpty);
        expect(service.loggedScreens, isEmpty);
      });
    });

    group('setAnalyticsCollectionEnabled', () {
      setUp(() async {
        await service.initialize();
      });

      test('can disable collection', () async {
        expect(service.isEnabled, isTrue);

        await service.setAnalyticsCollectionEnabled(false);

        expect(service.isEnabled, isFalse);
      });

      test('can re-enable collection', () async {
        await service.setAnalyticsCollectionEnabled(false);
        await service.setAnalyticsCollectionEnabled(true);

        expect(service.isEnabled, isTrue);
      });
    });

    group('dispose', () {
      test('marks service as not initialized', () async {
        await service.initialize();

        service.dispose();

        expect(service.isInitialized, isFalse);
        expect(service.isEnabled, isFalse);
      });
    });

    group('clearLogs', () {
      setUp(() async {
        await service.initialize();
      });

      test('clears logged events and screens', () async {
        await service.logEvent(const HomeScreenView(activeTab: 'play'));
        await service.setCurrentScreen(screenName: 'home');

        service.clearLogs();

        expect(service.loggedEvents, isEmpty);
        expect(service.loggedScreens, isEmpty);
      });

      test('does not clear user properties', () async {
        await service.setUserProperty(name: 'prop', value: 'value');

        service.clearLogs();

        expect(service.userProperties, isNotEmpty);
      });
    });
  });

  group('NoOpAnalyticsService', () {
    late NoOpAnalyticsService service;

    setUp(() {
      service = NoOpAnalyticsService();
    });

    tearDown(() {
      service.dispose();
    });

    test('starts disabled', () {
      expect(service.isEnabled, isFalse);
    });

    test('becomes enabled after initialize', () async {
      await service.initialize();

      expect(service.isEnabled, isTrue);
    });

    test('logEvent does nothing', () async {
      await service.initialize();

      // Should not throw
      await service.logEvent(const HomeScreenView(activeTab: 'play'));
    });

    test('setCurrentScreen does nothing', () async {
      await service.initialize();

      // Should not throw
      await service.setCurrentScreen(screenName: 'home');
    });

    test('setUserProperty does nothing', () async {
      await service.initialize();

      // Should not throw
      await service.setUserProperty(name: 'prop', value: 'value');
    });

    test('setUserId does nothing', () async {
      await service.initialize();

      // Should not throw
      await service.setUserId('user-123');
    });

    test('resetAnalyticsData does nothing', () async {
      await service.initialize();

      // Should not throw
      await service.resetAnalyticsData();
    });

    test('dispose disables service', () async {
      await service.initialize();

      service.dispose();

      expect(service.isEnabled, isFalse);
    });
  });

  group('AnalyticsUserProperties', () {
    test('constants are defined', () {
      expect(AnalyticsUserProperties.totalQuizzesTaken, isNotEmpty);
      expect(AnalyticsUserProperties.totalCorrectAnswers, isNotEmpty);
      expect(AnalyticsUserProperties.averageScore, isNotEmpty);
      expect(AnalyticsUserProperties.bestStreak, isNotEmpty);
      expect(AnalyticsUserProperties.achievementsUnlocked, isNotEmpty);
      expect(AnalyticsUserProperties.totalPoints, isNotEmpty);
      expect(AnalyticsUserProperties.favoriteCategory, isNotEmpty);
      expect(AnalyticsUserProperties.preferredQuizMode, isNotEmpty);
      expect(AnalyticsUserProperties.soundEffectsEnabled, isNotEmpty);
      expect(AnalyticsUserProperties.hapticFeedbackEnabled, isNotEmpty);
      expect(AnalyticsUserProperties.isPremiumUser, isNotEmpty);
      expect(AnalyticsUserProperties.appVersion, isNotEmpty);
      expect(AnalyticsUserProperties.firstOpenDate, isNotEmpty);
      expect(AnalyticsUserProperties.daysActive, isNotEmpty);
    });
  });
}
