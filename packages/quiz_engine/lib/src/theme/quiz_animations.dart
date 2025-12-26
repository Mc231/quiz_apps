import 'package:flutter/material.dart';

/// Centralized animation constants for consistent animations throughout the app.
///
/// Use these constants instead of hardcoding durations and curves to ensure
/// a cohesive and polished user experience.
///
/// ## Duration Tiers
///
/// - **Instant (50ms):** Imperceptible, for immediate feedback
/// - **Fast (100ms):** Micro-interactions, tap feedback, small UI changes
/// - **Quick (200ms):** Standard transitions, tooltips, small movements
/// - **Medium (300ms):** Slide in/out, fade effects, page transitions
/// - **Slow (500ms):** Emphasis animations, important feedback (correct/incorrect)
/// - **Long (800ms):** Celebration effects, attention-grabbing animations
/// - **Extended (1500ms):** Counting animations, continuous glow effects
///
/// ## Curve Categories
///
/// - **Standard:** `easeInOut` for most transitions
/// - **Enter:** `easeOut` for elements appearing
/// - **Exit:** `easeIn` for elements disappearing
/// - **Bounce:** `elasticOut` for playful, bouncy effects
/// - **Decelerate:** `easeOutCubic` for counting/progress animations
///
/// Example usage:
/// ```dart
/// AnimationController(
///   duration: QuizAnimations.durationMedium,
///   vsync: this,
/// );
///
/// CurvedAnimation(
///   parent: controller,
///   curve: QuizAnimations.curveEnter,
/// );
/// ```
abstract final class QuizAnimations {
  // ============================================================
  // DURATION CONSTANTS
  // ============================================================

  /// Instant feedback (50ms) - Imperceptible, for immediate response
  static const Duration durationInstant = Duration(milliseconds: 50);

  /// Fast animations (100ms) - Micro-interactions, tap feedback
  static const Duration durationFast = Duration(milliseconds: 100);

  /// Quick animations (200ms) - Tooltips, small movements
  static const Duration durationQuick = Duration(milliseconds: 200);

  /// Medium animations (300ms) - Standard transitions, page changes
  static const Duration durationMedium = Duration(milliseconds: 300);

  /// Slow animations (500ms) - Emphasis, important feedback
  static const Duration durationSlow = Duration(milliseconds: 500);

  /// Long animations (800ms) - Celebration, attention-grabbing
  static const Duration durationLong = Duration(milliseconds: 800);

  /// Extended animations (1500ms) - Counting, continuous effects
  static const Duration durationExtended = Duration(milliseconds: 1500);

  // ============================================================
  // CURVE CONSTANTS
  // ============================================================

  /// Standard curve for most transitions
  static const Curve curveStandard = Curves.easeInOut;

  /// Enter curve for elements appearing (decelerates into place)
  static const Curve curveEnter = Curves.easeOut;

  /// Exit curve for elements disappearing (accelerates out)
  static const Curve curveExit = Curves.easeIn;

  /// Bounce curve for playful, bouncy effects
  static const Curve curveBounce = Curves.elasticOut;

  /// Decelerate curve for counting and progress animations
  static const Curve curveDecelerate = Curves.easeOutCubic;

  /// Overshoot curve for subtle bounce without elasticity
  static const Curve curveOvershoot = Curves.easeOutBack;

  // ============================================================
  // SPECIFIC ANIMATION PRESETS
  // ============================================================

  // --- Answer Feedback ---

  /// Duration for answer feedback animation (correct/incorrect)
  static const Duration answerFeedbackDuration = durationSlow;

  /// Curve for answer feedback scale animation
  static const Curve answerFeedbackScaleCurve = curveBounce;

  /// Curve for answer feedback opacity animation
  static const Curve answerFeedbackOpacityCurve = curveEnter;

  // --- Achievement Notification ---

  /// Duration for achievement notification slide in/out
  static const Duration achievementSlideDuration = durationSlow;

  /// Duration for achievement icon bounce animation
  static const Duration achievementBounceDuration = Duration(milliseconds: 600);

  /// Duration for achievement glow pulse animation
  static const Duration achievementGlowDuration = durationExtended;

  /// Curve for achievement slide animation
  static const Curve achievementSlideCurve = curveBounce;

  /// Curve for achievement icon scale animation
  static const Curve achievementScaleCurve = curveEnter;

