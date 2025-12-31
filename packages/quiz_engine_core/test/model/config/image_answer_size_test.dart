import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('ImageAnswerSize', () {
    group('SmallImageSize', () {
      test('factory creates correct instance', () {
        final size = ImageAnswerSize.small();

        expect(size, isA<SmallImageSize>());
      });

      test('has correct values', () {
        const size = SmallImageSize();

        expect(size.maxSize, equals(80));
        expect(size.spacing, equals(8));
        expect(size.aspectRatio, isNull);
      });

      test('toMap produces correct map', () {
        const size = SmallImageSize();

        final map = size.toMap();

        expect(map['type'], equals('small'));
        expect(map['version'], equals(1));
      });

      test('fromMap creates correct instance', () {
        final map = {
          'type': 'small',
          'version': 1,
        };

        final size = ImageAnswerSize.fromMap(map);

        expect(size, isA<SmallImageSize>());
      });

      test('equality works correctly', () {
        const size1 = SmallImageSize();
        const size2 = SmallImageSize();

        expect(size1, equals(size2));
        expect(size1.hashCode, equals(size2.hashCode));
      });
    });

    group('MediumImageSize', () {
      test('factory creates correct instance', () {
        final size = ImageAnswerSize.medium();

        expect(size, isA<MediumImageSize>());
      });

      test('has correct values', () {
        const size = MediumImageSize();

        expect(size.maxSize, equals(120));
        expect(size.spacing, equals(12));
        expect(size.aspectRatio, isNull);
      });

      test('toMap produces correct map', () {
        const size = MediumImageSize();

        final map = size.toMap();

        expect(map['type'], equals('medium'));
        expect(map['version'], equals(1));
      });

      test('fromMap creates correct instance', () {
        final map = {
          'type': 'medium',
          'version': 1,
        };

        final size = ImageAnswerSize.fromMap(map);

        expect(size, isA<MediumImageSize>());
      });

      test('equality works correctly', () {
        const size1 = MediumImageSize();
        const size2 = MediumImageSize();

        expect(size1, equals(size2));
        expect(size1.hashCode, equals(size2.hashCode));
      });
    });

    group('LargeImageSize', () {
      test('factory creates correct instance', () {
        final size = ImageAnswerSize.large();

        expect(size, isA<LargeImageSize>());
      });

      test('has correct values', () {
        const size = LargeImageSize();

        expect(size.maxSize, equals(160));
        expect(size.spacing, equals(16));
        expect(size.aspectRatio, isNull);
      });

      test('toMap produces correct map', () {
        const size = LargeImageSize();

        final map = size.toMap();

        expect(map['type'], equals('large'));
        expect(map['version'], equals(1));
      });

      test('fromMap creates correct instance', () {
        final map = {
          'type': 'large',
          'version': 1,
        };

        final size = ImageAnswerSize.fromMap(map);

        expect(size, isA<LargeImageSize>());
      });

      test('equality works correctly', () {
        const size1 = LargeImageSize();
        const size2 = LargeImageSize();

        expect(size1, equals(size2));
        expect(size1.hashCode, equals(size2.hashCode));
      });
    });

    group('CustomImageSize', () {
      test('factory creates correct instance', () {
        final size = ImageAnswerSize.custom(
          maxSize: 100,
          spacing: 10,
          aspectRatio: 1.5,
        );

        expect(size, isA<CustomImageSize>());
        final customSize = size as CustomImageSize;
        expect(customSize.maxSize, equals(100));
        expect(customSize.spacing, equals(10));
        expect(customSize.aspectRatio, equals(1.5));
      });

      test('factory uses default spacing', () {
        final size = ImageAnswerSize.custom(maxSize: 100);

        expect(size, isA<CustomImageSize>());
        final customSize = size as CustomImageSize;
        expect(customSize.spacing, equals(12));
        expect(customSize.aspectRatio, isNull);
      });

      test('toMap produces correct map', () {
        const size = CustomImageSize(
          maxSize: 150,
          spacing: 20,
          aspectRatio: 0.75,
        );

        final map = size.toMap();

        expect(map['type'], equals('custom'));
        expect(map['version'], equals(1));
        expect(map['maxSize'], equals(150));
        expect(map['spacing'], equals(20));
        expect(map['aspectRatio'], equals(0.75));
      });

      test('toMap omits null aspectRatio', () {
        const size = CustomImageSize(maxSize: 100, spacing: 10);

        final map = size.toMap();

        expect(map.containsKey('aspectRatio'), isFalse);
      });

      test('fromMap creates correct instance', () {
        final map = {
          'type': 'custom',
          'version': 1,
          'maxSize': 200,
          'spacing': 25,
          'aspectRatio': 1.0,
        };

        final size = ImageAnswerSize.fromMap(map);

        expect(size, isA<CustomImageSize>());
        final customSize = size as CustomImageSize;
        expect(customSize.maxSize, equals(200));
        expect(customSize.spacing, equals(25));
        expect(customSize.aspectRatio, equals(1.0));
      });

      test('fromMap handles missing optional values', () {
        final map = {
          'type': 'custom',
          'version': 1,
          'maxSize': 100,
        };

        final size = ImageAnswerSize.fromMap(map);

        expect(size, isA<CustomImageSize>());
        final customSize = size as CustomImageSize;
        expect(customSize.maxSize, equals(100));
        expect(customSize.spacing, equals(12)); // Default
        expect(customSize.aspectRatio, isNull);
      });

      test('copyWith creates correct copy', () {
        const original = CustomImageSize(
          maxSize: 100,
          spacing: 10,
          aspectRatio: 1.0,
        );

        final copy = original.copyWith(maxSize: 150);

        expect(copy.maxSize, equals(150));
        expect(copy.spacing, equals(10)); // Unchanged
        expect(copy.aspectRatio, equals(1.0)); // Unchanged
      });

      test('equality works correctly', () {
        const size1 = CustomImageSize(maxSize: 100, spacing: 10, aspectRatio: 1.0);
        const size2 = CustomImageSize(maxSize: 100, spacing: 10, aspectRatio: 1.0);
        const size3 = CustomImageSize(maxSize: 100, spacing: 15, aspectRatio: 1.0);

        expect(size1, equals(size2));
        expect(size1.hashCode, equals(size2.hashCode));
        expect(size1, isNot(equals(size3)));
      });

      test('serialization roundtrip preserves data', () {
        const original = CustomImageSize(
          maxSize: 175,
          spacing: 18,
          aspectRatio: 0.8,
        );

        final map = original.toMap();
        final restored = ImageAnswerSize.fromMap(map) as CustomImageSize;

        expect(restored.maxSize, equals(175));
        expect(restored.spacing, equals(18));
        expect(restored.aspectRatio, equals(0.8));
      });
    });

    group('fromMap error handling', () {
      test('throws on unknown type', () {
        final map = {
          'type': 'unknownType',
          'version': 1,
        };

        expect(
          () => ImageAnswerSize.fromMap(map),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('comparison between types', () {
      test('different size types are not equal', () {
        const small = SmallImageSize();
        const medium = MediumImageSize();
        const large = LargeImageSize();
        const custom = CustomImageSize(maxSize: 80, spacing: 8);

        expect(small, isNot(equals(medium)));
        expect(medium, isNot(equals(large)));
        // Even with same values, different types are not equal
        expect(small, isNot(equals(custom)));
      });
    });
  });
}