import 'package:flags_quiz/data/flags_data_provider.dart';
import 'package:flags_quiz/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('FlagsDataProvider.createLayoutConfig', () {
    late FlagsDataProvider provider;

    setUp(() {
      provider = const FlagsDataProvider();
    });

    testWidgets('returns ImageQuestionTextAnswersLayout when category has no layoutConfig', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: null,
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });

    testWidgets('applies localized template to TextQuestionImageAnswersLayout', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: const TextQuestionImageAnswersLayout(
          questionTemplate: '{name}', // placeholder
        ),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<TextQuestionImageAnswersLayout>());
      final textImageLayout = layoutConfig! as TextQuestionImageAnswersLayout;

      // Should have localized template with {name} placeholder
      expect(textImageLayout.questionTemplate, contains('{name}'));
      // Should not be the original placeholder
      expect(textImageLayout.questionTemplate, isNot(equals('{name}')));
    });

    testWidgets('preserves image size when applying localized template', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      const customSize = LargeImageSize();
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: const TextQuestionImageAnswersLayout(
          questionTemplate: '{name}',
          imageSize: customSize,
        ),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<TextQuestionImageAnswersLayout>());
      final textImageLayout = layoutConfig! as TextQuestionImageAnswersLayout;
      expect(textImageLayout.imageSize, isA<LargeImageSize>());
    });

    testWidgets('applies localized template to MixedLayout text-image layouts', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: MixedLayout(
          layouts: [
            QuizLayoutConfig.imageQuestionTextAnswers(),
            const TextQuestionImageAnswersLayout(questionTemplate: '{name}'),
          ],
        ),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<MixedLayout>());
      final mixedLayout = layoutConfig! as MixedLayout;

      // First layout should remain unchanged
      expect(mixedLayout.layouts[0], isA<ImageQuestionTextAnswersLayout>());

      // Second layout should have localized template
      expect(mixedLayout.layouts[1], isA<TextQuestionImageAnswersLayout>());
      final textImageLayout = mixedLayout.layouts[1] as TextQuestionImageAnswersLayout;
      expect(textImageLayout.questionTemplate, contains('{name}'));
      expect(textImageLayout.questionTemplate, isNot(equals('{name}')));
    });

    testWidgets('returns ImageQuestionTextAnswersLayout as-is', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: const ImageQuestionTextAnswersLayout(),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });

    testWidgets('returns TextQuestionTextAnswersLayout as-is', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: const TextQuestionTextAnswersLayout(),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<TextQuestionTextAnswersLayout>());
    });

    testWidgets('returns AudioQuestionTextAnswersLayout as-is', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: const AudioQuestionTextAnswersLayout(),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<AudioQuestionTextAnswersLayout>());
    });

    testWidgets('preserves MixedLayout strategy', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
        layoutConfig: MixedLayout(
          layouts: [
            QuizLayoutConfig.imageQuestionTextAnswers(),
            const TextQuestionImageAnswersLayout(questionTemplate: '{name}'),
          ],
          strategy: const AlternatingStrategy(startIndex: 1),
        ),
      );

      final layoutConfig = provider.createLayoutConfig(context, category);

      expect(layoutConfig, isA<MixedLayout>());
      final mixedLayout = layoutConfig! as MixedLayout;
      expect(mixedLayout.strategy, isA<AlternatingStrategy>());
      final strategy = mixedLayout.strategy as AlternatingStrategy;
      expect(strategy.startIndex, equals(1));
    });
  });

  group('FlagsDataProvider.createQuizConfig', () {
    late FlagsDataProvider provider;

    setUp(() {
      provider = const FlagsDataProvider();
    });

    testWidgets('returns valid QuizConfig', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test',
        showAnswerFeedback: true,
      );

      final config = provider.createQuizConfig(context, category);

      expect(config, isNotNull);
      expect(config!.quizId, equals('test'));
    });

    testWidgets('uses category showAnswerFeedback in mode config', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));

      final categoryWithFeedback = QuizCategory(
        id: 'test1',
        title: (_) => 'Test',
        showAnswerFeedback: true,
      );

      final categoryWithoutFeedback = QuizCategory(
        id: 'test2',
        title: (_) => 'Test',
        showAnswerFeedback: false,
      );

      final configWithFeedback = provider.createQuizConfig(context, categoryWithFeedback);
      final configWithoutFeedback = provider.createQuizConfig(context, categoryWithoutFeedback);

      expect(configWithFeedback!.modeConfig.showAnswerFeedback, isTrue);
      expect(configWithoutFeedback!.modeConfig.showAnswerFeedback, isFalse);
    });
  });

  group('FlagsDataProvider.createStorageConfig', () {
    late FlagsDataProvider provider;

    setUp(() {
      provider = const FlagsDataProvider();
    });

    testWidgets('returns enabled storage config', (tester) async {
      await tester.pumpWidget(_buildTestApp());

      final context = tester.element(find.byType(Container));
      final category = QuizCategory(
        id: 'test',
        title: (_) => 'Test Category',
        showAnswerFeedback: true,
      );

      final config = provider.createStorageConfig(context, category);

      expect(config, isNotNull);
      expect(config!.enabled, isTrue);
      expect(config.quizType, equals('flags'));
      expect(config.quizCategory, equals('test'));
    });
  });
}

Widget _buildTestApp() {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('en'),
    home: Scaffold(body: Container()),
  );
}
