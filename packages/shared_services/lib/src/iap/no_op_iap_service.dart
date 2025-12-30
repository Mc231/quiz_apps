import 'dart:async';

import 'iap_config.dart';
import 'iap_event.dart';
import 'iap_product.dart';
import 'iap_service.dart';
import 'purchase_result.dart';

/// No-op implementation of [IAPService] for when IAP is disabled.
///
/// Returns disabled/unavailable for all operations.
/// Use this when:
/// - IAP is not configured for the app
/// - Running in an environment without store access
/// - User has disabled IAP via settings
///
/// Example:
/// ```dart
/// final iapService = NoOpIAPService();
/// await iapService.initialize();
///
/// // All purchases will return notAvailable
/// final result = await iapService.purchase('lives_small');
/// // result is PurchaseResultNotAvailable
/// ```
class NoOpIAPService implements IAPService {
  /// Creates a [NoOpIAPService].
  NoOpIAPService({IAPConfig? config}) : _config = config ?? const IAPConfig.empty();

  final IAPConfig _config;
  bool _isInitialized = false;

  final _iapEventController = StreamController<IAPEvent>.broadcast();
  final _subscriptionStatusController = StreamController<bool>.broadcast();
  final _removeAdsController = StreamController<bool>.broadcast();

  @override
  IAPConfig get config => _config;

  @override
  bool get isInitialized => _isInitialized;

  @override
  bool get isStoreAvailable => false;

  @override
  Future<bool> initialize() async {
    _isInitialized = true;
    return true;
  }

  // ============ Products ============

  @override
  List<IAPProduct> get products => [];

  @override
  IAPProduct? getProduct(String productId) => null;

  @override
  Future<List<IAPProduct>> queryProducts() async => [];

  // ============ Purchases ============

  @override
  Future<PurchaseResult> purchase(String productId) async {
    return PurchaseResult.notAvailable(productId: productId);
  }

  @override
  Future<bool> isPurchased(String productId) async => false;

  @override
  Future<List<String>> restorePurchases() async => [];

  // ============ Subscriptions ============

  @override
  Future<bool> isSubscriptionActive() async => false;

  @override
  Future<String?> getActiveSubscription() async => null;

  @override
  Stream<bool> get onSubscriptionStatusChanged =>
      _subscriptionStatusController.stream;

  // ============ Remove Ads ============

  @override
  bool get isRemoveAdsPurchased => false;

  @override
  Stream<bool> get onRemoveAdsPurchased => _removeAdsController.stream;

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
}
