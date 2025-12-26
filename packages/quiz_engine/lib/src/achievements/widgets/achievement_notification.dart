import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_services/shared_services.dart';

import '../../l10n/quiz_localizations.dart';
import '../../theme/quiz_animations.dart';

/// Style configuration for [AchievementNotification].
class AchievementNotificationStyle {
  /// Creates an [AchievementNotificationStyle].
  const AchievementNotificationStyle({
    this.backgroundColor,
    this.borderRadius = 16.0,
    this.padding = const EdgeInsets.all(16),
    this.iconSize = 48.0,
    this.showConfetti = true,
    this.showGlow = true,
    this.animationDuration = QuizAnimations.achievementSlideDuration,
    this.displayDuration = QuizAnimations.achievementDisplayDuration,
  });

  /// Background color of the notification.
  final Color? backgroundColor;

  /// Border radius of the notification.
  final double borderRadius;

  /// Padding around the content.
  final EdgeInsets padding;

  /// Size of the achievement icon.
  final double iconSize;

  /// Whether to show confetti animation.
  final bool showConfetti;

  /// Whether to show glow effect around the icon.
  final bool showGlow;

  /// Duration of enter/exit animations.
  final Duration animationDuration;

  /// How long the notification stays visible.
  final Duration displayDuration;
}

/// A notification widget that displays when an achievement is unlocked.
///
/// Shows the achievement icon, name, and points earned with
/// celebration animations.
///
/// Example:
/// ```dart
/// AchievementNotification(
///   achievement: unlockedAchievement,
///   onDismiss: () => removeNotification(),
/// )
/// ```
class AchievementNotification extends StatefulWidget {
  /// Creates an [AchievementNotification].
  const AchievementNotification({
    super.key,
    required this.achievement,
    this.onDismiss,
    this.style = const AchievementNotificationStyle(),
    this.hapticService,
    this.audioService,
  });

  /// The achievement that was unlocked.
  final Achievement achievement;

  /// Called when the notification is dismissed.
  final VoidCallback? onDismiss;

  /// Style configuration.
  final AchievementNotificationStyle style;

  /// Optional haptic service for feedback.
  final HapticService? hapticService;

  /// Optional audio service for sound effects.
  final AudioService? audioService;

  @override
  State<AchievementNotification> createState() =>
      _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final AnimationController _glowController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _glowAnimation;

  Timer? _dismissTimer;
  Timer? _animationDelayTimer;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();

