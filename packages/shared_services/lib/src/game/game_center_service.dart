import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:games_services/games_services.dart' as gs;

import 'game_service.dart';

/// iOS Game Center implementation of [GameService].
///
/// Provides authentication and player information through Apple's Game Center.
///
/// **Setup Required:**
/// 1. Enable Game Center capability in Xcode (Runner → Signing & Capabilities → +)
/// 2. Configure Game Center in App Store Connect
/// 3. Test with a sandbox account on a real device
///
/// On non-iOS platforms, this service will return not-authenticated results.
/// For cross-platform apps, use platform detection to choose the appropriate
/// service implementation.
class GameCenterService implements GameService {
  /// Creates a new Game Center service instance.
  GameCenterService();

  /// Cached player info after successful sign-in.
  PlayerInfo? _cachedPlayerInfo;

  /// Cached avatar data.
  Uint8List? _cachedAvatarData;

  /// Whether the current platform supports Game Center.
  bool get isSupported => Platform.isIOS || Platform.isMacOS;

  @override
  Future<SignInResult> signIn() async {
    if (!isSupported) {
      return SignInResult.notAuthenticated();
    }

    try {
      final result = await gs.GameAuth.signIn();

      if (result == null) {
        return SignInResult.notAuthenticated();
      }

      // GameAuth.signIn() returns a string message on success.
      // Use Player static methods to get player details.
      final playerId = await gs.Player.getPlayerID();
      final displayName = await gs.Player.getPlayerName();
      final iconImage = await gs.Player.getPlayerIconImage();

      if (playerId == null && displayName == null) {
        return SignInResult.notAuthenticated();
      }

      // Cache player info on successful sign-in
      _cachedPlayerInfo = PlayerInfo(
        playerId: playerId ?? '',
        displayName: displayName ?? 'Player',
        avatarUrl: iconImage, // Base64 encoded image data
      );

      // Cache avatar data if available
      if (iconImage != null) {
        try {
          _cachedAvatarData = base64Decode(iconImage);
        } on FormatException {
          _cachedAvatarData = null;
        }
      }

      return SignInResult.success(
        playerId: _cachedPlayerInfo!.playerId,
        displayName: _cachedPlayerInfo!.displayName,
      );
    } on Exception catch (e) {
      // Check for common Game Center errors
      final errorMessage = e.toString();

      if (errorMessage.contains('cancelled') ||
          errorMessage.contains('cancel')) {
        return SignInResult.cancelled();
      }

      if (errorMessage.contains('not authenticated') ||
          errorMessage.contains('GKErrorDomain') ||
          errorMessage.contains('not signed in')) {
        return SignInResult.notAuthenticated();
      }

      return SignInResult.failed(
        error: 'Game Center sign-in failed: $errorMessage',
        errorCode: 'GAME_CENTER_ERROR',
      );
    }
  }

  @override
  Future<void> signOut() async {
    // Game Center doesn't support programmatic sign-out.
    // Users must sign out through iOS Settings → Game Center.
    // Clear cached data as if signed out.
    _cachedPlayerInfo = null;
    _cachedAvatarData = null;
  }

  @override
  Future<bool> isSignedIn() async {
    if (!isSupported) {
      return false;
    }

    try {
      return await gs.GameAuth.isSignedIn;
    } on Exception {
      return false;
    }
  }

  @override
  Future<String?> getPlayerId() async {
    if (!isSupported) {
      return null;
    }

    // Return cached value if available
    if (_cachedPlayerInfo != null) {
      return _cachedPlayerInfo!.playerId;
    }

    // Try to get directly from Player
    try {
      return await gs.Player.getPlayerID();
    } on Exception {
      return null;
    }
  }

  @override
  Future<String?> getPlayerDisplayName() async {
    if (!isSupported) {
      return null;
    }

    // Return cached value if available
    if (_cachedPlayerInfo != null) {
      return _cachedPlayerInfo!.displayName;
    }

    // Try to get directly from Player
    try {
      return await gs.Player.getPlayerName();
    } on Exception {
      return null;
    }
  }

  @override
  Future<Uint8List?> getPlayerAvatar() async {
    if (!isSupported) {
      return null;
    }

    // Return cached avatar data if available
    if (_cachedAvatarData != null) {
      return _cachedAvatarData;
    }

    // Try to get from Player
    try {
      final iconImage = await gs.Player.getPlayerIconImage();
      if (iconImage != null) {
        _cachedAvatarData = base64Decode(iconImage);
        return _cachedAvatarData;
      }
    } on Exception {
      // Ignore and return null
    }

    return null;
  }

  @override
  Future<PlayerInfo?> getPlayerInfo() async {
    if (!isSupported) {
      return null;
    }

    // Return cached value if available and still signed in
    if (_cachedPlayerInfo != null) {
      final signedIn = await isSignedIn();
      if (signedIn) {
        return _cachedPlayerInfo;
      }
      // Clear cache if no longer signed in
      _cachedPlayerInfo = null;
      _cachedAvatarData = null;
    }

    try {
      // Attempt to sign in to get player info
      final signInResult = await signIn();

      if (signInResult is SignInSuccess) {
        return _cachedPlayerInfo;
      }

      return null;
    } on Exception {
      return null;
    }
  }

  /// Gets the player's avatar as base64-encoded string (if available).
  ///
  /// This is the raw data returned from Game Center.
  /// Use [getPlayerAvatar] for decoded [Uint8List] data.
  String? get playerAvatarBase64 => _cachedPlayerInfo?.avatarUrl;

  /// Clears the cached player information.
  ///
  /// Call this when you want to force a refresh of player data.
  void clearCache() {
    _cachedPlayerInfo = null;
    _cachedAvatarData = null;
  }

  /// Gets high-resolution player avatar.
  ///
  /// This makes a separate API call and may be slow.
  /// Use [getPlayerAvatar] for the cached icon-sized avatar.
  Future<Uint8List?> getPlayerHiResAvatar() async {
    if (!isSupported) {
      return null;
    }

    try {
      final hiResImage = await gs.Player.getPlayerHiResImage();
      if (hiResImage != null) {
        return base64Decode(hiResImage);
      }
    } on Exception {
      // Ignore and return null
    }

    return null;
  }
}
