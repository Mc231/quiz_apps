/// Result of a purchase attempt.
enum PurchaseResult {
  /// Purchase completed successfully.
  success,

  /// User cancelled the purchase.
  cancelled,

  /// Purchase failed (network, payment, etc.).
  failed,

  /// Purchase is pending (e.g., parental approval).
  pending,
}

/// Interface for in-app purchase integration.
///
/// Implement this in your app when ready to process purchases.
/// Pass to [ResourceManager] to enable purchase options.
///
/// Example implementation with RevenueCat:
/// ```dart
/// class RevenueCatIAPProvider implements IAPProvider {
///   @override
///   bool get isStoreAvailable => Purchases.isConfigured;
///
///   @override
///   Future<PurchaseResult> purchase(String productId) async {
///     try {
///       await Purchases.purchaseProduct(productId);
///       return PurchaseResult.success;
///     } on PurchasesErrorCode catch (e) {
///       if (e == PurchasesErrorCode.purchaseCancelledError) {
///         return PurchaseResult.cancelled;
///       }
///       return PurchaseResult.failed;
///     }
///   }
///
///   @override
///   Future<String?> getLocalizedPrice(String productId) async {
///     final offerings = await Purchases.getOfferings();
///     return offerings.current?.getPackage(productId)?.product.priceString;
///   }
///
///   @override
///   Future<List<String>> restorePurchases() async {
///     final info = await Purchases.restorePurchases();
///     return info.entitlements.active.keys.toList();
///   }
///
///   @override
///   Stream<bool> get onStoreAvailabilityChanged => _storeController.stream;
/// }
/// ```
abstract class IAPProvider {
  /// Whether the store is available and ready.
  bool get isStoreAvailable;

  /// Attempt to purchase a product.
  ///
  /// [productId] is the platform-specific product identifier.
  /// Returns the result of the purchase attempt.
  Future<PurchaseResult> purchase(String productId);

  /// Get the localized price for a product.
  ///
  /// Returns null if product not found or store unavailable.
  Future<String?> getLocalizedPrice(String productId);

  /// Restore previous purchases.
  ///
  /// Returns list of product IDs that were restored.
  Future<List<String>> restorePurchases();

  /// Stream of store availability changes.
  Stream<bool> get onStoreAvailabilityChanged;
}

/// Stub implementation when IAP is not yet integrated.
///
/// Use this as a placeholder until your app integrates in-app purchases.
/// The purchase options will be hidden when using this provider.
class NoIAPProvider implements IAPProvider {
  /// Creates a [NoIAPProvider].
  const NoIAPProvider();

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
