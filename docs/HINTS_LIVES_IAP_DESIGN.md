# Hints & Lives IAP/Ads Architecture

**Sprint:** 8.15
**Status:** Design
**Last Updated:** 2025-12-26

---

## Overview

This document defines the architecture for integrating hints and lives with in-app purchases (IAP) and rewarded ads. The system uses a **hybrid pool model** where users get free daily resources that reset at midnight, plus permanent purchased resources that never expire.

---

## Goals

1. **Monetization Ready**: Prepare interfaces for IAP and rewarded ads integration
2. **Fair Free Tier**: Provide meaningful daily free resources
3. **Flexible Configuration**: All limits configurable per app
4. **Offline Resilient**: Clear behavior when offline
5. **Future Proof**: Easy to extend with new resource types

---

## Resource Types

Using a sealed class allows each resource type to carry its own associated data (icon, color, localization key):

```dart
/// Resource types available in the quiz system
///
/// Each resource type has associated visual properties and localization keys.
/// Using sealed class pattern for type-safe pattern matching and extensibility.
sealed class ResourceType {
  /// Icon for this resource type
  IconData get icon;

  /// Default color for this resource type
  Color get color;

  /// Localization key for the resource name
  String get localizationKey;

  /// Unique identifier for database storage
  String get id;

  const ResourceType();

  /// Lives (hearts) - lose one on wrong answer
  factory ResourceType.lives() = LivesResource;

  /// 50/50 hint - eliminate 2 wrong answers
  factory ResourceType.fiftyFifty() = FiftyFiftyResource;

  /// Skip hint - skip question without penalty
  factory ResourceType.skip() = SkipResource;

  /// All available resource types
  static List<ResourceType> get values => const [
    LivesResource(),
    FiftyFiftyResource(),
    SkipResource(),
  ];

  /// Get resource type by ID (for database lookups)
  static ResourceType? fromId(String id) {
    return switch (id) {
      'lives' => const LivesResource(),
      'fiftyFifty' => const FiftyFiftyResource(),
      'skip' => const SkipResource(),
      _ => null,
    };
  }
}

/// Lives resource - hearts that are lost on wrong answers
class LivesResource extends ResourceType {
  const LivesResource();

  @override
  IconData get icon => Icons.favorite;

  @override
  Color get color => const Color(0xFFF44336); // Colors.red

  @override
  String get localizationKey => 'lives';

  @override
  String get id => 'lives';
}

/// 50/50 hint - eliminates 2 wrong answers
class FiftyFiftyResource extends ResourceType {
  const FiftyFiftyResource();

  @override
  IconData get icon => Icons.filter_2;

  @override
  Color get color => const Color(0xFF2196F3); // Colors.blue

  @override
  String get localizationKey => 'fiftyFifty';

  @override
  String get id => 'fiftyFifty';
}

/// Skip hint - skip question without penalty
class SkipResource extends ResourceType {
  const SkipResource();

  @override
  IconData get icon => Icons.skip_next;

  @override
  Color get color => const Color(0xFFFF9800); // Colors.orange

  @override
  String get localizationKey => 'skip';

  @override
  String get id => 'skip';
}
```

### Usage with Pattern Matching

```dart
// Get localized name
String getResourceName(ResourceType type, AppLocalizations l10n) {
  return switch (type) {
    LivesResource() => l10n.lives,
    FiftyFiftyResource() => l10n.fiftyFifty,
    SkipResource() => l10n.skip,
  };
}

// Build UI based on type
Widget buildResourceIcon(ResourceType type) {
  return Icon(type.icon, color: type.color);
}
```

---

## Hybrid Pool Model

Each resource has two separate pools:

