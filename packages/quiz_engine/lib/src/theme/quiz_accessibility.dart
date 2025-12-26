import 'package:flutter/material.dart';

/// Centralized accessibility constants and helpers for the quiz engine.
///
/// This class provides:
/// - Minimum touch target sizes (WCAG compliance)
/// - Helper methods for building semantic widgets
/// - Constants for accessibility-related values
///
/// ## Touch Target Sizes
///
/// All interactive elements should meet the minimum touch target size of 48x48
/// logical pixels as recommended by WCAG 2.1 and Material Design guidelines.
///
/// ## Usage Examples
///
/// ```dart
/// // Ensure minimum touch target size
/// SizedBox(
///   width: QuizAccessibility.minTouchTarget,
///   height: QuizAccessibility.minTouchTarget,
///   child: IconButton(...),
/// )
///
/// // Wrap interactive element with button semantics
/// QuizAccessibility.semanticButton(
///   label: 'Play Europe quiz',
///   hint: 'Double tap to start',
///   child: CategoryCard(...),
/// )
/// ```
abstract final class QuizAccessibility {
  // ============================================================
  // TOUCH TARGET SIZES
  // ============================================================

  /// Minimum touch target size (48x48) per WCAG 2.1 and Material Design.
  static const double minTouchTarget = 48.0;

  /// Recommended touch target size for important actions.
  static const double recommendedTouchTarget = 56.0;

  /// Minimum touch target size for compact layouts.
  static const double compactTouchTarget = 40.0;

  // ============================================================
  // SEMANTIC HELPERS
  // ============================================================

  /// Wraps a child widget with button semantics.
  ///
  /// Use this for custom interactive elements that act as buttons
  /// but don't use Flutter's built-in button widgets.
  ///
  /// [label] is the accessible name read by screen readers.
  /// [hint] provides additional context about the action.
  /// [enabled] indicates if the button is currently actionable.
  /// [onTap] callback for the tap action (for semantic tap handling).
  static Widget semanticButton({
    required String label,
    String? hint,
    bool enabled = true,
    VoidCallback? onTap,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      hint: hint,
      button: true,
      enabled: enabled,
      onTap: onTap,
      child: child,
    );
  }

  /// Wraps a child widget with image semantics.
  ///
  /// Use this for meaningful images that convey information.
  /// For decorative images, use [decorativeImage] instead.
  static Widget semanticImage({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      image: true,
      child: child,
    );
  }

  /// Wraps a decorative element to exclude it from semantics.
  ///
  /// Use this for purely decorative elements that don't convey
  /// meaningful information (icons next to text, decorative images, etc.).
  static Widget decorative({required Widget child}) {
    return ExcludeSemantics(child: child);
  }

  /// Wraps an image that is purely decorative.
  static Widget decorativeImage({required Widget child}) {
    return ExcludeSemantics(
      child: Semantics(
        image: true,
        label: '',
        child: child,
      ),
    );
  }

  /// Wraps a child with header semantics.
  ///
  /// Use this for section headers and titles.
  static Widget semanticHeader({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      header: true,
      child: child,
    );
  }

  /// Wraps a child with live region semantics.
  ///
  /// Use this for content that updates dynamically and should be
  /// announced by screen readers (e.g., score updates, timer).
  static Widget liveRegion({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      liveRegion: true,
      child: child,
    );
  }

  /// Creates a semantic group for related elements.
  ///
  /// Use this to group related information that should be read together.
  static Widget semanticGroup({
    required String label,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      container: true,
      child: child,
    );
  }

  /// Wraps a slider/progress indicator with value semantics.
  static Widget semanticSlider({
    required String label,
    required double value,
    double increasedValue = 0,
    double decreasedValue = 0,
    VoidCallback? onIncrease,
    VoidCallback? onDecrease,
    required Widget child,
  }) {
    return Semantics(
      label: label,
      value: '${(value * 100).round()}%',
      slider: true,
      increasedValue: '${(increasedValue * 100).round()}%',
      decreasedValue: '${(decreasedValue * 100).round()}%',
      onIncrease: onIncrease,
      onDecrease: onDecrease,
      child: child,
    );
  }

  // ============================================================
  // MINIMUM SIZE WRAPPER
  // ============================================================

  /// Ensures a widget meets the minimum touch target size.
  ///
  /// Wraps the child in a SizedBox with minimum dimensions.
  /// The child is centered within the touch target area.
  static Widget ensureMinTouchTarget({
    required Widget child,
    double minSize = minTouchTarget,
  }) {
    return SizedBox(
      width: minSize,
      height: minSize,
      child: Center(child: child),
    );
  }

  /// Ensures a widget meets the minimum touch target size horizontally.
  static Widget ensureMinTouchTargetWidth({
    required Widget child,
    double minWidth = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: minWidth),
      child: child,
    );
  }

  /// Ensures a widget meets the minimum touch target size vertically.
  static Widget ensureMinTouchTargetHeight({
    required Widget child,
    double minHeight = minTouchTarget,
  }) {
    return ConstrainedBox(
      constraints: BoxConstraints(minHeight: minHeight),
      child: child,
    );
  }

  // ============================================================
  // FOCUS HELPERS
  // ============================================================

  /// Creates a focus node with standard traversal behavior.
  static FocusNode createFocusNode({
    String? debugLabel,
    bool skipTraversal = false,
    bool canRequestFocus = true,
  }) {
    return FocusNode(
      debugLabel: debugLabel,
      skipTraversal: skipTraversal,
      canRequestFocus: canRequestFocus,
    );
  }

  // ============================================================
  // TEXT SCALING
  // ============================================================

  /// Maximum text scale factor to prevent layout overflow.
  ///
  /// Apps should support at least 200% text scaling for accessibility.
  static const double maxTextScaleFactor = 2.0;

  /// Clamps text scale factor to prevent layout issues.
  static double clampTextScale(double scale) {
    return scale.clamp(1.0, maxTextScaleFactor);
  }
}
