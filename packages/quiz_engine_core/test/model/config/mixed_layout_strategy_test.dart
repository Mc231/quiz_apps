import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_engine_core/quiz_engine_core.dart';

void main() {
  group('MixedLayoutStrategy', () {
    group('RandomStrategy', () {
      test('factory creates correct instance', () {
        final strategy = MixedLayoutStrategy.random();

        expect(strategy, isA<RandomStrategy>());
      });

      test('factory creates correct instance with seed', () {
        final strategy = MixedLayoutStrategy.random(seed: 42);

        expect(strategy, isA<RandomStrategy>());
        expect((strategy as RandomStrategy).seed, equals(42));
      });

      test('selectIndex returns valid index', () {
        final strategy = RandomStrategy();

        for (var i = 0; i < 100; i++) {
          final index = strategy.selectIndex(i, 5);
          expect(index, greaterThanOrEqualTo(0));
          expect(index, lessThan(5));
        }
      });

      test('selectIndex with seed produces deterministic results per question', () {
        final strategy1 = RandomStrategy(seed: 42);
        final strategy2 = RandomStrategy(seed: 42);

        // For seeded random, same question index should give same result
        for (var i = 0; i < 10; i++) {
          expect(
            strategy1.selectIndex(i, 3),
            equals(strategy2.selectIndex(i, 3)),
          );
        }
      });

      test('selectIndex throws on invalid layoutCount', () {
        final strategy = RandomStrategy();

        expect(
          () => strategy.selectIndex(0, 0),
          throwsA(isA<ArgumentError>()),
        );
        expect(
          () => strategy.selectIndex(0, -1),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('toMap produces correct map without seed', () {
        final strategy = RandomStrategy();

        final map = strategy.toMap();

        expect(map['type'], equals('random'));
        expect(map['version'], equals(1));
        expect(map.containsKey('seed'), isFalse);
      });

      test('toMap produces correct map with seed', () {
        final strategy = RandomStrategy(seed: 123);

        final map = strategy.toMap();

        expect(map['type'], equals('random'));
        expect(map['seed'], equals(123));
      });

      test('fromMap creates correct instance without seed', () {
        final map = {
          'type': 'random',
          'version': 1,
        };

        final strategy = MixedLayoutStrategy.fromMap(map);

        expect(strategy, isA<RandomStrategy>());
        expect((strategy as RandomStrategy).seed, isNull);
      });

      test('fromMap creates correct instance with seed', () {
        final map = {
          'type': 'random',
          'version': 1,
          'seed': 456,
        };

        final strategy = MixedLayoutStrategy.fromMap(map);

        expect(strategy, isA<RandomStrategy>());
        expect((strategy as RandomStrategy).seed, equals(456));
      });

      test('equality works correctly', () {
        final strategy1 = RandomStrategy(seed: 42);
        final strategy2 = RandomStrategy(seed: 42);
        final strategy3 = RandomStrategy(seed: 100);
        final strategy4 = RandomStrategy();

        expect(strategy1, equals(strategy2));
        expect(strategy1, isNot(equals(strategy3)));
        expect(strategy1, isNot(equals(strategy4)));
      });
    });

    group('AlternatingStrategy', () {
      test('factory creates correct instance', () {
        final strategy = MixedLayoutStrategy.alternating();

        expect(strategy, isA<AlternatingStrategy>());
        expect((strategy as AlternatingStrategy).startIndex, equals(0));
      });

      test('factory creates correct instance with startIndex', () {
        final strategy = MixedLayoutStrategy.alternating(startIndex: 2);

        expect(strategy, isA<AlternatingStrategy>());
        expect((strategy as AlternatingStrategy).startIndex, equals(2));
      });

      test('selectIndex cycles through layouts', () {
        const strategy = AlternatingStrategy();

        expect(strategy.selectIndex(0, 3), equals(0));
        expect(strategy.selectIndex(1, 3), equals(1));
        expect(strategy.selectIndex(2, 3), equals(2));
        expect(strategy.selectIndex(3, 3), equals(0)); // Wraps around
        expect(strategy.selectIndex(4, 3), equals(1));
        expect(strategy.selectIndex(5, 3), equals(2));
      });

      test('selectIndex respects startIndex', () {
        const strategy = AlternatingStrategy(startIndex: 1);

        expect(strategy.selectIndex(0, 3), equals(1)); // Starts at 1
        expect(strategy.selectIndex(1, 3), equals(2));
        expect(strategy.selectIndex(2, 3), equals(0)); // Wraps around
        expect(strategy.selectIndex(3, 3), equals(1));
      });

      test('selectIndex throws on invalid layoutCount', () {
        const strategy = AlternatingStrategy();

        expect(
          () => strategy.selectIndex(0, 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('toMap produces correct map', () {
        const strategy = AlternatingStrategy(startIndex: 2);

        final map = strategy.toMap();

        expect(map['type'], equals('alternating'));
        expect(map['version'], equals(1));
        expect(map['startIndex'], equals(2));
      });

      test('fromMap creates correct instance', () {
        final map = {
          'type': 'alternating',
          'version': 1,
          'startIndex': 3,
        };

        final strategy = MixedLayoutStrategy.fromMap(map);

        expect(strategy, isA<AlternatingStrategy>());
        expect((strategy as AlternatingStrategy).startIndex, equals(3));
      });

      test('fromMap handles missing startIndex', () {
        final map = {
          'type': 'alternating',
          'version': 1,
        };

        final strategy = MixedLayoutStrategy.fromMap(map);

        expect(strategy, isA<AlternatingStrategy>());
        expect((strategy as AlternatingStrategy).startIndex, equals(0));
      });

      test('equality works correctly', () {
        const strategy1 = AlternatingStrategy(startIndex: 1);
        const strategy2 = AlternatingStrategy(startIndex: 1);
        const strategy3 = AlternatingStrategy(startIndex: 2);

        expect(strategy1, equals(strategy2));
        expect(strategy1.hashCode, equals(strategy2.hashCode));
        expect(strategy1, isNot(equals(strategy3)));
      });
    });

    group('WeightedStrategy', () {
      test('factory creates correct instance', () {
        final strategy = MixedLayoutStrategy.weighted(
          weights: [0.7, 0.3],
        );

        expect(strategy, isA<WeightedStrategy>());
        final weightedStrategy = strategy as WeightedStrategy;
        expect(weightedStrategy.weights, equals([0.7, 0.3]));
        expect(weightedStrategy.seed, isNull);
      });

      test('factory creates correct instance with seed', () {
        final strategy = MixedLayoutStrategy.weighted(
          weights: [0.5, 0.5],
          seed: 42,
        );

        expect(strategy, isA<WeightedStrategy>());
        expect((strategy as WeightedStrategy).seed, equals(42));
      });

      test('selectIndex returns valid index', () {
        const strategy = WeightedStrategy(weights: [1.0, 1.0, 1.0]);

        for (var i = 0; i < 100; i++) {
          final index = strategy.selectIndex(i, 3);
          expect(index, greaterThanOrEqualTo(0));
          expect(index, lessThan(3));
        }
      });

      test('selectIndex respects weights distribution', () {
        // Weight of 10 for first, 0 for second - should always return 0
        const strategy = WeightedStrategy(weights: [10.0, 0.0]);

        for (var i = 0; i < 50; i++) {
          expect(strategy.selectIndex(i, 2), equals(0));
        }
      });

      test('selectIndex with seed produces deterministic results', () {
        const strategy1 = WeightedStrategy(weights: [0.5, 0.5], seed: 42);
        const strategy2 = WeightedStrategy(weights: [0.5, 0.5], seed: 42);

        for (var i = 0; i < 10; i++) {
          expect(
            strategy1.selectIndex(i, 2),
            equals(strategy2.selectIndex(i, 2)),
          );
        }
      });

      test('selectIndex throws on mismatched weights length', () {
        const strategy = WeightedStrategy(weights: [0.5, 0.5]);

        expect(
          () => strategy.selectIndex(0, 3), // 3 layouts but 2 weights
          throwsA(isA<ArgumentError>()),
        );
      });

      test('selectIndex throws on invalid layoutCount', () {
        const strategy = WeightedStrategy(weights: [1.0]);

        expect(
          () => strategy.selectIndex(0, 0),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('toMap produces correct map', () {
        const strategy = WeightedStrategy(
          weights: [0.6, 0.3, 0.1],
          seed: 123,
        );

        final map = strategy.toMap();

        expect(map['type'], equals('weighted'));
        expect(map['version'], equals(1));
        expect(map['weights'], equals([0.6, 0.3, 0.1]));
        expect(map['seed'], equals(123));
      });

      test('toMap omits null seed', () {
        const strategy = WeightedStrategy(weights: [0.5, 0.5]);

        final map = strategy.toMap();

        expect(map.containsKey('seed'), isFalse);
      });

      test('fromMap creates correct instance', () {
        final map = {
          'type': 'weighted',
          'version': 1,
          'weights': [0.7, 0.2, 0.1],
          'seed': 456,
        };

        final strategy = MixedLayoutStrategy.fromMap(map);

        expect(strategy, isA<WeightedStrategy>());
        final weightedStrategy = strategy as WeightedStrategy;
        expect(weightedStrategy.weights, equals([0.7, 0.2, 0.1]));
        expect(weightedStrategy.seed, equals(456));
      });

      test('fromMap handles missing seed', () {
        final map = {
          'type': 'weighted',
          'version': 1,
          'weights': [0.5, 0.5],
        };

        final strategy = MixedLayoutStrategy.fromMap(map);

        expect(strategy, isA<WeightedStrategy>());
        expect((strategy as WeightedStrategy).seed, isNull);
      });

      test('copyWith creates correct copy', () {
        const original = WeightedStrategy(
          weights: [0.5, 0.5],
          seed: 42,
        );

        final copy = original.copyWith(weights: [0.7, 0.3]);

        expect(copy.weights, equals([0.7, 0.3]));
        expect(copy.seed, equals(42)); // Unchanged
      });

      test('equality works correctly', () {
        const strategy1 = WeightedStrategy(weights: [0.5, 0.5], seed: 42);
        const strategy2 = WeightedStrategy(weights: [0.5, 0.5], seed: 42);
        const strategy3 = WeightedStrategy(weights: [0.6, 0.4], seed: 42);
        const strategy4 = WeightedStrategy(weights: [0.5, 0.5], seed: 100);

        expect(strategy1, equals(strategy2));
        expect(strategy1.hashCode, equals(strategy2.hashCode));
        expect(strategy1, isNot(equals(strategy3)));
        expect(strategy1, isNot(equals(strategy4)));
      });

      test('serialization roundtrip preserves data', () {
        const original = WeightedStrategy(
          weights: [0.4, 0.35, 0.25],
          seed: 789,
        );

        final map = original.toMap();
        final restored = MixedLayoutStrategy.fromMap(map) as WeightedStrategy;

        expect(restored.weights, equals([0.4, 0.35, 0.25]));
        expect(restored.seed, equals(789));
      });
    });

    group('fromMap error handling', () {
      test('throws on unknown type', () {
        final map = {
          'type': 'unknownType',
          'version': 1,
        };

        expect(
          () => MixedLayoutStrategy.fromMap(map),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('comparison between types', () {
      test('different strategy types are not equal', () {
        final random = RandomStrategy(seed: 0);
        const alternating = AlternatingStrategy(startIndex: 0);
        const weighted = WeightedStrategy(weights: [1.0], seed: 0);

        expect(random, isNot(equals(alternating)));
        expect(alternating, isNot(equals(weighted)));
        expect(weighted, isNot(equals(random)));
      });
    });
  });
}