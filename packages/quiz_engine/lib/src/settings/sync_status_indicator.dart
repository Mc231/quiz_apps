import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';

/// A compact indicator showing cloud sync status.
///
/// Can be used in app bars, home screens, or settings to show
/// the current state of cloud synchronization.
///
/// Example:
/// ```dart
/// AppBar(
///   actions: [
///     SyncStatusIndicator(
///       syncService: cloudSaveService,
///       onTap: () => _showSyncDetails(),
///     ),
///   ],
/// )
/// ```
class SyncStatusIndicator extends StatefulWidget {
  /// Creates a [SyncStatusIndicator].
  const SyncStatusIndicator({
    super.key,
    required this.syncService,
    this.onTap,
    this.size = 24.0,
    this.showTooltip = true,
  });

  /// The cloud save service to monitor.
  final CloudSaveService syncService;

  /// Callback when the indicator is tapped.
  final VoidCallback? onTap;

  /// Size of the icon.
  final double size;

  /// Whether to show a tooltip on hover/long press.
  final bool showTooltip;

  @override
  State<SyncStatusIndicator> createState() => _SyncStatusIndicatorState();
}

class _SyncStatusIndicatorState extends State<SyncStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  StreamSubscription<SyncStatus>? _subscription;
  SyncStatus _status = SyncStatus.synced;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));

    _status = widget.syncService.getSyncStatus();
    _subscription = widget.syncService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
        _updateAnimation();
      }
    });
    _updateAnimation();
  }

  void _updateAnimation() {
    if (_status == SyncStatus.syncing) {
      _animationController.repeat();
    } else {
      _animationController.stop();
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final icon = _buildIcon();
    final tooltip = _getTooltip(l10n);

    Widget indicator = InkWell(
      onTap: widget.onTap,
      borderRadius: BorderRadius.circular(widget.size),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: icon,
      ),
    );

    if (widget.showTooltip) {
      indicator = Tooltip(
        message: tooltip,
        child: indicator,
      );
    }

    return indicator;
  }

  Widget _buildIcon() {
    final (icon, color) = _getIconAndColor();

    if (_status == SyncStatus.syncing) {
      return RotationTransition(
        turns: _rotationAnimation,
        child: Icon(
          icon,
          size: widget.size,
          color: color,
        ),
      );
    }

    return Icon(
      icon,
      size: widget.size,
      color: color,
    );
  }

  (IconData, Color) _getIconAndColor() {
    final theme = Theme.of(context);

    return switch (_status) {
      SyncStatus.synced => (Icons.cloud_done, theme.colorScheme.primary),
      SyncStatus.syncing => (Icons.sync, theme.colorScheme.primary),
      SyncStatus.pendingSync => (
          Icons.cloud_upload,
          theme.colorScheme.tertiary
        ),
      SyncStatus.offline => (
          Icons.cloud_off,
          theme.colorScheme.onSurfaceVariant
        ),
      SyncStatus.error => (Icons.cloud_off, theme.colorScheme.error),
    };
  }

  String _getTooltip(QuizLocalizations l10n) {
    return switch (_status) {
      SyncStatus.synced => l10n.syncStatusSynced,
      SyncStatus.syncing => l10n.syncStatusSyncing,
      SyncStatus.pendingSync => l10n.syncStatusPending,
      SyncStatus.offline => l10n.syncStatusOffline,
      SyncStatus.error => l10n.syncStatusError,
    };
  }
}

/// Compact sync badge for displaying in cards or lists.
class SyncStatusBadge extends StatelessWidget {
  /// Creates a [SyncStatusBadge].
  const SyncStatusBadge({
    super.key,
    required this.status,
    this.size = 16.0,
  });

  /// The sync status to display.
  final SyncStatus status;

  /// Size of the badge icon.
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final (icon, color) = switch (status) {
      SyncStatus.synced => (Icons.cloud_done, theme.colorScheme.primary),
      SyncStatus.syncing => (Icons.sync, theme.colorScheme.primary),
      SyncStatus.pendingSync => (
          Icons.cloud_upload,
          theme.colorScheme.tertiary
        ),
      SyncStatus.offline => (
          Icons.cloud_off,
          theme.colorScheme.onSurfaceVariant
        ),
      SyncStatus.error => (Icons.cloud_off, theme.colorScheme.error),
    };

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }
}
