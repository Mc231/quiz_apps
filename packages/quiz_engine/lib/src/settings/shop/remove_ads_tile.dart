import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../services/quiz_services_context.dart';

/// A tile that displays the Remove Ads purchase option.
///
/// Shows:
/// - Purchase button with price when not purchased
/// - "Purchased" status when already owned
/// - Loading state during purchase
///
/// Example:
/// ```dart
/// RemoveAdsTile(
///   onPurchased: () {
///     // Called when remove_ads is purchased
///   },
/// )
/// ```
class RemoveAdsTile extends StatefulWidget {
  /// Callback when remove_ads is purchased successfully.
  final VoidCallback? onPurchased;

  /// Creates a [RemoveAdsTile].
  const RemoveAdsTile({
    super.key,
    this.onPurchased,
  });

  @override
  State<RemoveAdsTile> createState() => _RemoveAdsTileState();
}

class _RemoveAdsTileState extends State<RemoveAdsTile> {
  bool _isPurchasing = false;
  bool _isPurchased = false;
  DateTime? _purchaseStartTime;
  StreamSubscription<bool>? _removeAdsSubscription;

  IAPService get _iapService => context.iapService;
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _isPurchased = _iapService.isRemoveAdsPurchased;
    _removeAdsSubscription?.cancel();
    _removeAdsSubscription = _iapService.onRemoveAdsPurchased.listen((value) {
      if (mounted) {
        setState(() {
          _isPurchased = value;
        });
        if (value) {
          widget.onPurchased?.call();
        }
      }
    });
  }

  @override
  void dispose() {
    _removeAdsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePurchase() async {
    if (_isPurchasing || _isPurchased) return;

    setState(() {
      _isPurchasing = true;
      _purchaseStartTime = DateTime.now();
    });

    final product = _iapService.getProduct('remove_ads');

    try {
      final result = await _iapService.purchase('remove_ads');

      if (!mounted) return;

      final purchaseDuration = _purchaseStartTime != null
          ? DateTime.now().difference(_purchaseStartTime!)
          : Duration.zero;

      switch (result) {
        case PurchaseResultSuccess(:final transactionId):
          _analyticsService.logEvent(
            MonetizationEvent.purchaseCompleted(
              packId: 'remove_ads',
              packName: 'Remove Ads',
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              transactionId: transactionId,
              purchaseDuration: purchaseDuration,
            ),
          );
          setState(() {
            _isPurchased = true;
          });
          widget.onPurchased?.call();

        case PurchaseResultCancelled():
          _analyticsService.logEvent(
            MonetizationEvent.purchaseCancelled(
              packId: 'remove_ads',
              packName: 'Remove Ads',
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              cancelReason: 'user_cancelled',
              timeBeforeCancel: purchaseDuration,
            ),
          );

        case PurchaseResultFailed(:final errorCode, :final errorMessage):
          _analyticsService.logEvent(
            MonetizationEvent.purchaseFailed(
              packId: 'remove_ads',
              packName: 'Remove Ads',
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              errorCode: errorCode,
              errorMessage: errorMessage,
            ),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(QuizL10n.of(context).purchaseFailed)),
            );
          }

        case PurchaseResultPending():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(QuizL10n.of(context).purchasePending)),
            );
          }

        case PurchaseResultNotAvailable():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(QuizL10n.of(context).purchaseNotAvailable)),
            );
          }

        case PurchaseResultAlreadyOwned():
          setState(() {
            _isPurchased = true;
          });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPurchasing = false;
          _purchaseStartTime = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);
    final product = _iapService.getProduct('remove_ads');
    final isAvailable = _iapService.isStoreAvailable && product != null;

    if (_isPurchased) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.removeAdsPurchased,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.removeAdsPurchasedDescription,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.removeAds,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.removeAdsDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            _isPurchasing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : FilledButton(
                    onPressed: isAvailable ? _handlePurchase : null,
                    child: Text(product?.price ?? l10n.buy),
                  ),
          ],
        ),
      ),
    );
  }
}
