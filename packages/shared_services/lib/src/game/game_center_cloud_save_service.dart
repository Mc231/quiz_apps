import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:icloud_kv_storage/icloud_kv_storage.dart' as icloud;
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_save_conflict_resolver.dart';
import 'cloud_save_data.dart';
import 'cloud_save_service.dart';
import 'game_center_service.dart';
import 'sync_status.dart';

/// Key used for storing cloud save data in iCloud.
const String _iCloudKey = 'quiz_cloud_save';

/// Key used for local cache in SharedPreferences.
const String _localCacheKey = 'cloud_save_local_cache';

/// Key for last sync time in SharedPreferences.
const String _lastSyncTimeKey = 'cloud_save_last_sync_time';

/// Key for pending sync flag in SharedPreferences.
const String _pendingSyncKey = 'cloud_save_pending_sync';

/// iOS Game Center cloud save implementation using iCloud key-value storage.
///
/// This service:
/// - Uses iCloud key-value storage for cloud persistence
/// - Falls back to local SharedPreferences when offline
/// - Uses [GameCenterService] for authentication status
/// - Implements auto-merge conflict resolution
///
/// **Setup Required:**
/// 1. Enable iCloud capability in Xcode
/// 2. Enable "Key-value storage" in iCloud capabilities
/// 3. Use real device for testing (simulator may not sync in real-time)
class GameCenterCloudSaveService implements CloudSaveService {
  /// Creates a Game Center cloud save service.
  ///
  /// Requires [gameCenterService] for authentication checks.
  GameCenterCloudSaveService({
    required GameCenterService gameCenterService,
    CloudSaveConflictResolver? conflictResolver,
  })  : _gameCenterService = gameCenterService,
        _conflictResolver = conflictResolver ?? const CloudSaveConflictResolver();

  final GameCenterService _gameCenterService;
  final CloudSaveConflictResolver _conflictResolver;

  SyncStatus _currentStatus = SyncStatus.synced;
  final _statusController = StreamController<SyncStatus>.broadcast();

  late SharedPreferences _prefs;
  bool _initialized = false;
  icloud.CKKVStorage? _iCloud;

  /// Whether the current platform supports this service.
  bool get isSupported => Platform.isIOS || Platform.isMacOS;

  /// Initializes the service.
  ///
  /// Must be called before using any other methods.
  Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();

    if (isSupported) {
      _iCloud = icloud.CKKVStorage();
    }

    // Check if there's a pending sync from last session
    final hasPending = _prefs.getBool(_pendingSyncKey) ?? false;
    if (hasPending) {
      _updateStatus(SyncStatus.pendingSync);
    }

