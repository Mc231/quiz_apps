import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// A mock analytics service that captures all events for testing.
class MockAnalyticsService implements AnalyticsService {
  final List<AnalyticsEvent> loggedEvents = [];
  final List<String> screenViews = [];
  final Map<String, String?> userProperties = {};
  String? userId;
  bool _isEnabled = true;

  @override
  bool get isEnabled => _isEnabled;

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
    screenViews.add(screenName);
  }

  @override
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    userProperties[name] = value;
  }

  @override
  Future<void> setUserId(String? userId) async {
    this.userId = userId;
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
    _isEnabled = enabled;
  }

  @override
  void dispose() {}

  /// Gets events by type.
  List<T> getEventsOfType<T extends AnalyticsEvent>() {
    return loggedEvents.whereType<T>().toList();
  }

  /// Gets the last event of a specific type.
  T? getLastEventOfType<T extends AnalyticsEvent>() {
    final events = getEventsOfType<T>();
    return events.isNotEmpty ? events.last : null;
  }
}

void main() {
  group('Analytics Integration Tests', () {
    late MockAnalyticsService analytics;

    setUp(() {
      analytics = MockAnalyticsService();
    });

    group('Quiz Lifecycle Analytics', () {
      test('complete quiz lifecycle logs all expected events', () async {
        // 1. Quiz started
        await analytics.logEvent(QuizEvent.started(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          categoryName: 'Europe',
          mode: 'standard',
          totalQuestions: 10,
        ));

        // 2. Question displayed
        await analytics.logEvent(QuestionEvent.displayed(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          totalQuestions: 10,
          questionType: 'image',
          optionCount: 4,
        ));

        // 3. Answer submitted (correct)
        await analytics.logEvent(QuestionEvent.answered(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          isCorrect: true,
          responseTime: const Duration(seconds: 3),
          selectedAnswer: 'France',
          correctAnswer: 'France',
        ));

        await analytics.logEvent(QuestionEvent.correct(
          quizId: 'quiz-123',
          questionId: 'q1',
          questionIndex: 0,
          responseTime: const Duration(seconds: 3),
          currentStreak: 1,
          pointsEarned: 100,
        ));

        // 4. Quiz completed
        await analytics.logEvent(QuizEvent.completed(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          totalQuestions: 10,
          correctAnswers: 10,
          incorrectAnswers: 0,
          skippedQuestions: 0,
          scorePercentage: 100.0,
          duration: const Duration(minutes: 5),
          hintsUsed: 0,
          isPerfectScore: true,
          starRating: 3,
        ));

        // Verify all events were logged
        expect(analytics.loggedEvents.length, equals(5));
        expect(analytics.getEventsOfType<QuizStartedEvent>().length, equals(1));
        expect(
          analytics.getEventsOfType<QuestionDisplayedEvent>().length,
          equals(1),
        );
        expect(
          analytics.getEventsOfType<QuestionAnsweredEvent>().length,
          equals(1),
        );
        expect(
          analytics.getEventsOfType<QuestionCorrectEvent>().length,
          equals(1),
        );
        expect(
          analytics.getEventsOfType<QuizCompletedEvent>().length,
          equals(1),
        );

        // Verify event details
        final completedEvent = analytics.getLastEventOfType<QuizCompletedEvent>();
        expect(completedEvent?.isPerfectScore, isTrue);
        expect(completedEvent?.starRating, equals(3));
      });

      test('quiz cancellation logs correct events', () async {
        await analytics.logEvent(QuizEvent.started(
          quizId: 'quiz-456',
          quizName: 'World Capitals',
          categoryId: 'world',
          categoryName: 'World',
          mode: 'timed',
          totalQuestions: 20,
          timeLimit: 300,
        ));

        // Simulate user cancelling quiz
        await analytics.logEvent(InteractionEvent.exitDialogShown(
          quizId: 'quiz-456',
          questionsAnswered: 5,
          totalQuestions: 20,
        ));

        await analytics.logEvent(InteractionEvent.exitDialogConfirmed(
          quizId: 'quiz-456',
          questionsAnswered: 5,
          totalQuestions: 20,
          timeSpent: const Duration(minutes: 2),
        ));

        await analytics.logEvent(QuizEvent.cancelled(
          quizId: 'quiz-456',
          quizName: 'World Capitals',
          categoryId: 'world',
          mode: 'timed',
          questionsAnswered: 5,
          totalQuestions: 20,
          timeSpent: const Duration(minutes: 2),
        ));

        expect(analytics.loggedEvents.length, equals(4));
        expect(
          analytics.getEventsOfType<QuizCancelledEvent>().length,
          equals(1),
        );

        final cancelledEvent = analytics.getLastEventOfType<QuizCancelledEvent>();
        expect(cancelledEvent?.parameters['completion_percentage'], equals('25.0'));
      });

      test('quiz failure due to lives depleted logs correct events', () async {
        await analytics.logEvent(QuizEvent.started(
          quizId: 'quiz-789',
          quizName: 'Asian Flags',
          categoryId: 'asia',
          categoryName: 'Asia',
          mode: 'lives',
          totalQuestions: 30,
          initialLives: 3,
        ));

        // Simulate losing lives
        for (int i = 0; i < 3; i++) {
          await analytics.logEvent(ResourceEvent.lifeLost(
            quizId: 'quiz-789',
            questionId: 'q${i + 1}',
            questionIndex: i,
            livesRemaining: 2 - i,
            livesTotal: 3,
            reason: 'incorrect_answer',
          ));
        }

        await analytics.logEvent(ResourceEvent.livesDepleted(
          quizId: 'quiz-789',
          quizName: 'Asian Flags',
          categoryId: 'asia',
          questionsAnswered: 3,
          totalQuestions: 30,
          correctAnswers: 0,
          scorePercentage: 0.0,
          duration: const Duration(minutes: 1),
        ));

        await analytics.logEvent(QuizEvent.failed(
          quizId: 'quiz-789',
          quizName: 'Asian Flags',
          categoryId: 'asia',
          mode: 'lives',
          questionsAnswered: 3,
          totalQuestions: 30,
          correctAnswers: 0,
          scorePercentage: 0.0,
          duration: const Duration(minutes: 1),
          reason: 'lives_depleted',
        ));

        expect(analytics.getEventsOfType<LifeLostEvent>().length, equals(3));
        expect(
          analytics.getEventsOfType<LivesDepletedEvent>().length,
          equals(1),
        );
        expect(analytics.getEventsOfType<QuizFailedEvent>().length, equals(1));
      });
    });

    group('Screen Tracking Integration', () {
      test('tracks screen views in correct order', () async {
        // Simulate navigation flow
        await analytics.setCurrentScreen(
          screenName: 'home',
          screenClass: 'HomeScreen',
        );
        await analytics.logEvent(ScreenViewEvent.home(activeTab: 'play'));

        await analytics.setCurrentScreen(
          screenName: 'play',
          screenClass: 'PlayScreen',
        );
        await analytics.logEvent(ScreenViewEvent.play(categoryCount: 6));

        await analytics.setCurrentScreen(
          screenName: 'quiz',
          screenClass: 'QuizScreen',
        );
        await analytics.logEvent(ScreenViewEvent.quiz(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          mode: 'standard',
          totalQuestions: 20,
        ));

        await analytics.setCurrentScreen(
          screenName: 'results',
          screenClass: 'QuizResultsScreen',
        );
        await analytics.logEvent(ScreenViewEvent.results(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          scorePercentage: 85.0,
          isPerfectScore: false,
          starRating: 2,
        ));

        expect(analytics.screenViews.length, equals(4));
        expect(
          analytics.screenViews,
          equals(['home', 'play', 'quiz', 'results']),
        );
        expect(analytics.getEventsOfType<ScreenViewEvent>().length, equals(4));
      });

      test('tracks all standard screen types', () async {
        final screenEvents = <ScreenViewEvent>[
          ScreenViewEvent.home(activeTab: 'play'),
          ScreenViewEvent.play(categoryCount: 5),
          ScreenViewEvent.playTabbed(tabId: 'continents', tabName: 'Continents'),
          ScreenViewEvent.history(sessionCount: 10),
          ScreenViewEvent.statistics(totalSessions: 50, averageScore: 75.5),
          ScreenViewEvent.achievements(
            unlockedCount: 5,
            totalCount: 20,
            totalPoints: 500,
          ),
          ScreenViewEvent.settings(),
          ScreenViewEvent.quiz(
            quizId: 'q1',
            quizName: 'Test',
            mode: 'standard',
            totalQuestions: 10,
          ),
          ScreenViewEvent.results(
            quizId: 'q1',
            quizName: 'Test',
            scorePercentage: 80,
            isPerfectScore: false,
            starRating: 2,
          ),
          ScreenViewEvent.sessionDetail(
            sessionId: 's1',
            quizName: 'Test',
            scorePercentage: 80,
            daysAgo: 1,
          ),
          ScreenViewEvent.categoryStatistics(
            categoryId: 'cat1',
            categoryName: 'Category',
            totalSessions: 10,
            averageScore: 85,
          ),
          ScreenViewEvent.challenges(challengeCount: 5, completedCount: 2),
          ScreenViewEvent.practice(
            categoryId: 'cat1',
            categoryName: 'Category',
          ),
          ScreenViewEvent.leaderboard(
            leaderboardType: 'global',
            entryCount: 100,
          ),
          ScreenViewEvent.about(appVersion: '1.0.0', buildNumber: '1'),
          ScreenViewEvent.licenses(),
          ScreenViewEvent.tutorial(stepIndex: 0, totalSteps: 5),
          ScreenViewEvent.custom(
            name: 'continent_selection',
            className: 'ContinentSelectionScreen',
            additionalParams: {'continentCount': 7},
          ),
        ];

        for (final event in screenEvents) {
          await analytics.logEvent(event);
        }

        expect(analytics.loggedEvents.length, equals(18));

        // Verify all events have required properties
        for (final event in analytics.loggedEvents) {
          expect(event.eventName, equals('screen_view'));
          expect(event.parameters, isA<Map<String, dynamic>>());
          // Screen events like settings() and licenses() have empty parameters
          // which is valid
        }
      });
    });

    group('Hint Usage Analytics', () {
      test('tracks hint usage correctly', () async {
        await analytics.logEvent(HintEvent.fiftyFiftyUsed(
          quizId: 'quiz-123',
          questionId: 'q5',
          questionIndex: 4,
          hintsRemaining: 2,
          eliminatedOptions: ['Germany', 'Spain'],
        ));

        await analytics.logEvent(HintEvent.skipUsed(
          quizId: 'quiz-123',
          questionId: 'q6',
          questionIndex: 5,
          hintsRemaining: 1,
          timeBeforeSkip: const Duration(seconds: 10),
        ));

        await analytics.logEvent(HintEvent.unavailableTapped(
          quizId: 'quiz-123',
          questionId: 'q7',
          questionIndex: 6,
          hintType: 'fifty_fifty',
          totalHintsUsed: 3,
        ));

        expect(analytics.getEventsOfType<HintEvent>().length, equals(3));
      });
    });

    group('Achievement Analytics', () {
      test('tracks achievement unlock flow', () async {
        await analytics.logEvent(AchievementEvent.unlocked(
          achievementId: 'first_perfect',
          achievementName: 'Perfectionist',
          achievementCategory: 'score',
          pointsAwarded: 100,
          totalPoints: 500,
          unlockedCount: 5,
          totalAchievements: 20,
          triggerQuizId: 'quiz-123',
        ));

        await analytics.logEvent(AchievementEvent.notificationShown(
          achievementId: 'first_perfect',
          achievementName: 'Perfectionist',
          pointsAwarded: 100,
          displayDuration: const Duration(seconds: 3),
        ));

        await analytics.logEvent(AchievementEvent.notificationTapped(
          achievementId: 'first_perfect',
          achievementName: 'Perfectionist',
          timeToTap: const Duration(seconds: 1),
        ));

        expect(analytics.getEventsOfType<AchievementEvent>().length, equals(3));

        final unlockedEvent =
            analytics.getLastEventOfType<AchievementUnlockedEvent>();
        expect(unlockedEvent?.parameters['unlock_percentage'], equals('25.0'));
      });
    });

    group('Settings Analytics', () {
      test('tracks settings changes', () async {
        await analytics.logEvent(SettingsEvent.soundEffectsToggled(
          enabled: false,
          source: 'settings_screen',
        ));

        await analytics.logEvent(SettingsEvent.hapticFeedbackToggled(
          enabled: true,
          source: 'settings_screen',
        ));

        await analytics.logEvent(SettingsEvent.themeChanged(
          newTheme: 'dark',
          previousTheme: 'light',
          source: 'settings_screen',
        ));

        expect(analytics.getEventsOfType<SettingsEvent>().length, equals(3));

        // Verify user properties can be set
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.soundEffectsEnabled,
          value: 'false',
        );
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.hapticFeedbackEnabled,
          value: 'true',
        );

        expect(
          analytics.userProperties[AnalyticsUserProperties.soundEffectsEnabled],
          equals('false'),
        );
        expect(
          analytics.userProperties[AnalyticsUserProperties.hapticFeedbackEnabled],
          equals('true'),
        );
      });
    });

    group('Error Analytics', () {
      test('tracks error events', () async {
        await analytics.logEvent(ErrorEvent.dataLoadFailed(
          dataType: 'quiz_data',
          errorCode: 'NETWORK_ERROR',
          errorMessage: 'Failed to connect to server',
          source: 'quiz_repository',
          retryCount: 2,
        ));

        await analytics.logEvent(ErrorEvent.retryTapped(
          errorType: 'network',
          context: 'quiz_loading',
          attemptNumber: 3,
          timeSinceError: const Duration(seconds: 5),
        ));

        expect(analytics.getEventsOfType<ErrorEvent>().length, equals(2));
      });
    });

    group('Monetization Analytics', () {
      test('tracks purchase flow', () async {
        await analytics.logEvent(MonetizationEvent.purchaseSheetOpened(
          source: 'resource_button',
          availablePacksCount: 3,
          triggeredByFeature: 'extra_lives',
        ));

        await analytics.logEvent(MonetizationEvent.packSelected(
          packId: 'lives_small',
          packName: 'Small Lives Pack',
          price: 0.99,
          currency: 'USD',
          packIndex: 0,
        ));

        await analytics.logEvent(MonetizationEvent.purchaseInitiated(
          packId: 'lives_small',
          packName: 'Small Lives Pack',
          price: 0.99,
          currency: 'USD',
          paymentMethod: 'apple_pay',
        ));

        await analytics.logEvent(MonetizationEvent.purchaseCompleted(
          packId: 'lives_small',
          packName: 'Small Lives Pack',
          price: 0.99,
          currency: 'USD',
          transactionId: 'txn-123',
          purchaseDuration: const Duration(seconds: 10),
          isFirstPurchase: true,
        ));

        expect(analytics.getEventsOfType<MonetizationEvent>().length, equals(4));
      });

      test('tracks ad watching', () async {
        await analytics.logEvent(MonetizationEvent.adWatched(
          adType: 'rewarded',
          adPlacement: 'extra_life',
          watchDuration: const Duration(seconds: 30),
          wasCompleted: true,
          rewardType: 'lives',
          rewardAmount: 1,
        ));

        final adEvent = analytics.getLastEventOfType<AdWatchedEvent>();
        expect(adEvent?.wasCompleted, isTrue);
        expect(adEvent?.rewardAmount, equals(1));
      });
    });

    group('Performance Analytics', () {
      test('tracks app lifecycle events', () async {
        await analytics.logEvent(PerformanceEvent.appLaunch(
          coldStartDuration: const Duration(milliseconds: 800),
          isFirstLaunch: false,
          launchType: 'cold',
        ));

        await analytics.logEvent(PerformanceEvent.sessionStart(
          sessionId: 'session-123',
          startTime: DateTime.now(),
          entryPoint: 'app_icon',
        ));

        await analytics.logEvent(PerformanceEvent.screenRender(
          screenName: 'home',
          renderDuration: const Duration(milliseconds: 50),
          isInitialRender: true,
          widgetCount: 100,
        ));

        await analytics.logEvent(PerformanceEvent.sessionEnd(
          sessionId: 'session-123',
          sessionDuration: const Duration(minutes: 15),
          screenViewCount: 10,
          interactionCount: 50,
          exitReason: 'user_exit',
        ));

        expect(analytics.getEventsOfType<PerformanceEvent>().length, equals(4));
      });
    });

    group('User Properties', () {
      test('sets and retrieves user properties', () async {
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.totalQuizzesTaken,
          value: '50',
        );
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.averageScore,
          value: '75.5',
        );
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.achievementsUnlocked,
          value: '10',
        );
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.favoriteCategory,
          value: 'europe',
        );
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.isPremiumUser,
          value: 'false',
        );

        expect(analytics.userProperties.length, equals(5));
        expect(
          analytics.userProperties[AnalyticsUserProperties.totalQuizzesTaken],
          equals('50'),
        );
        expect(
          analytics.userProperties[AnalyticsUserProperties.isPremiumUser],
          equals('false'),
        );
      });

      test('clears user properties on reset', () async {
        await analytics.setUserProperty(
          name: AnalyticsUserProperties.totalQuizzesTaken,
          value: '50',
        );
        await analytics.setUserId('user-123');

        await analytics.resetAnalyticsData();

        expect(analytics.userProperties.isEmpty, isTrue);
        expect(analytics.userId, isNull);
      });
    });

    group('Composite Analytics Service', () {
      test('fans out events to multiple services', () async {
        final service1 = MockAnalyticsService();
        final service2 = MockAnalyticsService();
        final composite = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(provider: service1, name: 'Service1'),
            AnalyticsProviderConfig(provider: service2, name: 'Service2'),
          ],
        );

        await composite.initialize();
        await composite.logEvent(QuizEvent.started(
          quizId: 'quiz-123',
          quizName: 'Test',
          categoryId: 'cat1',
          categoryName: 'Category',
          mode: 'standard',
          totalQuestions: 10,
        ));

        expect(service1.loggedEvents.length, equals(1));
        expect(service2.loggedEvents.length, equals(1));

        composite.dispose();
      });

      test('filters events per provider', () async {
        final allEventsService = MockAnalyticsService();
        final monetizationOnlyService = MockAnalyticsService();

        final composite = CompositeAnalyticsService(
          providers: [
            AnalyticsProviderConfig(
              provider: allEventsService,
              name: 'AllEvents',
            ),
            AnalyticsProviderConfig(
              provider: monetizationOnlyService,
              name: 'MonetizationOnly',
              eventFilter: (event) => event is MonetizationEvent,
            ),
          ],
        );

        await composite.initialize();

        // Log a quiz event (should go to allEventsService only)
        await composite.logEvent(QuizEvent.started(
          quizId: 'quiz-123',
          quizName: 'Test',
          categoryId: 'cat1',
          categoryName: 'Category',
          mode: 'standard',
          totalQuestions: 10,
        ));

        // Log a monetization event (should go to both)
        await composite.logEvent(MonetizationEvent.purchaseSheetOpened(
          source: 'test',
          availablePacksCount: 3,
        ));

        expect(allEventsService.loggedEvents.length, equals(2));
        expect(monetizationOnlyService.loggedEvents.length, equals(1));
        expect(
          monetizationOnlyService.loggedEvents.first,
          isA<PurchaseSheetOpenedEvent>(),
        );

        composite.dispose();
      });
    });

    group('Event Parameter Validation', () {
      test('all events have valid event names', () async {
        final events = <AnalyticsEvent>[
          QuizEvent.started(
            quizId: 'q1',
            quizName: 'Test',
            categoryId: 'c1',
            categoryName: 'Cat',
            mode: 'standard',
            totalQuestions: 10,
          ),
          QuestionEvent.displayed(
            quizId: 'q1',
            questionId: 'q1',
            questionIndex: 0,
            totalQuestions: 10,
            questionType: 'image',
            optionCount: 4,
          ),
          HintEvent.fiftyFiftyUsed(
            quizId: 'q1',
            questionId: 'q1',
            questionIndex: 0,
            hintsRemaining: 2,
            eliminatedOptions: ['a', 'b'],
          ),
          ResourceEvent.lifeLost(
            quizId: 'q1',
            questionId: 'q1',
            questionIndex: 0,
            livesRemaining: 2,
            livesTotal: 3,
            reason: 'incorrect',
          ),
          InteractionEvent.categorySelected(
            categoryId: 'c1',
            categoryName: 'Category',
            categoryIndex: 0,
          ),
          SettingsEvent.changed(
            settingName: 'sound',
            oldValue: 'on',
            newValue: 'off',
          ),
          AchievementEvent.unlocked(
            achievementId: 'a1',
            achievementName: 'Test',
            achievementCategory: 'score',
            pointsAwarded: 100,
            totalPoints: 100,
            unlockedCount: 1,
            totalAchievements: 10,
          ),
          MonetizationEvent.purchaseSheetOpened(
            source: 'button',
            availablePacksCount: 3,
          ),
          ErrorEvent.dataLoadFailed(
            dataType: 'quiz',
            errorCode: 'ERR',
            errorMessage: 'Error',
          ),
          PerformanceEvent.appLaunch(
            coldStartDuration: const Duration(milliseconds: 500),
            isFirstLaunch: true,
          ),
          ScreenViewEvent.home(activeTab: 'play'),
        ];

        for (final event in events) {
          expect(event.eventName, isNotEmpty);
          expect(event.eventName, isA<String>());
          // Firebase Analytics requires snake_case event names
          expect(
            event.eventName,
            matches(RegExp(r'^[a-z][a-z0-9_]*$')),
            reason: 'Event name should be snake_case: ${event.eventName}',
          );
        }
      });

      test('all parameters have valid keys', () async {
        final event = QuizEvent.completed(
          quizId: 'quiz-123',
          quizName: 'European Flags',
          categoryId: 'europe',
          mode: 'standard',
          totalQuestions: 20,
          correctAnswers: 18,
          incorrectAnswers: 2,
          skippedQuestions: 0,
          scorePercentage: 90.0,
          duration: const Duration(minutes: 5),
          hintsUsed: 1,
          isPerfectScore: false,
          starRating: 2,
        );

        for (final key in event.parameters.keys) {
          expect(key, isNotEmpty);
          expect(key, isA<String>());
          // Firebase Analytics requires snake_case parameter keys
          expect(
            key,
            matches(RegExp(r'^[a-z][a-z0-9_]*$')),
            reason: 'Parameter key should be snake_case: $key',
          );
        }
      });
    });
  });
}
