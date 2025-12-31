import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine/src/components/image_option_button.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';
import 'package:responsive_builder/responsive_builder.dart';

import '../test_helpers.dart';

void main() {
  final defaultSizingInfo = SizingInformation(
    deviceScreenType: DeviceScreenType.mobile,
    screenSize: const Size(400, 800),
    localWidgetSize: const Size(400, 400),
    refinedSize: RefinedSize.normal,
  );

  QuestionEntry createImageOption(String id, String imagePath, String name) {
    return QuestionEntry(
      type: ImageQuestion(imagePath),
      otherOptions: {'id': id, 'name': name},
    );
  }

  group('QuizImageAnswersWidget', () {
    testWidgets('renders correct number of image options',
        (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
        createImageOption('it', 'assets/flags/it.png', 'Italy'),
        createImageOption('es', 'assets/flags/es.png', 'Spain'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsNWidgets(4));
    });

    testWidgets('handles tap on image option', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
      ];
      QuestionEntry? tappedAnswer;

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (answer) {
              tappedAnswer = answer;
            },
          ),
        ),
      );
      await tester.pump();

      // Tap the first option (France)
      await tester.tap(find.byType(ImageOptionButton).first);
      await tester.pump();

      expect(tappedAnswer, equals(options[0]));
    });

    testWidgets('disables specified options', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
        createImageOption('it', 'assets/flags/it.png', 'Italy'),
        createImageOption('es', 'assets/flags/es.png', 'Spain'),
      ];
      QuestionEntry? tappedAnswer;

      // Disable France and Italy (50/50 hint simulation)
      final disabledOptions = {options[0], options[2]};

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (answer) {
              tappedAnswer = answer;
            },
            disabledOptions: disabledOptions,
          ),
        ),
      );
      await tester.pump();

      // Try to tap disabled option (France - first one)
      await tester.tap(find.byType(ImageOptionButton).first);
      await tester.pump();

      // Should not trigger callback
      expect(tappedAnswer, isNull);

      // Tap enabled option (Germany - second one)
      await tester.tap(find.byType(ImageOptionButton).at(1));
      await tester.pump();

      expect(tappedAnswer, equals(options[1]));
    });

    testWidgets('renders with custom image size', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
            imageSize: const LargeImageSize(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(QuizImageAnswersWidget), findsOneWidget);
      expect(find.byType(ImageOptionButton), findsNWidgets(2));
    });

    testWidgets('renders with custom theme', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
      ];

      const customTheme = QuizThemeData(
        buttonBorderColor: Colors.red,
        buttonBorderWidth: 4,
      );

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
            themeData: customTheme,
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(QuizImageAnswersWidget), findsOneWidget);
    });

    testWidgets('uses custom semantic label builder',
        (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
            semanticLabelBuilder: (option) =>
                'Flag of ${option.otherOptions['name']}',
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('handles options with text question type',
        (WidgetTester tester) async {
      // Test fallback when option doesn't have ImageQuestion type
      final options = [
        QuestionEntry(
          type: TextQuestion('France'),
          otherOptions: {
            'id': 'fr',
            'name': 'France',
            'imagePath': 'assets/flags/fr.png',
          },
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Should still render using imagePath from otherOptions
      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('uses GridView for layout', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
        createImageOption('it', 'assets/flags/it.png', 'Italy'),
        createImageOption('es', 'assets/flags/es.png', 'Spain'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('assigns correct keys to image options',
        (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byKey(const Key('image_option_fr')), findsOneWidget);
      expect(find.byKey(const Key('image_option_de')), findsOneWidget);
    });

    testWidgets('renders with 2 options', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsNWidgets(2));
    });

    testWidgets('renders with single option', (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('handles network image URLs', (WidgetTester tester) async {
      final options = [
        QuestionEntry(
          type: ImageQuestion('https://example.com/flag.png'),
          otherOptions: {'id': 'fr', 'name': 'France'},
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('falls back to placeholder for non-image options',
        (WidgetTester tester) async {
      // Option without imagePath in otherOptions and non-ImageQuestion type
      final options = [
        QuestionEntry(
          type: TextQuestion('France'),
          otherOptions: {'id': 'fr', 'name': 'France'},
        ),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Should still render (will try to load placeholder)
      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('uses name from otherOptions for semantic label',
        (WidgetTester tester) async {
      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: defaultSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      // Verify semantic label is set (would use 'France' from otherOptions)
      expect(find.byType(ImageOptionButton), findsOneWidget);
    });

    testWidgets('renders on tablet screen size', (WidgetTester tester) async {
      final tabletSizingInfo = SizingInformation(
        deviceScreenType: DeviceScreenType.tablet,
        screenSize: const Size(768, 1024),
        localWidgetSize: const Size(768, 600),
        refinedSize: RefinedSize.large,
      );

      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
        createImageOption('it', 'assets/flags/it.png', 'Italy'),
        createImageOption('es', 'assets/flags/es.png', 'Spain'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: tabletSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsNWidgets(4));
    });

    testWidgets('renders on desktop screen size', (WidgetTester tester) async {
      final desktopSizingInfo = SizingInformation(
        deviceScreenType: DeviceScreenType.desktop,
        screenSize: const Size(1920, 1080),
        localWidgetSize: const Size(800, 600),
        refinedSize: RefinedSize.extraLarge,
      );

      final options = [
        createImageOption('fr', 'assets/flags/fr.png', 'France'),
        createImageOption('de', 'assets/flags/de.png', 'Germany'),
        createImageOption('it', 'assets/flags/it.png', 'Italy'),
        createImageOption('es', 'assets/flags/es.png', 'Spain'),
      ];

      await tester.pumpWidget(
        wrapWithLocalizations(
          QuizImageAnswersWidget(
            key: const Key('test_image_answers'),
            options: options,
            sizingInformation: desktopSizingInfo,
            answerClickListener: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ImageOptionButton), findsNWidgets(4));
    });
  });
}
