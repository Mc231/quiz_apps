import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_product.dart';
import 'iap_service.dart';
import 'purchase_result.dart';

/// Real IAP implementation using the `in_app_purchase` package.
///
/// Integrates with App Store (iOS) and Google Play (Android) for
/// real in-app purchases.
///
/// Example:
/// ```dart
/// final iapService = StoreIAPService(
///   config: IAPConfig(
///     consumableProducts: [
///       IAPProduct.definition(id: 'lives_small', type: IAPProductType.consumable),
///     ],
///     nonConsumableProducts: [
///       IAPProduct.definition(id: 'remove_ads', type: IAPProductType.nonConsumable),
///     ],
///   ),
/// );
///
/// await iapService.initialize();
///
/// final result = await iapService.purchase('lives_small');
/// if (result is PurchaseResultSuccess) {
///   // Grant the resource
/// }
/// ```
class StoreIAPService implements IAPService {
  /// Creates a [StoreIAPService].
  StoreIAPService({
    required IAPConfig config,
    InAppPurchase? inAppPurchase,
  })  : _config = config,
        _inAppPurchase = inAppPurchase ?? InAppPurchase.instance;

  final IAPConfig _config;
  final InAppPurchase _inAppPurchase;

  bool _isInitialized = false;
  bool _isStoreAvailable = false;
  bool _isRemoveAdsPurchased = false;
  bool _isSubscriptionActive = false;
  String? _activeSubscriptionId;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  final List<IAPProduct> _products = [];
  final Set<String> _ownedNonConsumables = {};
  final Map<String, ProductDetails> _productDetailsMap = {};

  // Pending purchase completers for async purchase handling
  final Map<String, Completer<PurchaseResult>> _pendingPurchases = {};

  final _iapEventController = StreamController<IAPEvent>.broadcast();
  final _subscriptionStatusController = StreamController<bool>.broadcast();
  final _removeAdsController = StreamController<bool>.broadcast();

  @override
  IAPConfig get config => _config;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isStoreAvailable => _isStoreAvailable;

