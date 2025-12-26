import 'package:flutter/material.dart';

import '../theme/game_resource_theme.dart';
import 'game_resource_button.dart';

/// Configuration for a single game resource in the panel.
class GameResourceConfig {
  /// The current count of this resource.
  final int count;

  /// Called when this resource is tapped (only when count > 0).
  final VoidCallback? onTap;

  /// Called when this resource is tapped while depleted (count == 0).
  ///
  /// Use this to show a restore dialog or purchase options.
  final VoidCallback? onDepletedTap;

  /// Called when this resource is long-pressed.
  final VoidCallback? onLongPress;

  /// Whether this resource is currently enabled.
  final bool enabled;

  /// Tooltip text shown on long-press.
  final String? tooltip;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  const GameResourceConfig({
    required this.count,
    this.onTap,
    this.onDepletedTap,
    this.onLongPress,
    this.enabled = true,
    this.tooltip,
    this.semanticLabel,
  });

  /// Creates a copy with the specified fields replaced.
  GameResourceConfig copyWith({
    int? count,
    VoidCallback? onTap,
    VoidCallback? onDepletedTap,
    VoidCallback? onLongPress,
    bool? enabled,
    String? tooltip,
    String? semanticLabel,
  }) {
    return GameResourceConfig(
      count: count ?? this.count,
      onTap: onTap ?? this.onTap,
      onDepletedTap: onDepletedTap ?? this.onDepletedTap,
      onLongPress: onLongPress ?? this.onLongPress,
      enabled: enabled ?? this.enabled,
      tooltip: tooltip ?? this.tooltip,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }
}

/// A horizontal panel displaying game resources (Lives, 50/50, Skip).
///
/// Shows up to three resource buttons in a row with consistent spacing.
/// Each resource can be individually configured or hidden by passing null.
///
/// Example:
/// ```dart
/// GameResourcePanel(
///   lives: GameResourceConfig(count: 3, onTap: onLivesTapped),
///   fiftyFifty: GameResourceConfig(count: 2, onTap: onFiftyFiftyTapped),
///   skip: GameResourceConfig(count: 1, onTap: onSkipTapped),
/// )
/// ```
class GameResourcePanel extends StatelessWidget {
  /// Configuration for lives resource (null = hidden).
  final GameResourceConfig? lives;

  /// Configuration for 50/50 hint resource (null = hidden).
  final GameResourceConfig? fiftyFifty;

  /// Configuration for skip hint resource (null = hidden).
  final GameResourceConfig? skip;

  /// Theme for all buttons in this panel.
  final GameResourceTheme? theme;

  /// Alignment of buttons within the panel.
  final MainAxisAlignment alignment;

  /// Main axis size of the row.
  final MainAxisSize mainAxisSize;

  /// Custom icon for lives (defaults to favorite/heart).
  final IconData livesIcon;

  /// Custom icon for 50/50 hint (defaults to filter_2).
  final IconData fiftyFiftyIcon;

  /// Custom icon for skip hint (defaults to skip_next).
  final IconData skipIcon;

  const GameResourcePanel({
    super.key,
    this.lives,
    this.fiftyFifty,
    this.skip,
    this.theme,
    this.alignment = MainAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.min,
    this.livesIcon = Icons.favorite,
    this.fiftyFiftyIcon = Icons.filter_2,
    this.skipIcon = Icons.skip_next,
  });

  /// Creates a panel with compact theme (for AppBar usage).
  factory GameResourcePanel.compact({
    Key? key,
    GameResourceConfig? lives,
    GameResourceConfig? fiftyFifty,
    GameResourceConfig? skip,
    MainAxisAlignment alignment = MainAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    IconData livesIcon = Icons.favorite,
    IconData fiftyFiftyIcon = Icons.filter_2,
    IconData skipIcon = Icons.skip_next,
  }) {
    return GameResourcePanel(
      key: key,
      lives: lives,
      fiftyFifty: fiftyFifty,
      skip: skip,
      theme: GameResourceTheme.compact(),
      alignment: alignment,
      mainAxisSize: mainAxisSize,
      livesIcon: livesIcon,
      fiftyFiftyIcon: fiftyFiftyIcon,
      skipIcon: skipIcon,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? GameResourceTheme.standard();
    final spacing = effectiveTheme.spacingBetweenResources;

    final resources = <Widget>[];

    // Build list of resource buttons
    if (lives != null) {
      resources.add(_buildButton(
        config: lives!,
        icon: livesIcon,
        type: GameResourceType.lives,
        theme: effectiveTheme,
      ));
    }

    if (fiftyFifty != null) {
      resources.add(_buildButton(
        config: fiftyFifty!,
        icon: fiftyFiftyIcon,
        type: GameResourceType.fiftyFifty,
        theme: effectiveTheme,
      ));
    }

    if (skip != null) {
      resources.add(_buildButton(
        config: skip!,
        icon: skipIcon,
        type: GameResourceType.skip,
        theme: effectiveTheme,
      ));
    }

    // Add spacing between buttons
    final spacedResources = <Widget>[];
    for (var i = 0; i < resources.length; i++) {
      spacedResources.add(resources[i]);
      if (i < resources.length - 1) {
        spacedResources.add(SizedBox(width: spacing));
      }
    }

    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: mainAxisSize,
      children: spacedResources,
    );
  }