```
┌─────────────────────────────────────────────────────────────┐
│                    Resource Inventory                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────┐    ┌─────────────────────────────┐ │
│  │   FREE POOL         │    │   PURCHASED POOL            │ │
│  │   (Daily Reset)     │    │   (Permanent)               │ │
│  ├─────────────────────┤    ├─────────────────────────────┤ │
│  │ • Resets at midnight│    │ • Never expires             │ │
│  │ • Capped at daily   │    │ • Added via purchase or ad  │ │
│  │   limit             │    │ • No daily cap              │ │
│  │ • Cannot exceed cap │    │                             │ │
│  └─────────────────────┘    └─────────────────────────────┘ │
│                                                              │
│  Available = freeRemaining + purchasedRemaining              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Usage Priority

When a resource is used, deduct from pools in this order:
1. **Free pool first** (use it or lose it at midnight)
2. **Purchased pool second** (preserve permanent resources)

### Example

```
Daily limit: 5 lives
Current state: 2 free + 3 purchased = 5 available

User loses a life:
→ Deduct from free pool first
→ New state: 1 free + 3 purchased = 4 available

At midnight:
→ Free pool resets to 5
→ New state: 5 free + 3 purchased = 8 available
```

---

## Configuration

### ResourceConfig

All settings are configurable per app:

```dart
/// Configuration for the resource system
class ResourceConfig {
  /// Daily free limits per resource type
  /// Resources reset to these values at midnight
  final Map<ResourceType, int> dailyFreeLimits;

  /// Amount rewarded per ad view, per resource type
  final Map<ResourceType, int> adRewardAmounts;

  /// Available purchase packs (defined by app)
  final List<ResourcePack> purchasePacks;

  /// Whether to show ads option (requires AdRewardProvider)
  final bool enableAds;

  /// Whether to show purchase option (requires IAPProvider)
  final bool enablePurchases;

  const ResourceConfig({
    required this.dailyFreeLimits,
    required this.adRewardAmounts,
    this.purchasePacks = const [],
    this.enableAds = true,
    this.enablePurchases = true,
  });

  /// Standard configuration with sensible defaults
  factory ResourceConfig.standard() => ResourceConfig(
    dailyFreeLimits: {
      ResourceType.lives(): 5,
      ResourceType.fiftyFifty(): 3,
      ResourceType.skip(): 2,
    },
    adRewardAmounts: {
      ResourceType.lives(): 1,
      ResourceType.fiftyFifty(): 1,
      ResourceType.skip(): 1,
    },
  );

  /// No free resources (hardcore mode)
  factory ResourceConfig.noFree() => ResourceConfig(
    dailyFreeLimits: {
      ResourceType.lives(): 0,
      ResourceType.fiftyFifty(): 0,
      ResourceType.skip(): 0,
    },
    adRewardAmounts: {
      ResourceType.lives(): 1,
      ResourceType.fiftyFifty(): 1,
      ResourceType.skip(): 1,
    },
  );

  /// Generous free tier
  factory ResourceConfig.generous() => ResourceConfig(
    dailyFreeLimits: {
      ResourceType.lives(): 10,
      ResourceType.fiftyFifty(): 5,
      ResourceType.skip(): 5,
    },
    adRewardAmounts: {
      ResourceType.lives(): 2,
      ResourceType.fiftyFifty(): 2,
      ResourceType.skip(): 2,
    },
  );
}
```

### ResourcePack

```dart
/// A purchasable pack of resources
class ResourcePack {
  /// Unique identifier for this pack
  final String id;

  /// Type of resource in this pack
  final ResourceType type;

  /// Amount of resources in this pack
  final int amount;

  /// IAP product ID (platform-specific)
  final String productId;

  /// Display price (for UI, actual price from store)
  final String? displayPrice;

  /// Optional icon override
  final String? iconAsset;

  const ResourcePack({
    required this.id,
    required this.type,
    required this.amount,
    required this.productId,
    this.displayPrice,
    this.iconAsset,
  });
}
```

### Example: Flags Quiz Configuration

```dart
// In apps/flagsquiz/lib/config/resource_config.dart

