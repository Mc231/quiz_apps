import '../analytics_event.dart';

/// Sealed class for monetization-related events.
///
/// Tracks in-app purchases, subscriptions, and ad interactions.
/// Total: 10 events.
sealed class MonetizationEvent extends AnalyticsEvent {
  const MonetizationEvent();

  // ============ Purchase Flow Events ============

  /// Purchase sheet opened event.
  factory MonetizationEvent.purchaseSheetOpened({
    required String source,
    required int availablePacksCount,
    String? triggeredByFeature,
  }) = PurchaseSheetOpenedEvent;

  /// Pack selected event.
  factory MonetizationEvent.packSelected({
    required String packId,
    required String packName,
    required double price,
    required String currency,
    required int packIndex,
  }) = PackSelectedEvent;

  /// Purchase initiated event.
  factory MonetizationEvent.purchaseInitiated({
    required String packId,
    required String packName,
    required double price,
    required String currency,
    required String paymentMethod,
  }) = PurchaseInitiatedEvent;

  /// Purchase completed event.
  factory MonetizationEvent.purchaseCompleted({
    required String packId,
    required String packName,
    required double price,
    required String currency,
    required String transactionId,
    required Duration purchaseDuration,
    bool isFirstPurchase,
  }) = PurchaseCompletedEvent;

  /// Purchase cancelled event.
  factory MonetizationEvent.purchaseCancelled({
    required String packId,
    required String packName,
    required double price,
    required String currency,
    required String cancelReason,
    required Duration timeBeforeCancel,
  }) = PurchaseCancelledEvent;

  /// Purchase failed event.
  factory MonetizationEvent.purchaseFailed({
    required String packId,
    required String packName,
    required double price,
    required String currency,
    required String errorCode,
    required String errorMessage,
  }) = PurchaseFailedEvent;

  // ============ Restore Events ============

  /// Restore initiated event.
  factory MonetizationEvent.restoreInitiated({
    required String source,
  }) = RestoreInitiatedEvent;

  /// Restore completed event.
  factory MonetizationEvent.restoreCompleted({
    required bool success,
    required int restoredCount,
    required Duration restoreDuration,
    String? errorMessage,
  }) = RestoreCompletedEvent;

  // ============ Ad Events ============

  /// Ad watched event.
  factory MonetizationEvent.adWatched({
    required String adType,
    required String adPlacement,
    required Duration watchDuration,
    required bool wasCompleted,
    String? rewardType,
    int? rewardAmount,
  }) = AdWatchedEvent;

  /// Ad failed event.
  factory MonetizationEvent.adFailed({
    required String adType,
    required String adPlacement,
    required String errorCode,
    required String errorMessage,
    required String failureStage,
  }) = AdFailedEvent;
}

// ============ Purchase Flow Event Implementations ============

/// Purchase sheet opened event.
final class PurchaseSheetOpenedEvent extends MonetizationEvent {
  const PurchaseSheetOpenedEvent({
    required this.source,
    required this.availablePacksCount,
    this.triggeredByFeature,
  });

  final String source;
  final int availablePacksCount;
  final String? triggeredByFeature;

  @override
  String get eventName => 'purchase_sheet_opened';

  @override
  Map<String, dynamic> get parameters => {
        'source': source,
        'available_packs_count': availablePacksCount,
        if (triggeredByFeature != null)
          'triggered_by_feature': triggeredByFeature,
      };
}

/// Pack selected event.
final class PackSelectedEvent extends MonetizationEvent {
  const PackSelectedEvent({
    required this.packId,
    required this.packName,
    required this.price,
    required this.currency,
    required this.packIndex,
  });

  final String packId;
  final String packName;
  final double price;
  final String currency;
  final int packIndex;

  @override
  String get eventName => 'pack_selected';

  @override
  Map<String, dynamic> get parameters => {
        'pack_id': packId,
        'pack_name': packName,
        'price': price,
        'currency': currency,
        'pack_index': packIndex,
      };
}

/// Purchase initiated event.
final class PurchaseInitiatedEvent extends MonetizationEvent {
  const PurchaseInitiatedEvent({
    required this.packId,
    required this.packName,
    required this.price,
    required this.currency,
    required this.paymentMethod,
  });

  final String packId;
  final String packName;
  final double price;
  final String currency;
  final String paymentMethod;

  @override
  String get eventName => 'purchase_initiated';

  @override
  Map<String, dynamic> get parameters => {
        'pack_id': packId,
        'pack_name': packName,
        'price': price,
        'currency': currency,
        'payment_method': paymentMethod,
      };
}

