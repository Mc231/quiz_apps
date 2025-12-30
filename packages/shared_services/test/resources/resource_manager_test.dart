import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_services/shared_services.dart';

/// Mock ad provider for testing.
class MockAdProvider implements AdRewardProvider {
  bool _isAvailable = true;
  bool shouldSucceed = true;

  @override
  bool get isAdAvailable => _isAvailable;

  @override
  Future<bool> showRewardedAd() async {
    if (!_isAvailable) return false;
    return shouldSucceed;
  }

  @override
  Stream<bool> get onAdAvailabilityChanged => Stream.value(_isAvailable);

  void setAvailable(bool available) {
    _isAvailable = available;
  }
}

/// Mock IAP service for testing.
class MockIAPService implements IAPService {
  bool _isAvailable = true;
  bool _isInitialized = false;
  PurchaseResult nextResult = PurchaseResult.success(
    productId: 'test',
    transactionId: 'txn_123',
    purchaseDate: DateTime.now(),
    productType: IAPProductType.consumable,
  );
  String? lastProductId;
  final List<IAPProduct> _products = [];

  @override
  IAPConfig get config => const IAPConfig.empty();

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isStoreAvailable => _isAvailable;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  @override
  List<IAPProduct> get products => _products;

  @override
  IAPProduct? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return IAPProduct(
        id: productId,
        type: IAPProductType.consumable,
        title: 'Test Product',
        description: 'Test Description',
        price: '\$0.99',
        rawPrice: 0.99,
        currencyCode: 'USD',
      );
    }
  }

  @override
  Future<List<IAPProduct>> queryProducts() async => _products;

  @override
  Future<PurchaseResult> purchase(String productId) async {
    lastProductId = productId;
    return nextResult;
  }

  @override
  Future<bool> isPurchased(String productId) async => false;

  @override
  Future<List<String>> restorePurchases() async => [];

  @override
  Future<bool> isSubscriptionActive() async => false;

  @override
  Future<String?> getActiveSubscription() async => null;

  @override
  Stream<bool> get onSubscriptionStatusChanged => Stream.value(false);

  @override
  bool get isRemoveAdsPurchased => false;

  @override
  Stream<bool> get onRemoveAdsPurchased => Stream.value(false);

  @override
  Stream<IAPEvent> get onIAPEvent => const Stream.empty();

  @override
  void dispose() {}

  void setAvailable(bool available) {
    _isAvailable = available;
  }
}

