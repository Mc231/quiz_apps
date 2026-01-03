import 'cloud_save_data.dart';
import 'sync_status.dart';

/// Result of a cloud save operation.
sealed class SaveResult {
  const SaveResult();

  /// Save operation succeeded.
  factory SaveResult.success({DateTime? savedAt}) = SaveSuccess;

  /// Save operation failed with conflict requiring merge.
  factory SaveResult.conflict({
    required CloudSaveData localData,
    required CloudSaveData remoteData,
  }) = SaveConflict;

  /// Save operation failed due to an error.
  factory SaveResult.failed({
    required String error,
    String? errorCode,
  }) = SaveFailed;

  /// Save skipped because user is not authenticated.
  factory SaveResult.notAuthenticated() = SaveNotAuthenticated;

  /// Save skipped because device is offline.
  factory SaveResult.offline() = SaveOffline;
}

/// Successful save result.
class SaveSuccess extends SaveResult {
  const SaveSuccess({this.savedAt});

  /// Timestamp when data was saved.
  final DateTime? savedAt;
}

/// Save conflict detected - local and remote data differ.
class SaveConflict extends SaveResult {
  const SaveConflict({
    required this.localData,
    required this.remoteData,
  });

  /// Local data that was attempted to save.
  final CloudSaveData localData;

  /// Remote data that conflicts with local.
  final CloudSaveData remoteData;
}

/// Save operation failed.
class SaveFailed extends SaveResult {
  const SaveFailed({
    required this.error,
    this.errorCode,
  });

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// Save skipped - user not authenticated.
class SaveNotAuthenticated extends SaveResult {
  const SaveNotAuthenticated();
}

/// Save skipped - device is offline.
class SaveOffline extends SaveResult {
  const SaveOffline();
}

/// Result of a cloud load operation.
sealed class LoadResult {
  const LoadResult();

  /// Load operation succeeded.
  factory LoadResult.success({required CloudSaveData data}) = LoadSuccess;

  /// No cloud save data found.
  factory LoadResult.noData() = LoadNoData;

  /// Load operation failed.
  factory LoadResult.failed({
    required String error,
    String? errorCode,
  }) = LoadFailed;

  /// Load skipped because user is not authenticated.
  factory LoadResult.notAuthenticated() = LoadNotAuthenticated;

  /// Load skipped because device is offline.
  factory LoadResult.offline() = LoadOffline;
}

/// Successful load result.
class LoadSuccess extends LoadResult {
  const LoadSuccess({required this.data});

  /// Loaded cloud save data.
  final CloudSaveData data;
}

/// No cloud data exists.
class LoadNoData extends LoadResult {
  const LoadNoData();
}

/// Load operation failed.
class LoadFailed extends LoadResult {
  const LoadFailed({
    required this.error,
    this.errorCode,
  });

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// Load skipped - user not authenticated.
class LoadNotAuthenticated extends LoadResult {
  const LoadNotAuthenticated();
}

/// Load skipped - device is offline.
class LoadOffline extends LoadResult {
  const LoadOffline();
}

/// Platform-agnostic interface for cloud save operations.
///
/// Provides methods to save and load game progress to/from cloud storage.
/// Platform implementations:
/// - iOS: Game Center / iCloud
/// - Android: Google Play Games
/// - Other: NoOp implementation
abstract interface class CloudSaveService {
  /// Saves game data to the cloud.
  ///
  /// Returns [SaveResult] indicating success, failure, or conflict.
  /// If a conflict is detected, the result will contain both local
  /// and remote data for resolution.
  Future<SaveResult> saveGameData(CloudSaveData data);

  /// Loads game data from the cloud.
  ///
  /// Returns [LoadResult] with the data if found, or appropriate
  /// error/status if not available.
  Future<LoadResult> loadGameData();

  /// Gets the current sync status.
  ///
  /// This reflects the last known state of synchronization.
  SyncStatus getSyncStatus();

  /// Gets the timestamp of the last successful sync.
  ///
  /// Returns null if no sync has been performed.
  DateTime? getLastSyncTime();

  /// Forces a sync operation.
  ///
  /// Attempts to sync local changes with the cloud immediately.
  /// Returns [SaveResult] indicating the outcome.
  Future<SaveResult> forceSync();

  /// Deletes all cloud save data.
  ///
  /// Use with caution - this permanently removes cloud progress.
  /// Returns true if deletion was successful.
  Future<bool> deleteCloudData();

  /// Checks if cloud save is available on this platform.
  ///
  /// Returns true if the platform supports cloud saves and
  /// the user is authenticated.
  Future<bool> isAvailable();

  /// Stream of sync status changes.
  ///
  /// Allows UI to react to sync state changes.
  Stream<SyncStatus> get syncStatusStream;
}
