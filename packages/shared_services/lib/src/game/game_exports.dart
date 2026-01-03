/// Game services for platform gaming integration.
///
/// Provides platform-agnostic interfaces for:
/// - [GameService] - Authentication and player info
/// - [LeaderboardService] - Score submission and retrieval
/// - [CloudAchievementService] - Cloud-synced achievements
/// - [CloudSaveService] - Cloud save synchronization
///
/// Platform-specific implementations:
/// - **iOS/macOS:** [GameCenterServices] - Apple Game Center
///   - [GameCenterService]
///   - [GameCenterLeaderboardService]
///   - [GameCenterAchievementService]
///   - [GameCenterCloudSaveService]
/// - **Android:** [PlayGamesServices] - Google Play Games
///   - [PlayGamesService]
///   - [PlayGamesLeaderboardService]
///   - [PlayGamesAchievementService]
///   - [PlayGamesCloudSaveService]
///
/// For unsupported platforms, use:
/// - [NoOpGameService]
/// - [NoOpLeaderboardService]
/// - [NoOpCloudAchievementService]
/// - [NoOpCloudSaveService]
/// - [NoOpGameServices] - Combined convenience class
library;

// Core interfaces
export 'game_service.dart';
export 'leaderboard_service.dart';
export 'cloud_achievement_service.dart';
export 'cloud_save_service.dart';
export 'cloud_save_data.dart';
export 'sync_status.dart';
export 'cloud_save_conflict_resolver.dart';

// Configuration
export 'game_service_config.dart';
export 'leaderboard_config.dart';
export 'leaderboard_score_type.dart';

// No-op implementations for unsupported platforms
export 'noop_game_services.dart';
export 'noop_cloud_save_service.dart';

// iOS/macOS Game Center implementations
export 'game_center_service.dart';
export 'game_center_leaderboard_service.dart';
export 'game_center_achievement_service.dart';
export 'game_center_cloud_save_service.dart';
export 'game_center_services.dart';

// Android Play Games implementations
export 'play_games_service.dart';
export 'play_games_leaderboard_service.dart';
export 'play_games_achievement_service.dart';
export 'play_games_cloud_save_service.dart';
export 'play_games_services.dart';