/// Purchase completed event.
final class PurchaseCompletedEvent extends MonetizationEvent {
  const PurchaseCompletedEvent({
    required this.packId,
    required this.packName,
    required this.price,
    required this.currency,
    required this.transactionId,
    required this.purchaseDuration,
    this.isFirstPurchase = false,
  });

  final String packId;
  final String packName;
  final double price;
  final String currency;
  final String transactionId;
  final Duration purchaseDuration;
  final bool isFirstPurchase;

  @override
  String get eventName => 'purchase_completed';

  @override
  Map<String, dynamic> get parameters => {
        'pack_id': packId,
        'pack_name': packName,
        'price': price,
        'currency': currency,
        'transaction_id': transactionId,
        'purchase_duration_ms': purchaseDuration.inMilliseconds,
        'is_first_purchase': isFirstPurchase ? 1 : 0,
      };
}

/// Purchase cancelled event.
final class PurchaseCancelledEvent extends MonetizationEvent {
  const PurchaseCancelledEvent({
    required this.packId,
    required this.packName,
    required this.price,
    required this.currency,
    required this.cancelReason,
    required this.timeBeforeCancel,
  });

  final String packId;
  final String packName;
  final double price;
  final String currency;
  final String cancelReason;
  final Duration timeBeforeCancel;

  @override
  String get eventName => 'purchase_cancelled';

  @override
  Map<String, dynamic> get parameters => {
        'pack_id': packId,
        'pack_name': packName,
        'price': price,
        'currency': currency,
        'cancel_reason': cancelReason,
        'time_before_cancel_ms': timeBeforeCancel.inMilliseconds,
      };
}

/// Purchase failed event.
final class PurchaseFailedEvent extends MonetizationEvent {
  const PurchaseFailedEvent({
    required this.packId,
    required this.packName,
    required this.price,
    required this.currency,
    required this.errorCode,
    required this.errorMessage,
  });

  final String packId;
  final String packName;
  final double price;
  final String currency;
  final String errorCode;
  final String errorMessage;

  @override
  String get eventName => 'purchase_failed';

  @override
  Map<String, dynamic> get parameters => {
        'pack_id': packId,
        'pack_name': packName,
        'price': price,
        'currency': currency,
        'error_code': errorCode,
        'error_message': errorMessage,
      };
}

// ============ Restore Event Implementations ============

/// Restore initiated event.
final class RestoreInitiatedEvent extends MonetizationEvent {
  const RestoreInitiatedEvent({
    required this.source,
  });

  final String source;

  @override
  String get eventName => 'restore_initiated';

  @override
  Map<String, dynamic> get parameters => {
        'source': source,
      };
}

/// Restore completed event.
final class RestoreCompletedEvent extends MonetizationEvent {
  const RestoreCompletedEvent({
    required this.success,
    required this.restoredCount,
    required this.restoreDuration,
    this.errorMessage,
  });

  final bool success;
  final int restoredCount;
  final Duration restoreDuration;
  final String? errorMessage;

  @override
  String get eventName => 'restore_completed';

  @override
  Map<String, dynamic> get parameters => {
        'success': success ? 1 : 0,
        'restored_count': restoredCount,
        'restore_duration_ms': restoreDuration.inMilliseconds,
        if (errorMessage != null) 'error_message': errorMessage,
      };
}

// ============ Ad Event Implementations ============

/// Ad watched event.
final class AdWatchedEvent extends MonetizationEvent {
  const AdWatchedEvent({
    required this.adType,
    required this.adPlacement,
    required this.watchDuration,
    required this.wasCompleted,
    this.rewardType,
    this.rewardAmount,
  });

  final String adType;
  final String adPlacement;
  final Duration watchDuration;
  final bool wasCompleted;
  final String? rewardType;
  final int? rewardAmount;

  @override
  String get eventName => 'ad_watched';

  @override
  Map<String, dynamic> get parameters => {
        'ad_type': adType,
        'ad_placement': adPlacement,
        'watch_duration_ms': watchDuration.inMilliseconds,
        'was_completed': wasCompleted ? 1 : 0,
        if (rewardType != null) 'reward_type': rewardType,
        if (rewardAmount != null) 'reward_amount': rewardAmount,
      };
}

/// Ad failed event.
final class AdFailedEvent extends MonetizationEvent {
  const AdFailedEvent({
    required this.adType,
    required this.adPlacement,
    required this.errorCode,
    required this.errorMessage,
    required this.failureStage,
  });

  final String adType;
  final String adPlacement;
  final String errorCode;
  final String errorMessage;
  final String failureStage;

  @override
  String get eventName => 'ad_failed';

  @override
  Map<String, dynamic> get parameters => {
        'ad_type': adType,
        'ad_placement': adPlacement,
        'error_code': errorCode,
        'error_message': errorMessage,
        'failure_stage': failureStage,
      };
}
