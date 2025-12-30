import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../services/quiz_services_context.dart';

/// A tile that allows users to restore previous purchases.
///
/// Shows:
/// - Restore button with loading state
/// - Success/failure feedback via snackbar
///
/// Example:
/// ```dart
/// RestorePurchasesTile(
///   onRestored: (productIds) {
///     // Handle restored product IDs
///   },
/// )
/// ```
class RestorePurchasesTile extends StatefulWidget {
  /// Callback when purchases are restored successfully.
  ///
  /// Receives a list of restored product IDs.
  final void Function(List<String> productIds)? onRestored;

  /// Creates a [RestorePurchasesTile].
  const RestorePurchasesTile({
    super.key,
    this.onRestored,
  });

  @override
  State<RestorePurchasesTile> createState() => _RestorePurchasesTileState();
}

class _RestorePurchasesTileState extends State<RestorePurchasesTile> {
  bool _isRestoring = false;
  DateTime? _restoreStartTime;

  IAPService get _iapService => context.iapService;
  AnalyticsService get _analyticsService => context.screenAnalyticsService;

  Future<void> _handleRestore() async {
    if (_isRestoring) return;

    setState(() {
      _isRestoring = true;
      _restoreStartTime = DateTime.now();
    });

    _analyticsService.logEvent(
      MonetizationEvent.restoreInitiated(source: 'settings_shop'),
    );

    try {
      final restoredIds = await _iapService.restorePurchases();

      if (!mounted) return;

      final restoreDuration = _restoreStartTime != null
          ? DateTime.now().difference(_restoreStartTime!)
          : Duration.zero;

      _analyticsService.logEvent(
        MonetizationEvent.restoreCompleted(
          success: true,
          restoredCount: restoredIds.length,
          restoreDuration: restoreDuration,
        ),
      );

      final l10n = QuizL10n.of(context);

      if (restoredIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.noPurchasesToRestore)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.purchasesRestoredCount(restoredIds.length)),
          ),
        );
        widget.onRestored?.call(restoredIds);
      }
    } catch (e) {
      final restoreDuration = _restoreStartTime != null
          ? DateTime.now().difference(_restoreStartTime!)
          : Duration.zero;

      _analyticsService.logEvent(
        MonetizationEvent.restoreCompleted(
          success: false,
          restoredCount: 0,
          restoreDuration: restoreDuration,
          errorMessage: e.toString(),
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(QuizL10n.of(context).purchaseFailed)),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRestoring = false;
          _restoreStartTime = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);

    return ListTile(
      leading: const Icon(Icons.restore),
      title: Text(l10n.restorePurchases),
      subtitle: Text(l10n.restorePurchasesDescription),
      trailing: _isRestoring
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : null,
      onTap: _iapService.isStoreAvailable && !_isRestoring
          ? _handleRestore
          : null,
    );
  }
}