  /// Curve for achievement glow animation
  static const Curve achievementGlowCurve = curveStandard;

  /// Display duration for achievement notification
  static const Duration achievementDisplayDuration = Duration(seconds: 3);

  // --- Game Resource Button ---

  /// Duration for tap scale animation
  static const Duration resourceTapDuration = durationFast;

  /// Duration for pulse animation (last resource warning)
  static const Duration resourcePulseDuration = durationLong;

  /// Duration for shake animation (on depletion)
  static const Duration resourceShakeDuration = Duration(milliseconds: 400);

  /// Duration for badge count change animation
  static const Duration resourceBadgeChangeDuration = durationMedium;

  /// Curve for resource tap animation
  static const Curve resourceTapCurve = curveEnter;

  /// Curve for resource pulse animation
  static const Curve resourcePulseCurve = curveStandard;

  /// Curve for resource shake animation
  static const Curve resourceShakeCurve = curveBounce;

  /// Curve for resource badge animation
  static const Curve resourceBadgeCurve = curveBounce;

  // --- Score Display ---

  /// Duration for score counting animation
  static const Duration scoreCountDuration = durationExtended;

  /// Curve for score counting animation
  static const Curve scoreCountCurve = curveDecelerate;

  // --- Tooltip ---

  /// Duration for tooltip fade in/out
  static const Duration tooltipDuration = durationQuick;

  /// Curve for tooltip animation
  static const Curve tooltipCurve = curveEnter;

  /// Auto-dismiss duration for tooltips
  static const Duration tooltipDisplayDuration = Duration(seconds: 3);

  // --- Page Transitions ---

  /// Duration for page transitions
  static const Duration pageTransitionDuration = durationMedium;

  /// Curve for page transition enter
  static const Curve pageTransitionEnterCurve = curveEnter;

  /// Curve for page transition exit
  static const Curve pageTransitionExitCurve = curveExit;

  // --- Modal/Dialog ---

  /// Duration for modal/dialog animations
  static const Duration modalDuration = durationMedium;

  /// Curve for modal scale animation
  static const Curve modalScaleCurve = curveOvershoot;

  /// Curve for modal fade animation
  static const Curve modalFadeCurve = curveEnter;

  // --- Loading States ---

  /// Duration for loading indicator rotation
  static const Duration loadingRotationDuration = Duration(milliseconds: 1200);

  /// Duration for shimmer effect
  static const Duration shimmerDuration = durationExtended;

  // ============================================================
  // SCALE VALUES
  // ============================================================

  /// Scale when button is pressed
  static const double pressedScale = 0.95;

  /// Scale for pulse animation (max)
  static const double pulseScale = 1.1;

  /// Scale for bounce animation overshoot
  static const double bounceOvershoot = 1.2;

  /// Scale for subtle emphasis
  static const double subtleEmphasis = 1.05;

  // ============================================================
  // HELPER METHODS
  // ============================================================

  /// Creates a standard enter animation curve
  static CurvedAnimation createEnterCurve(Animation<double> parent) {
    return CurvedAnimation(parent: parent, curve: curveEnter);
  }

  /// Creates a standard exit animation curve
  static CurvedAnimation createExitCurve(Animation<double> parent) {
    return CurvedAnimation(parent: parent, curve: curveExit);
  }

  /// Creates a bounce animation curve
  static CurvedAnimation createBounceCurve(Animation<double> parent) {
    return CurvedAnimation(parent: parent, curve: curveBounce);
  }

  /// Creates a standard scale tween (1.0 -> pressedScale)
  static Tween<double> get pressedScaleTween =>
      Tween<double>(begin: 1.0, end: pressedScale);

  /// Creates a pulse scale tween (1.0 -> pulseScale)
  static Tween<double> get pulseScaleTween =>
      Tween<double>(begin: 1.0, end: pulseScale);

  /// Creates a fade in tween (0.0 -> 1.0)
  static Tween<double> get fadeInTween =>
      Tween<double>(begin: 0.0, end: 1.0);

  /// Creates a fade out tween (1.0 -> 0.0)
  static Tween<double> get fadeOutTween =>
      Tween<double>(begin: 1.0, end: 0.0);

  /// Creates a slide from top tween
  static Tween<Offset> get slideFromTopTween =>
      Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero);

  /// Creates a slide from bottom tween
  static Tween<Offset> get slideFromBottomTween =>
      Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero);
}
