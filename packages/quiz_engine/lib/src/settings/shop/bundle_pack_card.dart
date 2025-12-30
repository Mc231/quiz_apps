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
///
/// The bundle must be defined in [ResourceConfig.bundlePacks] for the
/// resources to be added to the user's inventory after purchase.
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

  /// Callback when the bundle is purchased successfully.
  final void Function(String productId)? onPurchased;

  /// Creates a [BundlePackCard].
  const BundlePackCard({
    super.key,
    required this.productId,
    required this.title,
    required this.description,
    this.onPurchased,
  });

  @override
  State<BundlePackCard> createState() => _BundlePackCardState();
}

class _BundlePackCardState extends State<BundlePackCard> {
  bool _isPurchasing = false;
  DateTime? _purchaseStartTime;

  IAPService get _iapService => context.iapService;
  ResourceManager get _resourceManager => context.resourceManager;
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  Future<void> _handlePurchase() async {
    if (_isPurchasing) return;

    // Get the bundle definition from config
    final bundle = _resourceManager.config.getBundleByProductId(widget.productId);
    if (bundle == null) {
      // Fallback to direct IAP purchase if bundle not defined in config
      // This maintains backward compatibility but won't add resources
      await _handleDirectPurchase();
      return;
    }

    setState(() {
      _isPurchasing = true;
      _purchaseStartTime = DateTime.now();
    });

    final product = _iapService.getProduct(widget.productId);

    try {
      // Use ResourceManager to purchase bundle - this adds resources on success
      final result = await _resourceManager.purchaseBundle(bundle);

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
                    bundle.totalResources,
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
              SnackBar(content: Text(QuizL10n.of(context).purchaseFailed)),
            );
          }

        case PurchaseResultPending():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(QuizL10n.of(context).purchasePending)),
            );
          }

        case PurchaseResultNotAvailable():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(QuizL10n.of(context).purchaseNotAvailable)),
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

  /// Fallback for direct IAP purchase when bundle not in config.
  /// This won't add resources to inventory - bundle must be defined in config.
  Future<void> _handleDirectPurchase() async {
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
                  QuizL10n.of(context).purchaseSuccess(1, widget.title),
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
              SnackBar(content: Text(QuizL10n.of(context).purchaseFailed)),
            );
          }

        case PurchaseResultPending():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(QuizL10n.of(context).purchasePending)),
            );
          }

        case PurchaseResultNotAvailable():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(QuizL10n.of(context).purchaseNotAvailable)),
            );
          }

        case PurchaseResultAlreadyOwned():
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
      child: Padding(
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
    );
  }
}
