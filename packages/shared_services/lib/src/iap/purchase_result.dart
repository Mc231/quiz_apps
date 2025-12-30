import 'iap_product.dart';

/// Result of a purchase attempt.
///
/// A sealed class hierarchy representing all possible outcomes
/// of an in-app purchase operation.
///
/// Example:
/// ```dart
/// final result = await iapService.purchase('lives_small');
///
/// switch (result) {
///   case PurchaseResultSuccess(:final productId, :final transactionId):
///     print('Purchased $productId with transaction $transactionId');
///   case PurchaseResultCancelled():
///     print('User cancelled');
///   case PurchaseResultFailed(:final errorMessage):
///     print('Purchase failed: $errorMessage');
///   case PurchaseResultPending(:final reason):
///     print('Purchase pending: $reason');
///   case PurchaseResultNotAvailable():
///     print('Product not available');
///   case PurchaseResultAlreadyOwned():
///     print('Already owned');
/// }
/// ```
sealed class PurchaseResult {
  const PurchaseResult._();

  /// Purchase completed successfully.
  factory PurchaseResult.success({
    required String productId,
    required String transactionId,
    required DateTime purchaseDate,
    required IAPProductType productType,
  }) = PurchaseResultSuccess;

  /// User cancelled the purchase.
  factory PurchaseResult.cancelled({
    required String productId,
  }) = PurchaseResultCancelled;

  /// Purchase failed with an error.
  factory PurchaseResult.failed({
    required String productId,
    required String errorCode,
    required String errorMessage,
  }) = PurchaseResultFailed;

  /// Purchase is pending (e.g., parental approval, payment processing).
  factory PurchaseResult.pending({
    required String productId,
    required String reason,
  }) = PurchaseResultPending;

  /// Product is not available for purchase.
  factory PurchaseResult.notAvailable({
    required String productId,
  }) = PurchaseResultNotAvailable;

  /// Product is already owned (for non-consumables).
  factory PurchaseResult.alreadyOwned({
    required String productId,
  }) = PurchaseResultAlreadyOwned;
}

/// Purchase completed successfully.
final class PurchaseResultSuccess extends PurchaseResult {
  /// Creates a [PurchaseResultSuccess].
  const PurchaseResultSuccess({
    required this.productId,
    required this.transactionId,
    required this.purchaseDate,
    required this.productType,
  }) : super._();

  /// The purchased product ID.
  final String productId;

  /// The transaction ID from the store.
  final String transactionId;

  /// When the purchase was completed.
  final DateTime purchaseDate;

  /// Type of the purchased product.
  final IAPProductType productType;
}

/// User cancelled the purchase.
final class PurchaseResultCancelled extends PurchaseResult {
  /// Creates a [PurchaseResultCancelled].
  const PurchaseResultCancelled({
    required this.productId,
  }) : super._();

  /// The product ID that was being purchased.
  final String productId;
}

/// Purchase failed with an error.
final class PurchaseResultFailed extends PurchaseResult {
  /// Creates a [PurchaseResultFailed].
  const PurchaseResultFailed({
    required this.productId,
    required this.errorCode,
    required this.errorMessage,
  }) : super._();

  /// The product ID that was being purchased.
  final String productId;

  /// Error code from the store.
  final String errorCode;

  /// Human-readable error message.
  final String errorMessage;
}

/// Purchase is pending approval or processing.
final class PurchaseResultPending extends PurchaseResult {
  /// Creates a [PurchaseResultPending].
  const PurchaseResultPending({
    required this.productId,
    required this.reason,
  }) : super._();

  /// The product ID being purchased.
  final String productId;

  /// Reason for the pending state.
  ///
  /// Common reasons:
  /// - 'awaiting_approval' - Waiting for parental/family approval
  /// - 'processing' - Payment is being processed
  /// - 'deferred' - Payment deferred by user
  final String reason;
}

/// Product is not available for purchase.
final class PurchaseResultNotAvailable extends PurchaseResult {
  /// Creates a [PurchaseResultNotAvailable].
  const PurchaseResultNotAvailable({
    required this.productId,
  }) : super._();

  /// The product ID that was not available.
  final String productId;
}

/// Product is already owned (non-consumables only).
final class PurchaseResultAlreadyOwned extends PurchaseResult {
  /// Creates a [PurchaseResultAlreadyOwned].
  const PurchaseResultAlreadyOwned({
    required this.productId,
  }) : super._();

  /// The product ID that is already owned.
  final String productId;
}
