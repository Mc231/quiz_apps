import 'bundle_pack.dart';
import 'resource_type.dart';

/// Configuration for the resource system.
///
/// Defines daily free limits, ad reward amounts, and available purchase packs.
/// All settings are configurable per app.
///
/// Example usage:
/// ```dart
/// final config = ResourceConfig(
///   dailyFreeLimits: {
///     ResourceType.lives(): 5,
///     ResourceType.fiftyFifty(): 3,
///     ResourceType.skip(): 2,
///   },
///   adRewardAmounts: {
///     ResourceType.lives(): 1,
///     ResourceType.fiftyFifty(): 1,
///     ResourceType.skip(): 1,
///   },
///   purchasePacks: [
///     ResourcePack(
///       id: 'lives_5',
///       type: ResourceType.lives(),
///       amount: 5,
///       productId: 'com.app.lives_5',
///     ),
///   ],
/// );
/// ```
class ResourceConfig {
  /// Daily free limits per resource type.
  ///
  /// Resources reset to these values at midnight local time.
  final Map<ResourceType, int> dailyFreeLimits;

  /// Amount rewarded per ad view, per resource type.
  final Map<ResourceType, int> adRewardAmounts;

  /// Available purchase packs (defined by app).
  final List<ResourcePack> purchasePacks;

  /// Available bundle packs (defined by app).
  final List<BundlePack> bundlePacks;

  /// Whether to show ads option (requires [AdRewardProvider]).
  final bool enableAds;

  /// Whether to show purchase option (requires [IAPProvider]).
  final bool enablePurchases;

  /// Creates a [ResourceConfig] with the specified settings.
  const ResourceConfig({
    required this.dailyFreeLimits,
    required this.adRewardAmounts,
    this.purchasePacks = const [],
    this.bundlePacks = const [],
    this.enableAds = true,
    this.enablePurchases = true,
  });

  /// Standard configuration with sensible defaults.
  ///
  /// - Lives: 5/day, +1 per ad
  /// - 50/50: 3/day, +1 per ad
  /// - Skip: 2/day, +1 per ad
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

  /// No free resources (hardcore mode).
  ///
  /// Users must watch ads or purchase to get resources.
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

  /// Generous free tier.
  ///
  /// - Lives: 10/day, +2 per ad
  /// - 50/50: 5/day, +2 per ad
  /// - Skip: 5/day, +2 per ad
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

  /// Get the daily free limit for a resource type.
  ///
  /// Returns 0 if not configured.
  int getDailyLimit(ResourceType type) => dailyFreeLimits[type] ?? 0;

  /// Get the ad reward amount for a resource type.
  ///
  /// Returns 0 if not configured.
  int getAdReward(ResourceType type) => adRewardAmounts[type] ?? 0;

  /// Get purchase packs for a specific resource type.
  List<ResourcePack> getPacksForType(ResourceType type) {
    return purchasePacks.where((pack) => pack.type == type).toList();
  }

  /// Get a bundle pack by its product ID.
  ///
  /// Returns `null` if no bundle with the given product ID exists.
  BundlePack? getBundleByProductId(String productId) {
    try {
      return bundlePacks.firstWhere((bundle) => bundle.productId == productId);
    } catch (_) {
      return null;
    }
  }

  /// Creates a copy with the given fields replaced.
  ResourceConfig copyWith({
    Map<ResourceType, int>? dailyFreeLimits,
    Map<ResourceType, int>? adRewardAmounts,
    List<ResourcePack>? purchasePacks,
    List<BundlePack>? bundlePacks,
    bool? enableAds,
    bool? enablePurchases,
  }) {
    return ResourceConfig(
      dailyFreeLimits: dailyFreeLimits ?? this.dailyFreeLimits,
      adRewardAmounts: adRewardAmounts ?? this.adRewardAmounts,
      purchasePacks: purchasePacks ?? this.purchasePacks,
      bundlePacks: bundlePacks ?? this.bundlePacks,
      enableAds: enableAds ?? this.enableAds,
      enablePurchases: enablePurchases ?? this.enablePurchases,
    );
  }
}

/// A purchasable pack of resources.
///
/// Represents a bundle that users can buy via in-app purchase.
///
/// Example:
/// ```dart
/// final pack = ResourcePack(
///   id: 'lives_20',
///   type: ResourceType.lives(),
///   amount: 20,
///   productId: 'com.flagsquiz.lives_20',
/// );
/// ```
class ResourcePack {
  /// Unique identifier for this pack.
  final String id;

  /// Type of resource in this pack.
  final ResourceType type;

  /// Amount of resources in this pack.
  final int amount;

  /// IAP product ID (platform-specific).
  ///
  /// This should match the product ID configured in App Store Connect
  /// or Google Play Console.
  final String productId;

  /// Display price (for UI, actual price comes from store).
  ///
  /// This is a fallback value; prefer fetching the localized price
  /// from the IAP provider at runtime.
  final String? displayPrice;

  /// Optional icon asset override.
  ///
  /// If not provided, the resource type's default icon will be used.
  final String? iconAsset;

  /// Whether this pack is marked as "best value".
  ///
  /// Used to highlight recommended packs in the UI.
  final bool isBestValue;

  /// Creates a [ResourcePack].
  const ResourcePack({
    required this.id,
    required this.type,
    required this.amount,
    required this.productId,
    this.displayPrice,
    this.iconAsset,
    this.isBestValue = false,
  });

  /// Creates a copy with the given fields replaced.
  ResourcePack copyWith({
    String? id,
    ResourceType? type,
    int? amount,
    String? productId,
    String? displayPrice,
    String? iconAsset,
    bool? isBestValue,
  }) {
    return ResourcePack(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      productId: productId ?? this.productId,
      displayPrice: displayPrice ?? this.displayPrice,
      iconAsset: iconAsset ?? this.iconAsset,
      isBestValue: isBestValue ?? this.isBestValue,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResourcePack && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ResourcePack($id: ${amount}x ${type.id})';
}
