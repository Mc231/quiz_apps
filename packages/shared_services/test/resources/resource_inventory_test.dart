import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

void main() {
  group('ResourceInventory', () {
    test('empty creates inventory with default values', () {
      final inventory = ResourceInventory.empty(ResourceType.lives(), freeLimit: 5);

      expect(inventory.type, isA<LivesResource>());
      expect(inventory.freeRemaining, equals(5));
      expect(inventory.freeLimit, equals(5));
      expect(inventory.purchasedRemaining, equals(0));
      expect(inventory.total, equals(5));
      expect(inventory.isAvailable, isTrue);
    });

    test('total returns sum of free and purchased', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 3,
        freeLimit: 5,
        purchasedRemaining: 10,
      );

      expect(inventory.total, equals(13));
    });

    test('isAvailable returns true when resources available', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 1,
        freeLimit: 5,
        purchasedRemaining: 0,
      );

      expect(inventory.isAvailable, isTrue);
    });

    test('isAvailable returns true with only purchased resources', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 0,
        freeLimit: 5,
        purchasedRemaining: 5,
      );

      expect(inventory.isAvailable, isTrue);
    });

    test('isAvailable returns false when no resources', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 0,
        freeLimit: 5,
        purchasedRemaining: 0,
      );

      expect(inventory.isAvailable, isFalse);
    });

    test('isFreeDepleted returns true when free is 0', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 0,
        freeLimit: 5,
        purchasedRemaining: 10,
      );

      expect(inventory.isFreeDepleted, isTrue);
    });

    test('freePercentage calculates correctly', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 2,
        freeLimit: 5,
        purchasedRemaining: 0,
      );

      expect(inventory.freePercentage, closeTo(0.4, 0.001));
    });

    group('consume', () {
      test('consumes from free pool first', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 3,
          freeLimit: 5,
          purchasedRemaining: 10,
        );

        final updated = inventory.consume();

        expect(updated, isNotNull);
        expect(updated!.freeRemaining, equals(2));
        expect(updated.purchasedRemaining, equals(10));
      });

      test('consumes from purchased pool when free exhausted', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 0,
          freeLimit: 5,
          purchasedRemaining: 10,
        );

        final updated = inventory.consume();

        expect(updated, isNotNull);
        expect(updated!.freeRemaining, equals(0));
        expect(updated.purchasedRemaining, equals(9));
      });

      test('returns null when nothing to consume', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 0,
          freeLimit: 5,
          purchasedRemaining: 0,
        );

        final updated = inventory.consume();

        expect(updated, isNull);
      });
    });

    group('addPurchased', () {
      test('adds to purchased pool', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 3,
          freeLimit: 5,
          purchasedRemaining: 10,
        );

        final updated = inventory.addPurchased(5);

        expect(updated.freeRemaining, equals(3));
        expect(updated.purchasedRemaining, equals(15));
      });

      test('adds to empty purchased pool', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 3,
          freeLimit: 5,
          purchasedRemaining: 0,
        );

        final updated = inventory.addPurchased(5);

        expect(updated.purchasedRemaining, equals(5));
      });
    });

    group('resetFreePool', () {
      test('resets free pool to limit', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 1,
          freeLimit: 5,
          purchasedRemaining: 10,
        );

        final updated = inventory.resetFreePool();

        expect(updated.freeRemaining, equals(5));
        expect(updated.freeLimit, equals(5));
        expect(updated.purchasedRemaining, equals(10));
      });

      test('does not affect already full free pool', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 5,
          freeLimit: 5,
          purchasedRemaining: 0,
        );

        final updated = inventory.resetFreePool();

        expect(updated.freeRemaining, equals(5));
      });
    });

    group('copyWith', () {
      test('creates copy with updated values', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 3,
          freeLimit: 5,
          purchasedRemaining: 10,
        );

        final updated = inventory.copyWith(
          freeRemaining: 4,
          purchasedRemaining: 20,
        );

        expect(updated.freeRemaining, equals(4));
        expect(updated.freeLimit, equals(5)); // unchanged
        expect(updated.purchasedRemaining, equals(20));
      });

      test('preserves original values when not specified', () {
        final inventory = ResourceInventory(
          type: ResourceType.lives(),
          freeRemaining: 3,
          freeLimit: 5,
          purchasedRemaining: 10,
        );

        final updated = inventory.copyWith();

        expect(updated.freeRemaining, equals(3));
        expect(updated.freeLimit, equals(5));
        expect(updated.purchasedRemaining, equals(10));
      });
    });

    test('equals compares all fields', () {
      final inv1 = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 3,
        freeLimit: 5,
        purchasedRemaining: 10,
      );

      final inv2 = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 3,
        freeLimit: 5,
        purchasedRemaining: 10,
      );

      expect(inv1, equals(inv2));
    });
  });

  group('ResourceInventoryEntity', () {
    test('creates from inventory', () {
      final inventory = ResourceInventory(
        type: ResourceType.lives(),
        freeRemaining: 3,
        freeLimit: 5,
        purchasedRemaining: 10,
      );

      final entity = ResourceInventoryEntity.fromInventory(inventory);

      expect(entity.resourceTypeId, equals('lives'));
      expect(entity.freeRemaining, equals(3));
      expect(entity.purchasedRemaining, equals(10));
    });

    test('toInventory converts back correctly', () {
      final entity = ResourceInventoryEntity(
        resourceTypeId: 'lives',
        freeRemaining: 3,
        purchasedRemaining: 10,
        lastResetDate: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );

      final inventory = entity.toInventory(5);

      expect(inventory, isNotNull);
      expect(inventory!.type, isA<LivesResource>());
      expect(inventory.freeRemaining, equals(3));
      expect(inventory.freeLimit, equals(5));
      expect(inventory.purchasedRemaining, equals(10));
    });

    test('toInventory returns null for unknown type', () {
      final entity = ResourceInventoryEntity(
        resourceTypeId: 'unknown',
        freeRemaining: 3,
        purchasedRemaining: 10,
        lastResetDate: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );

      final inventory = entity.toInventory(5);

      expect(inventory, isNull);
    });

    test('fromMap creates from database map', () {
      final map = {
        'resource_type': 'lives',
        'free_remaining': 3,
        'purchased_remaining': 10,
        'last_reset_date': '2024-01-15T00:00:00.000',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-15T00:00:00.000',
      };

      final entity = ResourceInventoryEntity.fromMap(map);

      expect(entity.resourceTypeId, equals('lives'));
      expect(entity.freeRemaining, equals(3));
      expect(entity.purchasedRemaining, equals(10));
    });

    test('toMap creates database map', () {
      final entity = ResourceInventoryEntity(
        resourceTypeId: 'lives',
        freeRemaining: 3,
        purchasedRemaining: 10,
        lastResetDate: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );

      final map = entity.toMap();

      expect(map['resource_type'], equals('lives'));
      expect(map['free_remaining'], equals(3));
      expect(map['purchased_remaining'], equals(10));
    });
  });
}
