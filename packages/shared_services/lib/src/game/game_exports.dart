/// Game services for platform gaming integration.
///
/// Provides platform-agnostic interfaces for:
/// - [GameService] - Authentication and player info
/// - [LeaderboardService] - Score submission and retrieval
/// - [CloudAchievementService] - Cloud-synced achievements
///
/// For unsupported platforms, use:
/// - [NoOpGameService]
/// - [NoOpLeaderboardService]
/// - [NoOpCloudAchievementService]
/// - [NoOpGameServices] - Combined convenience class

// Core interfaces
export 'game_service.dart';
export 'leaderboard_service.dart';
export 'cloud_achievement_service.dart';

// No-op implementations for unsupported platforms
export 'noop_game_services.dart';