import 'leaderboard_config.dart';

/// Configuration for game services integration.
///
/// Defines how the app integrates with platform gaming services
/// (Game Center on iOS, Play Games on Android) including:
/// - Authentication and account display
/// - Cloud save synchronization
/// - Leaderboard configuration
/// - Achievement ID mapping
///
/// Example:
/// ```dart
/// final config = GameServiceConfig(
///   leaderboards: [
///     LeaderboardConfig(
///       id: 'global',
///       gameCenterId: 'com.app.global',
///       playGamesId: 'CgkI_global',
///     ),
///   ],
///   achievementIdMap: {
///     'first_quiz': 'com.app.first_quiz',
///     'perfect_score': 'com.app.perfect_score',
///   },
/// );
/// ```
class GameServiceConfig {
  /// Creates a [GameServiceConfig].
  const GameServiceConfig({
    this.isEnabled = true,
    this.cloudSyncEnabled = true,
    this.syncOnLaunch = true,
    this.syncAfterQuizCompletion = true,
    this.showAccountInSettings = true,
    this.leaderboards = const [],
    this.achievementIdMap = const {},
  });

  /// Creates a disabled configuration.
  ///
  /// Use when game services should not be available.
  const GameServiceConfig.disabled()
      : isEnabled = false,
        cloudSyncEnabled = false,
        syncOnLaunch = false,
        syncAfterQuizCompletion = false,
        showAccountInSettings = false,
        leaderboards = const [],
        achievementIdMap = const {};

  /// Creates a test configuration with all features enabled.
  ///
  /// Use for testing with mock services.
  const GameServiceConfig.test()
      : isEnabled = true,
        cloudSyncEnabled = true,
        syncOnLaunch = true,
        syncAfterQuizCompletion = true,
        showAccountInSettings = true,
        leaderboards = const [],
        achievementIdMap = const {};

  /// Whether game services are enabled.
  ///
  /// When false, all game service features are disabled.
  final bool isEnabled;

  /// Whether cloud save sync is enabled.
  ///
  /// When enabled, game progress is synced across devices.
  final bool cloudSyncEnabled;

  /// Whether to sync on app launch.
  ///
  /// When enabled, cloud save data is synced when the app starts.
  final bool syncOnLaunch;

  /// Whether to sync after quiz completion.
  ///
  /// When enabled, progress is synced after each quiz is completed.
  final bool syncAfterQuizCompletion;

  /// Whether to show Account section in settings.
  ///
  /// When enabled, shows player info, sign-in, and cloud sync options.
  final bool showAccountInSettings;

  /// List of leaderboard configurations.
  ///
  /// Each leaderboard maps internal IDs to platform-specific IDs.
  final List<LeaderboardConfig> leaderboards;

  /// Maps internal achievement IDs to platform-specific IDs.
  ///
  /// Key: Internal achievement ID (e.g., 'first_quiz')
  /// Value: Platform achievement ID
  ///
  /// For Game Center, this is typically the achievement reference name.
  /// For Play Games, this is the achievement ID from the console.
  final Map<String, String> achievementIdMap;

  /// Finds a leaderboard configuration by internal ID.
  ///
  /// Returns null if no leaderboard with the given ID exists.
  LeaderboardConfig? getLeaderboard(String id) {
    try {
      return leaderboards.firstWhere((l) => l.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Gets the platform achievement ID for an internal achievement ID.
  ///
  /// Returns null if no mapping exists.
  String? getPlatformAchievementId(String internalId) {
    return achievementIdMap[internalId];
  }

  /// Whether any leaderboards are configured.
  bool get hasLeaderboards => leaderboards.isNotEmpty;

  /// Whether any achievement mappings are configured.
  bool get hasAchievements => achievementIdMap.isNotEmpty;

  /// Number of configured leaderboards.
  int get leaderboardCount => leaderboards.length;

  /// Number of mapped achievements.
  int get achievementCount => achievementIdMap.length;

  /// Creates a copy with the given fields replaced.
  GameServiceConfig copyWith({
    bool? isEnabled,
    bool? cloudSyncEnabled,
    bool? syncOnLaunch,
    bool? syncAfterQuizCompletion,
    bool? showAccountInSettings,
    List<LeaderboardConfig>? leaderboards,
    Map<String, String>? achievementIdMap,
  }) {
    return GameServiceConfig(
      isEnabled: isEnabled ?? this.isEnabled,
      cloudSyncEnabled: cloudSyncEnabled ?? this.cloudSyncEnabled,
      syncOnLaunch: syncOnLaunch ?? this.syncOnLaunch,
      syncAfterQuizCompletion:
          syncAfterQuizCompletion ?? this.syncAfterQuizCompletion,
      showAccountInSettings:
          showAccountInSettings ?? this.showAccountInSettings,
      leaderboards: leaderboards ?? this.leaderboards,
      achievementIdMap: achievementIdMap ?? this.achievementIdMap,
    );
  }

  @override
  String toString() {
    return 'GameServiceConfig(isEnabled: $isEnabled, '
        'cloudSyncEnabled: $cloudSyncEnabled, '
        'syncOnLaunch: $syncOnLaunch, '
        'syncAfterQuizCompletion: $syncAfterQuizCompletion, '
        'showAccountInSettings: $showAccountInSettings, '
        'leaderboards: ${leaderboards.length}, '
        'achievements: ${achievementIdMap.length})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! GameServiceConfig) return false;

    return other.isEnabled == isEnabled &&
        other.cloudSyncEnabled == cloudSyncEnabled &&
        other.syncOnLaunch == syncOnLaunch &&
        other.syncAfterQuizCompletion == syncAfterQuizCompletion &&
        other.showAccountInSettings == showAccountInSettings &&
        _listEquals(other.leaderboards, leaderboards) &&
        _mapEquals(other.achievementIdMap, achievementIdMap);
  }

  @override
  int get hashCode {
    return Object.hash(
      isEnabled,
      cloudSyncEnabled,
      syncOnLaunch,
      syncAfterQuizCompletion,
      showAccountInSettings,
      Object.hashAll(leaderboards),
      Object.hashAll(achievementIdMap.entries),
    );
  }

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _mapEquals<K, V>(Map<K, V> a, Map<K, V> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
