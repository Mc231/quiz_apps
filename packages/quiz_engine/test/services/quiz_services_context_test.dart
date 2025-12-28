import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'quiz_services_test_helper.dart';

void main() {
  group('QuizServicesContext extension', () {
    testWidgets('services getter returns QuizServices', (tester) async {
      final expectedServices = createMockQuizServices();
      QuizServices? retrievedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: expectedServices,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedServices = context.services;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedServices, equals(expectedServices));
    });

    testWidgets('services getter throws when no provider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(
                () => context.services,
                throwsA(isA<FlutterError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('maybeServices getter returns services when present',
        (tester) async {
      final expectedServices = createMockQuizServices();
      QuizServices? retrievedServices;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: expectedServices,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedServices = context.maybeServices;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedServices, equals(expectedServices));
    });

    testWidgets('maybeServices getter returns null when no provider',
        (tester) async {
      QuizServices? retrievedServices;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              retrievedServices = context.maybeServices;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(retrievedServices, isNull);
    });

    testWidgets('settingsService getter returns SettingsService',
        (tester) async {
      final mockSettings = MockSettingsService();
      final services = createMockQuizServices(settingsService: mockSettings);
      SettingsService? retrievedService;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedService = context.settingsService;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedService, equals(mockSettings));
    });

    testWidgets('storageService getter returns StorageService',
        (tester) async {
      final mockStorage = MockStorageService();
      final services = createMockQuizServices(storageService: mockStorage);
      StorageService? retrievedService;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedService = context.storageService;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedService, equals(mockStorage));
    });

    testWidgets('achievementService getter returns AchievementService',
        (tester) async {
      final mockAchievements = MockAchievementService();
      final services =
          createMockQuizServices(achievementService: mockAchievements);
      AchievementService? retrievedService;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedService = context.achievementService;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedService, equals(mockAchievements));
    });

    testWidgets('screenAnalyticsService getter returns AnalyticsService',
        (tester) async {
      final mockAnalytics = MockAnalyticsService();
      final services =
          createMockQuizServices(screenAnalyticsService: mockAnalytics);
      AnalyticsService? retrievedService;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedService = context.screenAnalyticsService;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedService, equals(mockAnalytics));
    });

    testWidgets('quizAnalyticsService getter returns QuizAnalyticsService',
        (tester) async {
      final mockQuizAnalytics = MockQuizAnalyticsService();
      final services =
          createMockQuizServices(quizAnalyticsService: mockQuizAnalytics);
      QuizAnalyticsService? retrievedService;

      await tester.pumpWidget(
        QuizServicesProvider(
          services: services,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                retrievedService = context.quizAnalyticsService;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(retrievedService, equals(mockQuizAnalytics));
    });

    testWidgets('all service getters throw when no provider', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              expect(() => context.settingsService, throwsA(isA<FlutterError>()));
              expect(() => context.storageService, throwsA(isA<FlutterError>()));
              expect(
                () => context.achievementService,
                throwsA(isA<FlutterError>()),
              );
              expect(
                () => context.screenAnalyticsService,
                throwsA(isA<FlutterError>()),
              );
              expect(
                () => context.quizAnalyticsService,
                throwsA(isA<FlutterError>()),
              );
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });

  group('wrapWithQuizServices helper', () {
    testWidgets('provides default mock services', (tester) async {
      QuizServices? services;

      await tester.pumpWidget(
        wrapWithQuizServices(
          child: Builder(
            builder: (context) {
              services = context.services;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(services, isNotNull);
      expect(services!.settingsService, isA<MockSettingsService>());
      expect(services!.storageService, isA<MockStorageService>());
      expect(services!.achievementService, isA<MockAchievementService>());
    });

    testWidgets('allows custom service overrides', (tester) async {
      final customSettings = MockSettingsService();
      QuizServices? services;

      await tester.pumpWidget(
        wrapWithQuizServices(
          settingsService: customSettings,
          child: Builder(
            builder: (context) {
              services = context.services;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(services!.settingsService, equals(customSettings));
    });

    testWidgets('allows providing complete QuizServices', (tester) async {
      final customServices = createMockQuizServices();
      QuizServices? services;

      await tester.pumpWidget(
        wrapWithQuizServices(
          services: customServices,
          child: Builder(
            builder: (context) {
              services = context.services;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(services, equals(customServices));
    });

    testWidgets('wraps with MaterialApp and Scaffold', (tester) async {
      await tester.pumpWidget(
        wrapWithQuizServices(
          child: const Text('Test'),
        ),
      );

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('applies custom theme', (tester) async {
      final customTheme = ThemeData.dark();

      await tester.pumpWidget(
        wrapWithQuizServices(
          theme: customTheme,
          child: Builder(
            builder: (context) {
              expect(Theme.of(context).brightness, equals(Brightness.dark));
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('includes QuizLocalizationsDelegate by default',
        (tester) async {
      await tester.pumpWidget(
        wrapWithQuizServices(
          child: Builder(
            builder: (context) {
              // This should not throw if localizations are properly set up
              // QuizL10n.of() returns non-null when delegate is present
              try {
                QuizL10n.of(context);
                // If we get here, localizations are set up
              } catch (e) {
                fail('Localizations should be available');
              }
              return const SizedBox();
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
    });
  });
}
