import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_services/shared_services.dart';

/// Mock implementation of InAppReview for testing.
class MockInAppReview implements InAppReview {
  bool _isAvailable = true;
  bool requestReviewCalled = false;
  bool openStoreListingCalled = false;
  bool shouldThrow = false;

  void setAvailable(bool available) => _isAvailable = available;

  @override
  Future<bool> isAvailable() async => _isAvailable;

  @override
  Future<void> requestReview() async {
    if (shouldThrow) throw Exception('Review error');
    requestReviewCalled = true;
  }

  @override
  Future<void> openStoreListing({
    String? appStoreId,
    String? microsoftStoreId,
  }) async {
    openStoreListingCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockInAppReview mockReview;
  late RateAppService service;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    mockReview = MockInAppReview();
    service = RateAppService(
      config: const RateAppConfig.test(),
      inAppReview: mockReview,
    );
    await service.initialize();
  });

  group('RateAppService', () {
    group('initialization', () {
      test('initializes with fresh state on first launch', () async {
        expect(service.isInitialized, isTrue);
        expect(service.state.hasRated, isFalse);
        expect(service.state.declineCount, 0);
        expect(service.state.promptCount, 0);
        expect(service.state.firstLaunchDate, isNotNull);
      });

      test('loads existing state from SharedPreferences', () async {
        // Record a prompt
        await service.recordPromptShown();
        expect(service.state.promptCount, 1);

        // Create a new service instance
        final newService = RateAppService(
          config: const RateAppConfig.test(),
          inAppReview: mockReview,
        );
        await newService.initialize();

        expect(newService.state.promptCount, 1);
      });

      test('does not reinitialize if already initialized', () async {
        final firstLaunchDate = service.state.firstLaunchDate;
        await service.initialize();
        expect(service.state.firstLaunchDate, equals(firstLaunchDate));
      });
    });

    group('shouldShowPrompt', () {
      test('returns true when all conditions are met', () {
        final result = service.shouldShowPrompt(
          quizScore: 80,
          completedQuizzes: 5,
        );
        expect(result, isTrue);
      });

      test('returns false when disabled', () {
        final disabledService = RateAppService(
          config: const RateAppConfig.disabled(),
          inAppReview: mockReview,
        );

        final result = disabledService.shouldShowPrompt(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(result, isFalse);
      });

      test('returns false when user has already rated', () async {
        await service.recordUserRated();

        final result = service.shouldShowPrompt(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(result, isFalse);
      });

      test('returns false when max lifetime prompts reached', () async {
        final limitedService = RateAppService(
          config: const RateAppConfig(
            minCompletedQuizzes: 1,
            minDaysSinceInstall: 0,
            minScorePercentage: 0,
            cooldownDays: 0,
            maxLifetimePrompts: 2,
          ),
          inAppReview: mockReview,
        );
        await limitedService.initialize();

        // Simulate reaching max prompts
        await limitedService.recordPromptShown();
        await limitedService.recordPromptShown();

        final result = limitedService.shouldShowPrompt(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(result, isFalse);
      });

      test('returns false when max declines reached', () async {
        final limitedService = RateAppService(
          config: const RateAppConfig(
            minCompletedQuizzes: 1,
            minDaysSinceInstall: 0,
            minScorePercentage: 0,
            cooldownDays: 0,
            maxDeclines: 2,
          ),
          inAppReview: mockReview,
        );
        await limitedService.initialize();

        await limitedService.recordUserDeclined();
        await limitedService.recordUserDeclined();

        final result = limitedService.shouldShowPrompt(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(result, isFalse);
      });

      test('returns false when not enough quizzes completed', () {
        final strictService = RateAppService(
          config: const RateAppConfig(minCompletedQuizzes: 10),
          inAppReview: mockReview,
        );

        final result = strictService.shouldShowPrompt(
          quizScore: 100,
          completedQuizzes: 5,
        );
        expect(result, isFalse);
      });

      test('returns false when score is too low', () {
        final strictService = RateAppService(
          config: const RateAppConfig(
            minCompletedQuizzes: 1,
            minDaysSinceInstall: 0,
            minScorePercentage: 80,
          ),
          inAppReview: mockReview,
        );

        final result = strictService.shouldShowPrompt(
          quizScore: 70,
          completedQuizzes: 10,
        );
        expect(result, isFalse);
      });

      test('returns false during cooldown period', () async {
        await service.recordPromptShown();

        // Create a service with a long cooldown
        final cooldownService = RateAppService(
          config: const RateAppConfig(
            minCompletedQuizzes: 1,
            minDaysSinceInstall: 0,
            minScorePercentage: 0,
            cooldownDays: 30,
          ),
          inAppReview: mockReview,
        );
        await cooldownService.initialize();

        // Set state to have a recent prompt
        cooldownService.updateStateForTesting(
          RateAppState(
            firstLaunchDate: DateTime.now().subtract(const Duration(days: 100)),
            lastPromptDate: DateTime.now(),
            promptCount: 1,
          ),
        );

        final result = cooldownService.shouldShowPrompt(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(result, isFalse);
      });
    });

    group('getBlockingReason', () {
      test('returns null when all conditions are met', () {
        final reason = service.getBlockingReason(
          quizScore: 80,
          completedQuizzes: 5,
        );
        expect(reason, isNull);
      });

      test('returns reason when disabled', () {
        final disabledService = RateAppService(
          config: const RateAppConfig.disabled(),
          inAppReview: mockReview,
        );

        final reason = disabledService.getBlockingReason(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(reason, contains('disabled'));
      });

      test('returns reason when user has rated', () async {
        await service.recordUserRated();

        final reason = service.getBlockingReason(
          quizScore: 100,
          completedQuizzes: 100,
        );
        expect(reason, contains('already rated'));
      });

      test('returns reason when score is too low', () {
        final strictService = RateAppService(
          config: const RateAppConfig(
            minCompletedQuizzes: 1,
            minDaysSinceInstall: 0,
            minScorePercentage: 80,
          ),
          inAppReview: mockReview,
        );

        final reason = strictService.getBlockingReason(
          quizScore: 50,
          completedQuizzes: 100,
        );
        expect(reason, contains('Score too low'));
        expect(reason, contains('50%'));
        expect(reason, contains('80%'));
      });
    });

    group('showNativeRatingDialog', () {
      test('returns shown when review is available', () async {
        mockReview.setAvailable(true);

        final result = await service.showNativeRatingDialog();

        expect(result, isA<RateAppResultShown>());
        expect(mockReview.requestReviewCalled, isTrue);
        expect(service.state.promptCount, 1);
      });

      test('returns notAvailable when review is not available', () async {
        mockReview.setAvailable(false);

        final result = await service.showNativeRatingDialog();

        expect(result, isA<RateAppResultNotAvailable>());
        expect(mockReview.requestReviewCalled, isFalse);
      });

      test('returns error when exception occurs', () async {
        mockReview.shouldThrow = true;

        final result = await service.showNativeRatingDialog();

        expect(result, isA<RateAppResultError>());
        expect((result as RateAppResultError).error, isA<Exception>());
      });
    });

    group('state recording', () {
      test('recordPromptShown updates state correctly', () async {
        expect(service.state.promptCount, 0);
        expect(service.state.lastPromptDate, isNull);

        await service.recordPromptShown();

        expect(service.state.promptCount, 1);
        expect(service.state.lastPromptDate, isNotNull);
      });

      test('recordUserRated sets hasRated flag', () async {
        expect(service.state.hasRated, isFalse);

        await service.recordUserRated();

        expect(service.state.hasRated, isTrue);
      });

      test('recordUserDeclined increments decline count', () async {
        expect(service.state.declineCount, 0);

        await service.recordUserDeclined();
        await service.recordUserDeclined();

        expect(service.state.declineCount, 2);
      });

      test('recordUserDismissed updates lastPromptDate only', () async {
        final initialDeclineCount = service.state.declineCount;

        await service.recordUserDismissed();

        expect(service.state.declineCount, initialDeclineCount);
        expect(service.state.lastPromptDate, isNotNull);
      });

      test('recordFeedbackSubmitted increments decline count', () async {
        expect(service.state.declineCount, 0);

        await service.recordFeedbackSubmitted();

        expect(service.state.declineCount, 1);
      });
    });

    group('resetState', () {
      test('clears all state and reinitializes', () async {
        await service.recordPromptShown();
        await service.recordUserDeclined();
        await service.recordUserDeclined();

        expect(service.state.promptCount, 1);
        expect(service.state.declineCount, 2);

        await service.resetState();

        expect(service.state.promptCount, 0);
        expect(service.state.declineCount, 0);
        expect(service.state.hasRated, isFalse);
        expect(service.state.firstLaunchDate, isNotNull);
      });
    });

    group('openStoreListing', () {
      test('calls InAppReview.openStoreListing', () async {
        await service.openStoreListing(appStoreId: '123456');

        expect(mockReview.openStoreListingCalled, isTrue);
      });
    });
  });

  group('RateAppState', () {
    test('initial factory sets firstLaunchDate', () {
      final state = RateAppState.initial();

      expect(state.firstLaunchDate, isNotNull);
      expect(state.hasRated, isFalse);
      expect(state.declineCount, 0);
      expect(state.promptCount, 0);
    });

    test('daysSinceInstall returns correct value', () {
      final state = RateAppState(
        firstLaunchDate: DateTime.now().subtract(const Duration(days: 10)),
      );

      expect(state.daysSinceInstall, 10);
    });

    test('daysSinceInstall returns 0 when firstLaunchDate is null', () {
      const state = RateAppState();

      expect(state.daysSinceInstall, 0);
    });

    test('daysSinceLastPrompt returns correct value', () {
      final state = RateAppState(
        lastPromptDate: DateTime.now().subtract(const Duration(days: 5)),
      );

      expect(state.daysSinceLastPrompt, 5);
    });

    test('daysSinceLastPrompt returns null when lastPromptDate is null', () {
      const state = RateAppState();

      expect(state.daysSinceLastPrompt, isNull);
    });

    test('toJson and fromJson round-trip correctly', () {
      final original = RateAppState(
        lastPromptDate: DateTime(2024, 1, 15, 10, 30),
        hasRated: true,
        declineCount: 2,
        promptCount: 5,
        firstLaunchDate: DateTime(2024, 1, 1, 0, 0),
      );

      final json = original.toJson();
      final restored = RateAppState.fromJson(json);

      expect(restored.hasRated, original.hasRated);
      expect(restored.declineCount, original.declineCount);
      expect(restored.promptCount, original.promptCount);
      expect(restored.lastPromptDate, original.lastPromptDate);
      expect(restored.firstLaunchDate, original.firstLaunchDate);
    });

    test('fromJson handles missing fields gracefully', () {
      final state = RateAppState.fromJson({});

      expect(state.hasRated, isFalse);
      expect(state.declineCount, 0);
      expect(state.promptCount, 0);
      expect(state.lastPromptDate, isNull);
      expect(state.firstLaunchDate, isNull);
    });

    test('copyWith creates modified copy', () {
      const original = RateAppState(
        hasRated: false,
        declineCount: 1,
      );

      final modified = original.copyWith(
        hasRated: true,
        declineCount: 3,
      );

      expect(modified.hasRated, isTrue);
      expect(modified.declineCount, 3);
      expect(modified.promptCount, original.promptCount);
    });

    test('equality works correctly', () {
      final date = DateTime(2024, 1, 1);
      final state1 = RateAppState(
        hasRated: true,
        declineCount: 1,
        firstLaunchDate: date,
      );
      final state2 = RateAppState(
        hasRated: true,
        declineCount: 1,
        firstLaunchDate: date,
      );
      final state3 = RateAppState(
        hasRated: false,
        declineCount: 1,
        firstLaunchDate: date,
      );

      expect(state1, equals(state2));
      expect(state1, isNot(equals(state3)));
    });
  });

  group('RateAppResult', () {
    test('factory constructors create correct types', () {
      const shown = RateAppResult.shown();
      const notAvailable = RateAppResult.notAvailable();
      const conditionsNotMet = RateAppResult.conditionsNotMet('reason');
      final error = RateAppResult.error(Exception('test'));

      expect(shown, isA<RateAppResultShown>());
      expect(notAvailable, isA<RateAppResultNotAvailable>());
      expect(conditionsNotMet, isA<RateAppResultConditionsNotMet>());
      expect(error, isA<RateAppResultError>());
    });

    test('RateAppResultConditionsNotMet contains reason', () {
      const result = RateAppResult.conditionsNotMet('Not enough quizzes');

      expect(result, isA<RateAppResultConditionsNotMet>());
      expect((result as RateAppResultConditionsNotMet).reason,
          'Not enough quizzes');
    });

    test('RateAppResultError contains error object', () {
      final exception = Exception('test error');
      final result = RateAppResult.error(exception);

      expect(result, isA<RateAppResultError>());
      expect((result as RateAppResultError).error, exception);
    });
  });
}
