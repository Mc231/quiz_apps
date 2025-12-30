import 'dart:async';

import '../analytics/analytics_service.dart';
import '../analytics/events/monetization_event.dart';
import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_product.dart';
import 'iap_service.dart';
import 'purchase_result.dart';

/// Wrapper that adds analytics tracking to any [IAPService].
///
/// Listens to [IAPEvent]s and logs corresponding [MonetizationEvent]s
/// to the analytics service.
///
/// Example:
/// ```dart
/// final baseService = StoreIAPService(config: config);
/// final analyticsService = FirebaseAnalyticsService();
///
/// final iapService = AnalyticsIAPService(
///   iapService: baseService,
///   analyticsService: analyticsService,
/// );
///
/// await iapService.initialize();
///
/// // All purchase events will be logged to analytics
/// await iapService.purchase('lives_small');
/// ```
class AnalyticsIAPService implements IAPService {
  /// Creates an [AnalyticsIAPService].
  AnalyticsIAPService({
    required IAPService iapService,
    required AnalyticsService analyticsService,
  })  : _iapService = iapService,
        _analyticsService = analyticsService {
    _setupEventTracking();
  }

  final IAPService _iapService;
  final AnalyticsService _analyticsService;
  StreamSubscription<IAPEvent>? _eventSubscription;
  DateTime? _purchaseStartTime;

  void _setupEventTracking() {
    _eventSubscription = _iapService.onIAPEvent.listen(_handleIAPEvent);
  }

  void _handleIAPEvent(IAPEvent event) {
    switch (event) {
      case IAPEventPurchaseStarted(:final productId):
        _purchaseStartTime = DateTime.now();
        final product = _iapService.getProduct(productId);
        _analyticsService.logEvent(
          MonetizationEvent.purchaseInitiated(
            packId: productId,
            packName: product?.title ?? productId,
            price: product?.rawPrice ?? 0,
            currency: product?.currencyCode ?? 'USD',
            paymentMethod: 'store', // App Store / Play Store
          ),
        );

      case IAPEventPurchaseCompleted(
          :final productId,
          :final transactionId,
        ):
        final product = _iapService.getProduct(productId);
        final duration = _purchaseStartTime != null
            ? DateTime.now().difference(_purchaseStartTime!)
            : Duration.zero;
        _purchaseStartTime = null;

        _analyticsService.logEvent(
          MonetizationEvent.purchaseCompleted(
            packId: productId,
            packName: product?.title ?? productId,
            price: product?.rawPrice ?? 0,
            currency: product?.currencyCode ?? 'USD',
            transactionId: transactionId,
            purchaseDuration: duration,
          ),
        );

      case IAPEventPurchaseCancelled(:final productId):
        final product = _iapService.getProduct(productId);
        final duration = _purchaseStartTime != null
            ? DateTime.now().difference(_purchaseStartTime!)
            : Duration.zero;
        _purchaseStartTime = null;

        _analyticsService.logEvent(
          MonetizationEvent.purchaseCancelled(
            packId: productId,
            packName: product?.title ?? productId,
            price: product?.rawPrice ?? 0,
            currency: product?.currencyCode ?? 'USD',
            cancelReason: 'user_cancelled',
            timeBeforeCancel: duration,
          ),
        );

      case IAPEventPurchaseFailed(
          :final productId,
          :final errorCode,
          :final errorMessage,
        ):
        final product = _iapService.getProduct(productId);
        _purchaseStartTime = null;

        _analyticsService.logEvent(
          MonetizationEvent.purchaseFailed(
            packId: productId,
            packName: product?.title ?? productId,
            price: product?.rawPrice ?? 0,
            currency: product?.currencyCode ?? 'USD',
            errorCode: errorCode,
            errorMessage: errorMessage,
          ),
        );

      case IAPEventRestoreStarted():
        _analyticsService.logEvent(
          MonetizationEvent.restoreInitiated(source: 'iap_service'),
        );

      case IAPEventRestoreCompleted(:final restoredProductIds):
        _analyticsService.logEvent(
          MonetizationEvent.restoreCompleted(
            success: true,
            restoredCount: restoredProductIds.length,
            restoreDuration: Duration.zero,
          ),
        );

      case IAPEventRestoreFailed(:final errorMessage):
        _analyticsService.logEvent(
          MonetizationEvent.restoreCompleted(
            success: false,
            restoredCount: 0,
            restoreDuration: Duration.zero,
            errorMessage: errorMessage,
          ),
        );

      // These events don't need analytics tracking
      case IAPEventProductsLoaded():
      case IAPEventProductsLoadFailed():
      case IAPEventPurchasePending():
      case IAPEventSubscriptionStatusChanged():
      case IAPEventStoreAvailabilityChanged():
        break;
    }
  }

  // ============ Delegated Methods ============

  @override
  IAPConfig get config => _iapService.config;

  @override
  bool get isInitialized => _iapService.isInitialized;

  @override
  bool get isStoreAvailable => _iapService.isStoreAvailable;

  @override
  Future<bool> initialize() => _iapService.initialize();

  @override
  List<IAPProduct> get products => _iapService.products;

  @override
  IAPProduct? getProduct(String productId) => _iapService.getProduct(productId);

  @override
  Future<List<IAPProduct>> queryProducts() => _iapService.queryProducts();

  @override
  Future<PurchaseResult> purchase(String productId) =>
      _iapService.purchase(productId);

  @override
  Future<bool> isPurchased(String productId) =>
      _iapService.isPurchased(productId);

  @override
  Future<List<String>> restorePurchases() => _iapService.restorePurchases();

  @override
  Future<bool> isSubscriptionActive() => _iapService.isSubscriptionActive();

  @override
  Future<String?> getActiveSubscription() =>
      _iapService.getActiveSubscription();

  @override
  Stream<bool> get onSubscriptionStatusChanged =>
      _iapService.onSubscriptionStatusChanged;

  @override
  bool get isRemoveAdsPurchased => _iapService.isRemoveAdsPurchased;

  @override
  Stream<bool> get onRemoveAdsPurchased => _iapService.onRemoveAdsPurchased;

  @override
  Stream<IAPEvent> get onIAPEvent => _iapService.onIAPEvent;

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _iapService.dispose();
  }
}
