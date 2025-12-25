import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine/quiz_engine.dart';

void main() {
  group('PlayTabType', () {
    test('has correct values', () {
      expect(PlayTabType.values.length, 3);
      expect(PlayTabType.values, contains(PlayTabType.quiz));
      expect(PlayTabType.values, contains(PlayTabType.challenges));
      expect(PlayTabType.values, contains(PlayTabType.practice));
    });

    test('quiz is the first value', () {
      expect(PlayTabType.values.first, PlayTabType.quiz);
    });

    test('can be used in a Set', () {
      final tabs = {PlayTabType.quiz, PlayTabType.challenges};
      expect(tabs.length, 2);
      expect(tabs.contains(PlayTabType.quiz), isTrue);
      expect(tabs.contains(PlayTabType.challenges), isTrue);
      expect(tabs.contains(PlayTabType.practice), isFalse);
    });

    test('Set maintains uniqueness', () {
      final tabs = <PlayTabType>{};
      tabs.add(PlayTabType.quiz);
      tabs.add(PlayTabType.challenges);
      tabs.add(PlayTabType.quiz); // Duplicate
      expect(tabs.length, 2);
    });

    test('can be iterated in order', () {
      final tabs = {
        PlayTabType.quiz,
        PlayTabType.challenges,
        PlayTabType.practice,
      };

      final list = tabs.toList();
      expect(list[0], PlayTabType.quiz);
      expect(list[1], PlayTabType.challenges);
      expect(list[2], PlayTabType.practice);
    });
  });
}