  Widget _buildButton({
    required GameResourceConfig config,
    required IconData icon,
    required GameResourceType type,
    required GameResourceTheme theme,
  }) {
    return GameResourceButton(
      icon: icon,
      count: config.count,
      resourceType: type,
      onTap: config.onTap,
      onDepletedTap: config.onDepletedTap,
      onLongPress: config.onLongPress,
      enabled: config.enabled,
      tooltip: config.tooltip,
      semanticLabel: config.semanticLabel,
      theme: theme,
    );
  }
}

/// Data class containing all resource panel configuration.
///
/// Used by [AdaptiveResourcePanel] to pass configuration without
/// rebuilding the panel widget tree.
class GameResourcePanelData {
  /// Configuration for lives resource.
  final GameResourceConfig? lives;

  /// Configuration for 50/50 hint resource.
  final GameResourceConfig? fiftyFifty;

  /// Configuration for skip hint resource.
  final GameResourceConfig? skip;

  /// Custom icon for lives.
  final IconData livesIcon;

  /// Custom icon for 50/50 hint.
  final IconData fiftyFiftyIcon;

  /// Custom icon for skip hint.
  final IconData skipIcon;

  const GameResourcePanelData({
    this.lives,
    this.fiftyFifty,
    this.skip,
    this.livesIcon = Icons.favorite,
    this.fiftyFiftyIcon = Icons.filter_2,
    this.skipIcon = Icons.skip_next,
  });

  /// Creates a [GameResourcePanel] from this data.
  GameResourcePanel toPanel({
    GameResourceTheme? theme,
    MainAxisAlignment alignment = MainAxisAlignment.center,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return GameResourcePanel(
      lives: lives,
      fiftyFifty: fiftyFifty,
      skip: skip,
      theme: theme,
      alignment: alignment,
      mainAxisSize: mainAxisSize,
      livesIcon: livesIcon,
      fiftyFiftyIcon: fiftyFiftyIcon,
      skipIcon: skipIcon,
    );
  }

  /// Creates a copy with the specified fields replaced.
  GameResourcePanelData copyWith({
    GameResourceConfig? lives,
    GameResourceConfig? fiftyFifty,
    GameResourceConfig? skip,
    IconData? livesIcon,
    IconData? fiftyFiftyIcon,
    IconData? skipIcon,
    bool clearLives = false,
    bool clearFiftyFifty = false,
    bool clearSkip = false,
  }) {
    return GameResourcePanelData(
      lives: clearLives ? null : (lives ?? this.lives),
      fiftyFifty: clearFiftyFifty ? null : (fiftyFifty ?? this.fiftyFifty),
      skip: clearSkip ? null : (skip ?? this.skip),
      livesIcon: livesIcon ?? this.livesIcon,
      fiftyFiftyIcon: fiftyFiftyIcon ?? this.fiftyFiftyIcon,
      skipIcon: skipIcon ?? this.skipIcon,
    );
  }

  /// Whether this panel has any resources to display.
  bool get hasResources => lives != null || fiftyFifty != null || skip != null;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GameResourcePanelData &&
        other.lives == lives &&
        other.fiftyFifty == fiftyFifty &&
        other.skip == skip &&
        other.livesIcon == livesIcon &&
        other.fiftyFiftyIcon == fiftyFiftyIcon &&
        other.skipIcon == skipIcon;
  }

  @override
  int get hashCode {
    return Object.hash(
      lives,
      fiftyFifty,
      skip,
      livesIcon,
      fiftyFiftyIcon,
      skipIcon,
    );
  }
}
