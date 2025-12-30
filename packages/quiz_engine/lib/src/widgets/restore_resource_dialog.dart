import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import 'purchase_resource_sheet.dart';

/// Dialog shown when user taps on a depleted resource.
///
/// Offers options to restore resources via:
/// - Watching a rewarded ad (+1 resource)
/// - Purchasing resource packs
///
/// Example usage:
/// ```dart
/// showDialog(
///   context: context,
///   builder: (_) => RestoreResourceDialog(
///     resourceType: ResourceType.lives(),
///     manager: resourceManager,
///     onRestored: () {
///       // Resource restored, user can continue
///     },
///   ),
/// );
/// ```
class RestoreResourceDialog extends StatefulWidget {
  /// The type of resource to restore.
  final ResourceType resourceType;

  /// The resource manager for handling restoration.
  final ResourceManager manager;

  /// Called when resource is successfully restored with the amount added.
  final void Function(int amount)? onRestored;

  /// Whether the device is currently online.
  ///
  /// If false, shows a "connect to restore" message instead.
  final bool isOnline;

  /// Creates a [RestoreResourceDialog].
  const RestoreResourceDialog({
    super.key,
    required this.resourceType,
    required this.manager,
    this.onRestored,
    this.isOnline = true,
  });

  /// Shows the restore resource dialog.
  ///
  /// Returns the amount restored if successful, `null` otherwise.
  static Future<int?> show({
    required BuildContext context,
    required ResourceType resourceType,
    required ResourceManager manager,
    bool isOnline = true,
  }) async {
    int? restoredAmount;

    await showDialog<void>(
      context: context,
      builder: (_) => RestoreResourceDialog(
        resourceType: resourceType,
        manager: manager,
        isOnline: isOnline,
        onRestored: (amount) {
          restoredAmount = amount;
        },
      ),
    );

    return restoredAmount;
  }

  @override
  State<RestoreResourceDialog> createState() => _RestoreResourceDialogState();
}

class _RestoreResourceDialogState extends State<RestoreResourceDialog> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    // Show offline message if not connected
    if (!widget.isOnline) {
      return _buildOfflineDialog(context, l10n, theme);
    }

    return AlertDialog(
      title: Text(_getTitle(l10n)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Resource icon
          Icon(
            widget.resourceType.icon,
            size: 64,
            color: widget.resourceType.color,
          ),
          const SizedBox(height: 8),
          // Remaining count
          Text(
            l10n.resourceRemaining(widget.manager.getAvailableCount(widget.resourceType)),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          // Action buttons
          ..._buildActionButtons(context, l10n),
        ],
      ),
    );
  }

  Widget _buildOfflineDialog(
    BuildContext context,
    QuizEngineLocalizations l10n,
    ThemeData theme,
  ) {
    return AlertDialog(
      title: Text(l10n.noConnection),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_wifi_off,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.connectToRestore,
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.ok),
        ),
      ],
    );
  }

  List<Widget> _buildActionButtons(
    BuildContext context,
    QuizEngineLocalizations l10n,
  ) {
    final buttons = <Widget>[];

    // Watch ad button
    if (widget.manager.canRestoreViaAd) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _watchAd,
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.play_circle_outline),
            label: Text(
              l10n.watchAdForResource(
                widget.manager.config.getAdReward(widget.resourceType),
                _getResourceName(l10n),
              ),
            ),
          ),
        ),
      );
      buttons.add(const SizedBox(height: 8));
    }

    // Buy button
    if (widget.manager.canPurchase &&
        widget.manager.config.getPacksForType(widget.resourceType).isNotEmpty) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _isLoading ? null : _showPurchaseSheet,
            icon: const Icon(Icons.shopping_cart_outlined),
            label: Text(l10n.buyResource(_getResourceName(l10n))),
          ),
        ),
      );
      buttons.add(const SizedBox(height: 8));
    }

    // No thanks button
    buttons.add(
      SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.noThanks),
        ),
      ),
    );

    return buttons;
  }

  String _getTitle(QuizEngineLocalizations l10n) {
    return switch (widget.resourceType) {
      LivesResource() => l10n.needMoreLives,
      FiftyFiftyResource() => l10n.needMoreHints,
      SkipResource() => l10n.needMoreSkips,
    };
  }

  String _getResourceName(QuizEngineLocalizations l10n) {
    return switch (widget.resourceType) {
      LivesResource() => l10n.livesLabel,
      FiftyFiftyResource() => l10n.fiftyFiftyLabel,
      SkipResource() => l10n.skipLabel,
    };
  }

  Future<void> _watchAd() async {
    setState(() => _isLoading = true);

    try {
      final success = await widget.manager.restoreViaAd(widget.resourceType);

      if (!mounted) return;

      if (success) {
        final adReward = widget.manager.config.getAdReward(widget.resourceType);
        widget.onRestored?.call(adReward);
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              QuizL10n.of(context).adWatchSuccess(
                widget.manager.config.getAdReward(widget.resourceType),
                _getResourceName(QuizL10n.of(context)),
              ),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(QuizL10n.of(context).adNotAvailable),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showPurchaseSheet() async {
    final purchasedAmount = await PurchaseResourceSheet.show(
      context: context,
      resourceType: widget.resourceType,
      manager: widget.manager,
    );

    if (!mounted) return;

    if (purchasedAmount != null) {
      widget.onRestored?.call(purchasedAmount);
      Navigator.of(context).pop();
    }
  }
}
