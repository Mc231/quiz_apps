import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/src/models/quiz_category.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('QuizCategory', () {
    test('creates category with required fields', () {
      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
      );

      expect(category.id, 'europe');
      expect(category.subtitle, isNull);
      expect(category.imageProvider, isNull);
      expect(category.icon, isNull);
      expect(category.config, isNull);
      expect(category.metadata, isNull);
    });

    test('creates category with all fields', () {
      final config = QuizConfig(quizId: 'test');
      final metadata = {'key': 'value'};

      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        subtitle: (context) => '50 countries',
        icon: Icons.flag,
        config: config,
        metadata: metadata,
      );

      expect(category.id, 'europe');
      expect(category.icon, Icons.flag);
      expect(category.config, config);
      expect(category.metadata, metadata);
    });

    test('copyWith creates new instance with replaced fields', () {
      final original = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
        icon: Icons.flag,
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
      );

      final category2 = QuizCategory(
        id: 'europe',
        title: (context) => 'Different Title',
        icon: Icons.flag,
      );

      final category3 = QuizCategory(
        id: 'asia',
        title: (context) => 'Asia',
      );

      expect(category1 == category2, isTrue);
      expect(category1 == category3, isFalse);
    });

    test('hashCode is based on id', () {
      final category1 = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
      );

      final category2 = QuizCategory(
        id: 'europe',
        title: (context) => 'Different',
      );

      expect(category1.hashCode, category2.hashCode);
    });

    test('toString returns readable representation', () {
      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Europe',
      );

      expect(category.toString(), 'QuizCategory(id: europe)');
    });

    testWidgets('LocalizedString resolves with context', (tester) async {
      final category = QuizCategory(
        id: 'europe',
        title: (context) => 'Localized Europe',
        subtitle: (context) => '50 countries',
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
