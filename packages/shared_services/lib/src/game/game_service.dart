import 'dart:typed_data';

/// Result of a game service sign-in attempt.
sealed class SignInResult {
  const SignInResult();

  /// Sign-in was successful.
  factory SignInResult.success({
    required String playerId,
    required String displayName,
  }) = SignInSuccess;

  /// Sign-in was cancelled by the user.
  factory SignInResult.cancelled() = SignInCancelled;

  /// Sign-in failed with an error.
  factory SignInResult.failed({
    required String error,
    String? errorCode,
  }) = SignInFailed;

  /// User is not authenticated (e.g., Game Center not set up).
  factory SignInResult.notAuthenticated() = SignInNotAuthenticated;
}

/// Successful sign-in result.
class SignInSuccess extends SignInResult {
  const SignInSuccess({
    required this.playerId,
    required this.displayName,
  });

  /// Unique player identifier.
  final String playerId;

  /// Player's display name.
  final String displayName;
}

/// Sign-in was cancelled by the user.
class SignInCancelled extends SignInResult {
  const SignInCancelled();
}

/// Sign-in failed with an error.
class SignInFailed extends SignInResult {
  const SignInFailed({
    required this.error,
    this.errorCode,
  });

  /// Error message.
  final String error;

  /// Optional error code.
  final String? errorCode;
}

/// User is not authenticated on the platform.
class SignInNotAuthenticated extends SignInResult {
  const SignInNotAuthenticated();
}

/// Player information from game service.
class PlayerInfo {
  const PlayerInfo({
    required this.playerId,
    required this.displayName,
    this.avatarUrl,
  });

  /// Unique player identifier.
  final String playerId;

  /// Player's display name.
  final String displayName;

  /// URL to player's avatar image (if available).
  final String? avatarUrl;

  @override
  String toString() =>
      'PlayerInfo(playerId: $playerId, displayName: $displayName)';
}

/// Platform-agnostic interface for gaming services.
///
/// Provides authentication and player information for game platforms
/// such as Game Center (iOS) and Google Play Games (Android).
abstract interface class GameService {
  /// Signs in the user to the game service.
  ///
  /// Returns a [SignInResult] indicating success, failure, or cancellation.
  Future<SignInResult> signIn();

  /// Signs out the user from the game service.
  ///
  /// Note: On some platforms (e.g., Game Center), sign-out may not be
  /// supported programmatically and users must sign out via system settings.
  Future<void> signOut();

  /// Checks if the user is currently signed in.
  Future<bool> isSignedIn();

  /// Gets the unique player identifier.
  ///
  /// Returns `null` if the user is not signed in.
  Future<String?> getPlayerId();

  /// Gets the player's display name.
  ///
  /// Returns `null` if the user is not signed in.
  Future<String?> getPlayerDisplayName();

  /// Gets the player's avatar image data.
  ///
  /// Returns `null` if the user is not signed in or has no avatar.
  Future<Uint8List?> getPlayerAvatar();

  /// Gets complete player information.
  ///
  /// Returns `null` if the user is not signed in.
  Future<PlayerInfo?> getPlayerInfo();
}