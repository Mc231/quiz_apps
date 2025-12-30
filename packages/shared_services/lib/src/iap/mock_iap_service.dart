import 'dart:async';

import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_product.dart';
import 'iap_service.dart';
import 'purchase_result.dart';

/// Mock implementation of [IAPService] for testing.
///
/// Simulates purchase flows with configurable delays and outcomes.
/// Use this for:
/// - Unit testing
/// - UI development without store access
/// - Demo/preview builds
///
/// Example:
/// ```dart
/// final iapService = MockIAPService(
///   config: IAPConfig.test(),
///   simulatedDelay: Duration(seconds: 1),
/// );
///
/// await iapService.initialize();
///
/// // Simulate a successful purchase
/// final result = await iapService.purchase('lives_small');
/// // result is PurchaseResultSuccess after 1 second delay
///
/// // Force a failure for testing
/// iapService.nextPurchaseResult = PurchaseResult.failed(
///   productId: 'lives_small',
///   errorCode: 'TEST_ERROR',
///   errorMessage: 'Simulated failure',
/// );
/// ```
class MockIAPService implements IAPService {
  /// Creates a [MockIAPService].
  MockIAPService({
    IAPConfig? config,
    this.simulatedDelay = const Duration(milliseconds: 500),
    this.simulateStoreAvailable = true,
  }) : _config = config ?? IAPConfig.test();

  final IAPConfig _config;
  bool _isInitialized = false;
  bool _isRemoveAdsPurchased = false;
  bool _isSubscriptionActive = false;
  String? _activeSubscriptionId;

  /// Delay to simulate network latency.
  final Duration simulatedDelay;

  /// Whether to simulate the store being available.
  bool simulateStoreAvailable;

  /// Override the next purchase result for testing.
  ///
  /// Set this before calling [purchase()] to simulate specific outcomes.
  /// Resets to `null` after being used.
  PurchaseResult? nextPurchaseResult;

  final List<IAPProduct> _products = [];
  final Set<String> _ownedNonConsumables = {};
  int _transactionCounter = 0;

  final _iapEventController = StreamController<IAPEvent>.broadcast();
  final _subscriptionStatusController = StreamController<bool>.broadcast();
  final _removeAdsController = StreamController<bool>.broadcast();

  @override
  IAPConfig get config => _config;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isStoreAvailable => simulateStoreAvailable;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    await Future.delayed(simulatedDelay);

    if (!simulateStoreAvailable) {
      _isInitialized = true;
      return false;
    }

    // Load mock products with simulated prices
    await queryProducts();