final flagsResourceConfig = ResourceConfig(
  dailyFreeLimits: {
    ResourceType.lives(): 5,
    ResourceType.fiftyFifty(): 3,
    ResourceType.skip(): 2,
  },
  adRewardAmounts: {
    ResourceType.lives(): 1,
    ResourceType.fiftyFifty(): 1,
    ResourceType.skip(): 1,
  },
  purchasePacks: [
    // Lives packs
    ResourcePack(
      id: 'lives_small',
      type: ResourceType.lives(),
      amount: 5,
      productId: 'com.flagsquiz.lives_5',
    ),
    ResourcePack(
      id: 'lives_medium',
      type: ResourceType.lives(),
      amount: 20,
      productId: 'com.flagsquiz.lives_20',
    ),
    ResourcePack(
      id: 'lives_large',
      type: ResourceType.lives(),
      amount: 50,
      productId: 'com.flagsquiz.lives_50',
    ),

    // 50/50 packs
    ResourcePack(
      id: 'fifty_small',
      type: ResourceType.fiftyFifty(),
      amount: 5,
      productId: 'com.flagsquiz.fifty_5',
    ),
    ResourcePack(
      id: 'fifty_medium',
      type: ResourceType.fiftyFifty(),
      amount: 15,
      productId: 'com.flagsquiz.fifty_15',
    ),

    // Skip packs
    ResourcePack(
      id: 'skip_small',
      type: ResourceType.skip(),
      amount: 5,
      productId: 'com.flagsquiz.skip_5',
    ),
    ResourcePack(
      id: 'skip_medium',
      type: ResourceType.skip(),
      amount: 15,
      productId: 'com.flagsquiz.skip_15',
    ),
  ],
);
```

---

## Provider Interfaces

### AdRewardProvider

Implemented by the app when rewarded ads are integrated:

```dart
/// Interface for rewarded ad integration
///
/// Implement this in your app when ready to show rewarded ads.
/// Pass to ResourceManager to enable "Watch Ad" option.
abstract class AdRewardProvider {
  /// Whether a rewarded ad is currently available to show
  bool get isAdAvailable;

  /// Show a rewarded ad
  ///
  /// Returns `true` if the user watched the full ad and should receive reward.
  /// Returns `false` if ad was skipped, failed, or not available.
  Future<bool> showRewardedAd();

  /// Stream of ad availability changes
  ///
  /// Useful for updating UI when ads become available/unavailable.
  Stream<bool> get onAdAvailabilityChanged;
}

/// Stub implementation when ads are not yet integrated
class NoAdsProvider implements AdRewardProvider {
  @override
  bool get isAdAvailable => false;

  @override
  Future<bool> showRewardedAd() async => false;

  @override
  Stream<bool> get onAdAvailabilityChanged => Stream.value(false);
}
```

### IAPProvider

Implemented by the app when in-app purchases are integrated:

```dart
/// Result of a purchase attempt
enum PurchaseResult {
  /// Purchase completed successfully
  success,

  /// User cancelled the purchase
  cancelled,

  /// Purchase failed (network, payment, etc.)
  failed,

  /// Purchase is pending (e.g., parental approval)
  pending,
}

/// Interface for in-app purchase integration
///
/// Implement this in your app when ready to process purchases.
/// Pass to ResourceManager to enable purchase options.
abstract class IAPProvider {
  /// Whether the store is available and ready
  bool get isStoreAvailable;

  /// Attempt to purchase a product
  ///
  /// [productId] is the platform-specific product identifier.
  /// Returns the result of the purchase attempt.
  Future<PurchaseResult> purchase(String productId);

  /// Get the localized price for a product
  ///
  /// Returns null if product not found or store unavailable.
  Future<String?> getLocalizedPrice(String productId);

  /// Restore previous purchases
  ///
  /// Returns list of product IDs that were restored.
  Future<List<String>> restorePurchases();

