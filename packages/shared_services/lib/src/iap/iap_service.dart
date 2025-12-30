import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_product.dart';
import 'purchase_result.dart';

/// Abstract service for managing in-app purchases.
///
/// Provides a unified interface for:
/// - Consumable products (lives, hints, bundles)
/// - Non-consumable products (remove_ads)
/// - Subscriptions (premium_monthly, premium_yearly)
///
/// Implementations:
/// - [StoreIAPService] - Real App Store/Play Store integration
/// - [MockIAPService] - Testing with simulated purchases
/// - [NoOpIAPService] - When IAP is disabled
///
/// Example usage:
/// ```dart
/// final iapService = StoreIAPService(
///   config: IAPConfig.test(),
/// );
///
/// await iapService.initialize();
///
/// // Query products from store
/// final products = await iapService.queryProducts();
///
/// // Purchase a product
/// final result = await iapService.purchase('lives_small');
/// if (result is PurchaseResultSuccess) {
///   // Grant the resource
/// }
///
/// // Check remove_ads status
/// if (iapService.isRemoveAdsPurchased) {
///   adsService.disableAds();
/// }
/// ```
abstract class IAPService {
  /// Configuration for the IAP service.
  IAPConfig get config;

  /// Whether the service has been initialized.
  bool get isInitialized;

  /// Whether the store is available for purchases.
  ///
  /// Returns `false` if:
  /// - Device is in Airplane mode
  /// - Parental controls block purchases
  /// - Store is unavailable in region
  bool get isStoreAvailable;

  /// Initialize the IAP service.
  ///
  /// Must be called before using any other methods.
  /// Returns `true` if initialization was successful.
  ///
  /// This method:
  /// - Checks store availability
  /// - Sets up purchase stream listeners
  /// - Loads previously purchased non-consumables
  /// - Queries products from the store
  Future<bool> initialize();

  // ============ Products ============

  /// All available products (loaded from store).
  ///
  /// Returns an empty list if products haven't been queried yet
  /// or if the store is unavailable.
  List<IAPProduct> get products;

  /// Get a specific product by ID.
  ///
  /// Returns `null` if the product is not found or not loaded.
  IAPProduct? getProduct(String productId);

  /// Refresh products from the store.
  ///
  /// Call this to get localized pricing and product details.
  /// Products are automatically queried during [initialize()].
  Future<List<IAPProduct>> queryProducts();

  // ============ Purchases ============

  /// Purchase a product.
  ///
  /// Returns a [PurchaseResult] indicating the outcome:
  /// - [PurchaseResultSuccess] - Purchase completed
  /// - [PurchaseResultCancelled] - User cancelled
  /// - [PurchaseResultFailed] - Error occurred
  /// - [PurchaseResultPending] - Awaiting approval
  /// - [PurchaseResultNotAvailable] - Product not found
  /// - [PurchaseResultAlreadyOwned] - Non-consumable already owned
  Future<PurchaseResult> purchase(String productId);

  /// Check if a non-consumable product is owned.
  ///
  /// Always returns `false` for consumable products.
  /// For subscriptions, use [isSubscriptionActive()] instead.
  Future<bool> isPurchased(String productId);

  /// Restore previous purchases.
  ///
  /// Returns a list of restored product IDs.
  /// Use this to restore non-consumables and active subscriptions
  /// when a user installs on a new device.
  Future<List<String>> restorePurchases();

  // ============ Subscriptions ============

  /// Check if any subscription is currently active.
  ///
  /// Returns `true` if the user has an active premium subscription.
  Future<bool> isSubscriptionActive();

  /// Get the active subscription product ID.
  ///
  /// Returns `null` if no subscription is active.
  Future<String?> getActiveSubscription();

  /// Stream of subscription status changes.
  ///
  /// Emits `true` when a subscription becomes active,
  /// `false` when it expires or is cancelled.
  Stream<bool> get onSubscriptionStatusChanged;

  // ============ Remove Ads ============

  /// Whether remove_ads has been purchased.
  ///
  /// This is a convenience property for checking the common
  /// 'remove_ads' non-consumable purchase.
  bool get isRemoveAdsPurchased;

  /// Stream that emits when remove_ads status changes.
  ///
  /// Use this to connect to [AdsService.disableAds()]:
  /// ```dart
  /// iapService.onRemoveAdsPurchased.listen((purchased) {
  ///   if (purchased) {
  ///     adsService.disableAds();
  ///   }
  /// });
  /// ```
  Stream<bool> get onRemoveAdsPurchased;

  // ============ Events ============

  /// Stream of IAP events for analytics and debugging.
  ///
  /// Emits events for all IAP operations:
  /// - Product loading
  /// - Purchase lifecycle
  /// - Restore operations
  /// - Subscription status changes
  Stream<IAPEvent> get onIAPEvent;

  // ============ Lifecycle ============

  /// Dispose the service and release resources.
  ///
  /// Call this when the service is no longer needed.
  void dispose();
}
