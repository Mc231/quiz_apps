import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/game_resource_theme.dart';
import '../theme/quiz_animations.dart';

/// A button displaying a game resource (Lives, 50/50, Skip) with icon and count badge.
///
/// Features:
/// - Single icon with count badge in top-right corner
/// - Tap and long-press interactions
/// - Animations: scale on tap, pulse on last resource, shake on depletion
/// - Responsive sizing based on screen type
/// - Accessibility support with semantic labels
///
/// Example:
/// ```dart
/// GameResourceButton(
///   icon: Icons.favorite,
///   count: 3,
///   resourceType: GameResourceType.lives,
///   onTap: () => print('Lives tapped'),
///   onLongPress: () => showTooltip(),
/// )
/// ```
class GameResourceButton extends StatefulWidget {
  /// The icon to display.
  final IconData icon;

  /// The current count (shown in badge).
  final int count;

  /// The type of resource (determines color from theme).
  final GameResourceType resourceType;

  /// Called when button is tapped (only when count > 0).
  final VoidCallback? onTap;

  /// Called when button is tapped while depleted (count == 0).
  ///
  /// Use this to show a restore dialog or purchase options.
  final VoidCallback? onDepletedTap;

  /// Called when button is long-pressed.
  final VoidCallback? onLongPress;

  /// Override color (uses theme color if null).
  final Color? activeColor;

  /// Override theme for this button.
  final GameResourceTheme? theme;

  /// Whether this resource is currently enabled.
  final bool enabled;

  /// Semantic label for accessibility.
  final String? semanticLabel;

  /// Tooltip text shown on long-press.
  final String? tooltip;

  const GameResourceButton({
    super.key,
    required this.icon,
    required this.count,
    required this.resourceType,
    this.onTap,
    this.onDepletedTap,
    this.onLongPress,
    this.activeColor,
    this.theme,
    this.enabled = true,
    this.semanticLabel,
    this.tooltip,
  });

  @override
  State<GameResourceButton> createState() => _GameResourceButtonState();
}

