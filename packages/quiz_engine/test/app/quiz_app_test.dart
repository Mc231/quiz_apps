import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:shared_services/shared_services.dart' show AppThemeMode;

import '../services/quiz_services_test_helper.dart';

/// Test categories for the quiz app.
final List<QuizCategory> testCategories = [
  QuizCategory(
    id: 'category1',
    title: (_) => 'Test Category 1',
    icon: Icons.star,
    answerFeedbackConfig: const AlwaysFeedbackConfig(),
  ),
  QuizCategory(
    id: 'category2',
    title: (_) => 'Test Category 2',
    icon: Icons.circle,
    answerFeedbackConfig: const AlwaysFeedbackConfig(),
  ),
];

void main() {
  late MockSettingsService settingsService;

  setUp(() {
    settingsService = MockSettingsService();
  });

  tearDown(() {
    settingsService.dispose();
  });

  group('QuizApp', () {
    testWidgets('renders MaterialApp with QuizHomeScreen', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
        ),
      );
      await tester.pumpAndSettle();

      // Should render MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);

      // Should render home content with categories
      expect(find.text('Test Category 1'), findsOneWidget);
      expect(find.text('Test Category 2'), findsOneWidget);
    });

    testWidgets('hides debug banner when configured', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: const QuizAppConfig(debugShowCheckedModeBanner: false),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('shows debug banner when configured', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: const QuizAppConfig(debugShowCheckedModeBanner: true),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, isTrue);
    });

    testWidgets('applies title from config', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: const QuizAppConfig(title: 'My Quiz App'),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.title, 'My Quiz App');
    });

    testWidgets('uses custom home builder when provided', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          homeBuilder:
              (context) =>
                  const Scaffold(body: Center(child: Text('Custom Home'))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom Home'), findsOneWidget);
    });

    testWidgets('responds to theme mode changes', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
        ),
      );
      await tester.pumpAndSettle();

      // Initial theme is system default
      var materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.system);

      // Change to dark mode
      await settingsService.setThemeMode(AppThemeMode.dark);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.dark);

      // Change to light mode
      await settingsService.setThemeMode(AppThemeMode.light);
      await tester.pumpAndSettle();

      materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.themeMode, ThemeMode.light);
    });

    testWidgets('includes engine localization delegate', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final delegates = materialApp.localizationsDelegates?.toList() ?? [];

      expect(delegates.any((d) => d is QuizLocalizationsDelegate), isTrue);
    });

    testWidgets('combines app and engine localization delegates', (
      tester,
    ) async {
      final customDelegate = _TestLocalizationsDelegate();

      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: QuizAppConfig(appLocalizationDelegates: [customDelegate]),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final delegates = materialApp.localizationsDelegates?.toList() ?? [];

      // Should have both engine and app delegates
      expect(delegates.any((d) => d is QuizLocalizationsDelegate), isTrue);
      expect(delegates.any((d) => d is _TestLocalizationsDelegate), isTrue);
    });

    testWidgets('passes navigation observers to MaterialApp', (tester) async {
      final observer = _TestNavigatorObserver();

      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: QuizAppConfig(navigatorObservers: [observer]),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.navigatorObservers, contains(observer));
    });

    testWidgets('calls onCategorySelected callback', (tester) async {
      QuizCategory? selectedCategory;

      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          callbacks: QuizAppCallbacks(
            onCategorySelected: (category) => selectedCategory = category,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on a category
      await tester.tap(find.text('Test Category 1'));
      await tester.pumpAndSettle();

      expect(selectedCategory?.id, 'category1');
    });

    testWidgets('applies custom light theme', (tester) async {
      final customTheme = ThemeData(
        primaryColor: Colors.purple,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
      );

      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: QuizAppConfig(lightTheme: customTheme),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.theme, customTheme);
    });

    testWidgets('applies custom dark theme', (tester) async {
      // Set dark mode first
      await settingsService.setThemeMode(AppThemeMode.dark);

      final customDarkTheme = ThemeData.dark().copyWith(
        primaryColor: Colors.teal,
      );

      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          config: QuizAppConfig(darkTheme: customDarkTheme),
        ),
      );
      await tester.pumpAndSettle();

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.darkTheme, customDarkTheme);
    });
  });

  group('QuizAppConfig', () {
    test('has sensible defaults', () {
      const config = QuizAppConfig();

      expect(config.title, isNull);
      expect(config.debugShowCheckedModeBanner, isFalse);
      expect(config.useMaterial3, isTrue);
      expect(config.appLocalizationDelegates, isEmpty);
      expect(config.supportedLocales, [const Locale('en')]);
      expect(config.navigatorObservers, isEmpty);
    });

    test('copyWith creates modified copy', () {
      const original = QuizAppConfig();
      final modified = original.copyWith(
        title: 'New Title',
        debugShowCheckedModeBanner: true,
        useMaterial3: false,
      );

      expect(modified.title, 'New Title');
      expect(modified.debugShowCheckedModeBanner, isTrue);
      expect(modified.useMaterial3, isFalse);
      // Unchanged values
      expect(modified.supportedLocales, [const Locale('en')]);
    });
  });

  group('QuizAppCallbacks', () {
    test('can be created with all callbacks', () {
      final callbacks = QuizAppCallbacks(
        onCategorySelected: (_) {},
        onSettingsPressed: () {},
        onSessionTap: (_) {},
        onViewAllSessions: () {},
      );

      expect(callbacks.onCategorySelected, isNotNull);
      expect(callbacks.onSettingsPressed, isNotNull);
      expect(callbacks.onSessionTap, isNotNull);
      expect(callbacks.onViewAllSessions, isNotNull);
    });

    test('default callbacks are null', () {
      const callbacks = QuizAppCallbacks();

      expect(callbacks.onCategorySelected, isNull);
      expect(callbacks.onSettingsPressed, isNull);
      expect(callbacks.onSessionTap, isNull);
      expect(callbacks.onViewAllSessions, isNull);
    });
  });

  group('QuizAppBuilder', () {
    testWidgets('shows loading widget while initializing', (tester) async {
      final completer = Completer<QuizServices>();

      await tester.pumpWidget(
        QuizAppBuilder(
          initializeServices: () => completer.future,
          builder:
              (context, services) => QuizApp(
                services: services,
                categories: testCategories,
              ),
          loadingWidget: const MaterialApp(
            home: Scaffold(body: Text('Loading...')),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Loading...'), findsOneWidget);

      // Complete initialization
      completer.complete(createMockQuizServices(settingsService: settingsService));
      await tester.pumpAndSettle();

      expect(find.text('Loading...'), findsNothing);
      expect(find.text('Test Category 1'), findsOneWidget);
    });

    testWidgets('shows default loading indicator', (tester) async {
      final completer = Completer<QuizServices>();

      await tester.pumpWidget(
        QuizAppBuilder(
          initializeServices: () => completer.future,
          builder:
              (context, services) => QuizApp(
                services: services,
                categories: testCategories,
              ),
        ),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete initialization
      completer.complete(createMockQuizServices(settingsService: settingsService));
      await tester.pumpAndSettle();
    });

    testWidgets('shows error widget on initialization failure', (tester) async {
      await tester.pumpWidget(
        QuizAppBuilder(
          initializeServices: () => Future.error('Init failed'),
          builder:
              (context, services) => QuizApp(
                services: services,
                categories: testCategories,
              ),
          errorBuilder:
              (context, error) =>
                  MaterialApp(home: Scaffold(body: Text('Error: $error'))),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Error: Init failed'), findsOneWidget);
    });

    testWidgets('shows default error message on failure', (tester) async {
      await tester.pumpWidget(
        QuizAppBuilder(
          initializeServices: () => Future.error('Test error'),
          builder:
              (context, services) => QuizApp(
                services: services,
                categories: testCategories,
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Initialization error'), findsOneWidget);
    });

    testWidgets('builds QuizApp after successful initialization', (
      tester,
    ) async {
      await tester.pumpWidget(
        QuizAppBuilder(
          initializeServices: () async {
            final mockSettingsService = MockSettingsService();
            await mockSettingsService.initialize();
            return createMockQuizServices(settingsService: mockSettingsService);
          },
          builder:
              (context, services) => QuizApp(
                services: services,
                categories: testCategories,
              ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Test Category 1'), findsOneWidget);
      expect(find.text('Test Category 2'), findsOneWidget);
    });
  });

  group('QuizApp with tabs', () {
    testWidgets('shows Play tab by default', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          homeConfig: QuizHomeScreenConfig(
            tabConfig: QuizTabConfig.defaultConfig(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Play tab content should be visible
      expect(find.text('Test Category 1'), findsOneWidget);
    });

    testWidgets('uses all tabs configuration', (tester) async {
      await tester.pumpWidget(
        QuizApp(
          services: createMockQuizServices(settingsService: settingsService),
          categories: testCategories,
          homeConfig: QuizHomeScreenConfig(tabConfig: QuizTabConfig.allTabs()),
          settingsConfig: const QuizSettingsConfig(showDataExport: false),
        ),
      );
      await tester.pumpAndSettle();

      // Should have 4 navigation destinations
      final navBar = find.byType(NavigationBar);
      expect(navBar, findsOneWidget);

      final destinations = find.byType(NavigationDestination);
      expect(destinations, findsNWidgets(4));
    });
  });
}

/// Test localization delegate for testing.
class _TestLocalizationsDelegate
    extends LocalizationsDelegate<_TestLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<_TestLocalizations> load(Locale locale) async {
    return _TestLocalizations();
  }

  @override
  bool shouldReload(_TestLocalizationsDelegate old) => false;
}

class _TestLocalizations {}

/// Test navigator observer for testing.
class _TestNavigatorObserver extends NavigatorObserver {
  final pushes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushes.add(route);
  }
}
