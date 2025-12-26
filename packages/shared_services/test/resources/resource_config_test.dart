import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ResourceConfig', () {
    group('standard', () {
      test('creates config with default values', () {
        final config = ResourceConfig.standard();

        expect(config.dailyFreeLimits[ResourceType.lives()], equals(5));
        expect(config.dailyFreeLimits[ResourceType.fiftyFifty()], equals(3));
        expect(config.dailyFreeLimits[ResourceType.skip()], equals(2));

        expect(config.adRewardAmounts[ResourceType.lives()], equals(1));
        expect(config.adRewardAmounts[ResourceType.fiftyFifty()], equals(1));
        expect(config.adRewardAmounts[ResourceType.skip()], equals(1));
      });

      test('enableAds and enablePurchases are true by default', () {
        final config = ResourceConfig.standard();

        expect(config.enableAds, isTrue);
        expect(config.enablePurchases, isTrue);
      });
    });

    group('noFree', () {
      test('creates config with zero daily limits', () {
        final config = ResourceConfig.noFree();

        expect(config.dailyFreeLimits[ResourceType.lives()], equals(0));
        expect(config.dailyFreeLimits[ResourceType.fiftyFifty()], equals(0));
        expect(config.dailyFreeLimits[ResourceType.skip()], equals(0));
      });
    });

    group('generous', () {
      test('creates config with high daily limits', () {
        final config = ResourceConfig.generous();

        expect(config.dailyFreeLimits[ResourceType.lives()], equals(10));
        expect(config.dailyFreeLimits[ResourceType.fiftyFifty()], equals(5));
        expect(config.dailyFreeLimits[ResourceType.skip()], equals(5));
      });
    });

    group('getDailyLimit', () {
      test('returns correct limit for each type', () {
        final config = ResourceConfig.standard();

        expect(config.getDailyLimit(ResourceType.lives()), equals(5));
        expect(config.getDailyLimit(ResourceType.fiftyFifty()), equals(3));
        expect(config.getDailyLimit(ResourceType.skip()), equals(2));
      });

      test('returns 0 for unknown type', () {
        final config = ResourceConfig(
          dailyFreeLimits: {},
          adRewardAmounts: {},
          purchasePacks: [],
        );

        expect(config.getDailyLimit(ResourceType.lives()), equals(0));
      });
    });

    group('getAdReward', () {
      test('returns correct reward for each type', () {
        final config = ResourceConfig.standard();

        expect(config.getAdReward(ResourceType.lives()), equals(1));
        expect(config.getAdReward(ResourceType.fiftyFifty()), equals(1));
        expect(config.getAdReward(ResourceType.skip()), equals(1));
      });

      test('returns 0 for unknown type', () {
        final config = ResourceConfig(
          dailyFreeLimits: {},
          adRewardAmounts: {},
          purchasePacks: [],
        );

        expect(config.getAdReward(ResourceType.lives()), equals(0));
      });
    });

    group('getPacksForType', () {
      test('returns packs filtered by type', () {
        final livesPack = ResourcePack(
          id: 'lives_5',
          type: ResourceType.lives(),
          amount: 5,
          productId: 'com.app.lives_5',
        );
        final hintsPack = ResourcePack(
          id: 'hints_5',
          type: ResourceType.fiftyFifty(),
          amount: 5,
          productId: 'com.app.hints_5',
        );

        final config = ResourceConfig(
          dailyFreeLimits: {},
          adRewardAmounts: {},
          purchasePacks: [livesPack, hintsPack],
        );

        final livesPacks = config.getPacksForType(ResourceType.lives());
        final hintsPacks = config.getPacksForType(ResourceType.fiftyFifty());

        expect(livesPacks.length, equals(1));
        expect(livesPacks.first.id, equals('lives_5'));

        expect(hintsPacks.length, equals(1));
        expect(hintsPacks.first.id, equals('hints_5'));
      });

      test('returns empty list when no packs for type', () {
        final config = ResourceConfig.standard();

        final packs = config.getPacksForType(ResourceType.lives());

        expect(packs, isEmpty);
      });
    });
  });

  group('ResourcePack', () {
    test('creates pack with required properties', () {
      final pack = ResourcePack(
        id: 'lives_10',
        type: ResourceType.lives(),
        amount: 10,
        productId: 'com.app.lives_10',
      );

      expect(pack.id, equals('lives_10'));
      expect(pack.type, isA<LivesResource>());
      expect(pack.amount, equals(10));
      expect(pack.productId, equals('com.app.lives_10'));
      expect(pack.displayPrice, isNull);
      expect(pack.isBestValue, isFalse);
    });

    test('creates pack with optional properties', () {
      final pack = ResourcePack(
        id: 'lives_50',
        type: ResourceType.lives(),
        amount: 50,
        productId: 'com.app.lives_50',
        displayPrice: '\$4.99',
        isBestValue: true,
      );

      expect(pack.displayPrice, equals('\$4.99'));
      expect(pack.isBestValue, isTrue);
    });

    test('equals compares all fields', () {
      final pack1 = ResourcePack(
        id: 'lives_10',
        type: ResourceType.lives(),
        amount: 10,
        productId: 'com.app.lives_10',
      );

      final pack2 = ResourcePack(
        id: 'lives_10',
        type: ResourceType.lives(),
        amount: 10,
        productId: 'com.app.lives_10',
      );

      expect(pack1, equals(pack2));
    });
  });
}
