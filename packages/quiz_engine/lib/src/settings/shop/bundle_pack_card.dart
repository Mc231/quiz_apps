import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../services/quiz_services_context.dart';

/// Extension to generate localized bundle descriptions from contents.
extension BundlePackLocalization on BundlePack {
  /// Generates a localized description from bundle contents.
  String localizedDescription(QuizEngineLocalizations l10n) {
    final parts = <String>[];

    final lives = contents[ResourceType.lives()];
    if (lives != null && lives > 0) {
      parts.add(l10n.bundleLivesContent(lives));
    }

    final hints = contents[ResourceType.fiftyFifty()];
    if (hints != null && hints > 0) {
      parts.add(l10n.bundleHintsContent(hints));
    }

    final skips = contents[ResourceType.skip()];
    if (skips != null && skips > 0) {
      parts.add(l10n.bundleSkipsContent(skips));
    }

    return parts.join(' + ');
  }
}

/// A card that displays a bundle pack for purchase.
///
/// Shows:
/// - Bundle title and localized description from contents
/// - Price from the store
/// - Buy button with loading state
///
/// The bundle must be defined in [ResourceConfig.bundlePacks] for the
/// resources to be added to the user's inventory after purchase.
///
/// Example:
/// ```dart
/// BundlePackCard(
///   bundle: starterBundle,
///   onPurchased: (productId) {
///     // Handle purchase completion
///   },
/// )
/// ```
class BundlePackCard extends StatefulWidget {
  /// The bundle pack to display.
  final BundlePack bundle;

  /// Callback when the bundle is purchased successfully.
  final void Function(String productId)? onPurchased;

  /// Creates a [BundlePackCard].
  const BundlePackCard({
    super.key,
    required this.bundle,
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

    final bundle = widget.bundle;

    setState(() {
      _isPurchasing = true;
      _purchaseStartTime = DateTime.now();
    });

    final product = _iapService.getProduct(widget.bundle.productId);

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
              packId: widget.bundle.productId,
              packName: widget.bundle.name,
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              transactionId: transactionId,
              purchaseDuration: purchaseDuration,
            ),
          );
          widget.onPurchased?.call(widget.bundle.productId);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  QuizL10n.of(context).purchaseSuccess(
                    bundle.totalResources,
                    widget.bundle.name,
                  ),
                ),
              ),
            );
          }

        case PurchaseResultCancelled():
          _analyticsService.logEvent(
            MonetizationEvent.purchaseCancelled(
              packId: widget.bundle.productId,
              packName: widget.bundle.name,
              price: product?.rawPrice ?? 0,
              currency: product?.currencyCode ?? 'USD',
              cancelReason: 'user_cancelled',
              timeBeforeCancel: purchaseDuration,
            ),
          );

        case PurchaseResultFailed(:final errorCode, :final errorMessage):
          _analyticsService.logEvent(
            MonetizationEvent.purchaseFailed(
              packId: widget.bundle.productId,
              packName: widget.bundle.name,
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

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);
    final product = _iapService.getProduct(widget.bundle.productId);
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
                    widget.bundle.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.bundle.localizedDescription(l10n),
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