  /// Stream of store availability changes
  Stream<bool> get onStoreAvailabilityChanged;
}

/// Stub implementation when IAP is not yet integrated
class NoIAPProvider implements IAPProvider {
  @override
  bool get isStoreAvailable => false;

  @override
  Future<PurchaseResult> purchase(String productId) async => PurchaseResult.failed;

  @override
  Future<String?> getLocalizedPrice(String productId) async => null;

  @override
  Future<List<String>> restorePurchases() async => [];

  @override
  Stream<bool> get onStoreAvailabilityChanged => Stream.value(false);
}
```

---

## ResourceManager

Central service for managing resource inventory:

```dart
/// Manages resource inventory (lives, hints, skips)
///
/// Handles:
/// - Tracking free and purchased pools
/// - Daily reset at midnight
/// - Consuming resources during gameplay
/// - Adding resources via ads or purchases
class ResourceManager {
  final ResourceConfig config;
  final AdRewardProvider adProvider;
  final IAPProvider iapProvider;
  final ResourceRepository repository;

  ResourceManager({
    required this.config,
    this.adProvider = const NoAdsProvider(),
    this.iapProvider = const NoIAPProvider(),
    required this.repository,
  });

  /// Initialize the manager (load from database, check reset)
  Future<void> initialize() async;

  /// Get current inventory for a resource type
  ResourceInventory getInventory(ResourceType type);

  /// Get total available count for a resource type
  int getAvailableCount(ResourceType type);

  /// Check if resource is available (count > 0)
  bool isAvailable(ResourceType type);

  /// Use one resource (deducts from free pool first)
  ///
  /// Returns `true` if resource was available and used.
  /// Returns `false` if no resources available.
  Future<bool> useResource(ResourceType type);

  /// Add resources to purchased pool
  Future<void> addPurchasedResources(ResourceType type, int amount);

  /// Attempt to restore resource via rewarded ad
  ///
  /// Shows ad, waits for completion, adds resource if successful.
  /// Returns `true` if resource was added.
  Future<bool> restoreViaAd(ResourceType type);

  /// Attempt to purchase a resource pack
  ///
  /// Initiates purchase flow, adds resources if successful.
  /// Returns the purchase result.
  Future<PurchaseResult> purchasePack(ResourcePack pack);

  /// Check if daily reset is needed and perform it
  Future<void> checkAndResetDaily();

  /// Stream of inventory changes
  Stream<Map<ResourceType, ResourceInventory>> get onInventoryChanged;

  /// Dispose resources
  void dispose();
}

/// Inventory state for a single resource type
class ResourceInventory {
  /// Remaining free resources (resets daily)
  final int freeRemaining;

  /// Daily limit for free resources
  final int freeLimit;

  /// Remaining purchased resources (never expires)
  final int purchasedRemaining;

  /// Total available (free + purchased)
  int get total => freeRemaining + purchasedRemaining;

  /// Whether any resources are available
  bool get isAvailable => total > 0;

  /// Whether free pool is depleted
  bool get isFreeDepleted => freeRemaining <= 0;

  const ResourceInventory({
    required this.freeRemaining,
    required this.freeLimit,
    required this.purchasedRemaining,
  });
}
```

---

## Database Schema

### Table: resource_inventory

```sql
CREATE TABLE resource_inventory (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  resource_type TEXT NOT NULL,           -- 'lives', 'fiftyFifty', 'skip'
  free_remaining INTEGER NOT NULL,        -- Current free pool count
  purchased_remaining INTEGER NOT NULL,   -- Current purchased pool count
  last_reset_date TEXT NOT NULL,          -- ISO8601 date of last reset
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,

  UNIQUE(resource_type)
);
```

### Repository Interface

```dart
/// Repository for persisting resource inventory
abstract class ResourceRepository {
  /// Get inventory for a resource type
  Future<ResourceInventoryEntity?> getInventory(ResourceType type);

