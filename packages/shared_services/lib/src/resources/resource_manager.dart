import 'dart:async';

import '../analytics/analytics_service.dart';
import '../analytics/events/resource_event.dart';
import 'providers/ad_reward_provider.dart';
import 'providers/iap_provider.dart';
import 'resource_config.dart';
import 'resource_inventory.dart';
import 'resource_repository.dart';
import 'resource_type.dart';

/// Manages resource inventory (lives, hints, skips).
///
/// Handles:
/// - Tracking free and purchased pools
/// - Daily reset at midnight
/// - Consuming resources during gameplay
/// - Adding resources via ads or purchases
///
/// Example usage:
/// ```dart
/// final manager = ResourceManager(
///   config: ResourceConfig.standard(),
///   repository: SqliteResourceRepository(database),
/// );
///
/// await manager.initialize();
///
/// // Check if lives are available
/// if (manager.isAvailable(ResourceType.lives())) {
///   await manager.useResource(ResourceType.lives());
/// } else {
///   // Show restore dialog
/// }
/// ```
class ResourceManager {
  /// Configuration for the resource system.
  final ResourceConfig config;

  /// Provider for rewarded ads.
  final AdRewardProvider adProvider;

  /// Provider for in-app purchases.
  final IAPProvider iapProvider;

  /// Repository for persisting inventory.
  final ResourceRepository repository;

  /// Analytics service for tracking resource events.
  final AnalyticsService? analyticsService;

  /// Current inventory state.
  final Map<ResourceType, ResourceInventory> _inventories = {};

  /// Stream controller for inventory changes.
  final _inventoryController =
      StreamController<Map<ResourceType, ResourceInventory>>.broadcast();

  /// Whether the manager has been initialized.
  bool _isInitialized = false;

  /// Creates a [ResourceManager].
  ResourceManager({
    required this.config,
    this.adProvider = const NoAdsProvider(),
    this.iapProvider = const NoIAPProvider(),
    required this.repository,
    this.analyticsService,
  });

  /// Whether the manager has been initialized.
  bool get isInitialized => _isInitialized;

  /// Stream of inventory changes.
  ///
  /// Emits the full inventory map whenever any resource changes.
  Stream<Map<ResourceType, ResourceInventory>> get onInventoryChanged =>
      _inventoryController.stream;

  /// Initialize the manager.
  ///
  /// Loads inventory from database and checks for daily reset.
  /// Must be called before using other methods.
  Future<void> initialize() async {
    if (_isInitialized) return;

    await _loadInventories();
    await checkAndResetDaily();
    _isInitialized = true;
  }

  /// Load inventories from repository.
  Future<void> _loadInventories() async {
    final entities = await repository.getAllInventories();

    for (final type in ResourceType.values) {
      final entity = entities[type];
      final freeLimit = config.getDailyLimit(type);

      if (entity != null) {
        _inventories[type] = entity.toInventory(freeLimit) ??
            ResourceInventory.empty(type, freeLimit: freeLimit);
      } else {
        _inventories[type] = ResourceInventory.empty(type, freeLimit: freeLimit);
      }
    }
  }

  /// Get current inventory for a resource type.
  ResourceInventory getInventory(ResourceType type) {
    _ensureInitialized();
    return _inventories[type] ??
        ResourceInventory.empty(type, freeLimit: config.getDailyLimit(type));
  }

  /// Get total available count for a resource type.
  int getAvailableCount(ResourceType type) {
    return getInventory(type).total;
  }

  /// Check if resource is available (count > 0).
  bool isAvailable(ResourceType type) {
    return getInventory(type).isAvailable;
  }

  /// Use one resource (deducts from free pool first).
  ///
  /// Returns `true` if resource was available and used.
  /// Returns `false` if no resources available.
  Future<bool> useResource(ResourceType type) async {
    _ensureInitialized();

    final inventory = getInventory(type);
    final newInventory = inventory.consume();

    if (newInventory == null) {
      return false;
    }

    await _updateInventory(type, newInventory);
    return true;
  }

  /// Add resources to purchased pool.
  Future<void> addPurchasedResources(ResourceType type, int amount) async {
    _ensureInitialized();

    final inventory = getInventory(type);
    final newInventory = inventory.addPurchased(amount);

    await _updateInventory(type, newInventory);
  }

