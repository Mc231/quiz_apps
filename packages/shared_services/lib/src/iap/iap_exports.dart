/// In-App Purchases service exports.
///
/// Provides a unified interface for managing in-app purchases:
/// - Consumable products (lives, hints, bundles)
/// - Non-consumable products (remove_ads)
/// - Subscriptions (premium_monthly, premium_yearly)
///
/// Example usage:
/// ```dart
/// import 'package:shared_services/shared_services.dart';
///
/// // Create and initialize the service
/// final iapService = StoreIAPService(config: IAPConfig.test());
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
library;

export 'analytics_iap_service.dart';
export 'iap_config.dart';
export 'iap_event.dart';
export 'iap_product.dart';
export 'iap_service.dart';
export 'mock_iap_service.dart';
export 'no_op_iap_service.dart';
export 'purchase_result.dart';
export 'store_iap_service.dart';
