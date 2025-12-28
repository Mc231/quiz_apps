import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'quiz_services_test_helper.dart';

void main() {
  group('QuizServices', () {
    test('creates instance with all required services', () {
      final settingsService = MockSettingsService();
      final storageService = MockStorageService();
      final achievementService = MockAchievementService();
      final screenAnalyticsService = MockAnalyticsService();
      final quizAnalyticsService = MockQuizAnalyticsService();
      final resourceManager = ResourceManager(
        config: ResourceConfig.standard(),
        repository: InMemoryResourceRepository(),
      );

      final services = QuizServices(
        settingsService: settingsService,
        storageService: storageService,
        achievementService: achievementService,
        screenAnalyticsService: screenAnalyticsService,
        quizAnalyticsService: quizAnalyticsService,
        resourceManager: resourceManager,
      );

      expect(services.settingsService, equals(settingsService));
      expect(services.storageService, equals(storageService));
      expect(services.achievementService, equals(achievementService));
      expect(services.screenAnalyticsService, equals(screenAnalyticsService));
      expect(services.quizAnalyticsService, equals(quizAnalyticsService));
      expect(services.resourceManager, equals(resourceManager));
    });

    test('noOp factory creates instance with NoOp analytics services', () {
      final settingsService = MockSettingsService();
      final storageService = MockStorageService();
      final achievementService = MockAchievementService();
      final resourceManager = ResourceManager(
        config: ResourceConfig.standard(),
        repository: InMemoryResourceRepository(),
      );

      final services = QuizServices.noOp(
        settingsService: settingsService,
        storageService: storageService,
        achievementService: achievementService,
        resourceManager: resourceManager,
      );

      expect(services.settingsService, equals(settingsService));
      expect(services.storageService, equals(storageService));
      expect(services.achievementService, equals(achievementService));
      expect(services.screenAnalyticsService, isA<NoOpAnalyticsService>());
      expect(services.quizAnalyticsService, isA<NoOpQuizAnalyticsService>());
      expect(services.resourceManager, equals(resourceManager));
    });

    test('copyWith creates modified copy', () {
      final original = createMockQuizServices();
      final newSettingsService = MockSettingsService();

      final copied = original.copyWith(settingsService: newSettingsService);

      expect(copied.settingsService, equals(newSettingsService));
      expect(copied.storageService, equals(original.storageService));
      expect(copied.achievementService, equals(original.achievementService));
      expect(
        copied.screenAnalyticsService,
        equals(original.screenAnalyticsService),
      );
      expect(
        copied.quizAnalyticsService,
        equals(original.quizAnalyticsService),
      );
    });

    test('copyWith preserves all services when no overrides', () {
      final original = createMockQuizServices();
      final copied = original.copyWith();

      expect(copied, equals(original));
    });

    test('equality works correctly', () {
      final settingsService = MockSettingsService();
      final storageService = MockStorageService();
      final achievementService = MockAchievementService();
      final screenAnalyticsService = MockAnalyticsService();
      final quizAnalyticsService = MockQuizAnalyticsService();
      final resourceManager = ResourceManager(
        config: ResourceConfig.standard(),
        repository: InMemoryResourceRepository(),
      );

      final services1 = QuizServices(
        settingsService: settingsService,
        storageService: storageService,
        achievementService: achievementService,
        screenAnalyticsService: screenAnalyticsService,
        quizAnalyticsService: quizAnalyticsService,
        resourceManager: resourceManager,
      );

      final services2 = QuizServices(
        settingsService: settingsService,
        storageService: storageService,
        achievementService: achievementService,
        screenAnalyticsService: screenAnalyticsService,
        quizAnalyticsService: quizAnalyticsService,
        resourceManager: resourceManager,
      );

      expect(services1, equals(services2));
      expect(services1.hashCode, equals(services2.hashCode));
    });

    test('inequality when services differ', () {
      final services1 = createMockQuizServices();
      final services2 = createMockQuizServices();

      // Different mock instances should not be equal
      expect(services1, isNot(equals(services2)));
    });
  });

  group('QuizServicesProvider', () {
    testWidgets('provides services to descendants', (tester) async {
      final services = createMockQuizServices();
      QuizServices? retrievedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedServices = QuizServicesProvider.of(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedServices, equals(services));
    });

    testWidgets('of() throws when no provider in tree', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => QuizServicesProvider.of(context),
                throwsA(isA<FlutterError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('maybeOf() returns null when no provider', (tester) async {
      QuizServices? retrievedServices;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              retrievedServices = QuizServicesProvider.maybeOf(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedServices, isNull);
    });

    testWidgets('maybeOf() returns services when provider exists',
        (tester) async {
      final services = createMockQuizServices();
      QuizServices? retrievedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedServices = QuizServicesProvider.maybeOf(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedServices, equals(services));
    });

    testWidgets('updateShouldNotify returns true when services differ',
        (tester) async {
      final services1 = createMockQuizServices();
      final services2 = createMockQuizServices();

      final provider1 = QuizServicesProvider(
        services: services1,
        child: const SizedBox(),
      );

      final provider2 = QuizServicesProvider(
        services: services2,
        child: const SizedBox(),
      );

      final provider1Same = QuizServicesProvider(
        services: services1,
        child: const SizedBox(),
      );

      // Different services should trigger notification
      expect(provider1.updateShouldNotify(provider2), isTrue);

      // Same services should not trigger notification
      expect(provider1.updateShouldNotify(provider1Same), isFalse);
    });
  });

  group('QuizServicesScope', () {
    testWidgets('overrides specific services', (tester) async {
      final parentServices = createMockQuizServices();
      final overrideSettingsService = MockSettingsService();
      QuizServices? scopedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: parentServices,
          child: MaterialApp(
            home: QuizServicesScope(
              settingsService: overrideSettingsService,
              child: Builder(
                builder: (context) {
                  scopedServices = QuizServicesProvider.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(scopedServices!.settingsService, equals(overrideSettingsService));
      expect(
        scopedServices!.storageService,
        equals(parentServices.storageService),
      );
      expect(
        scopedServices!.achievementService,
        equals(parentServices.achievementService),
      );
    });

    testWidgets('inherits non-overridden services from parent',
        (tester) async {
      final parentServices = createMockQuizServices();
      final overrideStorageService = MockStorageService();
      QuizServices? scopedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: parentServices,
          child: MaterialApp(
            home: QuizServicesScope(
              storageService: overrideStorageService,
              child: Builder(
                builder: (context) {
                  scopedServices = QuizServicesProvider.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(
        scopedServices!.settingsService,
        equals(parentServices.settingsService),
      );
      expect(scopedServices!.storageService, equals(overrideStorageService));
      expect(
        scopedServices!.achievementService,
        equals(parentServices.achievementService),
      );
      expect(
        scopedServices!.screenAnalyticsService,
        equals(parentServices.screenAnalyticsService),
      );
      expect(
        scopedServices!.quizAnalyticsService,
        equals(parentServices.quizAnalyticsService),
      );
    });

    testWidgets('throws when no parent provider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizServicesScope(
            settingsService: MockSettingsService(),
            child: const SizedBox(),
          ),
        ),
      );

      expect(tester.takeException(), isA<FlutterError>());
    });

    testWidgets('allows multiple overrides', (tester) async {
      final parentServices = createMockQuizServices();
      final overrideSettings = MockSettingsService();
      final overrideStorage = MockStorageService();
      final overrideAchievements = MockAchievementService();
      QuizServices? scopedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: parentServices,
          child: MaterialApp(
            home: QuizServicesScope(
              settingsService: overrideSettings,
              storageService: overrideStorage,
              achievementService: overrideAchievements,
              child: Builder(
                builder: (context) {
                  scopedServices = QuizServicesProvider.of(context);
                  return const SizedBox();
                },
              ),
            ),
          ),
        ),
      );

      expect(scopedServices!.settingsService, equals(overrideSettings));
      expect(scopedServices!.storageService, equals(overrideStorage));
      expect(scopedServices!.achievementService, equals(overrideAchievements));
      expect(
        scopedServices!.screenAnalyticsService,
        equals(parentServices.screenAnalyticsService),
      );
    });

    testWidgets('can be nested for deeper overrides', (tester) async {
      final parentServices = createMockQuizServices();
      final firstOverride = MockSettingsService();
      final secondOverride = MockStorageService();
      QuizServices? innerServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: parentServices,
          child: MaterialApp(
            home: QuizServicesScope(
              settingsService: firstOverride,
              child: QuizServicesScope(
                storageService: secondOverride,
                child: Builder(
                  builder: (context) {
                    innerServices = QuizServicesProvider.of(context);
                    return const SizedBox();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      // Inner scope should have both overrides
      expect(innerServices!.settingsService, equals(firstOverride));
      expect(innerServices!.storageService, equals(secondOverride));
    });
  });
}