  /// Attempt to restore resource via rewarded ad.
  ///
  /// Shows ad, waits for completion, adds resource if successful.
  /// Returns `true` if resource was added.
  Future<bool> restoreViaAd(ResourceType type) async {
    _ensureInitialized();

    if (!adProvider.isAdAvailable) {
      return false;
    }

    final watched = await adProvider.showRewardedAd();
    if (!watched) {
      return false;
    }

    final rewardAmount = config.getAdReward(type);
    await addPurchasedResources(type, rewardAmount);

    // Log analytics event
    analyticsService?.logEvent(
      ResourceEvent.added(
        quizId: '', // Global context, not within a specific quiz
        resourceType: type.id,
        amountAdded: rewardAmount,
        newTotal: getAvailableCount(type),
        source: 'rewarded_ad',
      ),
    );

    return true;
  }

  /// Attempt to purchase a resource pack.
  ///
  /// Initiates purchase flow, adds resources if successful.
  /// Returns the purchase result.
  Future<PurchaseResult> purchasePack(ResourcePack pack) async {
    _ensureInitialized();

    if (!iapProvider.isStoreAvailable) {
      return PurchaseResult.failed;
    }

    final result = await iapProvider.purchase(pack.productId);

    if (result == PurchaseResult.success) {
      await addPurchasedResources(pack.type, pack.amount);

      // Log analytics event
      analyticsService?.logEvent(
        ResourceEvent.added(
          quizId: '', // Global context, not within a specific quiz
          resourceType: pack.type.id,
          amountAdded: pack.amount,
          newTotal: getAvailableCount(pack.type),
          source: 'purchase',
        ),
      );
    }

    return result;
  }

  /// Check if daily reset is needed and perform it.
  Future<void> checkAndResetDaily() async {
    final now = DateTime.now();
    final lastReset = await repository.getLastResetDate();

    // First launch - initialize with daily limits
    if (lastReset == null) {
      await _initializeInventories();
      await repository.setLastResetDate(now);
      _notifyChange();
      return;
    }

    // Check if we've crossed midnight since last reset
    final lastResetDate = DateTime(lastReset.year, lastReset.month, lastReset.day);
    final todayDate = DateTime(now.year, now.month, now.day);

    if (todayDate.isAfter(lastResetDate)) {
      await _resetFreePools();
      await repository.setLastResetDate(now);
      _notifyChange();
    }
  }

  /// Initialize inventories for first launch.
  Future<void> _initializeInventories() async {
    for (final type in ResourceType.values) {
      final dailyLimit = config.getDailyLimit(type);
      final inventory = ResourceInventory.empty(type, freeLimit: dailyLimit);
      _inventories[type] = inventory;

      final entity = ResourceInventoryEntity.fromInventory(inventory);
      await repository.saveInventory(type, entity);
    }
  }

  /// Reset free pools to daily limits.
  Future<void> _resetFreePools() async {
    await repository.resetFreePools(config.dailyFreeLimits);

    // Reload inventories
    for (final type in ResourceType.values) {
      final entity = await repository.getInventory(type);
      if (entity != null) {
        final freeLimit = config.getDailyLimit(type);
        _inventories[type] = entity.toInventory(freeLimit) ??
            ResourceInventory.empty(type, freeLimit: freeLimit);
      }
    }
  }

  /// Update inventory and persist to repository.
  Future<void> _updateInventory(
    ResourceType type,
    ResourceInventory inventory,
  ) async {
    _inventories[type] = inventory;

    final existingEntity = await repository.getInventory(type);
    final entity = ResourceInventoryEntity.fromInventory(
      inventory,
      lastResetDate: existingEntity?.lastResetDate,
      createdAt: existingEntity?.createdAt,
    );

    await repository.saveInventory(type, entity);
    _notifyChange();
  }

  /// Notify listeners of inventory change.
  void _notifyChange() {
    _inventoryController.add(Map.unmodifiable(_inventories));
  }

  /// Ensure the manager has been initialized.
  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'ResourceManager has not been initialized. Call initialize() first.',
      );
    }
  }

  /// Whether ads are available for restoring resources.
  bool get canRestoreViaAd => config.enableAds && adProvider.isAdAvailable;

  /// Whether purchases are available.
  bool get canPurchase => config.enablePurchases && iapProvider.isStoreAvailable;

  /// Get localized price for a pack.
  Future<String?> getLocalizedPrice(ResourcePack pack) {
    return iapProvider.getLocalizedPrice(pack.productId);
  }

  /// Restore previous purchases.
  ///
  /// This is typically called when user taps "Restore Purchases" button.
  /// The implementation depends on how your IAP provider tracks purchases.
  Future<void> restorePurchases() async {
    await iapProvider.restorePurchases();
    // Note: The actual resource restoration would need to be handled
    // by your IAP provider implementation, which should call
    // addPurchasedResources() for each restored purchase.
  }

  /// Dispose resources.
  void dispose() {
    _inventoryController.close();
  }
}
