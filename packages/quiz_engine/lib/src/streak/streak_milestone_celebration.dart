import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/quiz_localizations.dart';
import '../theme/quiz_animations.dart';

/// Configuration for milestone celebration.
class StreakMilestoneConfig {
  /// Creates a [StreakMilestoneConfig].
  const StreakMilestoneConfig({
    required this.days,
    required this.title,
    this.icon = '🔥',
    this.color = Colors.orange,
    this.secondaryColor = Colors.amber,
  });

  /// Number of days for this milestone.
  final int days;

  /// Title for the milestone.
  final String title;

  /// Emoji or icon for the milestone.
  final String icon;

  /// Primary color for the celebration.
  final Color color;

  /// Secondary color for gradient effects.
  final Color secondaryColor;

  /// Gets the standard milestones with localized titles.
  static List<StreakMilestoneConfig> getStandardMilestones(
    QuizEngineLocalizations l10n,
  ) {
    return [
      StreakMilestoneConfig(
        days: 7,
        title: l10n.streakMilestone7,
        icon: '🔥',
        color: Colors.orange,
        secondaryColor: Colors.amber,
      ),
      StreakMilestoneConfig(
        days: 14,
        title: l10n.streakMilestone14,
        icon: '⚡',
        color: Colors.deepOrange,
        secondaryColor: Colors.orange,
      ),
      StreakMilestoneConfig(
        days: 30,
        title: l10n.streakMilestone30,
        icon: '💪',
        color: Colors.red,
        secondaryColor: Colors.deepOrange,
      ),
      StreakMilestoneConfig(
        days: 50,
        title: l10n.streakMilestone50,
        icon: '🌟',
        color: Colors.purple,
        secondaryColor: Colors.deepPurple,
      ),
      StreakMilestoneConfig(
        days: 100,
        title: l10n.streakMilestone100,
        icon: '👑',
        color: Colors.amber,
        secondaryColor: Colors.yellow,
      ),
      StreakMilestoneConfig(
        days: 365,
        title: l10n.streakMilestone365,
        icon: '🏆',
        color: Colors.blue,
        secondaryColor: Colors.lightBlue,
      ),
    ];
  }

  /// Gets the configuration for a specific milestone day count.
  static StreakMilestoneConfig? forDays(
    int days,
    QuizEngineLocalizations l10n,
  ) {
    final milestones = getStandardMilestones(l10n);
    try {
      return milestones.firstWhere((m) => m.days == days);
    } catch (_) {
      return null;
    }
  }
}

/// A full-screen overlay celebrating a streak milestone.
///
/// Shows animated flames, confetti, and the milestone achievement
/// with a dramatic entrance animation.
///
/// Example:
/// ```dart
/// StreakMilestoneCelebration.show(
///   context: context,
///   milestone: 7,
///   onDismiss: () => print('Dismissed'),
/// );
/// ```
class StreakMilestoneCelebration extends StatefulWidget {
  /// Creates a [StreakMilestoneCelebration].
  const StreakMilestoneCelebration({
    super.key,
    required this.milestone,
    required this.config,
    this.onDismiss,
    this.autoDismiss = true,
    this.autoDismissDuration = const Duration(seconds: 4),
  });

  /// The milestone day count (e.g., 7, 30, 100).
  final int milestone;

  /// Configuration for this milestone.
  final StreakMilestoneConfig config;

  /// Callback when celebration is dismissed.
  final VoidCallback? onDismiss;

  /// Whether to automatically dismiss after [autoDismissDuration].
  final bool autoDismiss;

  /// Duration before auto-dismiss.
  final Duration autoDismissDuration;

