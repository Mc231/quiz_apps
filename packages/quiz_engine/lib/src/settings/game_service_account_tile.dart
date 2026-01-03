import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../services/quiz_services_context.dart';

/// A tile displaying game service account information.
///
/// Shows the player's avatar, display name, and sign-in status.
/// Provides sign-in/sign-out functionality for Game Center/Play Games.
///
/// Example:
/// ```dart
/// GameServiceAccountTile(
///   gameService: gameCenterService,
///   onSignedIn: (playerId) => syncProgress(),
/// )
/// ```
class GameServiceAccountTile extends StatefulWidget {
  /// Creates a [GameServiceAccountTile].
  const GameServiceAccountTile({
    super.key,
    required this.gameService,
    this.onSignedIn,
    this.onSignedOut,
    this.onError,
    this.platformName,
  });

  /// The game service for authentication.
  final GameService gameService;

  /// Callback when user signs in successfully.
  final void Function(String playerId)? onSignedIn;

  /// Callback when user signs out.
  final VoidCallback? onSignedOut;

  /// Callback when an error occurs.
  final void Function(String error)? onError;

  /// Override platform name (defaults to auto-detected).
  final String? platformName;

  @override
  State<GameServiceAccountTile> createState() => _GameServiceAccountTileState();
}

class _GameServiceAccountTileState extends State<GameServiceAccountTile> {
  bool _isLoading = true;
  bool _isSignedIn = false;
  PlayerInfo? _playerInfo;
  Uint8List? _avatarData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  Future<void> _checkSignInStatus() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _isSignedIn = await widget.gameService.isSignedIn();

      if (_isSignedIn) {
        _playerInfo = await widget.gameService.getPlayerInfo();
        _avatarData = await widget.gameService.getPlayerAvatar();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Log analytics event
    context.screenAnalyticsService.logEvent(
      InteractionEvent.buttonTapped(
        buttonName: 'sign_in_game_service',
        context: 'settings_screen',
      ),
    );

    try {
      final result = await widget.gameService.signIn();

      switch (result) {
        case SignInSuccess(:final playerId, :final displayName):
          _isSignedIn = true;
          _playerInfo = PlayerInfo(
            playerId: playerId,
            displayName: displayName,
          );
          _avatarData = await widget.gameService.getPlayerAvatar();
          widget.onSignedIn?.call(playerId);

        case SignInCancelled():
          // User cancelled, no action needed
          break;

        case SignInFailed(:final error):
          _error = error;
          widget.onError?.call(error);

        case SignInNotAuthenticated():
          _error = 'not_authenticated';
          break;
      }
    } catch (e) {
      _error = e.toString();
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    setState(() {
      _isLoading = true;
    });

    // Log analytics event
    context.screenAnalyticsService.logEvent(
      InteractionEvent.buttonTapped(
        buttonName: 'sign_out_game_service',
        context: 'settings_screen',
      ),
    );

    try {
      await widget.gameService.signOut();
      _isSignedIn = false;
      _playerInfo = null;
      _avatarData = null;
      widget.onSignedOut?.call();
    } catch (e) {
      _error = e.toString();
      widget.onError?.call(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = QuizL10n.of(context);
    final theme = Theme.of(context);

    if (_isLoading) {
      return ListTile(
        leading: _buildLoadingAvatar(theme),
        title: Text(l10n.gameServiceLoading),
        subtitle: Text(_getPlatformName(l10n)),
      );
    }

    if (_isSignedIn && _playerInfo != null) {
      return ListTile(
        leading: _buildPlayerAvatar(theme),
        title: Text(_playerInfo!.displayName),
        subtitle: Text(l10n.gameServiceConnected(_getPlatformName(l10n))),
        trailing: TextButton(
          onPressed: _handleSignOut,
          child: Text(l10n.signOut),
        ),
      );
    }

    return ListTile(
      leading: _buildDefaultAvatar(theme),
      title: Text(l10n.gameServiceNotConnected),
      subtitle: Text(
        _error != null
            ? l10n.gameServiceError
            : l10n.gameServiceSignInSubtitle(_getPlatformName(l10n)),
      ),
      trailing: FilledButton(
        onPressed: _handleSignIn,
        child: Text(l10n.signIn),
      ),
    );
  }

  Widget _buildLoadingAvatar(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildPlayerAvatar(ThemeData theme) {
    if (_avatarData != null) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: MemoryImage(_avatarData!),
      );
    }

    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        _playerInfo?.displayName.substring(0, 1).toUpperCase() ?? '?',
        style: TextStyle(
          color: theme.colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline,
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }

  String _getPlatformName(QuizLocalizations l10n) {
    if (widget.platformName != null) return widget.platformName!;

    // Auto-detect based on platform
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return l10n.gameCenter;
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return l10n.playGames;
    }
    return l10n.gameServices;
  }
}
