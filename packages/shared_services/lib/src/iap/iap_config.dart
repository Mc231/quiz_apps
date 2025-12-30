import 'iap_product.dart';

/// Configuration for the IAP service.
///
/// Defines which products are available for purchase in the app.
/// Each app provides its own configuration with app-specific product IDs.
///
/// Example:
/// ```dart
/// final config = IAPConfig(
///   consumableProducts: [
///     IAPProduct.definition(id: 'lives_small', type: IAPProductType.consumable),
///     IAPProduct.definition(id: 'hints_small', type: IAPProductType.consumable),
///   ],
///   nonConsumableProducts: [
///     IAPProduct.definition(id: 'remove_ads', type: IAPProductType.nonConsumable),
///   ],
///   subscriptionProducts: [
///     IAPProduct.definition(id: 'premium_monthly', type: IAPProductType.subscription),
///   ],
/// );
/// ```
class IAPConfig {
  /// Creates an [IAPConfig].
  const IAPConfig({
    this.consumableProducts = const [],
    this.nonConsumableProducts = const [],
    this.subscriptionProducts = const [],
    this.verifyPurchases = true,
    this.autoFinishTransactions = true,
  });

  /// Creates a test configuration for development.
  ///
  /// Includes standard product IDs that can be used with sandbox testing.
  factory IAPConfig.test() => IAPConfig(
        consumableProducts: [
          const IAPProduct.definition(
            id: 'lives_small',
            type: IAPProductType.consumable,
            title: '5 Lives',
            description: 'Get 5 extra lives',
          ),
          const IAPProduct.definition(
            id: 'lives_medium',
            type: IAPProductType.consumable,
            title: '15 Lives',
            description: 'Get 15 extra lives',
          ),
          const IAPProduct.definition(
            id: 'lives_large',
            type: IAPProductType.consumable,
            title: '50 Lives',
            description: 'Get 50 extra lives',
          ),
          const IAPProduct.definition(
            id: 'hints_small',
            type: IAPProductType.consumable,
            title: '10 Hints',
            description: 'Get 10 hints',
          ),
          const IAPProduct.definition(
            id: 'hints_medium',
            type: IAPProductType.consumable,
            title: '30 Hints',
            description: 'Get 30 hints',
          ),
          const IAPProduct.definition(
            id: 'hints_large',
            type: IAPProductType.consumable,
            title: '100 Hints',
            description: 'Get 100 hints',
          ),
          const IAPProduct.definition(
            id: 'bundle_starter',
            type: IAPProductType.consumable,
            title: 'Starter Pack',
            description: '5 lives + 10 hints',
          ),
          const IAPProduct.definition(
            id: 'bundle_value',
            type: IAPProductType.consumable,
            title: 'Value Pack',
            description: '15 lives + 30 hints',
          ),
          const IAPProduct.definition(
            id: 'bundle_pro',
            type: IAPProductType.consumable,
            title: 'Pro Pack',
            description: '50 lives + 100 hints',
          ),
        ],
        nonConsumableProducts: [
          const IAPProduct.definition(
            id: 'remove_ads',
            type: IAPProductType.nonConsumable,
            title: 'Remove Ads',
            description: 'Remove all advertisements',
          ),
        ],
        subscriptionProducts: [
          const IAPProduct.definition(
            id: 'premium_monthly',
            type: IAPProductType.subscription,
            title: 'Premium Monthly',
            description: 'Premium features - monthly subscription',
          ),
          const IAPProduct.definition(
            id: 'premium_yearly',
            type: IAPProductType.subscription,
            title: 'Premium Yearly',
            description: 'Premium features - yearly subscription (save 58%)',
          ),
        ],
      );

  /// Creates an empty configuration.
  ///
  /// Use this when IAP is completely disabled.
  const IAPConfig.empty()
      : consumableProducts = const [],
        nonConsumableProducts = const [],
        subscriptionProducts = const [],
        verifyPurchases = false,
        autoFinishTransactions = true;

  /// Consumable products (can be purchased multiple times).
  ///
  /// Examples: lives, hints, bundles.
  final List<IAPProduct> consumableProducts;

  /// Non-consumable products (one-time purchases).
  ///
  /// Examples: remove_ads, unlock_all_levels.
  final List<IAPProduct> nonConsumableProducts;

  /// Subscription products (recurring purchases).
  ///
  /// Examples: premium_monthly, premium_yearly.
  final List<IAPProduct> subscriptionProducts;

  /// Whether to verify purchases server-side.
  ///
  /// Set to `false` for testing without a verification server.
  final bool verifyPurchases;

  /// Whether to automatically finish transactions.
  ///
  /// Set to `false` if you need to manually acknowledge purchases
  /// after server verification.
  final bool autoFinishTransactions;

  /// All product IDs combined.
  Set<String> get allProductIds => {
        ...consumableProducts.map((p) => p.id),
        ...nonConsumableProducts.map((p) => p.id),
        ...subscriptionProducts.map((p) => p.id),
      };

  /// Get the product type for a given product ID.
  IAPProductType? getProductType(String productId) {
    if (consumableProducts.any((p) => p.id == productId)) {
      return IAPProductType.consumable;
    }
    if (nonConsumableProducts.any((p) => p.id == productId)) {
      return IAPProductType.nonConsumable;
    }
    if (subscriptionProducts.any((p) => p.id == productId)) {
      return IAPProductType.subscription;
    }
    return null;
  }

  /// Check if a product ID is for a consumable.
  bool isConsumable(String productId) =>
      consumableProducts.any((p) => p.id == productId);

  /// Check if a product ID is for a non-consumable.
  bool isNonConsumable(String productId) =>
      nonConsumableProducts.any((p) => p.id == productId);

  /// Check if a product ID is for a subscription.
  bool isSubscription(String productId) =>
      subscriptionProducts.any((p) => p.id == productId);

  /// Creates a copy with the given fields replaced.
  IAPConfig copyWith({
    List<IAPProduct>? consumableProducts,
    List<IAPProduct>? nonConsumableProducts,
    List<IAPProduct>? subscriptionProducts,
    bool? verifyPurchases,
    bool? autoFinishTransactions,
  }) {
    return IAPConfig(
      consumableProducts: consumableProducts ?? this.consumableProducts,
      nonConsumableProducts:
          nonConsumableProducts ?? this.nonConsumableProducts,
      subscriptionProducts: subscriptionProducts ?? this.subscriptionProducts,
      verifyPurchases: verifyPurchases ?? this.verifyPurchases,
      autoFinishTransactions:
          autoFinishTransactions ?? this.autoFinishTransactions,
    );
  }
}
