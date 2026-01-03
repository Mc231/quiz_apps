import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';
import '../theme/quiz_animations.dart';

/// A tile for managing cloud save synchronization.
///
/// Shows last sync time, current sync status, and provides
/// a "Sync Now" button to force synchronization.
///
/// Example:
/// ```dart
/// CloudSyncTile(
///   syncService: cloudSaveService,
///   onSyncComplete: (result) => showSyncResult(result),
/// )
/// ```
class CloudSyncTile extends StatefulWidget {
  /// Creates a [CloudSyncTile].
  const CloudSyncTile({
    super.key,
    required this.syncService,
    this.onSyncComplete,
    this.onError,
    this.showLastSyncTime = true,
  });

  /// The cloud save service for sync operations.
  final CloudSaveService syncService;

  /// Callback when sync completes.
  final void Function(SaveResult result)? onSyncComplete;

  /// Callback when an error occurs.
  final void Function(String error)? onError;

  /// Whether to show the last sync timestamp.
  final bool showLastSyncTime;

  @override
  State<CloudSyncTile> createState() => _CloudSyncTileState();
}

class _CloudSyncTileState extends State<CloudSyncTile> {
  StreamSubscription<SyncStatus>? _subscription;
  SyncStatus _status = SyncStatus.synced;
  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _status = widget.syncService.getSyncStatus();
    _lastSyncTime = widget.syncService.getLastSyncTime();
    _subscription = widget.syncService.syncStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
          if (status == SyncStatus.synced) {
            _lastSyncTime = widget.syncService.getLastSyncTime();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _handleSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
    });

    // Log analytics event
    context.screenAnalyticsService.logEvent(
      InteractionEvent.buttonTapped(
        buttonName: 'sync_now',
        context: 'settings_screen',
      ),
    );

    try {
      final result = await widget.syncService.forceSync();
      widget.onSyncComplete?.call(result);

      if (mounted) {
        _showSyncResult(result);
      }
    } catch (e) {
      widget.onError?.call(e.toString());
      if (mounted) {
        _showError(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
          _lastSyncTime = widget.syncService.getLastSyncTime();
        });
      }
    }
  }

  void _showSyncResult(SaveResult result) {
    final l10n = QuizL10n.of(context);

    final message = switch (result) {
      SaveSuccess() => l10n.syncSuccess,
      SaveConflict() => l10n.syncConflictResolved,
      SaveFailed(:final error) => l10n.syncFailed(error),
      SaveNotAuthenticated() => l10n.syncNotAuthenticated,
      SaveOffline() => l10n.syncOffline,
    };

    final isError = result is SaveFailed ||
        result is SaveNotAuthenticated ||
        result is SaveOffline;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showError(String error) {
    final l10n = QuizL10n.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.syncFailed(error)),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    final subtitle = _buildSubtitle(l10n);
    final isSyncingOrLoading = _isSyncing || _status == SyncStatus.syncing;

    return ListTile(
      leading: _buildStatusIcon(theme),
      title: Text(l10n.cloudSync),
      subtitle: Text(subtitle),
      trailing: isSyncingOrLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : TextButton.icon(
              onPressed: _canSync() ? _handleSync : null,
              icon: const Icon(Icons.sync, size: 18),
              label: Text(l10n.syncNow),
            ),
    );
  }

  Widget _buildStatusIcon(ThemeData theme) {
    final (icon, color) = switch (_status) {
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

    if (_status == SyncStatus.syncing || _isSyncing) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: QuizAnimations.durationMedium,
        builder: (context, value, child) {
          return Transform.rotate(
            angle: value * 2 * 3.14159,
            child: Icon(icon, color: color),
          );
        },
      );
    }

    return Icon(icon, color: color);
  }

  String _buildSubtitle(QuizLocalizations l10n) {
    if (_status == SyncStatus.syncing || _isSyncing) {
      return l10n.syncStatusSyncing;
    }

    if (_status == SyncStatus.offline) {
      return l10n.syncStatusOffline;
    }

    if (_status == SyncStatus.error) {
      return l10n.syncStatusError;
    }

    if (_status == SyncStatus.pendingSync) {
      return l10n.syncStatusPending;
    }

    if (widget.showLastSyncTime && _lastSyncTime != null) {
      return l10n.lastSynced(_formatLastSync(_lastSyncTime!, l10n));
    }

    return l10n.syncStatusSynced;
  }

  String _formatLastSync(DateTime lastSync, QuizLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(lastSync);

    if (difference.inSeconds < 60) {
      return l10n.justNow;
    } else if (difference.inMinutes < 60) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inHours < 24) {
      return l10n.hoursAgo(difference.inHours);
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return DateFormat.yMMMd().format(lastSync);
    }
  }

  bool _canSync() {
    return !_isSyncing &&
        _status != SyncStatus.syncing &&
        _status != SyncStatus.offline;
  }
}
