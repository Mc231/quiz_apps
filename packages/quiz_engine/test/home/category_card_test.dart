import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/home/category_card.dart';
import 'package:quiz_engine/src/models/quiz_category.dart';

void main() {
  final testCategory = QuizCategory(
    id: 'test',
    title: (context) => 'Test Category',
    subtitle: (context) => 'Test Subtitle',
    icon: Icons.quiz,
    answerFeedbackConfig: const AlwaysFeedbackConfig(),
  );

  final categoryWithImage = QuizCategory(
    id: 'image',
    title: (context) => 'Image Category',
    imageProvider: const AssetImage('assets/test.png'),
    answerFeedbackConfig: const AlwaysFeedbackConfig(),
  );

  final categoryNoSubtitle = QuizCategory(
    id: 'no_subtitle',
    title: (context) => 'No Subtitle',
    icon: Icons.category,
    answerFeedbackConfig: const AlwaysFeedbackConfig(),
  );

  Widget buildTestWidget({
    required Widget child,
  }) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('CategoryCard', () {
    testWidgets('displays title', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: testCategory),
        ),
      );

      expect(find.text('Test Category'), findsOneWidget);
    });

    testWidgets('displays subtitle when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: testCategory),
        ),
      );

      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('does not display subtitle when not provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: categoryNoSubtitle),
        ),
      );

      expect(find.text('No Subtitle'), findsOneWidget);
      // No subtitle text should be found
      expect(find.byType(Text), findsOneWidget);
    });

    testWidgets('displays icon when provided', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: testCategory),
        ),
      );

      expect(find.byIcon(Icons.quiz), findsOneWidget);
    });

    testWidgets('displays default icon when no icon or image', (tester) async {
      final category = QuizCategory(
        id: 'default',
        title: (context) => 'Default',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: category),
        ),
      );

      expect(find.byIcon(Icons.quiz), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(
            category: testCategory,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.byType(CategoryCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('calls onLongPress when long-pressed', (tester) async {
      bool longPressed = false;

      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(
            category: testCategory,
            onLongPress: () => longPressed = true,
          ),
        ),
      );

      await tester.longPress(find.byType(CategoryCard));
      await tester.pumpAndSettle();

      expect(longPressed, isTrue);
    });

    testWidgets('does not throw when onTap is null', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: testCategory),
        ),
      );

      await tester.tap(find.byType(CategoryCard));
      await tester.pumpAndSettle();
      // No exception should be thrown
    });
  });

  group('CategoryCard.grid', () {
    testWidgets('uses vertical layout', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard.grid(category: testCategory),
        ),
      );

      // In vertical layout, Column is used
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('applies grid style', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard.grid(category: testCategory),
        ),
      );

      // Card should be present
      expect(find.byType(Card), findsOneWidget);
    });
  });

  group('CategoryCard.list', () {
    testWidgets('uses horizontal layout', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard.list(category: testCategory),
        ),
      );

      // In horizontal layout, Row is used
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('shows chevron icon in list mode', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard.list(category: testCategory),
        ),
      );

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });
  });

  group('CategoryCardStyle', () {
    test('default constructor creates valid style', () {
      const style = CategoryCardStyle();

      expect(style.elevation, 2);
      expect(style.iconSize, 48);
      expect(style.imageSize, 64);
      expect(style.spacing, 12);
      expect(style.showBorder, isFalse);
    });

    test('grid constructor creates valid style', () {
      const style = CategoryCardStyle.grid();

      expect(style.iconSize, 40);
      expect(style.imageSize, 56);
      expect(style.spacing, 8);
    });

    test('list constructor creates valid style', () {
      const style = CategoryCardStyle.list();

      expect(style.elevation, 1);
      expect(style.iconSize, 32);
      expect(style.imageSize, 48);
      expect(style.spacing, 16);
    });

    test('copyWith creates modified copy', () {
      const original = CategoryCardStyle();
      final modified = original.copyWith(
        elevation: 4,
        iconSize: 64,
        showBorder: true,
      );

      expect(modified.elevation, 4);
      expect(modified.iconSize, 64);
      expect(modified.showBorder, isTrue);
      // Unchanged values
      expect(modified.imageSize, original.imageSize);
      expect(modified.spacing, original.spacing);
    });

    testWidgets('custom style is applied', (tester) async {
      const customStyle = CategoryCardStyle(
        elevation: 8,
        showBorder: true,
        borderWidth: 2,
      );

      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(
            category: testCategory,
            style: customStyle,
          ),
        ),
      );

      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 8);
    });
  });

  group('Image handling', () {
    testWidgets('shows image when imageProvider is set', (tester) async {
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: categoryWithImage),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('falls back to icon on image error', (tester) async {
      // Image will fail to load in tests, triggering errorBuilder
      await tester.pumpWidget(
        buildTestWidget(
          child: CategoryCard(category: categoryWithImage),
        ),
      );

      // Pump a few frames to trigger error handling
      await tester.pump();
      await tester.pump();

      // Should find the fallback icon
      expect(find.byType(Icon), findsWidgets);
    });
  });
}
