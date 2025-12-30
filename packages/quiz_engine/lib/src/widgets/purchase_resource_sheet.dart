import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';

/// Bottom sheet for purchasing resource packs.
///
/// Displays available packs for a specific resource type with
/// prices and "best value" indicators.
///
/// Example usage:
/// ```dart
/// final purchased = await PurchaseResourceSheet.show(
///   context: context,
///   resourceType: ResourceType.lives(),
///   manager: resourceManager,
/// );
/// ```
class PurchaseResourceSheet extends StatefulWidget {
  /// The type of resource to purchase.
  final ResourceType resourceType;

  /// The resource manager for handling purchases.
  final ResourceManager manager;

  /// Called when a purchase is successful with the amount purchased.
  final void Function(int amount)? onPurchased;

  /// Creates a [PurchaseResourceSheet].
  const PurchaseResourceSheet({
    super.key,
    required this.resourceType,
    required this.manager,
    this.onPurchased,
  });

  /// Shows the purchase resource sheet.
  ///
  /// Returns the amount purchased if successful, `null` otherwise.
  static Future<int?> show({
    required BuildContext context,
    required ResourceType resourceType,
    required ResourceManager manager,
  }) async {
    int? purchasedAmount;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PurchaseResourceSheet(
        resourceType: resourceType,
        manager: manager,
        onPurchased: (amount) {
          purchasedAmount = amount;
        },
      ),
    );

    return purchasedAmount;
  }

  @override
  State<PurchaseResourceSheet> createState() => _PurchaseResourceSheetState();
}

class _PurchaseResourceSheetState extends State<PurchaseResourceSheet> {
  String? _purchasingPackId;
  bool _isRestoring = false;
  final Map<String, String> _prices = {};

  @override
  void initState() {
    super.initState();
    _loadPrices();
  }

  Future<void> _loadPrices() async {
    final packs = widget.manager.config.getPacksForType(widget.resourceType);

    for (final pack in packs) {
      final price = await widget.manager.getLocalizedPrice(pack);
      if (mounted && price != null) {
        setState(() {
          _prices[pack.id] = price;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);
    final packs = widget.manager.config.getPacksForType(widget.resourceType);

    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    widget.resourceType.icon,
                    color: widget.resourceType.color,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _getTitle(l10n),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const Divider(),

            // Pack list
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: packs.length,
                itemBuilder: (context, index) {
                  return _buildPackTile(context, packs[index], l10n, theme);
                },
              ),
            ),

            // Restore purchases button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isRestoring ? null : _restorePurchases,
                  child: _isRestoring
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.restorePurchases),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPackTile(
    BuildContext context,
    ResourcePack pack,
    QuizEngineLocalizations l10n,
    ThemeData theme,
  ) {
    final isPurchasing = _purchasingPackId == pack.id;
    final price = _prices[pack.id] ?? pack.displayPrice ?? '...';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Stack(
          children: [
            Icon(
              widget.resourceType.icon,
              color: widget.resourceType.color,
              size: 40,
            ),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'x${pack.amount}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ],
        ),
        title: Row(
          children: [
            Text('${pack.amount} ${_getResourceName(l10n)}'),
            if (pack.isBestValue) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.bestValue,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: isPurchasing
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : FilledButton(
                onPressed: _purchasingPackId != null
                    ? null
                    : () => _purchasePack(pack),
                child: Text(price),
              ),
      ),
    );
  }

  String _getTitle(QuizEngineLocalizations l10n) {
    return switch (widget.resourceType) {
      LivesResource() => l10n.buyLives,
      FiftyFiftyResource() => l10n.buyHints,
      SkipResource() => l10n.buySkips,
    };
  }

  String _getResourceName(QuizEngineLocalizations l10n) {
    return switch (widget.resourceType) {
      LivesResource() => l10n.livesLabel,
      FiftyFiftyResource() => l10n.fiftyFiftyLabel,
      SkipResource() => l10n.skipLabel,
    };
  }

  Future<void> _purchasePack(ResourcePack pack) async {
    setState(() => _purchasingPackId = pack.id);

    try {
      final result = await widget.manager.purchasePack(pack);

      if (!mounted) return;

      switch (result) {
        case PurchaseResultSuccess():
          widget.onPurchased?.call(pack.amount);
          Navigator.of(context).pop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                QuizL10n.of(context).purchaseSuccess(
                  pack.amount,
                  _getResourceName(QuizL10n.of(context)),
                ),
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );

        case PurchaseResultCancelled():
          // User cancelled, do nothing
          break;

        case PurchaseResultFailed():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(QuizL10n.of(context).purchaseFailed),
              behavior: SnackBarBehavior.floating,
            ),
          );

        case PurchaseResultPending():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(QuizL10n.of(context).purchasePending),
              behavior: SnackBarBehavior.floating,
            ),
          );

        case PurchaseResultNotAvailable():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(QuizL10n.of(context).purchaseNotAvailable),
              behavior: SnackBarBehavior.floating,
            ),
          );

        case PurchaseResultAlreadyOwned():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(QuizL10n.of(context).purchaseAlreadyOwned),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() => _purchasingPackId = null);
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isRestoring = true);

    try {
      await widget.manager.restorePurchases();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(QuizL10n.of(context).purchasesRestored),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isRestoring = false);
      }
    }
  }
}