  /// Shows the celebration as an overlay.
  static Future<void> show({
    required BuildContext context,
    required int milestone,
    VoidCallback? onDismiss,
    bool autoDismiss = true,
    Duration autoDismissDuration = const Duration(seconds: 4),
  }) async {
    final l10n = QuizL10n.of(context);
    final config = StreakMilestoneConfig.forDays(milestone, l10n);

    if (config == null) {
      // Unknown milestone, create a default config
      return;
    }

    await showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: l10n.accessibilityStreakMilestone(milestone, config.title),
      barrierColor: Colors.black54,
      transitionDuration: QuizAnimations.durationMedium,
      pageBuilder: (context, animation, secondaryAnimation) {
        return StreakMilestoneCelebration(
          milestone: milestone,
          config: config,
          onDismiss: () {
            Navigator.of(context).pop();
            onDismiss?.call();
          },
          autoDismiss: autoDismiss,
          autoDismissDuration: autoDismissDuration,
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: CurvedAnimation(
              parent: animation,
              curve: QuizAnimations.curveOvershoot,
            ),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<StreakMilestoneCelebration> createState() =>
      _StreakMilestoneCelebrationState();
}

class _StreakMilestoneCelebrationState extends State<StreakMilestoneCelebration>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  late AnimationController _particleController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();

    // Start animations
    _mainController.forward();
    _pulseController.repeat(reverse: true);
    _particleController.repeat();

    // Auto-dismiss if enabled
    if (widget.autoDismiss) {
      Future.delayed(widget.autoDismissDuration, () {
        if (mounted) {
          widget.onDismiss?.call();
        }
      });
    }
  }

  void _setupAnimations() {
    _mainController = AnimationController(
      duration: QuizAnimations.durationLong,
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: QuizAnimations.resourcePulseDuration,
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: QuizAnimations.curveBounce,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: QuizAnimations.curveStandard,
      ),
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    return GestureDetector(
      onTap: widget.onDismiss,
      child: Material(
        color: Colors.transparent,
        child: AnimatedBuilder(
          animation: _mainController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            );
          },
          child: Stack(
            children: [
              // Particle effects
              ..._buildParticles(),

              // Main content
              Center(
                child: AnimatedBuilder(
                  animation: Listenable.merge([_mainController, _pulseController]),
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value * _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: _buildContent(theme, l10n),
                ),
              ),

              // Dismiss hint
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    l10n.accessibilityDoubleTapToDismiss,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, QuizEngineLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.config.color,
            widget.config.secondaryColor,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: widget.config.color.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Milestone icon
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                widget.config.icon,
                style: const TextStyle(fontSize: 56),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Days count
          Text(
            l10n.streakMilestoneReached(widget.milestone),
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Title
          Text(
            widget.config.title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Message
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              l10n.streakMilestoneMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildParticles() {
    final particles = <Widget>[];
    final random = math.Random(42); // Fixed seed for consistent positions

    for (var i = 0; i < 20; i++) {
      final startX = random.nextDouble();
      final startY = random.nextDouble();
      final delay = random.nextDouble();
      final size = 8.0 + random.nextDouble() * 16;
      final isFlame = random.nextBool();

      particles.add(
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final progress = (_particleController.value + delay) % 1.0;
            final y = startY - progress * 0.5;
            final opacity = (1.0 - progress) * 0.8;

            if (y < -0.1) return const SizedBox.shrink();

            return Positioned(
              left: startX * MediaQuery.of(context).size.width,
              top: y * MediaQuery.of(context).size.height,
              child: Opacity(
                opacity: opacity.clamp(0.0, 1.0),
                child: isFlame
                    ? Icon(
                        Icons.local_fire_department,
                        size: size,
                        color: widget.config.color.withValues(alpha: 0.7),
                      )
                    : Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          color: widget.config.secondaryColor.withValues(alpha: 0.6),
                          shape: BoxShape.circle,
                        ),
                      ),
              ),
            );
          },
        ),
      );
    }

    return particles;
  }
}

/// A notification-style streak milestone banner.
///
/// Slides in from the top and auto-dismisses.
class StreakMilestoneBanner extends StatefulWidget {
  /// Creates a [StreakMilestoneBanner].
  const StreakMilestoneBanner({
    super.key,
    required this.milestone,
    required this.config,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  });

  /// The milestone day count.
  final int milestone;

  /// Configuration for this milestone.
  final StreakMilestoneConfig config;

  /// Callback when banner is dismissed.
  final VoidCallback? onDismiss;

  /// Duration to show the banner.
  final Duration duration;

  @override
  State<StreakMilestoneBanner> createState() => _StreakMilestoneBannerState();
}

class _StreakMilestoneBannerState extends State<StreakMilestoneBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuizAnimations.durationMedium,
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: QuizAnimations.curveBounce,
    ));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5),
      ),
    );

    _controller.forward();

    // Auto-dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = QuizL10n.of(context);

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.config.color, widget.config.secondaryColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      widget.config.icon,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.streakMilestoneReached(widget.milestone),
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.config.title,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}