import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_animations.dart';

/// Size variants for [StreakBadge].
enum StreakBadgeSize {
  /// Small badge (24px icon, 12px font).
  small,

  /// Medium badge (32px icon, 16px font).
  medium,

  /// Large badge (48px icon, 24px font).
  large,
}

/// Style configuration for [StreakBadge].
class StreakBadgeStyle {
  /// Creates a [StreakBadgeStyle].
  const StreakBadgeStyle({
    this.activeColor,
    this.atRiskColor,
    this.inactiveColor,
    this.textColor,
    this.showAnimation = true,
    this.showLabel = true,
    this.backgroundColor,
    this.borderRadius = 20.0,
    this.padding,
  });

  /// Default style.
  static const StreakBadgeStyle defaults = StreakBadgeStyle();

  /// Color for active streak (played today).
  final Color? activeColor;

  /// Color for at-risk streak (not played today).
  final Color? atRiskColor;

  /// Color for inactive/broken streak.
  final Color? inactiveColor;

  /// Text color for the count.
  final Color? textColor;

  /// Whether to show flame animation for active streaks.
  final bool showAnimation;

  /// Whether to show the "day streak" label.
  final bool showLabel;

  /// Background color for the badge.
  final Color? backgroundColor;

  /// Border radius of the badge.
  final double borderRadius;

  /// Custom padding for the badge.
  final EdgeInsets? padding;
}

/// A badge widget displaying the user's current streak with a flame icon.
///
/// Shows an animated flame for active streaks, a warning flame for at-risk
/// streaks, and a gray flame for broken/no streaks.
///
/// Example:
/// ```dart
/// StreakBadge(
///   streakCount: 7,
///   status: StreakStatus.active,
///   size: StreakBadgeSize.medium,
/// )
/// ```
class StreakBadge extends StatefulWidget {
  /// Creates a [StreakBadge].
  const StreakBadge({
    super.key,
    required this.streakCount,
    required this.status,
    this.size = StreakBadgeSize.medium,
    this.style = StreakBadgeStyle.defaults,
    this.onTap,
  });

  /// The current streak count.
  final int streakCount;

  /// The status of the streak.
  final StreakStatus status;

  /// Size variant of the badge.
  final StreakBadgeSize size;

  /// Style configuration.
  final StreakBadgeStyle style;

  /// Optional callback when badge is tapped.
  final VoidCallback? onTap;