  /// Save inventory for a resource type
  Future<void> saveInventory(ResourceType type, ResourceInventoryEntity entity);

  /// Get all inventories
  Future<Map<ResourceType, ResourceInventoryEntity>> getAllInventories();

  /// Reset free pools to daily limits
  Future<void> resetFreePools(Map<ResourceType, int> dailyLimits);

  /// Get last reset date
  Future<DateTime?> getLastResetDate();

  /// Set last reset date
  Future<void> setLastResetDate(DateTime date);
}

/// Database entity for resource inventory
class ResourceInventoryEntity {
  final String resourceType;
  final int freeRemaining;
  final int purchasedRemaining;
  final DateTime lastResetDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ... constructors, fromMap, toMap
}
```

---

## Daily Reset Logic

```dart
/// Check and perform daily reset if needed
Future<void> checkAndResetDaily() async {
  final now = DateTime.now();
  final lastReset = await repository.getLastResetDate();

  // First launch - initialize with daily limits
  if (lastReset == null) {
    await _initializeInventory();
    await repository.setLastResetDate(now);
    return;
  }

  // Check if we've crossed midnight since last reset
  final lastResetDate = DateTime(lastReset.year, lastReset.month, lastReset.day);
  final todayDate = DateTime(now.year, now.month, now.day);

  if (todayDate.isAfter(lastResetDate)) {
    // Reset free pools to daily limits
    await repository.resetFreePools(config.dailyFreeLimits);
    await repository.setLastResetDate(now);

    // Notify listeners
    _inventoryController.add(await _loadAllInventories());
  }
}

/// Initialize inventory for first launch
Future<void> _initializeInventory() async {
  for (final type in ResourceType.values) {
    final dailyLimit = config.dailyFreeLimits[type] ?? 0;
    await repository.saveInventory(type, ResourceInventoryEntity(
      resourceType: type.id,
      freeRemaining: dailyLimit,
      purchasedRemaining: 0,
      lastResetDate: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));
  }
}
```

---

## UI Components

### RestoreResourceDialog

Shown when user taps on a depleted resource:

```
┌─────────────────────────────────────────┐
│              Need More Lives?           │
│                                         │
│              ❤️                         │
│           0 remaining                   │
│                                         │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  🎬  Watch Ad for +1 Life       │   │  ← Only if online & ad available
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  💰  Buy Lives...               │   │  ← Opens PurchaseResourceSheet
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  ❌  No Thanks                  │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

### PurchaseResourceSheet

Bottom sheet for selecting a purchase pack:

```
┌─────────────────────────────────────────┐
│              Buy Lives                  │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  ❤️ x5          $0.99           │   │
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  ❤️ x20         $2.99      ⭐   │   │  ← Best value badge
│  └─────────────────────────────────┘   │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │  ❤️ x50         $4.99           │   │
│  └─────────────────────────────────┘   │
│                                         │
│           [Restore Purchases]           │
│                                         │
└─────────────────────────────────────────┘
```

### Offline State

When offline and user taps depleted resource:

```
┌─────────────────────────────────────────┐
│              No Connection              │
│                                         │
│              📡                         │
│                                         │
│    Connect to the internet to          │
│    restore your resources.              │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │           OK                    │   │
│  └─────────────────────────────────┘   │
│                                         │
└─────────────────────────────────────────┘
```

---

## Integration Flow

### 1. App Setup

```dart
// In app initialization
final resourceManager = ResourceManager(
  config: flagsResourceConfig,
  adProvider: NoAdsProvider(),      // Replace when ads ready
  iapProvider: NoIAPProvider(),     // Replace when IAP ready
  repository: SqliteResourceRepository(database),
);

await resourceManager.initialize();
```

### 2. Quiz Integration

