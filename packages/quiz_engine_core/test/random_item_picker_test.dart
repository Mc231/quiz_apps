import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/src/model/question_entry.dart';
import 'package:quiz_engine_core/src/model/question_type.dart';
import 'package:quiz_engine_core/src/random_item_picker.dart';

void main() {
  late RandomItemPicker sut;

  setUp(() {
    sut = RandomItemPicker([]);
  });

  group('RandomItemPicker Tests', () {
    test('replace items', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      expect(sut.items, isEmpty);

      // When
      sut.replaceItems(expectedItems);

      // Then
      expect(sut.items, equals(expectedItems));
      expect(sut.items.length, equals(4));
    });

    test('empty items', () {
      // Given
      expect(sut.items, isEmpty);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNull);
    });

    test('pick when count == items.length', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      expect(sut.items, isEmpty);

      // When
      sut.replaceItems(expectedItems);
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(
        result!.options.length,
        equals(4),
      ); // Should pick all items as options
      expect(result.options.contains(result.answer), isTrue);
    });

    test('pick when items < count', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(
        result!.options.length,
        equals(2),
      ); // Only available items can be options
    });

    test('pick random item', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("E"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("1"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("2"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("3"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("4"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("5"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(
        result!.options.length,
        lessThanOrEqualTo(4),
      ); // Max options should be count (4)
      expect(result.options.contains(result.answer), isTrue);
    });

    test('ensure picked items are added to answered list', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("CA"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(sut.items.contains(result!.answer), isFalse);
    });

    test('pick all items until empty', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      for (var i = 0; i < expectedItems.length; i++) {
        final result = sut.pick();
        expect(result, isNotNull);
      }

      // Then
      final lastResult = sut.pick();
      expect(
        lastResult,
        isNull,
      ); // Should return null after all items are picked
    });

    test('pick when count > available items and answered items exist', () {
      // Given
      sut.pick(); // Pick first item
      sut.pick(); // Pick second item

      // When
      final result = sut.pick(); // Should use answered items

      // Then
      expect(result, isNull);
    });

    test('ensure options list contains only unique values', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("1"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.length, result.options.toSet().length);
    });

    test('ensure answer is always part of options', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C1"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      final result = sut.pick();

      // Then
      expect(result, isNotNull);
      expect(result!.options.contains(result.answer), isTrue);
    });

    test('pick shuffles options', () {
      // Given
      final expectedItems = [
        QuestionEntry(type: QuestionType.text("A"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("B1"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("C"), otherOptions: {}),
        QuestionEntry(type: QuestionType.text("D"), otherOptions: {}),
      ];
      sut.replaceItems(expectedItems);

      // When
      final result1 = sut.pick();
      final result2 = sut.pick();

      // Then
      expect(result1, isNotNull);
      expect(result2, isNotNull);
      expect(
        result1!.options,
        isNot(equals(result2!.options)),
      ); // Expect shuffle
    });
  });
}