  @override
  State<StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<StreakBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: QuizAnimations.resourcePulseDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: QuizAnimations.curveStandard,
      ),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: QuizAnimations.curveStandard,
      ),
    );

    // Start animation for active or at-risk streaks
    if (widget.style.showAnimation && widget.status.isActive) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakBadge oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status ||
        oldWidget.style.showAnimation != widget.style.showAnimation) {
      if (widget.style.showAnimation && widget.status.isActive) {
        _animationController.repeat(reverse: true);
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final sizing = _getSizing();

    final statusMessage = _getStatusMessage(l10n);
    final semanticLabel =
        l10n.accessibilityStreakBadge(widget.streakCount, statusMessage);

    return Semantics(
      label: semanticLabel,
      button: widget.onTap != null,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(widget.style.borderRadius),
          excludeFromSemantics: true,
          child: Container(
            padding: widget.style.padding ?? sizing.padding,
            decoration: BoxDecoration(
              color: widget.style.backgroundColor ??
                  _getBackgroundColor(theme).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(widget.style.borderRadius),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFlameIcon(theme, sizing),
                SizedBox(width: sizing.spacing),
                _buildContent(theme, l10n, sizing),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFlameIcon(ThemeData theme, _StreakBadgeSizing sizing) {
    final color = _getFlameColor(theme);

    if (widget.style.showAnimation && widget.status.isActive) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Stack(
              children: [
                // Glow effect
                if (widget.status == StreakStatus.active)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: _glowAnimation.value),
                            blurRadius: sizing.iconSize * 0.5,
                            spreadRadius: sizing.iconSize * 0.1,
                          ),
                        ],
                      ),
                    ),
                  ),
                Icon(
                  Icons.local_fire_department,
                  size: sizing.iconSize,
                  color: color,
                ),
              ],
            ),
          );
        },
      );
    }

    return Icon(
      Icons.local_fire_department,
      size: sizing.iconSize,
      color: color,
    );
  }

  Widget _buildContent(
    ThemeData theme,
    QuizEngineLocalizations l10n,
    _StreakBadgeSizing sizing,
  ) {
    final textColor = widget.style.textColor ?? _getTextColor(theme);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${widget.streakCount}',
          style: TextStyle(
            fontSize: sizing.fontSize,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        if (widget.style.showLabel)
          Text(
            l10n.streakDayStreak,
            style: TextStyle(
              fontSize: sizing.labelFontSize,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
      ],
    );
  }

  Color _getFlameColor(ThemeData theme) {
    switch (widget.status) {
      case StreakStatus.active:
        return widget.style.activeColor ?? Colors.orange;
      case StreakStatus.atRisk:
        return widget.style.atRiskColor ?? Colors.amber;
      case StreakStatus.broken:
      case StreakStatus.none:
        return widget.style.inactiveColor ??
            theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    switch (widget.status) {
      case StreakStatus.active:
        return widget.style.activeColor ?? Colors.orange;
      case StreakStatus.atRisk:
        return widget.style.atRiskColor ?? Colors.amber;
      case StreakStatus.broken:
      case StreakStatus.none:
        return theme.colorScheme.onSurface;
    }
  }

  Color _getTextColor(ThemeData theme) {
    if (widget.status.isEmpty) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }
    return theme.colorScheme.onSurface;
  }

  String _getStatusMessage(QuizEngineLocalizations l10n) {
    switch (widget.status) {
      case StreakStatus.active:
        return l10n.streakActive;
      case StreakStatus.atRisk:
        return l10n.streakAtRisk;
      case StreakStatus.broken:
        return l10n.streakBroken;
      case StreakStatus.none:
        return l10n.streakNone;
    }
  }

  _StreakBadgeSizing _getSizing() {
    switch (widget.size) {
      case StreakBadgeSize.small:
        return _StreakBadgeSizing(
          iconSize: 24,
          fontSize: 14,
          labelFontSize: 10,
          spacing: 6,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        );
      case StreakBadgeSize.medium:
        return _StreakBadgeSizing(
          iconSize: 32,
          fontSize: 18,
          labelFontSize: 12,
          spacing: 8,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        );
      case StreakBadgeSize.large:
        return _StreakBadgeSizing(
          iconSize: 48,
          fontSize: 28,
          labelFontSize: 14,
          spacing: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        );
    }
  }
}

class _StreakBadgeSizing {
  const _StreakBadgeSizing({
    required this.iconSize,
    required this.fontSize,
    required this.labelFontSize,
    required this.spacing,
    required this.padding,
  });

  final double iconSize;
  final double fontSize;
  final double labelFontSize;
  final double spacing;
  final EdgeInsets padding;
}

/// A compact streak badge showing just the flame and count.
class StreakBadgeCompact extends StatelessWidget {
  /// Creates a [StreakBadgeCompact].
  const StreakBadgeCompact({
    super.key,
    required this.streakCount,
    required this.status,
    this.size = 20.0,
    this.onTap,
  });

  /// The current streak count.
  final int streakCount;

  /// The status of the streak.
  final StreakStatus status;

  /// Size of the icon.
  final double size;

  /// Optional callback when tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    final color = _getColor(theme);
    final statusMessage = _getStatusMessage(l10n);

    return Semantics(
      label: l10n.accessibilityStreakBadge(streakCount, statusMessage),
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        excludeFromSemantics: true,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.local_fire_department,
                size: size,
                color: color,
              ),
              const SizedBox(width: 2),
              Text(
                '$streakCount',
                style: TextStyle(
                  fontSize: size * 0.7,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColor(ThemeData theme) {
    switch (status) {
      case StreakStatus.active:
        return Colors.orange;
      case StreakStatus.atRisk:
        return Colors.amber;
      case StreakStatus.broken:
      case StreakStatus.none:
        return theme.colorScheme.onSurface.withValues(alpha: 0.4);
    }
  }

  String _getStatusMessage(QuizEngineLocalizations l10n) {
    switch (status) {
      case StreakStatus.active:
        return l10n.streakActive;
      case StreakStatus.atRisk:
        return l10n.streakAtRisk;
      case StreakStatus.broken:
        return l10n.streakBroken;
      case StreakStatus.none:
        return l10n.streakNone;
    }
  }
}