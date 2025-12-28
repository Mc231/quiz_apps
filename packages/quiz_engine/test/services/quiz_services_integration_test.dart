
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:shared_services/shared_services.dart';

import 'quiz_services_test_helper.dart';

/// Integration tests for the QuizServices dependency injection system.
///
/// These tests verify that the complete DI flow works correctly:
/// - QuizServicesProvider provides services to the widget tree
/// - Context extensions allow access to services
/// - QuizServicesScope enables scoped overrides
/// - Services are properly propagated through the widget tree
void main() {
  group('QuizServices Integration', () {
    group('Basic Service Access', () {
      testWidgets('widgets can access all services via context', (tester) async {
        final settingsService = MockSettingsService();
        final storageService = MockStorageService();
        final achievementService = MockAchievementService();
        final analyticsService = MockAnalyticsService();
        final quizAnalyticsService = MockQuizAnalyticsService();

        late QuizServices accessedServices;

        await tester.pumpWidget(
          wrapWithQuizServices(
            settingsService: settingsService,
            storageService: storageService,
            achievementService: achievementService,
            screenAnalyticsService: analyticsService,
            quizAnalyticsService: quizAnalyticsService,
            child: Builder(
              builder: (context) {
                accessedServices = context.services;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(accessedServices.settingsService, same(settingsService));
        expect(accessedServices.storageService, same(storageService));
        expect(accessedServices.achievementService, same(achievementService));
        expect(accessedServices.screenAnalyticsService, same(analyticsService));
        expect(accessedServices.quizAnalyticsService, same(quizAnalyticsService));
      });

      testWidgets('individual service extensions work correctly', (tester) async {
        final settingsService = MockSettingsService();
        final analyticsService = MockAnalyticsService();

        late SettingsService accessedSettings;
        late AnalyticsService accessedAnalytics;

        await tester.pumpWidget(
          wrapWithQuizServices(
            settingsService: settingsService,
            screenAnalyticsService: analyticsService,
            child: Builder(
              builder: (context) {
                accessedSettings = context.settingsService;
                accessedAnalytics = context.screenAnalyticsService;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(accessedSettings, same(settingsService));
        expect(accessedAnalytics, same(analyticsService));
      });

      testWidgets('maybeServices returns null when not in tree', (tester) async {
        QuizServices? accessedServices;

        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                accessedServices = context.maybeServices;
                return const SizedBox();
              },
            ),
          ),
        );

        expect(accessedServices, isNull);
      });
    });

    group('QuizServicesScope', () {
      testWidgets('overrides specific services in subtree', (tester) async {
        final parentAnalytics = MockAnalyticsService();
        final childAnalytics = MockAnalyticsService();
        final parentSettings = MockSettingsService();

        late AnalyticsService parentAccessedAnalytics;
        late AnalyticsService childAccessedAnalytics;
        late SettingsService childAccessedSettings;

        await tester.pumpWidget(
          wrapWithQuizServices(
            screenAnalyticsService: parentAnalytics,
            settingsService: parentSettings,
            child: Column(
              children: [
                // Parent level - should get parent analytics
                Builder(
                  builder: (context) {
                    parentAccessedAnalytics = context.screenAnalyticsService;
                    return const SizedBox();
                  },
                ),
                // Child level with scoped override
                QuizServicesScope(
                  screenAnalyticsService: childAnalytics,
                  child: Builder(
                    builder: (context) {
                      childAccessedAnalytics = context.screenAnalyticsService;
                      childAccessedSettings = context.settingsService;
                      return const SizedBox();
                    },
                  ),
                ),
              ],
            ),
          ),
        );

        // Parent gets parent service
        expect(parentAccessedAnalytics, same(parentAnalytics));

        // Child gets overridden service
        expect(childAccessedAnalytics, same(childAnalytics));

        // Child inherits non-overridden services from parent
        expect(childAccessedSettings, same(parentSettings));
      });

      testWidgets('nested scopes work correctly', (tester) async {
        final rootAnalytics = MockAnalyticsService();
        final level1Analytics = MockAnalyticsService();
        final level2Analytics = MockAnalyticsService();

        late AnalyticsService level1Accessed;
        late AnalyticsService level2Accessed;

        await tester.pumpWidget(
          wrapWithQuizServices(
            screenAnalyticsService: rootAnalytics,
            child: QuizServicesScope(
              screenAnalyticsService: level1Analytics,
              child: Column(
                children: [
                  Builder(
                    builder: (context) {
                      level1Accessed = context.screenAnalyticsService;
                      return const SizedBox();
                    },
                  ),
                  QuizServicesScope(
                    screenAnalyticsService: level2Analytics,
                    child: Builder(
                      builder: (context) {
                        level2Accessed = context.screenAnalyticsService;
                        return const SizedBox();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

        expect(level1Accessed, same(level1Analytics));
        expect(level2Accessed, same(level2Analytics));
      });
    });

    group('Service Usage in Widgets', () {
      testWidgets('StatelessWidget can use services in build', (tester) async {
        final analyticsService = MockAnalyticsService();
        await analyticsService.initialize();

        await tester.pumpWidget(
          wrapWithQuizServices(
            screenAnalyticsService: analyticsService,
            child: _TestStatelessWidget(
              onBuild: (context) {
                final analytics = context.screenAnalyticsService;
                analytics.logEvent(
                  InteractionEvent.tabSelected(
                    tabId: 'test_tab',
                    tabName: 'test',
                    tabIndex: 0,
                  ),
                );
              },
            ),
          ),
        );

        expect(analyticsService.loggedEvents, isNotEmpty);
        expect(analyticsService.loggedEvents.first.eventName, 'tab_selected');
      });

      testWidgets('StatefulWidget can use services in didChangeDependencies', (tester) async {
        final settingsService = MockSettingsService();
        var didChangeDependenciesCalled = false;

        await tester.pumpWidget(
          wrapWithQuizServices(
            settingsService: settingsService,
            child: _TestStatefulWidget(
              onDidChangeDependencies: (context) {
                // Access settings in didChangeDependencies
                final settings = context.settingsService;
                expect(settings, same(settingsService));
                didChangeDependenciesCalled = true;
              },
            ),
          ),
        );

        expect(didChangeDependenciesCalled, isTrue);
      });
    });

    group('QuizServices.copyWith', () {
      test('creates copy with specified overrides', () {
        final originalSettings = MockSettingsService();
        final originalStorage = MockStorageService();
        final newSettings = MockSettingsService();

        final original = QuizServices(
          settingsService: originalSettings,
          storageService: originalStorage,
          achievementService: MockAchievementService(),
          screenAnalyticsService: MockAnalyticsService(),
          quizAnalyticsService: MockQuizAnalyticsService(),
          resourceManager: ResourceManager(
            config: ResourceConfig.standard(),
            repository: InMemoryResourceRepository(),
          ),
        );

        final copied = original.copyWith(settingsService: newSettings);

        expect(copied.settingsService, same(newSettings));
        expect(copied.storageService, same(originalStorage));
      });
    });

    group('QuizServices.noOp factory', () {
      test('creates services with NoOp analytics', () {
        final services = QuizServices.noOp(
          settingsService: MockSettingsService(),
          storageService: MockStorageService(),
          achievementService: MockAchievementService(),
          resourceManager: ResourceManager(
            config: ResourceConfig.standard(),
            repository: InMemoryResourceRepository(),
          ),
        );

        expect(services.screenAnalyticsService, isA<NoOpAnalyticsService>());
        // NoOpQuizAnalyticsService is defined in quiz_engine_core
        expect(services.quizAnalyticsService, isA<QuizAnalyticsService>());
      });
    });

    group('Test Helper Functions', () {
      testWidgets('wrapWithQuizServices provides default mocks', (tester) async {
        late QuizServices services;

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

        // All services should be non-null mocks
        expect(services.settingsService, isNotNull);
        expect(services.storageService, isNotNull);
        expect(services.achievementService, isNotNull);
        expect(services.screenAnalyticsService, isNotNull);
        expect(services.quizAnalyticsService, isNotNull);
      });

      test('createMockQuizServices provides all mock services', () {
        final services = createMockQuizServices();

        expect(services.settingsService, isA<MockSettingsService>());
        expect(services.storageService, isA<MockStorageService>());
        expect(services.achievementService, isA<MockAchievementService>());
        expect(services.screenAnalyticsService, isA<MockAnalyticsService>());
        expect(services.quizAnalyticsService, isA<MockQuizAnalyticsService>());
      });
    });
  });
}

/// Test widget for StatelessWidget service access.
class _TestStatelessWidget extends StatelessWidget {
  const _TestStatelessWidget({required this.onBuild});

  final void Function(BuildContext context) onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild(context);
    return const SizedBox();
  }
}

/// Test widget for StatefulWidget service access.
class _TestStatefulWidget extends StatefulWidget {
  const _TestStatefulWidget({required this.onDidChangeDependencies});

  final void Function(BuildContext context) onDidChangeDependencies;

  @override
  State<_TestStatefulWidget> createState() => _TestStatefulWidgetState();
}

class _TestStatefulWidgetState extends State<_TestStatefulWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.onDidChangeDependencies(context);
  }

  @override
  Widget build(BuildContext context) {
    return const SizedBox();
  }
}
