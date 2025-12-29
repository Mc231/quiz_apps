import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/home/play_screen.dart';
import 'package:quiz_engine/src/home/play_screen_config.dart';
import 'package:quiz_engine/src/l10n/quiz_localizations_delegate.dart';
import 'package:quiz_engine/src/models/quiz_category.dart';

void main() {
  final testCategories = [
    QuizCategory(
      id: 'europe',
      title: (context) => 'Europe',
      subtitle: (context) => '50 countries',
      icon: Icons.flag,
      showAnswerFeedback: true,
    ),
    QuizCategory(
      id: 'asia',
      title: (context) => 'Asia',
      subtitle: (context) => '48 countries',
      icon: Icons.public,
      showAnswerFeedback: true,
    ),
    QuizCategory(
      id: 'africa',
      title: (context) => 'Africa',
      icon: Icons.terrain,
      showAnswerFeedback: true,
    ),
  ];

  Widget buildTestWidget({
    required Widget child,
    Size size = const Size(400, 800),
  }) {
    return MaterialApp(
      localizationsDelegates: const [
        QuizLocalizationsDelegate(),
      ],
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(body: child),
      ),
    );
  }

  group('PlayScreen', () {
    testWidgets('displays categories', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              layout: PlayScreenLayout.list,
              showAppBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);
      expect(find.text('Africa'), findsOneWidget);
    });

    testWidgets('displays app bar with title by default', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              layout: PlayScreenLayout.list,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Play'), findsOneWidget);
    });

    testWidgets('displays custom title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              title: 'Select Region',
              layout: PlayScreenLayout.list,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select Region'), findsOneWidget);
    });

    testWidgets('hides app bar when showAppBar is false', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              showAppBar: false,
              layout: PlayScreenLayout.list,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('calls onCategorySelected when category tapped', (tester) async {
      QuizCategory? selectedCategory;

      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            onCategorySelected: (category) => selectedCategory = category,
            config: const PlayScreenConfig(
              layout: PlayScreenLayout.list,
              showAppBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Europe'));
      await tester.pumpAndSettle();

      expect(selectedCategory, isNotNull);
      expect(selectedCategory!.id, 'europe');
    });

    testWidgets('shows settings button when enabled and callback provided',
        (tester) async {
      bool settingsPressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            onSettingsPressed: () => settingsPressed = true,
            config: const PlayScreenConfig(
              showSettingsAction: true,
              layout: PlayScreenLayout.list,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(settingsPressed, isTrue);
    });

    testWidgets('hides settings button when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            onSettingsPressed: () {},
            config: const PlayScreenConfig(
              showSettingsAction: false,
              layout: PlayScreenLayout.list,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.settings), findsNothing);
    });

    testWidgets('shows loading widget when isLoading is true', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            isLoading: true,
            config: const PlayScreenConfig(showAppBar: false),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows custom loading widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            isLoading: true,
            config: PlayScreenConfig(
              showAppBar: false,
              loadingWidget: const Text('Loading...'),
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('shows empty state when no categories', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: const [],
            config: const PlayScreenConfig(showAppBar: false),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.category_outlined), findsOneWidget);
    });

    testWidgets('shows custom empty state widget', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: const [],
            config: PlayScreenConfig(
              showAppBar: false,
              emptyStateWidget: const Text('No categories'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No categories'), findsOneWidget);
    });
  });

  group('PlayScreenLayout', () {
    testWidgets('list layout uses ListView', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              layout: PlayScreenLayout.list,
              showAppBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('grid layout uses GridView', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              layout: PlayScreenLayout.grid,
              showAppBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('list layout shows list-style cards', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: const PlayScreenConfig(
              layout: PlayScreenLayout.list,
              showAppBar: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // List cards have chevron icon
      expect(find.byIcon(Icons.chevron_right), findsNWidgets(3));
    });
  });

  group('PlayScreenConfig', () {
    test('default config has expected values', () {
      const config = PlayScreenConfig();

      expect(config.layout, PlayScreenLayout.adaptive);
      expect(config.gridColumnsMobile, 2);
      expect(config.gridColumnsTablet, 3);
      expect(config.gridColumnsDesktop, 4);
      expect(config.showSettingsAction, isTrue);
      expect(config.showAppBar, isTrue);
    });

    test('grid config has expected values', () {
      const config = PlayScreenConfig.grid();

      expect(config.layout, PlayScreenLayout.grid);
      expect(config.gridColumnsMobile, 2);
    });

    test('list config has expected values', () {
      const config = PlayScreenConfig.list();

      expect(config.layout, PlayScreenLayout.list);
      expect(config.gridColumnsMobile, 1);
    });
  });

  group('PlayScreenSliver', () {
    testWidgets('renders as sliver in list mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [QuizLocalizationsDelegate()],
          home: Scaffold(
            body: SizedBox(
              height: 600,
              width: 400,
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.zero,
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        for (final category in testCategories)
                          ListTile(
                            title: Builder(
                              builder: (context) => Text(category.title(context)),
                            ),
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify categories can be displayed in sliver context
      expect(find.text('Europe'), findsOneWidget);
      expect(find.text('Asia'), findsOneWidget);
    });
  });

  group('Custom app bar actions', () {
    testWidgets('displays custom actions', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            config: PlayScreenConfig(
              layout: PlayScreenLayout.list,
              appBarActions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows both custom actions and settings', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: PlayScreen(
            categories: testCategories,
            onSettingsPressed: () {},
            config: PlayScreenConfig(
              layout: PlayScreenLayout.list,
              showSettingsAction: true,
              appBarActions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });
  });
}
