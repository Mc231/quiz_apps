/// Status of cloud save synchronization.
enum SyncStatus {
  /// Data is fully synced with the cloud.
  synced,

  /// Sync is currently in progress.
  syncing,

  /// Local changes are pending upload.
  ///
  /// This occurs when changes are made while offline
  /// or when sync has been deferred.
  pendingSync,

  /// Device is offline, sync unavailable.
  ///
  /// Changes will be queued and synced when connection is restored.
  offline,

  /// Sync failed with an error.
  ///
  /// User action or retry may be needed.
  error,
}

/// Extension methods for SyncStatus.
extension SyncStatusExtension on SyncStatus {
  /// Returns true if sync is up to date.
  bool get isSynced => this == SyncStatus.synced;

  /// Returns true if sync is in progress.
  bool get isSyncing => this == SyncStatus.syncing;

  /// Returns true if there are pending changes to sync.
  bool get hasPendingChanges => this == SyncStatus.pendingSync;

  /// Returns true if device is offline.
  bool get isOffline => this == SyncStatus.offline;

  /// Returns true if sync has an error.
  bool get hasError => this == SyncStatus.error;

  /// Returns true if sync is available (not offline or errored).
  bool get canSync =>
      this == SyncStatus.synced ||
      this == SyncStatus.pendingSync ||
      this == SyncStatus.syncing;

  /// Returns true if the status indicates work to be done.
  bool get needsAttention =>
      this == SyncStatus.pendingSync || this == SyncStatus.error;
}
