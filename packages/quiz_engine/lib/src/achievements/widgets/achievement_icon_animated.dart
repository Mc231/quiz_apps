import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../theme/quiz_animations.dart';

/// An animated achievement icon with pulse and glow effects.
///
/// For unlocked achievements, displays a continuous pulse animation
/// with a tier-colored glow effect. For locked achievements, displays
/// a static greyed icon.
///
/// Example:
/// ```dart
/// AchievementIconAnimated(
///   icon: '🏆',
///   tier: AchievementTier.legendary,
///   isUnlocked: true,
///   size: 80,
/// )
/// ```
class AchievementIconAnimated extends StatefulWidget {
  /// Creates an [AchievementIconAnimated].
  const AchievementIconAnimated({
    super.key,
    required this.icon,
    required this.tier,
    required this.isUnlocked,
    this.size = 80.0,
    this.animate = true,
    this.isHidden = false,
  });

  /// The emoji icon to display.
  final String icon;

  /// The achievement tier (determines glow color).
  final AchievementTier tier;

  /// Whether the achievement is unlocked.
  final bool isUnlocked;

  /// Size of the icon container.
  final double size;

  /// Whether to animate (only applies to unlocked achievements).
  final bool animate;

  /// Whether this is a hidden achievement (shows mystery icon).
  final bool isHidden;

  @override
  State<AchievementIconAnimated> createState() =>
      _AchievementIconAnimatedState();
}

class _AchievementIconAnimatedState extends State<AchievementIconAnimated>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: QuizAnimations.achievementGlowDuration,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.3, end: 0.6)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.6, end: 0.3)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_controller);

    _startAnimationIfNeeded();
  }

  @override
  void didUpdateWidget(AchievementIconAnimated oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isUnlocked != widget.isUnlocked ||
        oldWidget.animate != widget.animate) {
      _startAnimationIfNeeded();
    }
  }

  void _startAnimationIfNeeded() {
    if (widget.isUnlocked && widget.animate) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tierColor = widget.tier.color;

    if (widget.isHidden && !widget.isUnlocked) {
      return _buildHiddenIcon(theme);
    }

    if (!widget.isUnlocked) {
      return _buildLockedIcon(theme);
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: tierColor.withValues(alpha: 0.15),
              border: Border.all(
                color: tierColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: tierColor.withValues(alpha: _glowAnimation.value),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.icon,
                style: TextStyle(fontSize: widget.size * 0.5),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLockedIcon(ThemeData theme) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Opacity(
          opacity: 0.5,
          child: Text(
            widget.icon,
            style: TextStyle(fontSize: widget.size * 0.5),
          ),
        ),
      ),
    );
  }

  Widget _buildHiddenIcon(ThemeData theme) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.help_outline,
          size: widget.size * 0.4,
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}