    _initialized = true;
  }

  void _updateStatus(SyncStatus newStatus) {
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      _statusController.add(newStatus);
    }
  }

  @override
  SyncStatus getSyncStatus() => _currentStatus;

  @override
  Stream<SyncStatus> get syncStatusStream => _statusController.stream;

  @override
  DateTime? getLastSyncTime() {
    final millis = _prefs.getInt(_lastSyncTimeKey);
    return millis != null ? DateTime.fromMillisecondsSinceEpoch(millis) : null;
  }

  @override
  Future<bool> isAvailable() async {
    if (!isSupported) return false;

    // Check if user is signed into Game Center
    final isSignedIn = await _gameCenterService.isSignedIn();
    if (!isSignedIn) return false;

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    return !connectivity.contains(ConnectivityResult.none);
  }

  @override
  Future<SaveResult> saveGameData(CloudSaveData data) async {
    _ensureInitialized();

    // Always save to local cache first
    await _saveToLocalCache(data);

    // Check if we can sync to cloud
    if (!isSupported) {
      return SaveResult.success(savedAt: DateTime.now());
    }

    final isSignedIn = await _gameCenterService.isSignedIn();
    if (!isSignedIn) {
      _markPendingSync();
      return SaveResult.notAuthenticated();
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _markPendingSync();
      return SaveResult.offline();
    }

    // Attempt cloud save
    _updateStatus(SyncStatus.syncing);

    try {
      // Load existing cloud data to check for conflicts
      final existingData = await _loadFromICloud();

      CloudSaveData dataToSave = data;

      if (existingData != null) {
        // Check for conflicts
        if (_conflictResolver.hasConflicts(data, existingData)) {
          // Auto-merge using our resolver
          dataToSave = _conflictResolver.resolve(data, existingData);
        }
      }

      // Save merged data to cloud
      await _saveToICloud(dataToSave);

      // Update local cache with merged data
      await _saveToLocalCache(dataToSave);

      // Update sync state
      await _prefs.setInt(
        _lastSyncTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      await _prefs.setBool(_pendingSyncKey, false);
      _updateStatus(SyncStatus.synced);

      return SaveResult.success(savedAt: DateTime.now());
    } on Exception catch (e) {
      _updateStatus(SyncStatus.error);
      return SaveResult.failed(
        error: 'iCloud save failed: $e',
        errorCode: 'ICLOUD_ERROR',
      );
    }
  }

  @override
  Future<LoadResult> loadGameData() async {
    _ensureInitialized();

    // Check if we can load from cloud
    if (!isSupported) {
      return _loadFromLocalCacheResult();
    }

    final isSignedIn = await _gameCenterService.isSignedIn();
    if (!isSignedIn) {
      return LoadResult.notAuthenticated();
    }

    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      // Return local cache when offline
      return _loadFromLocalCacheResult();
    }

    _updateStatus(SyncStatus.syncing);

    try {
      final cloudData = await _loadFromICloud();
      final localData = await _loadFromLocalCache();

      if (cloudData == null && localData == null) {
        _updateStatus(SyncStatus.synced);
        return LoadResult.noData();
      }

      // Merge cloud and local data
      CloudSaveData finalData;
      if (cloudData != null && localData != null) {
        finalData = _conflictResolver.resolve(localData, cloudData);
      } else {
        finalData = cloudData ?? localData!;
      }

      // Update local cache with merged data
      await _saveToLocalCache(finalData);
      _updateStatus(SyncStatus.synced);

      return LoadResult.success(data: finalData);
    } on Exception catch (e) {
      _updateStatus(SyncStatus.error);
      return LoadResult.failed(
        error: 'iCloud load failed: $e',
        errorCode: 'ICLOUD_ERROR',
      );
    }
  }

  @override
  Future<SaveResult> forceSync() async {
    _ensureInitialized();

    final localData = await _loadFromLocalCache();
    if (localData == null) {
      return SaveResult.success(savedAt: DateTime.now());
    }

    return saveGameData(localData);
  }

  @override
  Future<bool> deleteCloudData() async {
    _ensureInitialized();

    try {
      // Clear local cache
      await _prefs.remove(_localCacheKey);
      await _prefs.remove(_lastSyncTimeKey);
      await _prefs.remove(_pendingSyncKey);

      // Clear iCloud
      if (isSupported && _iCloud != null) {
        await _iCloud!.delete(_iCloudKey);
      }

      _updateStatus(SyncStatus.synced);
      return true;
    } on Exception {
      return false;
    }
  }

  // Private helper methods

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError(
        'GameCenterCloudSaveService not initialized. Call initialize() first.',
      );
    }
  }

  void _markPendingSync() {
    _prefs.setBool(_pendingSyncKey, true);
    _updateStatus(SyncStatus.pendingSync);
  }

  Future<void> _saveToLocalCache(CloudSaveData data) async {
    final json = jsonEncode(data.toJson());
    await _prefs.setString(_localCacheKey, json);
  }

  Future<CloudSaveData?> _loadFromLocalCache() async {
    final json = _prefs.getString(_localCacheKey);
    if (json == null) return null;

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return CloudSaveData.fromJson(map);
    } on Exception {
      return null;
    }
  }

  LoadResult _loadFromLocalCacheResult() {
    final json = _prefs.getString(_localCacheKey);
    if (json == null) return LoadResult.noData();

    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return LoadResult.success(data: CloudSaveData.fromJson(map));
    } on Exception {
      return LoadResult.noData();
    }
  }

  Future<void> _saveToICloud(CloudSaveData data) async {
    if (_iCloud == null) return;

    final json = jsonEncode(data.toJson());
    await _iCloud!.writeString(key: _iCloudKey, value: json);
  }

  Future<CloudSaveData?> _loadFromICloud() async {
    if (_iCloud == null) return null;

    try {
      final json = await _iCloud!.getString(_iCloudKey);
      if (json == null || json.isEmpty) return null;

      final map = jsonDecode(json) as Map<String, dynamic>;
      return CloudSaveData.fromJson(map);
    } on Exception {
      return null;
    }
  }

  /// Disposes resources.
  void dispose() {
    _statusController.close();
  }
}
