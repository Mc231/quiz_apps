import 'iap_product.dart';

/// Events emitted by the IAP service.
///
/// A sealed class hierarchy for tracking IAP lifecycle events.
/// Use these events for analytics, debugging, and UI updates.
///
/// Example:
/// ```dart
/// iapService.onIAPEvent.listen((event) {
///   switch (event) {
///     case IAPEventProductsLoaded(:final products):
///       print('Loaded ${products.length} products');
///     case IAPEventPurchaseCompleted(:final productId):
///       print('Purchased $productId');
///     case IAPEventPurchaseFailed(:final errorMessage):
///       print('Purchase failed: $errorMessage');
///     // ... handle other events
///   }
/// });
/// ```
sealed class IAPEvent {
  const IAPEvent._();

  /// Products were loaded from the store.
  factory IAPEvent.productsLoaded({
    required List<IAPProduct> products,
  }) = IAPEventProductsLoaded;

  /// Products failed to load from the store.
  factory IAPEvent.productsLoadFailed({
    required String errorMessage,
  }) = IAPEventProductsLoadFailed;

  /// A purchase was started.
  factory IAPEvent.purchaseStarted({
    required String productId,
  }) = IAPEventPurchaseStarted;

  /// A purchase completed successfully.
  factory IAPEvent.purchaseCompleted({
    required String productId,
    required String transactionId,
    required IAPProductType productType,
  }) = IAPEventPurchaseCompleted;

  /// A purchase failed.
  factory IAPEvent.purchaseFailed({
    required String productId,
    required String errorCode,
    required String errorMessage,
  }) = IAPEventPurchaseFailed;

  /// A purchase was cancelled by the user.
  factory IAPEvent.purchaseCancelled({
    required String productId,
  }) = IAPEventPurchaseCancelled;

  /// A purchase is pending (awaiting approval, etc.).
  factory IAPEvent.purchasePending({
    required String productId,
    required String reason,
  }) = IAPEventPurchasePending;

  /// Restore purchases was initiated.
  factory IAPEvent.restoreStarted() = IAPEventRestoreStarted;

  /// Restore purchases completed.
  factory IAPEvent.restoreCompleted({
    required List<String> restoredProductIds,
  }) = IAPEventRestoreCompleted;

  /// Restore purchases failed.
  factory IAPEvent.restoreFailed({
    required String errorMessage,
  }) = IAPEventRestoreFailed;

  /// Subscription status changed.
  factory IAPEvent.subscriptionStatusChanged({
    required bool isActive,
    required String? productId,
    DateTime? expirationDate,
  }) = IAPEventSubscriptionStatusChanged;

  /// Store availability changed.
  factory IAPEvent.storeAvailabilityChanged({
    required bool isAvailable,
  }) = IAPEventStoreAvailabilityChanged;
}

/// Products were loaded from the store.
final class IAPEventProductsLoaded extends IAPEvent {
  /// Creates an [IAPEventProductsLoaded].
  const IAPEventProductsLoaded({
    required this.products,
  }) : super._();

  /// The loaded products with store details.
  final List<IAPProduct> products;
}

/// Products failed to load from the store.
final class IAPEventProductsLoadFailed extends IAPEvent {
  /// Creates an [IAPEventProductsLoadFailed].
  const IAPEventProductsLoadFailed({
    required this.errorMessage,
  }) : super._();

  /// Error message describing the failure.
  final String errorMessage;
}

/// A purchase was started.
final class IAPEventPurchaseStarted extends IAPEvent {
  /// Creates an [IAPEventPurchaseStarted].
  const IAPEventPurchaseStarted({
    required this.productId,
  }) : super._();

  /// The product being purchased.
  final String productId;
}

/// A purchase completed successfully.
final class IAPEventPurchaseCompleted extends IAPEvent {
  /// Creates an [IAPEventPurchaseCompleted].
  const IAPEventPurchaseCompleted({
    required this.productId,
    required this.transactionId,
    required this.productType,
  }) : super._();

  /// The purchased product ID.
  final String productId;

  /// The transaction ID from the store.
  final String transactionId;

  /// Type of the purchased product.
  final IAPProductType productType;
}

/// A purchase failed.
final class IAPEventPurchaseFailed extends IAPEvent {
  /// Creates an [IAPEventPurchaseFailed].
  const IAPEventPurchaseFailed({
    required this.productId,
    required this.errorCode,
    required this.errorMessage,
  }) : super._();

  /// The product that failed to purchase.
  final String productId;

  /// Error code from the store.
  final String errorCode;

  /// Human-readable error message.
  final String errorMessage;
}

/// A purchase was cancelled by the user.
final class IAPEventPurchaseCancelled extends IAPEvent {
  /// Creates an [IAPEventPurchaseCancelled].
  const IAPEventPurchaseCancelled({
    required this.productId,
  }) : super._();

  /// The product that was being purchased.
  final String productId;
}

/// A purchase is pending.
final class IAPEventPurchasePending extends IAPEvent {
  /// Creates an [IAPEventPurchasePending].
  const IAPEventPurchasePending({
    required this.productId,
    required this.reason,
  }) : super._();

  /// The product being purchased.
  final String productId;

  /// Reason for the pending state.
  final String reason;
}

/// Restore purchases was initiated.
final class IAPEventRestoreStarted extends IAPEvent {
  /// Creates an [IAPEventRestoreStarted].
  const IAPEventRestoreStarted() : super._();
}

/// Restore purchases completed.
final class IAPEventRestoreCompleted extends IAPEvent {
  /// Creates an [IAPEventRestoreCompleted].
  const IAPEventRestoreCompleted({
    required this.restoredProductIds,
  }) : super._();

  /// Product IDs that were restored.
  final List<String> restoredProductIds;
}

/// Restore purchases failed.
final class IAPEventRestoreFailed extends IAPEvent {
  /// Creates an [IAPEventRestoreFailed].
  const IAPEventRestoreFailed({
    required this.errorMessage,
  }) : super._();

  /// Error message describing the failure.
  final String errorMessage;
}

/// Subscription status changed.
final class IAPEventSubscriptionStatusChanged extends IAPEvent {
  /// Creates an [IAPEventSubscriptionStatusChanged].
  const IAPEventSubscriptionStatusChanged({
    required this.isActive,
    required this.productId,
    this.expirationDate,
  }) : super._();

  /// Whether a subscription is currently active.
  final bool isActive;

  /// The active subscription product ID, or null if none.
  final String? productId;

  /// When the subscription expires, if known.
  final DateTime? expirationDate;
}

/// Store availability changed.
final class IAPEventStoreAvailabilityChanged extends IAPEvent {
  /// Creates an [IAPEventStoreAvailabilityChanged].
  const IAPEventStoreAvailabilityChanged({
    required this.isAvailable,
  }) : super._();

  /// Whether the store is available.
  final bool isAvailable;
}