  @override
  Future<bool> initialize() async {
    if (_isInitialized) return _isStoreAvailable;

    try {
      _isStoreAvailable = await _inAppPurchase.isAvailable();

      if (!_isStoreAvailable) {
        debugPrint('StoreIAPService: Store is not available');
        _isInitialized = true;
        _iapEventController.add(
          IAPEvent.storeAvailabilityChanged(isAvailable: false),
        );
        return false;
      }

      // Listen to purchase updates
      _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
        _handlePurchaseUpdates,
        onError: _handlePurchaseError,
        onDone: () {
          debugPrint('StoreIAPService: Purchase stream closed');
        },
      );

      // Load products
      await queryProducts();

      // Check for previously purchased non-consumables
      await _loadOwnedPurchases();

      _isInitialized = true;
      _iapEventController.add(
        IAPEvent.storeAvailabilityChanged(isAvailable: true),
      );

      return true;
    } catch (e) {
      debugPrint('StoreIAPService: Initialization failed: $e');
      _isInitialized = true;
      _isStoreAvailable = false;
      return false;
    }
  }

  Future<void> _loadOwnedPurchases() async {
    // Restore purchases to check owned non-consumables and subscriptions
    // This is done silently on init, without user interaction
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      debugPrint('StoreIAPService: Failed to load owned purchases: $e');
    }
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _processPurchase(purchase);
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final productType = _config.getProductType(productId);

    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        await _deliverProduct(purchase, productType);
        break;

      case PurchaseStatus.error:
        _handlePurchaseFailure(purchase);
        break;

      case PurchaseStatus.pending:
        _handlePurchasePending(purchase);
        break;

      case PurchaseStatus.canceled:
        _handlePurchaseCancelled(purchase);
        break;
    }

    // Complete the purchase if needed
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
  }

  Future<void> _deliverProduct(
    PurchaseDetails purchase,
    IAPProductType? productType,
  ) async {
    final productId = purchase.productID;

    // Update state based on product type
    if (productType == IAPProductType.nonConsumable) {
      _ownedNonConsumables.add(productId);
      if (productId == 'remove_ads') {
        _isRemoveAdsPurchased = true;
        _removeAdsController.add(true);
      }
    } else if (productType == IAPProductType.subscription) {
      _isSubscriptionActive = true;
      _activeSubscriptionId = productId;
      _subscriptionStatusController.add(true);
      _iapEventController.add(IAPEvent.subscriptionStatusChanged(
        isActive: true,
        productId: productId,
      ));
    }

    // Emit event
    _iapEventController.add(IAPEvent.purchaseCompleted(
      productId: productId,
      transactionId: purchase.purchaseID ?? 'unknown',
      productType: productType ?? IAPProductType.consumable,
    ));

    // Complete pending purchase
    final completer = _pendingPurchases.remove(productId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(PurchaseResult.success(
        productId: productId,
        transactionId: purchase.purchaseID ?? 'unknown',
        purchaseDate: DateTime.now(),
        productType: productType ?? IAPProductType.consumable,
      ));
    }
  }

  void _handlePurchaseFailure(PurchaseDetails purchase) {
    final productId = purchase.productID;
    final error = purchase.error;

    final errorCode = error?.code ?? 'UNKNOWN_ERROR';
    final errorMessage = error?.message ?? 'Purchase failed';

    _iapEventController.add(IAPEvent.purchaseFailed(
      productId: productId,
      errorCode: errorCode,
      errorMessage: errorMessage,
    ));

    // Complete pending purchase with failure
    final completer = _pendingPurchases.remove(productId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(PurchaseResult.failed(
        productId: productId,
        errorCode: errorCode,
        errorMessage: errorMessage,
      ));
    }
  }

  void _handlePurchasePending(PurchaseDetails purchase) {
    final productId = purchase.productID;

    _iapEventController.add(IAPEvent.purchasePending(
      productId: productId,
      reason: 'awaiting_approval',
    ));

    // Don't complete the pending purchase yet - it will complete when approved
  }

  void _handlePurchaseCancelled(PurchaseDetails purchase) {
    final productId = purchase.productID;

    _iapEventController.add(IAPEvent.purchaseCancelled(productId: productId));

    // Complete pending purchase with cancellation
    final completer = _pendingPurchases.remove(productId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(PurchaseResult.cancelled(productId: productId));
    }
  }

  void _handlePurchaseError(dynamic error) {
    debugPrint('StoreIAPService: Purchase stream error: $error');
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
    if (!_isStoreAvailable && _isInitialized) {
      return [];
    }

    try {
      final productIds = _config.allProductIds;
      if (productIds.isEmpty) {
        return [];
      }

      final response = await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        debugPrint('StoreIAPService: Product query error: ${response.error}');
        _iapEventController.add(IAPEvent.productsLoadFailed(
          errorMessage: response.error?.message ?? 'Failed to load products',
        ));
        return [];
      }

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint(
            'StoreIAPService: Products not found: ${response.notFoundIDs}');
      }

      _products.clear();
      _productDetailsMap.clear();

      for (final details in response.productDetails) {
        _productDetailsMap[details.id] = details;

        final productType = _config.getProductType(details.id);
        _products.add(IAPProduct(
          id: details.id,
          type: productType ?? IAPProductType.consumable,
          title: details.title,
          description: details.description,
          price: details.price,
          rawPrice: details.rawPrice,
          currencyCode: details.currencyCode,
          currencySymbol: details.currencySymbol,
        ));
      }

      _iapEventController.add(IAPEvent.productsLoaded(products: _products));
      return _products;
    } catch (e) {
      debugPrint('StoreIAPService: Failed to query products: $e');
      _iapEventController.add(IAPEvent.productsLoadFailed(
        errorMessage: e.toString(),
      ));
      return [];
    }
  }

  // ============ Purchases ============

  @override
  Future<PurchaseResult> purchase(String productId) async {
    if (!_isStoreAvailable) {
      return PurchaseResult.notAvailable(productId: productId);
    }

    final productDetails = _productDetailsMap[productId];
    if (productDetails == null) {
      return PurchaseResult.notAvailable(productId: productId);
    }

    // Check if non-consumable already owned
    final productType = _config.getProductType(productId);
    if (productType == IAPProductType.nonConsumable &&
        _ownedNonConsumables.contains(productId)) {
      return PurchaseResult.alreadyOwned(productId: productId);
    }

    _iapEventController.add(IAPEvent.purchaseStarted(productId: productId));

    // Create completer for async result
    final completer = Completer<PurchaseResult>();
    _pendingPurchases[productId] = completer;

    try {
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      final isConsumable = _config.isConsumable(productId);

      bool success;
      if (isConsumable) {
        success =
            await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } else {
        success =
            await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      }

      if (!success) {
        _pendingPurchases.remove(productId);
        return PurchaseResult.failed(
          productId: productId,
          errorCode: 'PURCHASE_NOT_STARTED',
          errorMessage: 'Failed to start purchase',
        );
      }

      // Wait for purchase stream to complete the purchase
      // Timeout after 5 minutes
      return await completer.future.timeout(
        const Duration(minutes: 5),
        onTimeout: () {
          _pendingPurchases.remove(productId);
          return PurchaseResult.failed(
            productId: productId,
            errorCode: 'TIMEOUT',
            errorMessage: 'Purchase timed out',
          );
        },
      );
    } catch (e) {
      _pendingPurchases.remove(productId);
      return PurchaseResult.failed(
        productId: productId,
        errorCode: 'PURCHASE_ERROR',
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<bool> isPurchased(String productId) async {
    return _ownedNonConsumables.contains(productId);
  }

  @override
  Future<List<String>> restorePurchases() async {
    if (!_isStoreAvailable) {
      return [];
    }

    _iapEventController.add(IAPEvent.restoreStarted());

    try {
      await _inAppPurchase.restorePurchases();

      // Wait a bit for the purchase stream to process restored purchases
      await Future.delayed(const Duration(seconds: 2));

      final restored = [
        ..._ownedNonConsumables,
        if (_isSubscriptionActive && _activeSubscriptionId != null)
          _activeSubscriptionId!,
      ];

      _iapEventController.add(IAPEvent.restoreCompleted(
        restoredProductIds: restored,
      ));

      return restored;
    } catch (e) {
      debugPrint('StoreIAPService: Restore failed: $e');
      _iapEventController.add(IAPEvent.restoreFailed(
        errorMessage: e.toString(),
      ));
      return [];
    }
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

  // ============ Remove Ads ============

  @override
  bool get isRemoveAdsPurchased => _isRemoveAdsPurchased;

  @override
  Stream<bool> get onRemoveAdsPurchased => _removeAdsController.stream;

  // ============ Events ============

  @override
  Stream<IAPEvent> get onIAPEvent => _iapEventController.stream;

  // ============ Lifecycle ============

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _iapEventController.close();
    _subscriptionStatusController.close();
    _removeAdsController.close();

    // Cancel any pending purchases
    for (final completer in _pendingPurchases.values) {
      if (!completer.isCompleted) {
        completer.complete(PurchaseResult.failed(
          productId: 'unknown',
          errorCode: 'DISPOSED',
          errorMessage: 'Service was disposed',
        ));
      }
    }
    _pendingPurchases.clear();
  }
}
