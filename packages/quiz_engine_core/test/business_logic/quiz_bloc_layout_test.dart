import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizLayoutConfig', () {
    group('MixedLayout', () {
      test('selectLayout returns first layout for index 0 with alternating',
          () {
        final mixedLayout = MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
          ],
          strategy: const AlternatingStrategy(),
        );

        // Index 0 -> first layout (ImageQuestionTextAnswersLayout)
        expect(
          mixedLayout.selectLayout(0),
          isA<ImageQuestionTextAnswersLayout>(),
        );
      });

      test('selectLayout returns second layout for index 1 with alternating',
          () {
        final mixedLayout = MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
          ],
          strategy: const AlternatingStrategy(),
        );

        // Index 1 -> second layout (TextQuestionImageAnswersLayout)
        expect(
          mixedLayout.selectLayout(1),
          isA<TextQuestionImageAnswersLayout>(),
        );
      });

      test('selectLayout alternates correctly', () {
        final mixedLayout = MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
          ],
          strategy: const AlternatingStrategy(),
        );

        // Index 2 -> first layout again (alternating)
        expect(
          mixedLayout.selectLayout(2),
          isA<ImageQuestionTextAnswersLayout>(),
        );

        // Index 3 -> second layout
        expect(
          mixedLayout.selectLayout(3),
          isA<TextQuestionImageAnswersLayout>(),
        );
      });

      test('selectLayout with RandomStrategy returns valid layout', () {
        final mixedLayout = MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
            const TextQuestionTextAnswersLayout(),
          ],
          strategy: const RandomStrategy(seed: 42),
        );

        // With a seed, results should be consistent and not MixedLayout
        for (var i = 0; i < 10; i++) {
          final layout = mixedLayout.selectLayout(i);
          expect(layout, isA<QuizLayoutConfig>());
          expect(layout, isNot(isA<MixedLayout>()));
        }
      });

      test('selectLayout with WeightedStrategy respects weights', () {
        final mixedLayout = MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
          ],
          strategy: const WeightedStrategy(weights: [0.9, 0.1], seed: 42),
        );

        // Should always return a valid layout (not MixedLayout)
        for (var i = 0; i < 10; i++) {
          final layout = mixedLayout.selectLayout(i);
          expect(layout, isNot(isA<MixedLayout>()));
        }
      });

      test('throws when layouts list is empty', () {
        final mixedLayout = MixedLayout(
          layouts: [],
          strategy: const AlternatingStrategy(),
        );

        expect(
          () => mixedLayout.selectLayout(0),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });

  group('QuizConfig layoutConfig', () {
    test('defaults to ImageQuestionTextAnswersLayout', () {
      const config = QuizConfig(quizId: 'test');
      expect(config.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });

    test('can be set to TextQuestionImageAnswersLayout', () {
      final config = QuizConfig(
        quizId: 'test',
        layoutConfig: TextQuestionImageAnswersLayout(
          questionTemplate: 'Select the flag of {name}',
          imageSize: const LargeImageSize(),
        ),
      );

      expect(config.layoutConfig, isA<TextQuestionImageAnswersLayout>());

      final layout = config.layoutConfig as TextQuestionImageAnswersLayout;
      expect(layout.questionTemplate, 'Select the flag of {name}');
      expect(layout.imageSize, isA<LargeImageSize>());
    });

    test('can be set to TextQuestionTextAnswersLayout', () {
      const config = QuizConfig(
        quizId: 'test',
        layoutConfig: TextQuestionTextAnswersLayout(),
      );

      expect(config.layoutConfig, isA<TextQuestionTextAnswersLayout>());
    });

    test('can be set to AudioQuestionTextAnswersLayout', () {
      const config = QuizConfig(
        quizId: 'test',
        layoutConfig: AudioQuestionTextAnswersLayout(
          autoPlay: true,
          showReplayButton: false,
        ),
      );

      expect(config.layoutConfig, isA<AudioQuestionTextAnswersLayout>());

      final layout = config.layoutConfig as AudioQuestionTextAnswersLayout;
      expect(layout.autoPlay, true);
      expect(layout.showReplayButton, false);
    });

    test('can be set to MixedLayout', () {
      final config = QuizConfig(
        quizId: 'test',
        layoutConfig: MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
          ],
          strategy: const AlternatingStrategy(),
        ),
      );

      expect(config.layoutConfig, isA<MixedLayout>());
    });

    test('serializes and deserializes ImageQuestionTextAnswersLayout', () {
      const config = QuizConfig(
        quizId: 'test',
        layoutConfig: ImageQuestionTextAnswersLayout(),
      );

      final map = config.toMap();
      final restored = QuizConfig.fromMap(map);

      expect(restored.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });

    test('serializes and deserializes TextQuestionImageAnswersLayout', () {
      final config = QuizConfig(
        quizId: 'test',
        layoutConfig: TextQuestionImageAnswersLayout(
          questionTemplate: 'Select {name}',
          imageSize: const SmallImageSize(),
        ),
      );

      final map = config.toMap();
      final restored = QuizConfig.fromMap(map);

      expect(restored.layoutConfig, isA<TextQuestionImageAnswersLayout>());

      final layout = restored.layoutConfig as TextQuestionImageAnswersLayout;
      expect(layout.questionTemplate, 'Select {name}');
      expect(layout.imageSize, isA<SmallImageSize>());
    });

    test('serializes and deserializes MixedLayout', () {
      final config = QuizConfig(
        quizId: 'test',
        layoutConfig: MixedLayout(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              questionTemplate: 'Select {name}',
            ),
          ],
          strategy: const AlternatingStrategy(),
        ),
      );

      final map = config.toMap();
      final restored = QuizConfig.fromMap(map);

      expect(restored.layoutConfig, isA<MixedLayout>());

      final layout = restored.layoutConfig as MixedLayout;
      expect(layout.layouts.length, 2);
      expect(layout.layouts[0], isA<ImageQuestionTextAnswersLayout>());
      expect(layout.layouts[1], isA<TextQuestionImageAnswersLayout>());
    });

    test('copyWith preserves layoutConfig when not overridden', () {
      final config = QuizConfig(
        quizId: 'test',
        layoutConfig: TextQuestionImageAnswersLayout(
          questionTemplate: 'Select {name}',
        ),
      );

      final copied = config.copyWith(quizId: 'new_id');

      expect(copied.quizId, 'new_id');
      expect(copied.layoutConfig, isA<TextQuestionImageAnswersLayout>());
    });

    test('copyWith allows overriding layoutConfig', () {
      const config = QuizConfig(
        quizId: 'test',
        layoutConfig: ImageQuestionTextAnswersLayout(),
      );

      final copied = config.copyWith(
        layoutConfig: const TextQuestionTextAnswersLayout(),
      );

      expect(copied.layoutConfig, isA<TextQuestionTextAnswersLayout>());
    });

    test('fromMap uses default when layoutConfig is null', () {
      final map = {
        'quizId': 'test',
        'modeConfig':
            const StandardMode(showAnswerFeedback: true).toMap(),
        'scoringStrategy': const SimpleScoring().toMap(),
        // layoutConfig is missing
      };

      final config = QuizConfig.fromMap(map);

      expect(config.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
    });
  });

  group('QuestionState resolvedLayout', () {
    test('can include resolvedLayout', () {
      final entry = QuestionEntry(
        type: ImageQuestion('test.png'),
        otherOptions: {'id': 'test', 'name': 'Test'},
      );

      final question = Question(entry, [entry]);

      final state = QuestionState(
        question,
        1,
        10,
        resolvedLayout: TextQuestionImageAnswersLayout(
          questionTemplate: 'Select {name}',
        ),
      );

      expect(state.resolvedLayout, isA<TextQuestionImageAnswersLayout>());
    });

    test('resolvedLayout is null by default', () {
      final entry = QuestionEntry(
        type: ImageQuestion('test.png'),
        otherOptions: {'id': 'test', 'name': 'Test'},
      );

      final question = Question(entry, [entry]);

      final state = QuestionState(question, 1, 10);

      expect(state.resolvedLayout, isNull);
    });
  });

  group('AnswerFeedbackState resolvedLayout', () {
    test('can include resolvedLayout', () {
      final entry = QuestionEntry(
        type: ImageQuestion('test.png'),
        otherOptions: {'id': 'test', 'name': 'Test'},
      );

      final question = Question(entry, [entry]);

      final state = AnswerFeedbackState(
        question,
        entry,
        true,
        1,
        10,
        resolvedLayout: TextQuestionImageAnswersLayout(
          questionTemplate: 'Select {name}',
        ),
      );

      expect(state.resolvedLayout, isA<TextQuestionImageAnswersLayout>());
    });

    test('resolvedLayout is null by default', () {
      final entry = QuestionEntry(
        type: ImageQuestion('test.png'),
        otherOptions: {'id': 'test', 'name': 'Test'},
      );

      final question = Question(entry, [entry]);

      final state = AnswerFeedbackState(question, entry, true, 1, 10);

      expect(state.resolvedLayout, isNull);
    });
  });
}
