import 'dart:async';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_save_data.dart';
import 'cloud_save_service.dart';
import 'sync_status.dart';

/// Key used for local cache in SharedPreferences.
const String _localCacheKey = 'noop_cloud_save_local_cache';

/// No-operation cloud save implementation for unsupported platforms.
///
/// This service:
/// - Uses SharedPreferences for local persistence only
/// - Does not sync to any cloud service
/// - Always reports as "synced" (since there's nothing to sync)
///
/// Use this service for:
/// - Web platform
/// - Desktop platforms without game service support
/// - Testing and development
class NoOpCloudSaveService implements CloudSaveService {
  /// Creates a no-op cloud save service.
  NoOpCloudSaveService();

  final _statusController = StreamController<SyncStatus>.broadcast();

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Initializes the service.
  ///
  /// Must be called before using any other methods.
  Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  @override
  SyncStatus getSyncStatus() => SyncStatus.synced;

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  DateTime? getLastSyncTime() => null;

  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<SaveResult> saveGameData(CloudSaveData data) async {
    _ensureInitialized();

    try {
      final json = jsonEncode(data.toJson());
      await _prefs!.setString(_localCacheKey, json);
      return SaveResult.success(savedAt: DateTime.now());
    } on Exception catch (e) {
      return SaveResult.failed(
        error: 'Local save failed: $e',
        errorCode: 'LOCAL_SAVE_ERROR',
      );
    }
  }

  @override
  Future<LoadResult> loadGameData() async {
    _ensureInitialized();

    try {
      final json = _prefs!.getString(_localCacheKey);
      if (json == null) {
        return LoadResult.noData();
      }

      final map = jsonDecode(json) as Map<String, dynamic>;
      return LoadResult.success(data: CloudSaveData.fromJson(map));
    } on Exception catch (e) {
      return LoadResult.failed(
        error: 'Local load failed: $e',
        errorCode: 'LOCAL_LOAD_ERROR',
      );
    }
  }

  @override
  Future<SaveResult> forceSync() async {
    // No sync needed for no-op implementation
    return SaveResult.success(savedAt: DateTime.now());
  }

  @override
  Future<bool> deleteCloudData() async {
    _ensureInitialized();

    try {
      await _prefs!.remove(_localCacheKey);
      return true;
    } on Exception {
      return false;
    }
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'NoOpCloudSaveService not initialized. Call initialize() first.',
      );
    }
  }

  /// Disposes resources.
  void dispose() {
    _statusController.close();
  }
}