class _GameResourceButtonState extends State<GameResourceButton>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  late AnimationController _shakeController;
  late AnimationController _badgeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shakeAnimation;
  late Animation<double> _badgeAnimation;

  int _previousCount = 0;

  GameResourceTheme get _theme => widget.theme ?? GameResourceTheme.standard();

  @override
  void initState() {
    super.initState();
    _previousCount = widget.count;
    _initAnimations();
  }

  void _initAnimations() {
    // Scale animation for tap
    _scaleController = AnimationController(
      duration: _theme.tapScaleDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: _theme.pressedScale,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: QuizAnimations.resourceTapCurve,
    ));

    // Pulse animation for last resource warning
    _pulseController = AnimationController(
      duration: _theme.pulseDuration,
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: _theme.pulseScale,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: QuizAnimations.resourcePulseCurve,
    ));

    // Shake animation for depletion
    _shakeController = AnimationController(
      duration: _theme.shakeDuration,
      vsync: this,
    );
    _shakeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _shakeController,
      curve: QuizAnimations.resourceShakeCurve,
    ));

    // Badge count change animation
    _badgeController = AnimationController(
      duration: _theme.countChangeDuration,
      vsync: this,
    );
    _badgeAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: QuizAnimations.resourceBadgeCurve,
    ));

    // Start pulse if count is 1
    _updatePulseAnimation();
  }

  void _updatePulseAnimation() {
    if (widget.count == 1 && widget.enabled && _theme.enablePulseOnLastResource) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void didUpdateWidget(GameResourceButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if count changed
    if (widget.count != _previousCount) {
      // Animate badge
      _badgeController.forward().then((_) {
        _badgeController.reverse();
      });

      // Check for depletion (count went from 1 to 0)
      if (_previousCount > 0 &&
          widget.count == 0 &&
          _theme.enableShakeOnDepletion) {
        _shakeController.forward().then((_) {
          _shakeController.reset();
        });
        HapticFeedback.heavyImpact();
      }

      _previousCount = widget.count;
    }

    // Update pulse animation
    _updatePulseAnimation();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _pulseController.dispose();
    _shakeController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.enabled || widget.count == 0) return;
    _scaleController.forward();
    HapticFeedback.selectionClick();
  }

  void _handleTapUp(TapUpDetails details) {
    _scaleController.reverse();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  void _handleTap() {
    if (!widget.enabled) return;

    if (widget.count == 0) {
      // Trigger depleted callback for showing restore dialog
      widget.onDepletedTap?.call();
      HapticFeedback.lightImpact();
      return;
    }

    widget.onTap?.call();
    HapticFeedback.mediumImpact();
  }

  void _handleLongPress() {
    if (widget.tooltip != null) {
      _showTooltip();
    }
    widget.onLongPress?.call();
    HapticFeedback.mediumImpact();
  }

  void _showTooltip() {
    if (widget.tooltip == null) return;

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TooltipOverlay(
        message: widget.tooltip!,
        position: position,
        size: renderBox.size,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final screenType = context.screenType;
    final buttonSize = _theme.getButtonSize(screenType);
    final iconSize = _theme.getIconSize(screenType);
    final badgeSize = _theme.getBadgeSize(screenType);
    final badgeFontSize = _theme.getBadgeFontSize(screenType);

    final isActive = widget.enabled && widget.count > 0;
    final color = widget.activeColor ?? _theme.getResourceColor(widget.resourceType);
    final effectiveColor = isActive ? color : _theme.disabledColor;
    final badgeColor = widget.count == 1 && _theme.enablePulseOnLastResource
        ? _theme.warningColor
        : effectiveColor;

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      enabled: isActive,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _scaleAnimation,
          _pulseAnimation,
          _shakeAnimation,
        ]),
        builder: (context, child) {
          // Calculate shake offset
          final shakeOffset = _shakeAnimation.value * 4 *
              math.sin(_shakeAnimation.value * math.pi * 4);

          // Combine scale animations
          double scale = _scaleAnimation.value;
          if (widget.count == 1 && _theme.enablePulseOnLastResource) {
            scale *= _pulseAnimation.value;
          }

          return Transform.translate(
            offset: Offset(shakeOffset, 0),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          );
        },
        child: GestureDetector(
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          onTap: _handleTap,
          onLongPress: _handleLongPress,
          child: SizedBox(
            width: buttonSize,
            height: buttonSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Button background
                Positioned.fill(
                  child: Material(
                    color: _theme.buttonBackgroundColor,
                    borderRadius: _theme.borderRadius,
                    elevation: isActive ? _theme.elevation : _theme.disabledElevation,
                    child: Center(
                      child: Icon(
                        widget.icon,
                        size: iconSize,
                        color: effectiveColor,
                      ),
                    ),
                  ),
                ),
                // Count badge
                Positioned(
                  right: _theme.badgeOffset.dx,
                  top: _theme.badgeOffset.dy,
                  child: AnimatedBuilder(
                    animation: _badgeAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _badgeAnimation.value,
                        child: child,
                      );
                    },
                    child: _CountBadge(
                      count: widget.count,
                      size: badgeSize,
                      fontSize: badgeFontSize,
                      color: badgeColor,
                      textColor: _theme.badgeTextColor,
                      borderColor: _theme.badgeBorderColor,
                      borderWidth: _theme.badgeBorderWidth,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The count badge shown in the top-right corner.
class _CountBadge extends StatelessWidget {
  final int count;
  final double size;
  final double fontSize;
  final Color color;
  final Color textColor;
  final Color borderColor;
  final double borderWidth;

  const _CountBadge({
    required this.count,
    required this.size,
    required this.fontSize,
    required this.color,
    required this.textColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          count.toString(),
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

/// Tooltip overlay shown on long-press.
class _TooltipOverlay extends StatefulWidget {
  final String message;
  final Offset position;
  final Size size;
  final VoidCallback onDismiss;

  const _TooltipOverlay({
    required this.message,
    required this.position,
    required this.size,
    required this.onDismiss,
  });

  @override
  State<_TooltipOverlay> createState() => _TooltipOverlayState();
}

class _TooltipOverlayState extends State<_TooltipOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: QuizAnimations.tooltipDuration,
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: QuizAnimations.tooltipCurve),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: QuizAnimations.tooltipCurve),
    );
    _controller.forward();

    // Auto-dismiss after configured duration
    Future.delayed(QuizAnimations.tooltipDisplayDuration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    const tooltipWidth = 200.0;
    const tooltipPadding = 12.0;
    const arrowSize = 8.0;

    // Calculate position (above the button, centered)
    double left = widget.position.dx + widget.size.width / 2 - tooltipWidth / 2;
    left = left.clamp(tooltipPadding, screenSize.width - tooltipWidth - tooltipPadding);

    final top = widget.position.dy - tooltipPadding - arrowSize;

    return GestureDetector(
      onTap: _dismiss,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        children: [
          // Tooltip
          Positioned(
            left: left,
            bottom: screenSize.height - top,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _opacityAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Material(
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(8),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: tooltipWidth),
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