    _isInitialized = true;
    return true;
  }

  // ============ Products ============

  @override
  List<IAPProduct> get products => List.unmodifiable(_products);

  @override
  IAPProduct? getProduct(String productId) {
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<IAPProduct>> queryProducts() async {
    await Future.delayed(simulatedDelay);

    _products.clear();

    // Create mock products with simulated prices
    final mockPrices = {
      'lives_small': 0.99,
      'lives_medium': 1.99,
      'lives_large': 4.99,
      'hints_small': 0.99,
      'hints_medium': 1.99,
      'hints_large': 4.99,
      'bundle_starter': 1.49,
      'bundle_value': 3.49,
      'bundle_pro': 7.99,
      'remove_ads': 2.99,
      'premium_monthly': 1.99,
      'premium_yearly': 9.99,
    };

    for (final product in [
      ..._config.consumableProducts,
      ..._config.nonConsumableProducts,
      ..._config.subscriptionProducts,
    ]) {
      final price = mockPrices[product.id] ?? 0.99;
      _products.add(product.withStoreDetails(
        title: product.title.isNotEmpty ? product.title : product.id,
        description: product.description.isNotEmpty
            ? product.description
            : 'Mock product description',
        price: '\$${price.toStringAsFixed(2)}',
        rawPrice: price,
        currencyCode: 'USD',
        currencySymbol: '\$',
      ));
    }

    _iapEventController.add(IAPEvent.productsLoaded(products: _products));
    return _products;
  }

  // ============ Purchases ============

  @override
  Future<PurchaseResult> purchase(String productId) async {
    _iapEventController.add(IAPEvent.purchaseStarted(productId: productId));

    await Future.delayed(simulatedDelay);

    // Check for override
    if (nextPurchaseResult != null) {
      final result = nextPurchaseResult!;
      nextPurchaseResult = null;
      _emitEventForResult(result);
      return result;
    }

    // Check if store is available
    if (!simulateStoreAvailable) {
      final result = PurchaseResult.notAvailable(productId: productId);
      _iapEventController.add(IAPEvent.purchaseFailed(
        productId: productId,
        errorCode: 'STORE_UNAVAILABLE',
        errorMessage: 'Store is not available',
      ));
      return result;
    }

    // Check if product exists
    final productType = _config.getProductType(productId);
    if (productType == null) {
      final result = PurchaseResult.notAvailable(productId: productId);
      _iapEventController.add(IAPEvent.purchaseFailed(
        productId: productId,
        errorCode: 'PRODUCT_NOT_FOUND',
        errorMessage: 'Product not found',
      ));
      return result;
    }

    // Check if non-consumable already owned
    if (productType == IAPProductType.nonConsumable &&
        _ownedNonConsumables.contains(productId)) {
      final result = PurchaseResult.alreadyOwned(productId: productId);
      return result;
    }

    // Simulate successful purchase
    _transactionCounter++;
    final transactionId = 'mock_txn_$_transactionCounter';

    final result = PurchaseResult.success(
      productId: productId,
      transactionId: transactionId,
      purchaseDate: DateTime.now(),
      productType: productType,
    );

    // Update state based on product type
    switch (productType) {
      case IAPProductType.nonConsumable:
        _ownedNonConsumables.add(productId);
        if (productId == 'remove_ads') {
          _isRemoveAdsPurchased = true;
          _removeAdsController.add(true);
        }
      case IAPProductType.subscription:
        _isSubscriptionActive = true;
        _activeSubscriptionId = productId;
        _subscriptionStatusController.add(true);
      case IAPProductType.consumable:
        // No state update needed for consumables
        break;
    }

    _iapEventController.add(IAPEvent.purchaseCompleted(
      productId: productId,
      transactionId: transactionId,
      productType: productType,
    ));

    return result;
  }

  void _emitEventForResult(PurchaseResult result) {
    switch (result) {
      case PurchaseResultSuccess(:final productId, :final transactionId, :final productType):
        _iapEventController.add(IAPEvent.purchaseCompleted(
          productId: productId,
          transactionId: transactionId,
          productType: productType,
        ));
      case PurchaseResultCancelled(:final productId):
        _iapEventController.add(IAPEvent.purchaseCancelled(productId: productId));
      case PurchaseResultFailed(:final productId, :final errorCode, :final errorMessage):
        _iapEventController.add(IAPEvent.purchaseFailed(
          productId: productId,
          errorCode: errorCode,
          errorMessage: errorMessage,
        ));
      case PurchaseResultPending(:final productId, :final reason):
        _iapEventController.add(IAPEvent.purchasePending(
          productId: productId,
          reason: reason,
        ));
      case PurchaseResultNotAvailable(:final productId):
        _iapEventController.add(IAPEvent.purchaseFailed(
          productId: productId,
          errorCode: 'NOT_AVAILABLE',
          errorMessage: 'Product not available',
        ));
      case PurchaseResultAlreadyOwned():
        // No event needed for already owned
        break;
    }
  }

  @override
  Future<bool> isPurchased(String productId) async {
    return _ownedNonConsumables.contains(productId);
  }

  @override
  Future<List<String>> restorePurchases() async {
    _iapEventController.add(IAPEvent.restoreStarted());

    await Future.delayed(simulatedDelay);

    final restored = _ownedNonConsumables.toList();

    if (_isSubscriptionActive && _activeSubscriptionId != null) {
      restored.add(_activeSubscriptionId!);
    }

    _iapEventController.add(IAPEvent.restoreCompleted(
      restoredProductIds: restored,
    ));

    return restored;
  }

  // ============ Subscriptions ============

  @override
  Future<bool> isSubscriptionActive() async {
    return _isSubscriptionActive;
  }

  @override
  Future<String?> getActiveSubscription() async {
    return _activeSubscriptionId;
  }

  @override
  Stream<bool> get onSubscriptionStatusChanged =>
      _subscriptionStatusController.stream;

  /// Simulate subscription expiration (for testing).
  void simulateSubscriptionExpired() {
    _isSubscriptionActive = false;
    _activeSubscriptionId = null;
    _subscriptionStatusController.add(false);
    _iapEventController.add(IAPEvent.subscriptionStatusChanged(
      isActive: false,
      productId: null,
    ));
  }

  // ============ Remove Ads ============

  @override
  bool get isRemoveAdsPurchased => _isRemoveAdsPurchased;

  @override
  Stream<bool> get onRemoveAdsPurchased => _removeAdsController.stream;

  /// Simulate remove_ads being restored (for testing).
  void simulateRemoveAdsRestored() {
    _isRemoveAdsPurchased = true;
    _ownedNonConsumables.add('remove_ads');
    _removeAdsController.add(true);
  }

  // ============ Events ============

  @override
  Stream<IAPEvent> get onIAPEvent => _iapEventController.stream;

  // ============ Lifecycle ============

  @override
  void dispose() {
    _iapEventController.close();
    _subscriptionStatusController.close();
    _removeAdsController.close();
  }

  // ============ Test Helpers ============

  /// Reset all mock state.
  void reset() {
    _products.clear();
    _ownedNonConsumables.clear();
    _isRemoveAdsPurchased = false;
    _isSubscriptionActive = false;
    _activeSubscriptionId = null;
    _transactionCounter = 0;
    nextPurchaseResult = null;
  }
}
