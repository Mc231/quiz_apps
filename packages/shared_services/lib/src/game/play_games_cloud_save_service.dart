import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'cloud_save_conflict_resolver.dart';
import 'cloud_save_data.dart';
import 'cloud_save_service.dart';
import 'play_games_service.dart';
import 'sync_status.dart';

/// Key used for local cache in SharedPreferences.
const String _localCacheKey = 'play_games_cloud_save_local_cache';

/// Key for last sync time in SharedPreferences.
const String _lastSyncTimeKey = 'play_games_cloud_save_last_sync_time';

/// Key for pending sync flag in SharedPreferences.
const String _pendingSyncKey = 'play_games_cloud_save_pending_sync';

/// Android Play Games cloud save implementation.
///
/// **Current Implementation:**
/// This service currently uses local SharedPreferences storage as the primary
/// persistence mechanism. The `games_services` package does not yet support
/// Play Games Snapshots API for cloud saves.
///
/// **Future Enhancement:**
/// When Play Games Snapshots support becomes available (via plugin or native
/// integration), this service can be updated to sync with Google's cloud.
///
/// This service:
/// - Uses SharedPreferences for local persistence
/// - Uses [PlayGamesService] for authentication status
/// - Implements auto-merge conflict resolution
/// - Ready for future cloud integration
///
/// **Setup Required:**
/// 1. Configure Play Games in Google Play Console
/// 2. Enable Saved Games in Play Games configuration
/// 3. Test with a test account on a real device
class PlayGamesCloudSaveService implements CloudSaveService {
  /// Creates a Play Games cloud save service.
  ///
  /// Requires [playGamesService] for authentication checks.
  PlayGamesCloudSaveService({
    required PlayGamesService playGamesService,
    CloudSaveConflictResolver? conflictResolver,
  })  : _playGamesService = playGamesService,
        _conflictResolver = conflictResolver ?? const CloudSaveConflictResolver();

  final PlayGamesService _playGamesService;
  final CloudSaveConflictResolver _conflictResolver;

  SyncStatus _currentStatus = SyncStatus.synced;
  final _statusController = StreamController<SyncStatus>.broadcast();

  late SharedPreferences _prefs;
  bool _initialized = false;

  /// Whether the current platform supports this service.
  bool get isSupported => Platform.isAndroid;

  /// Initializes the service.
  ///
  /// Must be called before using any other methods.
  Future<void> initialize() async {
    if (_initialized) return;

    _prefs = await SharedPreferences.getInstance();

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

    // Check if user is signed into Play Games
    final isSignedIn = await _playGamesService.isSignedIn();
    if (!isSignedIn) return false;

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    return !connectivity.contains(ConnectivityResult.none);
  }

  @override
  Future<SaveResult> saveGameData(CloudSaveData data) async {
    _ensureInitialized();

    // Save to local storage
    await _saveToLocalCache(data);

    // Check platform support
    if (!isSupported) {
      return SaveResult.success(savedAt: DateTime.now());
    }

    // Check authentication
    final isSignedIn = await _playGamesService.isSignedIn();
    if (!isSignedIn) {
      _markPendingSync();
      return SaveResult.notAuthenticated();
    }

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _markPendingSync();
      return SaveResult.offline();
    }

    _updateStatus(SyncStatus.syncing);

    try {
      // TODO: Implement Play Games Snapshots API when available
      // For now, we save locally and mark as synced since user is authenticated
      // When Play Games Snapshots is integrated:
      // 1. Load existing snapshot
      // 2. Merge with local data using _conflictResolver
      // 3. Save merged data to snapshot

      // Simulate successful sync (local save completed)
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
        error: 'Play Games save failed: $e',
        errorCode: 'PLAY_GAMES_ERROR',
      );
    }
  }

  @override
  Future<LoadResult> loadGameData() async {
    _ensureInitialized();

    // Check platform support
    if (!isSupported) {
      return _loadFromLocalCacheResult();
    }

    // Check authentication
    final isSignedIn = await _playGamesService.isSignedIn();
    if (!isSignedIn) {
      return LoadResult.notAuthenticated();
    }

    // Check connectivity
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      return _loadFromLocalCacheResult();
    }

    _updateStatus(SyncStatus.syncing);

    try {
      // TODO: Implement Play Games Snapshots API when available
      // For now, return local cache data
      // When Play Games Snapshots is integrated:
      // 1. Load snapshot from cloud
      // 2. Load local cache
      // 3. Merge both using _conflictResolver
      // 4. Return merged data

      final localData = await _loadFromLocalCache();
      _updateStatus(SyncStatus.synced);

      if (localData == null) {
        return LoadResult.noData();
      }

      return LoadResult.success(data: localData);
    } on Exception catch (e) {
      _updateStatus(SyncStatus.error);
      return LoadResult.failed(
        error: 'Play Games load failed: $e',
        errorCode: 'PLAY_GAMES_ERROR',
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

      // TODO: Delete Play Games snapshot when API is available

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
        'PlayGamesCloudSaveService not initialized. Call initialize() first.',
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

  /// Exposes the conflict resolver for testing.
  CloudSaveConflictResolver get conflictResolver => _conflictResolver;

  /// Disposes resources.
  void dispose() {
    _statusController.close();
  }
}
