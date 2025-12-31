import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizLayoutConfig', () {
    group('ImageQuestionTextAnswersLayout', () {
      test('factory creates correct instance', () {
        final layout = QuizLayoutConfig.imageQuestionTextAnswers();

        expect(layout, isA<ImageQuestionTextAnswersLayout>());
      });

      test('toMap produces correct map', () {
        const layout = ImageQuestionTextAnswersLayout();

        final map = layout.toMap();

        expect(map['type'], equals('imageQuestionTextAnswers'));
        expect(map['version'], equals(1));
      });

      test('fromMap creates correct config', () {
        final map = {
          'type': 'imageQuestionTextAnswers',
          'version': 1,
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<ImageQuestionTextAnswersLayout>());
      });

      test('serialization roundtrip preserves data', () {
        const original = ImageQuestionTextAnswersLayout();

        final map = original.toMap();
        final restored = QuizLayoutConfig.fromMap(map);

        expect(restored, isA<ImageQuestionTextAnswersLayout>());
      });
    });

    group('TextQuestionImageAnswersLayout', () {
      test('factory creates correct instance with defaults', () {
        final layout = QuizLayoutConfig.textQuestionImageAnswers();

        expect(layout, isA<TextQuestionImageAnswersLayout>());
        final typedLayout = layout as TextQuestionImageAnswersLayout;
        expect(typedLayout.imageSize, isA<MediumImageSize>());
        expect(typedLayout.questionTemplate, isNull);
      });

      test('factory creates correct instance with parameters', () {
        final layout = QuizLayoutConfig.textQuestionImageAnswers(
          imageSize: const LargeImageSize(),
          questionTemplate: 'Select the flag of {name}',
        );

        expect(layout, isA<TextQuestionImageAnswersLayout>());
        final typedLayout = layout as TextQuestionImageAnswersLayout;
        expect(typedLayout.imageSize, isA<LargeImageSize>());
        expect(typedLayout.questionTemplate, equals('Select the flag of {name}'));
      });

      test('toMap produces correct map', () {
        const layout = TextQuestionImageAnswersLayout(
          imageSize: LargeImageSize(),
          questionTemplate: 'Select {name}',
        );

        final map = layout.toMap();

        expect(map['type'], equals('textQuestionImageAnswers'));
        expect(map['version'], equals(1));
        expect(map['imageSize'], isNotNull);
        expect(map['imageSize']['type'], equals('large'));
        expect(map['questionTemplate'], equals('Select {name}'));
      });

      test('toMap omits null questionTemplate', () {
        const layout = TextQuestionImageAnswersLayout();

        final map = layout.toMap();

        expect(map.containsKey('questionTemplate'), isFalse);
      });

      test('fromMap creates correct config', () {
        final map = {
          'type': 'textQuestionImageAnswers',
          'version': 1,
          'imageSize': {'type': 'small', 'version': 1},
          'questionTemplate': 'Which is {name}?',
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<TextQuestionImageAnswersLayout>());
        final typedLayout = layout as TextQuestionImageAnswersLayout;
        expect(typedLayout.imageSize, isA<SmallImageSize>());
        expect(typedLayout.questionTemplate, equals('Which is {name}?'));
      });

      test('fromMap handles missing optional values', () {
        final map = {
          'type': 'textQuestionImageAnswers',
          'version': 1,
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<TextQuestionImageAnswersLayout>());
        final typedLayout = layout as TextQuestionImageAnswersLayout;
        expect(typedLayout.imageSize, isA<MediumImageSize>());
        expect(typedLayout.questionTemplate, isNull);
      });

      test('copyWith creates correct copy', () {
        const original = TextQuestionImageAnswersLayout(
          imageSize: SmallImageSize(),
          questionTemplate: 'Original',
        );

        final copy = original.copyWith(
          questionTemplate: 'Updated',
        );

        expect(copy.imageSize, isA<SmallImageSize>());
        expect(copy.questionTemplate, equals('Updated'));
      });

      test('equality works correctly', () {
        const layout1 = TextQuestionImageAnswersLayout(
          imageSize: MediumImageSize(),
          questionTemplate: 'Test',
        );
        const layout2 = TextQuestionImageAnswersLayout(
          imageSize: MediumImageSize(),
          questionTemplate: 'Test',
        );
        const layout3 = TextQuestionImageAnswersLayout(
          imageSize: LargeImageSize(),
          questionTemplate: 'Test',
        );

        expect(layout1, equals(layout2));
        expect(layout1, isNot(equals(layout3)));
      });

      test('hashCode is consistent', () {
        const layout1 = TextQuestionImageAnswersLayout(
          imageSize: MediumImageSize(),
          questionTemplate: 'Test',
        );
        const layout2 = TextQuestionImageAnswersLayout(
          imageSize: MediumImageSize(),
          questionTemplate: 'Test',
        );

        expect(layout1.hashCode, equals(layout2.hashCode));
      });
    });

    group('TextQuestionTextAnswersLayout', () {
      test('factory creates correct instance', () {
        final layout = QuizLayoutConfig.textQuestionTextAnswers();

        expect(layout, isA<TextQuestionTextAnswersLayout>());
      });

      test('toMap produces correct map', () {
        const layout = TextQuestionTextAnswersLayout();

        final map = layout.toMap();

        expect(map['type'], equals('textQuestionTextAnswers'));
        expect(map['version'], equals(1));
      });

      test('fromMap creates correct config', () {
        final map = {
          'type': 'textQuestionTextAnswers',
          'version': 1,
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<TextQuestionTextAnswersLayout>());
      });
    });

    group('AudioQuestionTextAnswersLayout', () {
      test('factory creates correct instance with defaults', () {
        final layout = QuizLayoutConfig.audioQuestionTextAnswers();

        expect(layout, isA<AudioQuestionTextAnswersLayout>());
        final typedLayout = layout as AudioQuestionTextAnswersLayout;
        expect(typedLayout.autoPlay, isTrue);
        expect(typedLayout.showReplayButton, isTrue);
      });

      test('factory creates correct instance with parameters', () {
        final layout = QuizLayoutConfig.audioQuestionTextAnswers(
          autoPlay: false,
          showReplayButton: false,
        );

        expect(layout, isA<AudioQuestionTextAnswersLayout>());
        final typedLayout = layout as AudioQuestionTextAnswersLayout;
        expect(typedLayout.autoPlay, isFalse);
        expect(typedLayout.showReplayButton, isFalse);
      });

      test('toMap produces correct map', () {
        const layout = AudioQuestionTextAnswersLayout(
          autoPlay: false,
          showReplayButton: true,
        );

        final map = layout.toMap();

        expect(map['type'], equals('audioQuestionTextAnswers'));
        expect(map['version'], equals(1));
        expect(map['autoPlay'], isFalse);
        expect(map['showReplayButton'], isTrue);
      });

      test('fromMap creates correct config', () {
        final map = {
          'type': 'audioQuestionTextAnswers',
          'version': 1,
          'autoPlay': false,
          'showReplayButton': false,
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<AudioQuestionTextAnswersLayout>());
        final typedLayout = layout as AudioQuestionTextAnswersLayout;
        expect(typedLayout.autoPlay, isFalse);
        expect(typedLayout.showReplayButton, isFalse);
      });

      test('fromMap handles missing values with defaults', () {
        final map = {
          'type': 'audioQuestionTextAnswers',
          'version': 1,
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<AudioQuestionTextAnswersLayout>());
        final typedLayout = layout as AudioQuestionTextAnswersLayout;
        expect(typedLayout.autoPlay, isTrue);
        expect(typedLayout.showReplayButton, isTrue);
      });

      test('copyWith creates correct copy', () {
        const original = AudioQuestionTextAnswersLayout(
          autoPlay: true,
          showReplayButton: true,
        );

        final copy = original.copyWith(autoPlay: false);

        expect(copy.autoPlay, isFalse);
        expect(copy.showReplayButton, isTrue);
      });

      test('equality works correctly', () {
        const layout1 = AudioQuestionTextAnswersLayout(
          autoPlay: true,
          showReplayButton: false,
        );
        const layout2 = AudioQuestionTextAnswersLayout(
          autoPlay: true,
          showReplayButton: false,
        );
        const layout3 = AudioQuestionTextAnswersLayout(
          autoPlay: false,
          showReplayButton: false,
        );

        expect(layout1, equals(layout2));
        expect(layout1, isNot(equals(layout3)));
      });
    });

    group('MixedLayout', () {
      test('factory creates correct instance', () {
        final layout = QuizLayoutConfig.mixed(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            const TextQuestionTextAnswersLayout(),
          ],
        );

        expect(layout, isA<MixedLayout>());
        final typedLayout = layout as MixedLayout;
        expect(typedLayout.layouts.length, equals(2));
        expect(typedLayout.strategy, isA<AlternatingStrategy>());
      });

      test('factory creates correct instance with custom strategy', () {
        final layout = QuizLayoutConfig.mixed(
          layouts: [
            const ImageQuestionTextAnswersLayout(),
            const TextQuestionTextAnswersLayout(),
          ],
          strategy: RandomStrategy(seed: 42),
        );

        expect(layout, isA<MixedLayout>());
        final typedLayout = layout as MixedLayout;
        expect(typedLayout.strategy, isA<RandomStrategy>());
      });

      test('selectLayout returns correct layout for alternating strategy', () {
        const layout = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(),
        );

        expect(layout.selectLayout(0), isA<ImageQuestionTextAnswersLayout>());
        expect(layout.selectLayout(1), isA<TextQuestionTextAnswersLayout>());
        expect(layout.selectLayout(2), isA<ImageQuestionTextAnswersLayout>());
        expect(layout.selectLayout(3), isA<TextQuestionTextAnswersLayout>());
      });

      test('selectLayout returns consistent results for seeded random', () {
        final layout = MixedLayout(
          layouts: const [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(),
          ],
          strategy: RandomStrategy(seed: 42),
        );

        // Store results
        final results = List.generate(10, (i) => layout.selectLayout(i));

        // Re-create with same seed and verify consistent results
        final layout2 = MixedLayout(
          layouts: const [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(),
          ],
          strategy: RandomStrategy(seed: 42),
        );

        for (var i = 0; i < 10; i++) {
          expect(
            layout2.selectLayout(i).runtimeType,
            equals(results[i].runtimeType),
          );
        }
      });

      test('toMap produces correct map', () {
        const layout = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(startIndex: 1),
        );

        final map = layout.toMap();

        expect(map['type'], equals('mixed'));
        expect(map['version'], equals(1));
        expect(map['layouts'], isA<List>());
        expect((map['layouts'] as List).length, equals(2));
        expect(map['strategy']['type'], equals('alternating'));
        expect(map['strategy']['startIndex'], equals(1));
      });

      test('fromMap creates correct config', () {
        final map = {
          'type': 'mixed',
          'version': 1,
          'layouts': [
            {'type': 'imageQuestionTextAnswers', 'version': 1},
            {'type': 'textQuestionTextAnswers', 'version': 1},
          ],
          'strategy': {
            'type': 'alternating',
            'version': 1,
            'startIndex': 0,
          },
        };

        final layout = QuizLayoutConfig.fromMap(map);

        expect(layout, isA<MixedLayout>());
        final typedLayout = layout as MixedLayout;
        expect(typedLayout.layouts.length, equals(2));
        expect(typedLayout.strategy, isA<AlternatingStrategy>());
      });

      test('serialization roundtrip preserves data', () {
        final original = MixedLayout(
          layouts: const [
            ImageQuestionTextAnswersLayout(),
            TextQuestionImageAnswersLayout(
              imageSize: LargeImageSize(),
              questionTemplate: 'Test',
            ),
          ],
          strategy: RandomStrategy(seed: 123),
        );

        final map = original.toMap();
        final restored = QuizLayoutConfig.fromMap(map) as MixedLayout;

        expect(restored.layouts.length, equals(2));
        expect(restored.layouts[0], isA<ImageQuestionTextAnswersLayout>());
        expect(restored.layouts[1], isA<TextQuestionImageAnswersLayout>());
        final layout1 = restored.layouts[1] as TextQuestionImageAnswersLayout;
        expect(layout1.imageSize, isA<LargeImageSize>());
        expect(layout1.questionTemplate, equals('Test'));
        expect(restored.strategy, isA<RandomStrategy>());
        expect((restored.strategy as RandomStrategy).seed, equals(123));
      });

      test('copyWith creates correct copy', () {
        const original = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(),
        );

        final copy = original.copyWith(
          strategy: RandomStrategy(seed: 42),
        );

        expect(copy.layouts.length, equals(2));
        expect(copy.strategy, isA<RandomStrategy>());
      });

      test('equality works correctly', () {
        const layout1 = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(startIndex: 0),
        );
        const layout2 = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(startIndex: 0),
        );
        const layout3 = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(startIndex: 0),
        );

        expect(layout1, equals(layout2));
        expect(layout1, isNot(equals(layout3)));
      });

      test('handles nested MixedLayout', () {
        const innerLayout = MixedLayout(
          layouts: [
            ImageQuestionTextAnswersLayout(),
            TextQuestionTextAnswersLayout(),
          ],
          strategy: AlternatingStrategy(),
        );

        const outerLayout = MixedLayout(
          layouts: [
            innerLayout,
            TextQuestionImageAnswersLayout(),
          ],
          strategy: AlternatingStrategy(),
        );

        // Question 0 -> outer index 0 -> inner layout -> inner index 0 -> ImageQuestionTextAnswersLayout
        expect(outerLayout.selectLayout(0), isA<ImageQuestionTextAnswersLayout>());
        // Question 1 -> outer index 1 -> TextQuestionImageAnswersLayout
        expect(outerLayout.selectLayout(1), isA<TextQuestionImageAnswersLayout>());
      });
    });

    group('fromMap error handling', () {
      test('throws on unknown type', () {
        final map = {
          'type': 'unknownType',
          'version': 1,
        };

        expect(
          () => QuizLayoutConfig.fromMap(map),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });

  group('QuestionConfig with layoutConfig', () {
    test('includes layoutConfig in toMap', () {
      const config = QuestionConfig(
        optionCount: 4,
        layoutConfig: TextQuestionImageAnswersLayout(
          imageSize: LargeImageSize(),
        ),
      );

      final map = config.toMap();

      expect(map['layoutConfig'], isNotNull);
      expect(map['layoutConfig']['type'], equals('textQuestionImageAnswers'));
    });

    test('toMap omits null layoutConfig', () {
      const config = QuestionConfig(optionCount: 4);

      final map = config.toMap();

      expect(map.containsKey('layoutConfig'), isFalse);
    });

    test('fromMap restores layoutConfig', () {
      final map = {
        'optionCount': 4,
        'shuffleQuestions': true,
        'shuffleOptions': true,
        'layoutConfig': {
          'type': 'textQuestionImageAnswers',
          'version': 1,
          'imageSize': {'type': 'small', 'version': 1},
        },
      };

      final config = QuestionConfig.fromMap(map);

      expect(config.layoutConfig, isA<TextQuestionImageAnswersLayout>());
      final layout = config.layoutConfig as TextQuestionImageAnswersLayout;
      expect(layout.imageSize, isA<SmallImageSize>());
    });

    test('fromMap handles missing layoutConfig', () {
      final map = {
        'optionCount': 6,
        'shuffleQuestions': false,
        'shuffleOptions': true,
      };

      final config = QuestionConfig.fromMap(map);

      expect(config.layoutConfig, isNull);
      expect(config.optionCount, equals(6));
    });

    test('copyWith updates layoutConfig', () {
      const original = QuestionConfig(
        optionCount: 4,
        layoutConfig: ImageQuestionTextAnswersLayout(),
      );

      final copy = original.copyWith(
        layoutConfig: const TextQuestionTextAnswersLayout(),
      );

      expect(copy.layoutConfig, isA<TextQuestionTextAnswersLayout>());
      expect(copy.optionCount, equals(4)); // Unchanged
    });

    test('copyWith preserves layoutConfig when not specified', () {
      const original = QuestionConfig(
        optionCount: 4,
        layoutConfig: TextQuestionImageAnswersLayout(),
      );

      final copy = original.copyWith(optionCount: 6);

      expect(copy.layoutConfig, isA<TextQuestionImageAnswersLayout>());
      expect(copy.optionCount, equals(6));
    });

    test('factory constructors accept layoutConfig', () {
      const fixedOrder = QuestionConfig.fixedOrder(
        layoutConfig: TextQuestionTextAnswersLayout(),
      );
      expect(fixedOrder.layoutConfig, isA<TextQuestionTextAnswersLayout>());
      expect(fixedOrder.shuffleQuestions, isFalse);

      const trueFalse = QuestionConfig.trueFalse(
        layoutConfig: ImageQuestionTextAnswersLayout(),
      );
      expect(trueFalse.layoutConfig, isA<ImageQuestionTextAnswersLayout>());
      expect(trueFalse.optionCount, equals(2));

      const multipleChoice = QuestionConfig.multipleChoice(
        optionCount: 6,
        layoutConfig: TextQuestionImageAnswersLayout(),
      );
      expect(multipleChoice.layoutConfig, isA<TextQuestionImageAnswersLayout>());
      expect(multipleChoice.optionCount, equals(6));
    });
  });
}