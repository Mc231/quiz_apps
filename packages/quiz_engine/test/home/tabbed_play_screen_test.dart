import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

import '../test_helpers.dart';

void main() {
  late List<QuizCategory> europeCategories;
  late List<QuizCategory> asiaCategories;

  setUp(() {
    europeCategories = [
      QuizCategory(
        id: 'france',
        title: (_) => 'France',
        icon: Icons.flag,
      ),
      QuizCategory(
        id: 'germany',
        title: (_) => 'Germany',
        icon: Icons.flag,
      ),
    ];

    asiaCategories = [
      QuizCategory(
        id: 'japan',
        title: (_) => 'Japan',
        icon: Icons.flag,
      ),
      QuizCategory(
        id: 'china',
        title: (_) => 'China',
        icon: Icons.flag,
      ),
    ];
  });

  group('PlayScreenTab', () {
    test('creates CategoriesTab with factory constructor', () {
      final tab = PlayScreenTab.categories(
        id: 'europe',
        label: 'Europe',
        icon: Icons.public,
        categories: europeCategories,
      );

      expect(tab, isA<CategoriesTab>());
      expect(tab.id, 'europe');
      expect(tab.label, 'Europe');
      expect(tab.icon, Icons.public);
      expect((tab as CategoriesTab).categories, europeCategories);
    });

    test('creates PracticeTab with factory constructor', () {
      final tab = PlayScreenTab.practice(
        id: 'practice',
        label: 'Practice',
        icon: Icons.replay,
        onLoadWrongAnswers: () async => [],
      );

      expect(tab, isA<PracticeTab>());
      expect(tab.id, 'practice');
      expect(tab.label, 'Practice');
      expect(tab.icon, Icons.replay);
    });

    test('creates CustomContentTab with factory constructor', () {
      final tab = PlayScreenTab.custom(
        id: 'custom',
        label: 'Custom',
        icon: Icons.star,
        builder: (context) => const Text('Custom Content'),
      );

      expect(tab, isA<CustomContentTab>());
      expect(tab.id, 'custom');
      expect(tab.label, 'Custom');
      expect(tab.icon, Icons.star);
    });

    test('CategoriesTab has default category icon', () {
      final tab = CategoriesTab(
        id: 'test',
        label: 'Test',
        categories: [],
      );

      expect(tab.icon, Icons.category);
    });

    test('PracticeTab has default replay icon', () {
      final tab = PracticeTab(
        id: 'test',
        label: 'Test',
        onLoadWrongAnswers: () async => [],
      );

      expect(tab.icon, Icons.replay);
    });
  });

  group('TabbedPlayScreen', () {
    testWidgets('displays tabs with labels', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
              PlayScreenTab.categories(
                id: 'asia',
                label: 'Asia',
                categories: asiaCategories,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);
    });

    testWidgets('displays tab icons when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                icon: Icons.public,
                categories: europeCategories,
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.public), findsOneWidget);
    });

    testWidgets('shows first tab content by default', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
              PlayScreenTab.categories(
                id: 'asia',
                label: 'Asia',
                categories: asiaCategories,
              ),
            ],
          ),
        ),
      );

      // First tab categories should be visible
      expect(find.text('France'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
    });

    testWidgets('shows specified initial tab', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
              PlayScreenTab.categories(
                id: 'asia',
                label: 'Asia',
                categories: asiaCategories,
              ),
            ],
            initialTabId: 'asia',
          ),
        ),
      );

      // Asia tab categories should be visible
      expect(find.text('Japan'), findsOneWidget);
      expect(find.text('China'), findsOneWidget);
    });

    testWidgets('can swipe between tabs', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
              PlayScreenTab.categories(
                id: 'asia',
                label: 'Asia',
                categories: asiaCategories,
              ),
            ],
          ),
        ),
      );

      // Initially Europe is visible
      expect(find.text('France'), findsOneWidget);

      // Swipe left to go to Asia tab
      await tester.fling(
        find.byType(TabBarView),
        const Offset(-300, 0),
        1000,
      );
      await tester.pumpAndSettle();

      // Asia categories should now be visible
      expect(find.text('Japan'), findsOneWidget);
    });

    testWidgets('can tap tabs to switch', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
              PlayScreenTab.categories(
                id: 'asia',
                label: 'Asia',
                categories: asiaCategories,
              ),
            ],
          ),
        ),
      );

      // Initially Europe is visible
      expect(find.text('France'), findsOneWidget);

      // Tap Asia tab
      await tester.tap(find.text('Asia'));
      await tester.pumpAndSettle();

      // Asia categories should now be visible
      expect(find.text('Japan'), findsOneWidget);
    });

    testWidgets('calls onCategorySelected when category is tapped',
        (tester) async {
      QuizCategory? selectedCategory;

      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
            ],
            onCategorySelected: (category) {
              selectedCategory = category;
            },
          ),
        ),
      );

      await tester.tap(find.text('France'));
      await tester.pump();

      expect(selectedCategory, isNotNull);
      expect(selectedCategory!.id, 'france');
    });

    testWidgets('calls onTabChanged when tab changes', (tester) async {
      PlayScreenTab? changedTab;

      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
              PlayScreenTab.categories(
                id: 'asia',
                label: 'Asia',
                categories: asiaCategories,
              ),
            ],
            onTabChanged: (tab) {
              changedTab = tab;
            },
          ),
        ),
      );

      await tester.tap(find.text('Asia'));
      await tester.pumpAndSettle();

      expect(changedTab, isNotNull);
      expect(changedTab!.id, 'asia');
    });

    testWidgets('shows CustomTab content', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.custom(
                id: 'custom',
                label: 'Custom',
                builder: (context) => const Center(
                  child: Text('Custom Content Here'),
                ),
              ),
            ],
          ),
        ),
      );

      expect(find.text('Custom Content Here'), findsOneWidget);
    });

    testWidgets('shows empty state for empty categories', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'empty',
                label: 'Empty',
                categories: [],
              ),
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    });

    testWidgets('shows settings button when configured', (tester) async {
      var settingsPressed = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
            ],
            onSettingsPressed: () {
              settingsPressed = true;
            },
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pump();

      expect(settingsPressed, isTrue);
    });

    testWidgets('hides app bar when configured', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.categories(
                id: 'europe',
                label: 'Europe',
                categories: europeCategories,
              ),
            ],
            config: const TabbedPlayScreenConfig(showAppBar: false),
          ),
        ),
      );

      expect(find.byType(AppBar), findsNothing);
    });
  });

  group('TabbedPlayScreen PracticeTab', () {
    testWidgets('shows practice categories after loading', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.practice(
                id: 'practice',
                label: 'Practice',
                onLoadWrongAnswers: () async => europeCategories,
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('France'), findsOneWidget);
      expect(find.text('Germany'), findsOneWidget);
    });

    testWidgets('shows empty state when no practice items', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.practice(
                id: 'practice',
                label: 'Practice',
                onLoadWrongAnswers: () async => [],
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_outline), findsOneWidget);
    });

    testWidgets('shows custom empty state when provided', (tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          TabbedPlayScreen(
            tabs: [
              PlayScreenTab.practice(
                id: 'practice',
                label: 'Practice',
                onLoadWrongAnswers: () async => [],
                emptyStateWidget: const Text('Custom Empty'),
              ),
            ],
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Custom Empty'), findsOneWidget);
    });
  });

  group('TabbedPlayScreenConfig', () {
    test('has sensible defaults', () {
      const config = TabbedPlayScreenConfig();

      expect(config.showAppBar, isTrue);
      expect(config.showSettingsAction, isTrue);
      expect(config.tabBarIndicatorWeight, 2.0);
      expect(config.tabBarIsScrollable, isFalse);
    });

    test('can customize tab bar appearance', () {
      const config = TabbedPlayScreenConfig(
        tabBarIndicatorColor: Colors.red,
        tabBarLabelColor: Colors.blue,
        tabBarUnselectedLabelColor: Colors.grey,
        tabBarIndicatorWeight: 4.0,
        tabBarIsScrollable: true,
      );

      expect(config.tabBarIndicatorColor, Colors.red);
      expect(config.tabBarLabelColor, Colors.blue);
      expect(config.tabBarUnselectedLabelColor, Colors.grey);
      expect(config.tabBarIndicatorWeight, 4.0);
      expect(config.tabBarIsScrollable, isTrue);
    });
  });
}