```dart
// In QuizBloc or QuizScreen
void useHint(HintType type) {
  final resourceType = _mapHintToResource(type);

  if (resourceManager.isAvailable(resourceType)) {
    resourceManager.useResource(resourceType);
    // Apply hint effect
  } else {
    // Show restore dialog
    _showRestoreDialog(resourceType);
  }
}

void _showRestoreDialog(ResourceType type) {
  showDialog(
    context: context,
    builder: (_) => RestoreResourceDialog(
      resourceType: type,
      manager: resourceManager,
      onRestored: () {
        // Resource restored, user can try again
      },
    ),
  );
}
```

### 3. Future: Adding Ads

```dart
// When AdMob is integrated
class AdMobRewardProvider implements AdRewardProvider {
  final RewardedAd? _rewardedAd;

  @override
  bool get isAdAvailable => _rewardedAd != null;

  @override
  Future<bool> showRewardedAd() async {
    if (_rewardedAd == null) return false;

    final completer = Completer<bool>();

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        completer.complete(true);
      },
    );

    return completer.future;
  }

  // ... load ads, handle availability
}

// Update app initialization
final resourceManager = ResourceManager(
  config: flagsResourceConfig,
  adProvider: AdMobRewardProvider(),  // Now with real ads!
  iapProvider: NoIAPProvider(),
  repository: SqliteResourceRepository(database),
);
```

### 4. Future: Adding IAP

```dart
// When RevenueCat/StoreKit is integrated
class RevenueCatIAPProvider implements IAPProvider {
  @override
  bool get isStoreAvailable => Purchases.isConfigured;

  @override
  Future<PurchaseResult> purchase(String productId) async {
    try {
      await Purchases.purchaseProduct(productId);
      return PurchaseResult.success;
    } on PurchasesErrorCode catch (e) {
      if (e == PurchasesErrorCode.purchaseCancelledError) {
        return PurchaseResult.cancelled;
      }
      return PurchaseResult.failed;
    }
  }

  // ... other methods
}

// Update app initialization
final resourceManager = ResourceManager(
  config: flagsResourceConfig,
  adProvider: AdMobRewardProvider(),
  iapProvider: RevenueCatIAPProvider(),  // Now with real IAP!
  repository: SqliteResourceRepository(database),
);
```

---

## Localization Strings

Add to `quiz_engine_en.arb`:

```json
{
  "needMoreLives": "Need More Lives?",
  "needMoreHints": "Need More Hints?",
  "needMoreSkips": "Need More Skips?",
  "resourceRemaining": "{count} remaining",
  "@resourceRemaining": {
    "placeholders": {
      "count": {"type": "int"}
    }
  },
  "watchAdForResource": "Watch Ad for +{count} {resource}",
  "@watchAdForResource": {
    "placeholders": {
      "count": {"type": "int"},
      "resource": {"type": "String"}
    }
  },
  "buyResource": "Buy {resource}...",
  "@buyResource": {
    "placeholders": {
      "resource": {"type": "String"}
    }
  },
  "noThanks": "No Thanks",
  "buyLives": "Buy Lives",
  "buyHints": "Buy Hints",
  "buySkips": "Buy Skips",
  "bestValue": "Best Value",
  "restorePurchases": "Restore Purchases",
  "noConnection": "No Connection",
  "connectToRestore": "Connect to the internet to restore your resources.",
  "ok": "OK",
  "purchaseSuccess": "Purchase successful! +{count} {resource}",
  "@purchaseSuccess": {
    "placeholders": {
      "count": {"type": "int"},
      "resource": {"type": "String"}
    }
  },
  "purchaseFailed": "Purchase failed. Please try again.",
  "purchaseCancelled": "Purchase cancelled.",
  "adWatchSuccess": "+{count} {resource} added!",
  "@adWatchSuccess": {
    "placeholders": {
      "count": {"type": "int"},
      "resource": {"type": "String"}
    }
  },
  "adNotAvailable": "Ad not available. Please try again later.",
  "dailyLimitReset": "Daily resources reset!",
  "freeResourcesInfo": "{count} free {resource} per day",
  "@freeResourcesInfo": {
    "placeholders": {
      "count": {"type": "int"},
      "resource": {"type": "String"}
    }
  }
}
```