    // Slide animation
    _slideController = AnimationController(
      vsync: this,
      duration: widget.style.animationDuration,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: QuizAnimations.achievementSlideCurve,
    ));

    // Scale/bounce animation for the icon
    _scaleController = AnimationController(
      vsync: this,
      duration: QuizAnimations.achievementBounceDuration,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: QuizAnimations.bounceOvershoot),
        weight: 40,
      ),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(
      parent: _scaleController,
      curve: QuizAnimations.achievementScaleCurve,
    ));

    // Glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: QuizAnimations.achievementGlowDuration,
    );
    _glowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: QuizAnimations.achievementGlowCurve,
      ),
    );

    _startAnimations();
  }

  void _startAnimations() {
    // Start entrance animations
    _slideController.forward();

    // Trigger haptic feedback and sound
    widget.hapticService?.importantAction();
    widget.audioService?.playSoundEffect(QuizSoundEffect.achievement);

    // Start icon animations after a slight delay
    _animationDelayTimer = Timer(QuizAnimations.durationQuick, () {
      if (mounted) {
        _scaleController.forward();
        if (widget.style.showGlow) {
          _glowController.repeat(reverse: true);
        }
      }
    });

    // Set up auto-dismiss timer
    _dismissTimer = Timer(widget.style.displayDuration, _dismiss);
  }

  void _dismiss() {
    if (_isDismissed) return;
    _isDismissed = true;

    _dismissTimer?.cancel();
    _slideController.reverse().then((_) {
      if (mounted) {
        widget.onDismiss?.call();
      }
    });
  }

  @override
  void dispose() {
    _dismissTimer?.cancel();
    _animationDelayTimer?.cancel();
    _slideController.dispose();
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);
    final tierColor = widget.achievement.tier.color;
    final tierName = widget.achievement.tier.name;

    final semanticLabel = l10n.accessibilityAchievementNotification(
      widget.achievement.name(context),
      tierName,
      widget.achievement.points,
    );

    return Semantics(
      label: semanticLabel,
      hint: l10n.accessibilityDoubleTapToDismiss,
      liveRegion: true,
      child: SlideTransition(
        position: _slideAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GestureDetector(
              onTap: _dismiss,
              excludeFromSemantics: true,
              child: Stack(
                children: [
                  // Main notification card
                  Container(
                    decoration: BoxDecoration(
                      color: widget.style.backgroundColor ??
                          theme.colorScheme.primaryContainer,
                      borderRadius:
                          BorderRadius.circular(widget.style.borderRadius),
                      boxShadow: [
                        BoxShadow(
                          color: tierColor.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                      border: Border.all(
                        color: tierColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    padding: widget.style.padding,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildIcon(theme, tierColor),
                        const SizedBox(width: 16),
                        Flexible(child: _buildContent(context, theme)),
                      ],
                    ),
                  ),

                  // Confetti overlay
                  if (widget.style.showConfetti)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: _ConfettiOverlay(
                          color: tierColor,
                          controller: _scaleController,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme, Color tierColor) {
    return AnimatedBuilder(
      animation: Listenable.merge([_scaleAnimation, _glowAnimation]),
      builder: (context, child) {
        return Container(
          decoration: widget.style.showGlow
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color:
                          tierColor.withValues(alpha: 0.4 * _glowAnimation.value),
                      blurRadius: 20 * _glowAnimation.value,
                      spreadRadius: 5 * _glowAnimation.value,
                    ),
                  ],
                )
              : null,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.style.iconSize,
              height: widget.style.iconSize,
              decoration: BoxDecoration(
                color: tierColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: tierColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: Text(
                  widget.achievement.icon,
                  style: TextStyle(fontSize: widget.style.iconSize * 0.5),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievement Unlocked!',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.achievement.name(context),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TierBadge(tier: widget.achievement.tier),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text(
                    '+${widget.achievement.points} pts',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.amber.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Simple tier badge for the notification.
class _TierBadge extends StatelessWidget {
  const _TierBadge({required this.tier});

  final AchievementTier tier;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tier.color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: tier.color.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Text(
        tier.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: tier.color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Simple confetti overlay animation.
class _ConfettiOverlay extends StatelessWidget {
  const _ConfettiOverlay({
    required this.color,
    required this.controller,
  });

  final Color color;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (controller.value < 0.3) {
          return const SizedBox.shrink();
        }

        return CustomPaint(
          painter: _ConfettiPainter(
            progress: controller.value,
            color: color,
          ),
        );
      },
    );
  }
}

/// Custom painter for confetti particles.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({
    required this.progress,
    required this.color,
  });

  final double progress;
  final Color color;

  static final _random = math.Random(42); // Fixed seed for consistent pattern
  static final List<_Particle> _particles = List.generate(
    20,
    (i) => _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: 4 + _random.nextDouble() * 4,
      rotation: _random.nextDouble() * math.pi * 2,
      color: [
        Colors.amber,
        Colors.orange,
        Colors.yellow,
        Colors.red,
        Colors.pink,
      ][_random.nextInt(5)],
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final adjustedProgress = (progress - 0.3) / 0.7;
    final opacity = (1.0 - adjustedProgress).clamp(0.0, 1.0);

    for (final particle in _particles) {
      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity * 0.8);

      final x = particle.x * size.width;
      final startY = -20.0;
      final endY = size.height + 20;
      final y = startY + (endY - startY) * adjustedProgress * particle.y * 2;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(particle.rotation + adjustedProgress * math.pi);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Represents a confetti particle.
class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.rotation,
    required this.color,
  });

  final double x;
  final double y;
  final double size;
  final double rotation;
  final Color color;
}
