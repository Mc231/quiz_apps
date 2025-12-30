import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../services/quiz_services_context.dart';

/// A card that displays a bundle pack for purchase.
///
/// Shows:
/// - Bundle title and description
/// - Price from the store
/// - Buy button with loading state
/// - Best value badge if applicable
///
/// Example:
/// ```dart
/// BundlePackCard(
///   productId: 'bundle_starter',
///   title: 'Starter Pack',
///   description: '5 lives + 5 hints + 5 skips',
///   onPurchased: (productId) {
///     // Handle purchase completion
///   },
/// )
/// ```
class BundlePackCard extends StatefulWidget {
  /// The product ID for this bundle.
  final String productId;

  /// The title to display for this bundle.
  final String title;

  /// The description of what's included.
  final String description;

  /// Whether this is the best value option.
  final bool isBestValue;

  /// Callback when the bundle is purchased successfully.
  final void Function(String productId)? onPurchased;

  /// Creates a [BundlePackCard].
  const BundlePackCard({
    super.key,
    required this.productId,
    required this.title,
    required this.description,
    this.isBestValue = false,
    this.onPurchased,
  });

  @override
  State<BundlePackCard> createState() => _BundlePackCardState();
}

class _BundlePackCardState extends State<BundlePackCard> {
  bool _isPurchasing = false;
  DateTime? _purchaseStartTime;

  IAPService get _iapService => context.iapService;
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  Future<void> _handlePurchase() async {
    if (_isPurchasing) return;

    setState(() {
      _isPurchasing = true;
      _purchaseStartTime = DateTime.now();
    });

    final product = _iapService.getProduct(widget.productId);

    try {
      final result = await _iapService.purchase(widget.productId);

      if (!mounted) return;

      final purchaseDuration = _purchaseStartTime != null
          ? DateTime.now().difference(_purchaseStartTime!)
          : Duration.zero;

      switch (result) {
        case PurchaseResultSuccess(:final transactionId):
          _analyticsService.logEvent(
            MonetizationEvent.purchaseCompleted(
              packId: widget.productId,
              packName: widget.title,
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              transactionId: transactionId,
              purchaseDuration: purchaseDuration,
            ),
          );
          widget.onPurchased?.call(widget.productId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  QuizL10n.of(context).purchaseSuccess(
                    1, // Bundle is a single item
                    widget.title,
                  ),
                ),
              ),
            );
          }

        case PurchaseResultCancelled():
          _analyticsService.logEvent(
            MonetizationEvent.purchaseCancelled(
              packId: widget.productId,
              packName: widget.title,
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              cancelReason: 'user_cancelled',
              timeBeforeCancel: purchaseDuration,
            ),
          );

        case PurchaseResultFailed(:final errorCode, :final errorMessage):
          _analyticsService.logEvent(
            MonetizationEvent.purchaseFailed(
              packId: widget.productId,
              packName: widget.title,
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              errorCode: errorCode,
              errorMessage: errorMessage,
            ),
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(QuizL10n.of(context).purchaseFailed)),
            );
          }

        case PurchaseResultPending():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text(QuizL10n.of(context).purchasePending)),
            );
          }

        case PurchaseResultNotAvailable():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      QuizL10n.of(context).purchaseNotAvailable)),
            );
          }

        case PurchaseResultAlreadyOwned():
          // Bundles are consumable, this shouldn't happen
          break;
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
    final product = _iapService.getProduct(widget.productId);
    final isAvailable = _iapService.isStoreAvailable && product != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.description,
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
          if (widget.isBestValue)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(12),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                child: Text(
                  l10n.bestValue,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