---

## File Structure

```
packages/shared_services/lib/src/
├── resources/
│   ├── resource_type.dart              # ResourceType sealed class
│   ├── resource_config.dart            # ResourceConfig, ResourcePack
│   ├── resource_inventory.dart         # ResourceInventory model
│   ├── resource_manager.dart           # ResourceManager service
│   ├── resource_repository.dart        # Repository interface
│   └── providers/
│       ├── ad_reward_provider.dart     # AdRewardProvider interface
│       └── iap_provider.dart           # IAPProvider interface
├── storage/database/
│   ├── tables/
│   │   └── resource_inventory_table.dart
│   └── repositories/
│       └── sqlite_resource_repository.dart

packages/quiz_engine/lib/src/
├── widgets/
│   ├── restore_resource_dialog.dart    # Dialog for restoring resources
│   └── purchase_resource_sheet.dart    # Bottom sheet for purchases
```

---

## Testing Strategy

### Unit Tests

1. **ResourceManager**
   - Initialize with empty database
   - Use resource from free pool
   - Use resource from purchased pool (when free depleted)
   - Daily reset logic
   - Add purchased resources

2. **Daily Reset**
   - Reset when crossing midnight
   - No reset on same day
   - Handle timezone edge cases

3. **ResourceConfig**
   - Factory constructors
   - Custom configurations

### Widget Tests

1. **RestoreResourceDialog**
   - Shows correct resource type
   - Watch ad button visibility (online/offline, ad available)
   - Purchase button opens sheet
   - Cancel closes dialog

2. **PurchaseResourceSheet**
   - Shows all packs for resource type
   - Displays prices
   - Restore purchases button

### Integration Tests

1. Full flow: deplete resource → show dialog → watch ad → resource restored
2. Full flow: deplete resource → show dialog → purchase → resource added

---

## Implementation Checklist

- [x] Create design document (this file)
- [ ] Create `ResourceType` sealed class with factory methods
- [ ] Create `ResourceConfig` and `ResourcePack` models
- [ ] Create `ResourceInventory` model
- [ ] Create `AdRewardProvider` interface with stub
- [ ] Create `IAPProvider` interface with stub
- [ ] Create `ResourceRepository` interface
- [ ] Create database table `resource_inventory`
- [ ] Implement `SqliteResourceRepository`
- [ ] Implement `ResourceManager`
- [ ] Implement daily reset mechanism
- [ ] Create `RestoreResourceDialog` widget
- [ ] Create `PurchaseResourceSheet` widget
- [ ] Add localization strings
- [ ] Write unit tests for ResourceManager
- [ ] Write unit tests for daily reset
- [ ] Write widget tests for dialogs
- [ ] Update `GameResourceButton` to use ResourceManager
- [ ] Integration with QuizBloc

---

## Future Considerations

### Subscription Model

Could add a "Premium" subscription that:
- Removes ads
- Unlimited hints/lives
- Or significantly higher daily limits

### Consumable vs Non-Consumable

Current design uses consumables (use once, buy again). Could add:
- Non-consumable "Unlimited Lives" one-time purchase
- Subscription for unlimited resources

### Analytics

Track for optimization:
- Resource depletion events
- Ad watch rate
- Purchase conversion rate
- Daily active users by resource type

### A/B Testing

Test different configurations:
- Daily limits (3 vs 5 vs 10)
- Ad reward amounts (1 vs 2)
- Pack pricing

---

## Approval

- [ ] Architecture reviewed
- [ ] Hybrid pool model approved
- [ ] Provider interfaces approved
- [ ] Database schema approved
- [ ] UI mockups approved
- [ ] Ready for implementation
