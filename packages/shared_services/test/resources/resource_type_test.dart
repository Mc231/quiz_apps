import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ResourceType', () {
    test('all types have unique IDs', () {
      final types = ResourceType.values;
      final ids = types.map((t) => t.id).toSet();
      expect(ids.length, equals(types.length));
    });

    test('LivesResource has correct properties', () {
      final lives = ResourceType.lives();

      expect(lives.id, equals('lives'));
      expect(lives.localizationKey, equals('lives'));
      expect(lives.icon, equals(Icons.favorite));
      expect(lives.color, equals(const Color(0xFFF44336)));
    });

    test('FiftyFiftyResource has correct properties', () {
      final fiftyFifty = ResourceType.fiftyFifty();

      expect(fiftyFifty.id, equals('fiftyFifty'));
      expect(fiftyFifty.localizationKey, equals('fiftyFifty'));
      expect(fiftyFifty.icon, equals(Icons.filter_2));
      expect(fiftyFifty.color, equals(const Color(0xFF2196F3)));
    });

    test('SkipResource has correct properties', () {
      final skip = ResourceType.skip();

      expect(skip.id, equals('skip'));
      expect(skip.localizationKey, equals('skip'));
      expect(skip.icon, equals(Icons.skip_next));
      expect(skip.color, equals(const Color(0xFFFF9800)));
    });

    test('values returns all resource types', () {
      final values = ResourceType.values;

      expect(values.length, equals(3));
      expect(values.any((t) => t is LivesResource), isTrue);
      expect(values.any((t) => t is FiftyFiftyResource), isTrue);
      expect(values.any((t) => t is SkipResource), isTrue);
    });

    test('fromId returns correct type for valid ID', () {
      expect(ResourceType.fromId('lives'), isA<LivesResource>());
      expect(ResourceType.fromId('fiftyFifty'), isA<FiftyFiftyResource>());
      expect(ResourceType.fromId('skip'), isA<SkipResource>());
    });

    test('fromId returns null for invalid ID', () {
      expect(ResourceType.fromId('invalid'), isNull);
      expect(ResourceType.fromId(''), isNull);
      expect(ResourceType.fromId('LIVES'), isNull); // case sensitive
    });

    test('factory constructors create correct types', () {
      expect(ResourceType.lives(), isA<LivesResource>());
      expect(ResourceType.fiftyFifty(), isA<FiftyFiftyResource>());
      expect(ResourceType.skip(), isA<SkipResource>());
    });

    test('same type instances are equal', () {
      final lives1 = ResourceType.lives();
      final lives2 = const LivesResource();

      expect(lives1, equals(lives2));
      expect(lives1.hashCode, equals(lives2.hashCode));
    });
  });
}
