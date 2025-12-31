import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine/src/components/image_option_button.dart';

import '../test_helpers.dart';

void main() {
  group('ImageOptionButton', () {
    testWidgets('renders asset image', (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('handles tap callback', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ImageOptionButton));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('does not respond to tap when disabled',
        (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {
              tapped = true;
            },
            isDisabled: true,
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byType(ImageOptionButton));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('shows disabled overlay when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {},
            isDisabled: true,
          ),
        ),
      );
      await tester.pump();

      // Should find the block icon indicating disabled state
      expect(find.byIcon(Icons.block), findsOneWidget);
    });

    testWidgets('applies reduced opacity when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {},
            isDisabled: true,
          ),
        ),
      );
      await tester.pump();

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, equals(0.4));
    });

    testWidgets('applies full opacity when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {},
            isDisabled: false,
          ),
        ),
      );
      await tester.pump();

      final animatedOpacity = tester.widget<AnimatedOpacity>(
        find.byType(AnimatedOpacity),
      );
      expect(animatedOpacity.opacity, equals(1.0));
    });

    testWidgets('has Semantics widget when enabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'France',
            onTap: () {},
          ),
        ),
      );
      await tester.pump();

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('has Semantics widget when disabled',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'France',
            onTap: () {},
            isDisabled: true,
          ),
        ),
      );
      await tester.pump();

      // Verify Semantics widget exists
      expect(find.byType(Semantics), findsWidgets);
      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('applies custom theme', (WidgetTester tester) async {
      const customTheme = QuizThemeData(
        buttonBorderRadius: BorderRadius.all(Radius.circular(16)),
        buttonBorderWidth: 3,
        buttonBorderColor: Colors.blue,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {},
            themeData: customTheme,
          ),
        ),
      );
      await tester.pump();

      // Widget renders without error with custom theme
      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('applies custom border radius', (WidgetTester tester) async {
      const customBorderRadius = BorderRadius.all(Radius.circular(24));

      await tester.pumpWidget(
        wrapWithLocalizations(
          ImageOptionButton(
            imageSource: const ImageSource.asset('assets/test.png'),
            semanticLabel: 'Test image',
            onTap: () {},
            borderRadius: customBorderRadius,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('uses different image sizes', (WidgetTester tester) async {
      for (final size in [
        const SmallImageSize(),
        const MediumImageSize(),
        const LargeImageSize(),
        const CustomImageSize(maxSize: 100, spacing: 10),
      ]) {
        await tester.pumpWidget(
          wrapWithLocalizations(
            ImageOptionButton(
              imageSource: const ImageSource.asset('assets/test.png'),
              semanticLabel: 'Test image',
              onTap: () {},
              imageSize: size,
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(ImageOptionButton), findsOneWidget);
      }
    });
  });

  group('ImageSource', () {
    test('AssetImage equality', () {
      const source1 = ImageSource.asset('assets/test.png');
      const source2 = ImageSource.asset('assets/test.png');
      const source3 = ImageSource.asset('assets/other.png');

      expect(source1, equals(source2));
      expect(source1, isNot(equals(source3)));
      expect(source1.hashCode, equals(source2.hashCode));
    });

    test('NetworkImage equality', () {
      const source1 = ImageSource.network('https://example.com/test.png');
      const source2 = ImageSource.network('https://example.com/test.png');
      const source3 = ImageSource.network('https://example.com/other.png');

      expect(source1, equals(source2));
      expect(source1, isNot(equals(source3)));
      expect(source1.hashCode, equals(source2.hashCode));
    });

    test('AssetImage and NetworkImage are not equal', () {
      const asset = ImageSource.asset('test.png');
      const network = ImageSource.network('test.png');

      expect(asset, isNot(equals(network)));
    });
  });
}
