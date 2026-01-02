import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/models/quiz_category.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

// ignore_for_file: prefer_const_constructors

void main() {
  group('QuizCategory', () {
    test('creates category with required fields', () {
      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      expect(category.id, 'europe');
      expect(category.subtitle, isNull);
      expect(category.imageProvider, isNull);
      expect(category.icon, isNull);
      expect(category.config, isNull);
      expect(category.metadata, isNull);
      expect(category.layoutConfig, isNull);
    });

    test('creates category with all fields', () {
      final config = QuizConfig(quizId: 'test');
      final metadata = {'key': 'value'};
      final layoutConfig = QuizLayoutConfig.imageQuestionTextAnswers();

      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        subtitle: (context) => '50 countries',
        icon: Icons.flag,
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
        config: config,
        metadata: metadata,
        layoutConfig: layoutConfig,
      );

      expect(category.id, 'europe');
      expect(category.icon, Icons.flag);
      expect(category.config, config);
      expect(category.metadata, metadata);
      expect(category.layoutConfig, layoutConfig);
    });

    test('copyWith creates new instance with replaced fields', () {
      final original = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        icon: Icons.flag,
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      final copied = original.copyWith(
        id: 'asia',
        icon: Icons.public,
      );

      expect(copied.id, 'asia');
      expect(copied.icon, Icons.public);
      // Original unchanged
      expect(original.id, 'europe');
      expect(original.icon, Icons.flag);
    });

    test('copyWith preserves unspecified fields', () {
      final config = QuizConfig(quizId: 'test');
      final original = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        icon: Icons.flag,
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
        config: config,
      );

      final copied = original.copyWith(id: 'asia');

      expect(copied.id, 'asia');
      expect(copied.icon, Icons.flag);
      expect(copied.config, config);
    });

    test('equality is based on id', () {
      final category1 = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      final category2 = QuizCategory(
        id: 'europe',
        title: (context) => 'Different Title',
        icon: Icons.flag,
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      final category3 = QuizCategory(
        id: 'asia',
        title: (context) => 'Asia',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      expect(category1 == category2, isTrue);
      expect(category1 == category3, isFalse);
    });

    test('hashCode is based on id', () {
      final category1 = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      final category2 = QuizCategory(
        id: 'europe',
        title: (context) => 'Different',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      expect(category1.hashCode, category2.hashCode);
    });

    test('toString returns readable representation', () {
      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      expect(category.toString(), 'QuizCategory(id: europe)');
    });

    group('layoutConfig', () {
      test('creates category with imageQuestionTextAnswers layout', () {
        final layoutConfig = QuizLayoutConfig.imageQuestionTextAnswers();
        final category = QuizCategory(
          id: 'standard',
          title: (context) => 'Standard Quiz',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: layoutConfig,
        );

        expect(category.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
      });

      test('creates category with textQuestionImageAnswers layout', () {
        final layoutConfig = QuizLayoutConfig.textQuestionImageAnswers(
          questionTemplate: 'Select the flag of {name}',
        );
        final category = QuizCategory(
          id: 'reverse',
          title: (context) => 'Find the Flag',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: layoutConfig,
        );

        expect(category.layoutConfig, isA<TextQuestionImageAnswersLayout>());
        final layout = category.layoutConfig as TextQuestionImageAnswersLayout;
        expect(layout.questionTemplate, 'Select the flag of {name}');
      });

      test('creates category with textQuestionTextAnswers layout', () {
        final layoutConfig = QuizLayoutConfig.textQuestionTextAnswers();
        final category = QuizCategory(
          id: 'trivia',
          title: (context) => 'Trivia',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: layoutConfig,
        );

        expect(category.layoutConfig, isA<TextQuestionTextAnswersLayout>());
      });

      test('creates category with audioQuestionTextAnswers layout', () {
        final layoutConfig = QuizLayoutConfig.audioQuestionTextAnswers(
          autoPlay: false,
          showReplayButton: true,
        );
        final category = QuizCategory(
          id: 'audio',
          title: (context) => 'Audio Quiz',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: layoutConfig,
        );

        expect(category.layoutConfig, isA<AudioQuestionTextAnswersLayout>());
        final layout = category.layoutConfig as AudioQuestionTextAnswersLayout;
        expect(layout.autoPlay, false);
        expect(layout.showReplayButton, true);
      });

      test('creates category with mixed layout', () {
        final layoutConfig = QuizLayoutConfig.mixed(
          layouts: [
            QuizLayoutConfig.imageQuestionTextAnswers(),
            QuizLayoutConfig.textQuestionImageAnswers(),
          ],
        );
        final category = QuizCategory(
          id: 'mixed',
          title: (context) => 'Mixed Quiz',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: layoutConfig,
        );

        expect(category.layoutConfig, isA<MixedLayout>());
        final layout = category.layoutConfig as MixedLayout;
        expect(layout.layouts.length, 2);
      });

      test('copyWith updates layoutConfig', () {
        final original = QuizCategory(
          id: 'test',
          title: (context) => 'Test',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: QuizLayoutConfig.imageQuestionTextAnswers(),
        );

        final newLayout = QuizLayoutConfig.textQuestionImageAnswers();
        final copied = original.copyWith(layoutConfig: newLayout);

        expect(copied.layoutConfig, isA<TextQuestionImageAnswersLayout>());
        expect(original.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
      });

      test('copyWith preserves layoutConfig when not specified', () {
        final layoutConfig = QuizLayoutConfig.textQuestionImageAnswers(
          questionTemplate: 'Original template',
        );
        final original = QuizCategory(
          id: 'test',
          title: (context) => 'Test',
          answerFeedbackConfig: const AlwaysFeedbackConfig(),
          layoutConfig: layoutConfig,
        );

        final copied = original.copyWith(id: 'new_id');

        expect(copied.layoutConfig, layoutConfig);
        expect(copied.id, 'new_id');
      });
    });

    testWidgets('LocalizedString resolves with context', (tester) async {
      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Localized Europe',
        subtitle: (context) => '50 countries',
        answerFeedbackConfig: const AlwaysFeedbackConfig(),
      );

      String? resolvedTitle;
      String? resolvedSubtitle;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              resolvedTitle = category.title(context);
              resolvedSubtitle = category.subtitle?.call(context);
              return const SizedBox();
            },
          ),
        ),
      );

      expect(resolvedTitle, 'Localized Europe');
      expect(resolvedSubtitle, '50 countries');
    });
  });
}