void main() {
  group('ResourceManager', () {
    late ResourceConfig config;
    late InMemoryResourceRepository repository;
    late ResourceManager manager;

    setUp(() {
      config = ResourceConfig.standard();
      repository = InMemoryResourceRepository();
      manager = ResourceManager(
        config: config,
        repository: repository,
      );
    });

    tearDown(() {
      manager.dispose();
    });

    group('initialize', () {
      test('initializes with default inventories', () async {
        await manager.initialize();

        expect(manager.isInitialized, isTrue);
        expect(manager.isAvailable(ResourceType.lives()), isTrue);
        expect(manager.isAvailable(ResourceType.fiftyFifty()), isTrue);
        expect(manager.isAvailable(ResourceType.skip()), isTrue);
      });

      test('restores inventories from repository', () async {
        // Pre-populate repository
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 2,
          purchasedRemaining: 10,
          lastResetDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(DateTime.now());

        await manager.initialize();

        expect(manager.getAvailableCount(ResourceType.lives()), equals(12));
      });
    });

    group('isAvailable', () {
      test('returns true when resources available', () async {
        await manager.initialize();

        expect(manager.isAvailable(ResourceType.lives()), isTrue);
      });

      test('returns false when no resources available', () async {
        // Configure with no free resources
        final noFreeConfig = ResourceConfig.noFree();
        final mgr = ResourceManager(
          config: noFreeConfig,
          repository: InMemoryResourceRepository(),
        );
        await mgr.initialize();

        expect(mgr.isAvailable(ResourceType.lives()), isFalse);
        mgr.dispose();
      });
    });

    group('getAvailableCount', () {
      test('returns total count of resources', () async {
        await manager.initialize();

        expect(
          manager.getAvailableCount(ResourceType.lives()),
          equals(5),
        ); // default free limit
      });

      test('includes purchased resources in count', () async {
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 3,
          purchasedRemaining: 10,
          lastResetDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(DateTime.now());

        await manager.initialize();

        expect(manager.getAvailableCount(ResourceType.lives()), equals(13));
      });
    });

    group('useResource', () {
      test('decrements resource count', () async {
        await manager.initialize();

        final initialCount = manager.getAvailableCount(ResourceType.lives());
        await manager.useResource(ResourceType.lives());
        final newCount = manager.getAvailableCount(ResourceType.lives());

        expect(newCount, equals(initialCount - 1));
      });

      test('consumes from free pool first', () async {
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 2,
          purchasedRemaining: 10,
          lastResetDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(DateTime.now());
        await manager.initialize();

        await manager.useResource(ResourceType.lives());

        final inventory = manager.getInventory(ResourceType.lives());
        expect(inventory.freeRemaining, equals(1));
        expect(inventory.purchasedRemaining, equals(10)); // unchanged
      });

      test('consumes from purchased pool when free exhausted', () async {
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 0,
          purchasedRemaining: 10,
          lastResetDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(DateTime.now());
        await manager.initialize();

        await manager.useResource(ResourceType.lives());

        final inventory = manager.getInventory(ResourceType.lives());
        expect(inventory.freeRemaining, equals(0));
        expect(inventory.purchasedRemaining, equals(9));
      });

      test('returns false when no resources available', () async {
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 0,
          purchasedRemaining: 0,
          lastResetDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(DateTime.now());
        await manager.initialize();

        final result = await manager.useResource(ResourceType.lives());

        expect(result, isFalse);
        expect(manager.getAvailableCount(ResourceType.lives()), equals(0));
      });

      test('notifies listeners on change', () async {
        await manager.initialize();

        int notificationCount = 0;
        final subscription = manager.onInventoryChanged.listen((_) => notificationCount++);

        await manager.useResource(ResourceType.lives());

        await Future.delayed(Duration.zero);
        expect(notificationCount, greaterThan(0));

        await subscription.cancel();
      });
    });

    group('addPurchasedResources', () {
      test('adds to purchased pool', () async {
        await manager.initialize();

        await manager.addPurchasedResources(ResourceType.lives(), 10);

        final inventory = manager.getInventory(ResourceType.lives());
        expect(inventory.purchasedRemaining, equals(10));
      });

      test('accumulates purchased resources', () async {
        await manager.initialize();

        await manager.addPurchasedResources(ResourceType.lives(), 5);
        await manager.addPurchasedResources(ResourceType.lives(), 5);

        final inventory = manager.getInventory(ResourceType.lives());
        expect(inventory.purchasedRemaining, equals(10));
      });

      test('does not affect free pool', () async {
        await manager.initialize();

        final initialFree =
            manager.getInventory(ResourceType.lives()).freeRemaining;
        await manager.addPurchasedResources(ResourceType.lives(), 10);

        final inventory = manager.getInventory(ResourceType.lives());
        expect(inventory.freeRemaining, equals(initialFree));
      });
    });

    group('with ad provider', () {
      late MockAdProvider adProvider;

      setUp(() {
        adProvider = MockAdProvider();
        manager = ResourceManager(
          config: ResourceConfig.standard(),
          repository: repository,
          adProvider: adProvider,
        );
      });

      test('canRestoreViaAd returns true when ads enabled and available',
          () async {
        await manager.initialize();

        expect(manager.canRestoreViaAd, isTrue);
      });

      test('restoreViaAd adds resources when ad watched', () async {
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 0,
          purchasedRemaining: 0,
          lastResetDate: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(DateTime.now());
        await manager.initialize();

        final result = await manager.restoreViaAd(ResourceType.lives());

        expect(result, isTrue);
        expect(manager.getAvailableCount(ResourceType.lives()), equals(1));
      });

      test('restoreViaAd returns false when ad fails', () async {
        adProvider.shouldSucceed = false;
        await manager.initialize();

        final initialCount = manager.getAvailableCount(ResourceType.lives());
        final result = await manager.restoreViaAd(ResourceType.lives());

        expect(result, isFalse);
        expect(manager.getAvailableCount(ResourceType.lives()), equals(initialCount));
      });
    });

    group('with IAP service', () {
      late MockIAPService iapService;

      setUp(() {
        iapService = MockIAPService();
        final pack = ResourcePack(
          id: 'lives_10',
          type: ResourceType.lives(),
          amount: 10,
          productId: 'com.app.lives_10',
        );
        config = ResourceConfig(
          dailyFreeLimits: {
            ResourceType.lives(): 5,
            ResourceType.fiftyFifty(): 3,
            ResourceType.skip(): 2,
          },
          adRewardAmounts: {},
          purchasePacks: [pack],
          enablePurchases: true,
        );
        manager = ResourceManager(
          config: config,
          repository: repository,
          iapService: iapService,
        );
      });

      test('canPurchase returns true when purchases enabled and available',
          () async {
        await manager.initialize();

        expect(manager.canPurchase, isTrue);
      });

      test('purchasePack adds resources on success', () async {
        await manager.initialize();

        final pack = config.purchasePacks.first;
        final result = await manager.purchasePack(pack);

        expect(result, isA<PurchaseResultSuccess>());
        expect(
          manager.getInventory(ResourceType.lives()).purchasedRemaining,
          equals(10),
        );
      });

      test('purchasePack does not add resources on failure', () async {
        iapService.nextResult = PurchaseResult.failed(
          productId: 'com.app.lives_10',
          errorCode: 'test_error',
          errorMessage: 'Test failure',
        );
        await manager.initialize();

        final pack = config.purchasePacks.first;
        final result = await manager.purchasePack(pack);

        expect(result, isA<PurchaseResultFailed>());
        expect(
          manager.getInventory(ResourceType.lives()).purchasedRemaining,
          equals(0),
        );
      });

      test('getLocalizedPrice returns price from provider', () async {
        await manager.initialize();

        final pack = config.purchasePacks.first;
        final price = await manager.getLocalizedPrice(pack);

        expect(price, equals('\$0.99'));
      });
    });

    group('daily reset', () {
      test('checkAndResetDaily resets when new day', () async {
        // Initialize with a past date
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 1,
          purchasedRemaining: 0,
          lastResetDate: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now().subtract(const Duration(days: 1)),
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(
          DateTime.now().subtract(const Duration(days: 1)),
        );

        await manager.initialize();

        // Free pool should be reset
        expect(
          manager.getInventory(ResourceType.lives()).freeRemaining,
          equals(5),
        );
      });

      test('checkAndResetDaily does not reset same day', () async {
        final now = DateTime.now();
        final entity = ResourceInventoryEntity(
          resourceTypeId: 'lives',
          freeRemaining: 1,
          purchasedRemaining: 0,
          lastResetDate: now,
          createdAt: now,
          updatedAt: now,
        );
        await repository.saveInventory(ResourceType.lives(), entity);
        await repository.setLastResetDate(now);

        await manager.initialize();

        expect(
          manager.getInventory(ResourceType.lives()).freeRemaining,
          equals(1),
        );
      });
    });

    group('dispose', () {
      test('disposes cleanly', () async {
        await manager.initialize();

        expect(() => manager.dispose(), returnsNormally);
      });
    });
  });

  group('InMemoryResourceRepository', () {
    late InMemoryResourceRepository repository;

    setUp(() {
      repository = InMemoryResourceRepository();
    });

    test('getInventory returns null when not saved', () async {
      final result = await repository.getInventory(ResourceType.lives());

      expect(result, isNull);
    });

    test('saveInventory and getInventory round trip', () async {
      final entity = ResourceInventoryEntity(
        resourceTypeId: 'lives',
        freeRemaining: 3,
        purchasedRemaining: 10,
        lastResetDate: DateTime(2024, 1, 15),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 15),
      );

      await repository.saveInventory(ResourceType.lives(), entity);
      final result = await repository.getInventory(ResourceType.lives());

      expect(result, isNotNull);
      expect(result!.freeRemaining, equals(3));
      expect(result.purchasedRemaining, equals(10));
    });

    test('getAllInventories returns all saved inventories', () async {
      final livesEntity = ResourceInventoryEntity(
        resourceTypeId: 'lives',
        freeRemaining: 5,
        purchasedRemaining: 0,
        lastResetDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final hintsEntity = ResourceInventoryEntity(
        resourceTypeId: 'fiftyFifty',
        freeRemaining: 3,
        purchasedRemaining: 0,
        lastResetDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveInventory(ResourceType.lives(), livesEntity);
      await repository.saveInventory(ResourceType.fiftyFifty(), hintsEntity);

      final all = await repository.getAllInventories();

      expect(all.length, equals(2));
    });

    test('resetFreePools resets all inventories', () async {
      final entity = ResourceInventoryEntity(
        resourceTypeId: 'lives',
        freeRemaining: 1,
        purchasedRemaining: 0,
        lastResetDate: DateTime.now().subtract(const Duration(days: 1)),
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        updatedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      await repository.saveInventory(ResourceType.lives(), entity);

      await repository.resetFreePools({ResourceType.lives(): 5});

      final result = await repository.getInventory(ResourceType.lives());
      expect(result?.freeRemaining, equals(5));
    });

    test('clearAll removes all data', () async {
      final entity = ResourceInventoryEntity(
        resourceTypeId: 'lives',
        freeRemaining: 5,
        purchasedRemaining: 0,
        lastResetDate: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await repository.saveInventory(ResourceType.lives(), entity);
      await repository.setLastResetDate(DateTime.now());

      await repository.clearAll();

      expect(await repository.getInventory(ResourceType.lives()), isNull);
      expect(await repository.getLastResetDate(), isNull);
    });
  });
}
